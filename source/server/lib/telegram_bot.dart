// ignore_for_file: avoid_print

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:lampa_server/data_source.dart';
import 'package:lampa_server/database/database.dart';
import 'package:televerse/televerse.dart';

/// Логирование с flush для Docker
void _log(String message) {
  print('[TelegramBot] $message');
  stdout.flush();
}

/// Сервис Telegram бота для управления устройствами
class TelegramBotService {
  TelegramBotService._();

  /// Singleton instance
  static final TelegramBotService instance = TelegramBotService._();

  Bot<Context>? _bot;

  /// Запустить бота
  Future<void> start() async {
    final token = Platform.environment['TELEGRAM_BOT_TOKEN'];
    if (token == null || token.isEmpty) {
      print('⚠️  TELEGRAM_BOT_TOKEN not set, bot disabled');
      return;
    }

    try {
      _log('Initializing bot...');
      _bot = Bot<Context>(token);

      _setupHandlers();
      _log('Handlers registered');

      // Запускаем бота асинхронно (не ждём завершения)
      await _bot!.start();

      _log('Bot started successfully');
    } catch (e, stack) {
      _log('Failed to start bot: $e');
      _log('Stack: $stack');
    }
  }

  /// Остановить бота
  Future<void> stop() async {
    await _bot?.stop();
  }

  /// Настроить обработчики команд
  void _setupHandlers() {
    _bot!

      // Обработка ошибок
      ..onError((error) async {
        _log('ERROR: ${error.error}');
        _log('Stack: ${error.stackTrace}');
      })

      // /start - приветствие с кнопками
      ..command('start', _handleStart)

      // /add - добавить устройство
      ..command('add', _handleAdd)

      // /devices - список устройств
      ..command('devices', _handleDevices)

      // /cancel - отмена
      ..command('cancel', _handleCancel)

      // /profile - профиль пользователя
      ..command('profile', _handleProfile)

      // /profiles - список профилей
      ..command('profiles', _handleProfiles)

      // /admin - админ панель
      ..command('admin', _handleAdmin)

      // Callback query для inline кнопок
      ..onCallbackQuery(_handleCallbackQuery)

      // Обработка контакта (регистрация)
      ..onContact(_handleContact)

      // Обработка текстовых сообщений (для переименования)
      ..onText(_handleText);
  }

  /// Клавиатура запроса контакта для регистрации
  Keyboard _contactRequestKeyboard() {
    return Keyboard()
        .requestContact('📱 Поделиться контактом')
        .resized()
        .oneTime();
  }

  /// Главное меню с кнопками
  InlineKeyboard _mainMenuKeyboard() {
    return InlineKeyboard()
        .add('➕ Добавить устройство', 'add_device')
        .row()
        .add('📱 Мои устройства', 'list_devices')
        .row()
        .add('👥 Профили', 'list_profiles')
        .row()
        .add('👤 Мой аккаунт', 'my_profile');
  }

  /// Главное меню с кнопками (с проверкой админа)
  Future<InlineKeyboard> _mainMenuKeyboardAsync(String telegramUserId) async {
    var keyboard = InlineKeyboard()
        .add('➕ Добавить устройство', 'add_device')
        .row()
        .add('📱 Мои устройства', 'list_devices')
        .row()
        .add('👥 Профили', 'list_profiles')
        .row()
        .add('👤 Мой аккаунт', 'my_profile');

    if (await DataSource.instance.isAdmin(telegramUserId)) {
      keyboard = keyboard.row().add('🔧 Админ-панель', 'admin_menu');
    }

    return keyboard;
  }

  /// /start - приветствие или запрос регистрации
  Future<void> _handleStart(Context ctx) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    _log('/start from user: $telegramUserId');

    try {
      // Проверяем, зарегистрирован ли пользователь
      if (await DataSource.instance.isUserRegistered(telegramUserId)) {
        _log('User is registered, showing main menu');
        // Проверяем, заблокирован ли пользователь
        final user =
            await DataSource.instance.findUserByTelegramId(telegramUserId);
        if (user?.blocked ?? false) {
          await ctx.reply(
            '🚫 *Ваш аккаунт заблокирован*\n\n'
            'Обратитесь к администратору для разблокировки.',
            parseMode: ParseMode.markdown,
          );
          return;
        }

        // Пользователь уже зарегистрирован - показываем главное меню
        final greeting = user?.firstName != null
            ? 'Привет, *${user!.firstName}*!'
            : 'С возвращением!';

        final keyboard = await _mainMenuKeyboardAsync(telegramUserId);
        await ctx.reply(
          '👋 $greeting\n\n'
          'Выберите действие:',
          parseMode: ParseMode.markdown,
          replyMarkup: keyboard,
        );
      } else {
        // Проверяем, есть ли ожидающая заявка на регистрацию
        final pending = await DataSource.instance
            .getPendingRegistrationByTelegramId(telegramUserId);
        if (pending != null) {
          await ctx.reply(
            '⏳ *Ожидание одобрения*\n\n'
            'Ваша заявка на регистрацию ожидает одобрения администратора.\n'
            'Вы получите уведомление после рассмотрения.',
            parseMode: ParseMode.markdown,
          );
          return;
        }

        _log('User not registered, requesting contact');
        // Новый пользователь - запрашиваем контакт
        await ctx.reply(
          '👋 *Добро пожаловать в Lampa Self-Hosted!*\n\n'
          'Для регистрации нажмите кнопку ниже и поделитесь своим контактом.\n\n'
          '🔒 Ваш номер телефона будет использоваться только для идентификации.',
          parseMode: ParseMode.markdown,
          replyMarkup: _contactRequestKeyboard(),
        );
      }
    } catch (e, stack) {
      _log('Error in /start: $e');
      _log('Stack: $stack');
    }
  }

  /// Обработка полученного контакта (регистрация)
  Future<void> _handleContact(Context ctx) async {
    final contact = ctx.message?.contact;
    if (contact == null) return;

    final telegramUserId = ctx.from?.id.toString() ?? '';
    _log('Contact received from $telegramUserId');

    // Проверяем, что это контакт самого пользователя
    if (contact.userId.toString() != telegramUserId) {
      await ctx.reply(
        '❌ Пожалуйста, поделитесь *своим* контактом, '
        'а не контактом другого человека.',
        parseMode: ParseMode.markdown,
        replyMarkup: _contactRequestKeyboard(),
      );
      return;
    }

    // Проверяем, что есть номер телефона
    final phone = contact.phoneNumber;
    if (phone.isEmpty) {
      await ctx.reply(
        '❌ Не удалось получить номер телефона. Попробуйте ещё раз.',
        replyMarkup: _contactRequestKeyboard(),
      );
      return;
    }

    // Проверяем режим регистрации
    final registrationMode = await DataSource.instance.getRegistrationMode();
    _log('Registration mode: $registrationMode');

    if (registrationMode == 'approval') {
      // Режим одобрения админом
      await DataSource.instance.createPendingRegistration(
        telegramId: telegramUserId,
        phone: phone,
        firstName: contact.firstName,
        lastName: contact.lastName,
      );

      await ctx.reply(
        '⏳ *Заявка отправлена!*\n\n'
        'Ваша заявка на регистрацию отправлена администратору.\n'
        'Вы получите уведомление после одобрения.',
        parseMode: ParseMode.markdown,
        replyMarkup: Keyboard.remove(),
      );

      // Уведомляем админов о новой заявке
      await _notifyAdminsNewPendingRegistration(
        firstName: contact.firstName,
        lastName: contact.lastName,
        phone: phone,
      );
      return;
    }

    if (registrationMode == 'allowed_phones') {
      // Режим разрешённых номеров
      final isAllowed = await DataSource.instance.isPhoneAllowed(phone);
      if (!isAllowed) {
        await ctx.reply(
          '❌ *Регистрация недоступна*\n\n'
          'Ваш номер телефона не в списке разрешённых.\n'
          'Обратитесь к администратору.',
          parseMode: ParseMode.markdown,
          replyMarkup: Keyboard.remove(),
        );
        return;
      }
    }

    if (registrationMode == 'invite_code') {
      // Режим инвайт-кода - запрашиваем код
      DataSource.instance.setPendingNoticeCreation(telegramUserId, {
        'step': 'invite_code',
        'phone': phone,
        'firstName': contact.firstName,
        'lastName': contact.lastName,
      });

      await ctx.reply(
        '🔐 *Требуется инвайт-код*\n\n'
        'Для регистрации введите инвайт-код:',
        parseMode: ParseMode.markdown,
        replyMarkup: Keyboard.remove(),
      );
      return;
    }

    // Свободная регистрация (free) или прошли проверку allowed_phones
    await _completeRegistration(
      ctx,
      telegramUserId: telegramUserId,
      phone: phone,
      firstName: contact.firstName,
      lastName: contact.lastName,
    );
  }

  /// Завершить регистрацию пользователя
  Future<void> _completeRegistration(
    Context ctx, {
    required String telegramUserId,
    required String phone,
    String? firstName,
    String? lastName,
  }) async {
    // Регистрируем пользователя
    final user = await DataSource.instance.createUserFromContact(
      telegramId: telegramUserId,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
    );

    final greeting = user.firstName ?? 'друг';

    // Убираем клавиатуру запроса контакта и показываем меню
    await ctx.reply(
      '✅ *Регистрация успешна!*\n\n'
      '👋 Добро пожаловать, *$greeting*!\n\n'
      '📧 Ваш аккаунт: `${user.email}`\n'
      '📱 Телефон: `${user.phone}`\n\n'
      'Теперь вы можете добавить устройства и синхронизировать данные.',
      parseMode: ParseMode.markdown,
      replyMarkup: Keyboard.remove(),
    );

    // Отправляем главное меню
    await ctx.reply(
      '📋 *Главное меню*\n\nВыберите действие:',
      parseMode: ParseMode.markdown,
      replyMarkup: _mainMenuKeyboard(),
    );

    // Уведомляем админов о новой регистрации
    await _notifyAdminsNewRegistration(user);
  }

  /// Уведомить админов о новой регистрации
  Future<void> _notifyAdminsNewRegistration(User user) async {
    try {
      final adminIds = await DataSource.instance.getAdminTelegramIds();
      if (adminIds.isEmpty) return;

      final name = [user.firstName, user.lastName]
          .where((s) => s != null && s.isNotEmpty)
          .join(' ');

      final text = '👤 *Новый пользователь зарегистрирован*\n\n'
          '${name.isNotEmpty ? '👋 Имя: *${_escapeMarkdown(name)}*\n' : ''}'
          '📱 Телефон: `${user.phone ?? "не указан"}`\n'
          '📅 Дата: ${_formatDate(user.createdAt)}';

      for (final adminId in adminIds) {
        try {
          await _bot?.api.sendMessage(
            ChatID(int.parse(adminId)),
            text,
            parseMode: ParseMode.markdown,
          );
        } catch (e) {
          _log('Failed to notify admin $adminId: $e');
        }
      }
    } catch (e) {
      _log('Error notifying admins: $e');
    }
  }

  /// Уведомить админов о новой заявке на регистрацию
  Future<void> _notifyAdminsNewPendingRegistration({
    String? firstName,
    String? lastName,
    required String phone,
  }) async {
    try {
      final adminIds = await DataSource.instance.getAdminTelegramIds();
      if (adminIds.isEmpty) return;

      final name = [firstName, lastName]
          .where((s) => s != null && s.isNotEmpty)
          .join(' ');

      final keyboard = InlineKeyboard()
          .add('📋 Посмотреть заявки', 'admin_pending_registrations');

      final text = '📝 *Новая заявка на регистрацию*\n\n'
          '${name.isNotEmpty ? '👋 Имя: *${_escapeMarkdown(name)}*\n' : ''}'
          '📱 Телефон: `$phone`';

      for (final adminId in adminIds) {
        try {
          await _bot?.api.sendMessage(
            ChatID(int.parse(adminId)),
            text,
            parseMode: ParseMode.markdown,
            replyMarkup: keyboard,
          );
        } catch (e) {
          _log('Failed to notify admin $adminId: $e');
        }
      }
    } catch (e) {
      _log('Error notifying admins: $e');
    }
  }

  /// /profile - профиль пользователя
  Future<void> _handleProfile(Context ctx) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';

    if (!(await DataSource.instance.isUserRegistered(telegramUserId))) {
      await ctx.reply(
        '❌ Сначала нужно зарегистрироваться.\n\n'
        'Нажмите кнопку ниже и поделитесь контактом:',
        replyMarkup: _contactRequestKeyboard(),
      );
      return;
    }

    await _showProfile(ctx);
  }

  /// /profiles - список профилей
  Future<void> _handleProfiles(Context ctx) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';

    if (!(await DataSource.instance.isUserRegistered(telegramUserId))) {
      await ctx.reply(
        '❌ Сначала нужно зарегистрироваться.\n\n'
        'Нажмите кнопку ниже и поделитесь контактом:',
        replyMarkup: _contactRequestKeyboard(),
      );
      return;
    }

    await _showProfilesList(ctx);
  }

  /// /admin - админ панель
  Future<void> _handleAdmin(Context ctx) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';

    if (!(await DataSource.instance.isUserRegistered(telegramUserId))) {
      await ctx.reply(
        '❌ Сначала нужно зарегистрироваться.',
        replyMarkup: _contactRequestKeyboard(),
      );
      return;
    }

    if (!(await DataSource.instance.isAdmin(telegramUserId))) {
      await ctx.reply(
        '❌ У вас нет прав администратора.',
        replyMarkup: _mainMenuKeyboard(),
      );
      return;
    }

    await _showAdminMenu(ctx);
  }

  /// Показать админ меню
  Future<void> _showAdminMenu(
    Context ctx, {
    int? messageId,
    bool edit = false,
  }) async {
    final keyboard = InlineKeyboard()
        .add('👥 Пользователи', 'admin_users')
        .row()
        .add('🔐 Регистрация', 'admin_registration')
        .row()
        .add('📢 Уведомления', 'admin_notices')
        .row()
        .add('« Главное меню', 'main_menu');

    const text = '🔧 *Панель администратора*\n\nВыберите раздел:';

    if (edit && messageId != null) {
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    } else {
      await ctx.reply(
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    }
  }

  /// Показать профиль пользователя
  Future<void> _showProfile(
    Context ctx, {
    int? messageId,
    bool edit = false,
  }) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    if (user == null) return;

    final devices = await DataSource.instance.getUserDevices(user.id);
    final profiles = await DataSource.instance.getProfilesForUser(user.id);

    final name = [user.firstName, user.lastName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');

    final keyboard = InlineKeyboard().add('« Главное меню', 'main_menu');

    final text = '👤 *Ваш профиль*\n\n'
        '${name.isNotEmpty ? '👋 Имя: *$name*\n' : ''}'
        '📧 Email: `${user.email}`\n'
        '📱 Телефон: `${user.phone ?? "не указан"}`\n'
        '📅 Зарегистрирован: ${_formatDate(user.createdAt)}\n\n'
        '📊 *Статистика:*\n'
        '• Устройств: ${devices.length}\n'
        '• Профилей: ${profiles.length}';

    if (edit && messageId != null) {
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    } else {
      await ctx.reply(
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    }
  }

  /// /add - добавить устройство
  Future<void> _handleAdd(Context ctx) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';

    if (!(await DataSource.instance.isUserRegistered(telegramUserId))) {
      await ctx.reply(
        '❌ Сначала нужно зарегистрироваться.\n\n'
        'Нажмите кнопку ниже и поделитесь контактом:',
        replyMarkup: _contactRequestKeyboard(),
      );
      return;
    }

    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    final code = DataSource.instance.generateTempCode(user!.id);

    final keyboard = InlineKeyboard()
        .add('🔄 Новый код', 'add_device')
        .row()
        .add('« Назад', 'main_menu');

    await ctx.reply(
      '🔐 *Код для добавления устройства:*\n\n'
      '`$code`\n\n'
      '📱 Введите этот код в приложении Lampa:\n'
      '*Настройки → Синхронизация → Привязать устройство*\n\n'
      '⏰ Код действителен *5 минут*',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// /devices - список устройств
  Future<void> _handleDevices(Context ctx) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';

    if (!(await DataSource.instance.isUserRegistered(telegramUserId))) {
      await ctx.reply(
        '❌ Сначала нужно зарегистрироваться.\n\n'
        'Нажмите кнопку ниже и поделитесь контактом:',
        replyMarkup: _contactRequestKeyboard(),
      );
      return;
    }

    await _showDevicesList(ctx);
  }

  /// /cancel - отмена
  Future<void> _handleCancel(Context ctx) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    DataSource.instance.clearAllPendingStates(telegramUserId);

    await ctx.reply(
      '✅ Операция отменена',
      replyMarkup: _mainMenuKeyboard(),
    );
  }

  /// Показать список устройств
  Future<void> _showDevicesList(
    Context ctx, {
    int? messageId,
    bool edit = false,
  }) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';

    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    if (user == null) {
      const text = '❌ Вы ещё не зарегистрированы. Используйте /start';
      if (edit && messageId != null) {
        await ctx.api.editMessageText(
          ChatID(ctx.chat!.id),
          messageId,
          text,
        );
      } else {
        await ctx.reply(text);
      }
      return;
    }

    final devices = await DataSource.instance.getUserDevices(user.id);
    if (devices.isEmpty) {
      final keyboard = InlineKeyboard()
          .add('➕ Добавить устройство', 'add_device')
          .row()
          .add('« Назад', 'main_menu');

      const text = '📱 У вас пока нет привязанных устройств.';

      if (edit && messageId != null) {
        await ctx.api.editMessageText(
          ChatID(ctx.chat!.id),
          messageId,
          text,
          replyMarkup: keyboard,
        );
      } else {
        await ctx.reply(text, replyMarkup: keyboard);
      }
      return;
    }

    // Создаём кнопки для каждого устройства
    var keyboard = InlineKeyboard();
    for (final device in devices) {
      final shortId = device.id.substring(0, 8);
      keyboard = keyboard
          .add(
            '📱 ${device.name} (${device.platform})',
            'device_$shortId',
          )
          .row();
    }
    keyboard = keyboard.add('« Назад', 'main_menu');

    const text = '📱 *Ваши устройства:*\n\nВыберите устройство для управления:';

    if (edit && messageId != null) {
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    } else {
      await ctx.reply(
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    }
  }

  /// Обработка callback query (inline кнопки)
  Future<void> _handleCallbackQuery(Context ctx) async {
    final query = ctx.callbackQuery;
    if (query == null) {
      _log('CallbackQuery is null');
      return;
    }

    final data = query.data ?? '';
    final messageId = query.message?.messageId;
    final telegramUserId = ctx.from?.id.toString() ?? '';

    _log('Callback: data="$data" from=$telegramUserId msgId=$messageId');

    try {
      // Отвечаем на callback чтобы убрать "часики"
      await ctx.api.answerCallbackQuery(query.id);
      _log('Answered callback query');

      // Проверяем регистрацию
      if (!(await DataSource.instance.isUserRegistered(telegramUserId))) {
        await ctx.api.sendMessage(
          ChatID(ctx.chat!.id),
          '❌ Сначала нужно зарегистрироваться. Используйте /start',
        );
        return;
      }

      // Проверяем блокировку пользователя
      final currentUser =
          await DataSource.instance.findUserByTelegramId(telegramUserId);
      if (currentUser?.blocked ?? false) {
        await ctx.api.sendMessage(
          ChatID(ctx.chat!.id),
          '🚫 *Ваш аккаунт заблокирован*\n\n'
          'Обратитесь к администратору для разблокировки.',
          parseMode: ParseMode.markdown,
        );
        return;
      }

      if (data == 'main_menu') {
        // Очищаем состояния
        DataSource.instance.clearAllPendingStates(telegramUserId);

        final keyboard = await _mainMenuKeyboardAsync(telegramUserId);
        await ctx.api.editMessageText(
          ChatID(ctx.chat!.id),
          messageId!,
          '👋 *Главное меню*\n\nВыберите действие:',
          parseMode: ParseMode.markdown,
          replyMarkup: keyboard,
        );
      } else if (data == 'add_device') {
        final user =
            await DataSource.instance.findUserByTelegramId(telegramUserId);
        final code = DataSource.instance.generateTempCode(user!.id);

        final keyboard = InlineKeyboard()
            .add('🔄 Новый код', 'add_device')
            .row()
            .add('« Назад', 'main_menu');

        await ctx.api.editMessageText(
          ChatID(ctx.chat!.id),
          messageId!,
          '🔐 *Код для добавления устройства:*\n\n'
          '`$code`\n\n'
          '📱 Введите этот код в приложении Lampa:\n'
          '*Настройки → Синхронизация → Привязать устройство*\n\n'
          '⏰ Код действителен *5 минут*',
          parseMode: ParseMode.markdown,
          replyMarkup: keyboard,
        );
      } else if (data == 'list_devices') {
        await _showDevicesList(ctx, messageId: messageId, edit: true);
      } else if (data == 'my_profile') {
        await _showProfile(ctx, messageId: messageId, edit: true);
      } else if (data.startsWith('device_')) {
        // Показываем информацию об устройстве
        final shortId = data.substring(7);
        await _showDeviceInfo(ctx, shortId, messageId!);
      } else if (data.startsWith('delete_device_')) {
        // Удаление устройства
        final shortId = data.substring(14);
        await _deleteDevice(ctx, shortId, messageId!);
      } else if (data.startsWith('rename_device_')) {
        // Переименование устройства
        final shortId = data.substring(14);
        await _startRename(ctx, shortId, messageId!);
      } else if (data.startsWith('confirm_delete_device_')) {
        // Подтверждение удаления устройства
        final shortId = data.substring(22);
        await _confirmDelete(ctx, shortId, messageId!);
      } else if (data == 'list_profiles') {
        // Список профилей
        await _showProfilesList(ctx, messageId: messageId, edit: true);
      } else if (data.startsWith('profile_')) {
        // Информация о профиле
        final profileId = int.tryParse(data.substring(8));
        if (profileId != null) {
          await _showProfileInfo(ctx, profileId, messageId!);
        }
      } else if (data.startsWith('rename_profile_')) {
        // Переименование профиля
        final profileId = int.tryParse(data.substring(15));
        if (profileId != null) {
          await _startProfileRename(ctx, profileId, messageId!);
        }
      } else if (data.startsWith('delete_profile_')) {
        // Удаление профиля
        final profileId = int.tryParse(data.substring(15));
        if (profileId != null) {
          await _deleteProfile(ctx, profileId, messageId!);
        }
      } else if (data.startsWith('confirm_delete_profile_')) {
        // Подтверждение удаления профиля
        final profileId = int.tryParse(data.substring(23));
        if (profileId != null) {
          await _confirmDeleteProfile(ctx, profileId, messageId!);
        }
      } else if (data.startsWith('toggle_child_')) {
        // Переключение детского режима
        final profileId = int.tryParse(data.substring(13));
        if (profileId != null) {
          await _toggleChildMode(ctx, profileId, messageId!);
        }
      } else if (data.startsWith('change_icon_')) {
        // Изменение иконки
        final profileId = int.tryParse(data.substring(12));
        if (profileId != null) {
          await _showIconPicker(ctx, profileId, messageId!);
        }
      } else if (data.startsWith('set_icon_')) {
        // Установка иконки
        final parts = data.substring(9).split('_');
        if (parts.length == 2) {
          final profileId = int.tryParse(parts[0]);
          final icon = 'l_${parts[1]}';
          if (profileId != null) {
            await _setProfileIcon(ctx, profileId, icon, messageId!);
          }
        }
      }
      // ============= Admin callbacks =============
      else if (data == 'admin_menu') {
        await _showAdminMenu(ctx, messageId: messageId, edit: true);
      } else if (data == 'admin_notices') {
        await _showNoticesList(ctx, messageId: messageId, edit: true);
      } else if (data == 'notice_create') {
        await _startNoticeCreation(ctx, messageId!);
      } else if (data == 'notice_type_simple') {
        await _selectNoticeType(ctx, 'simple', messageId!);
      } else if (data == 'notice_type_card') {
        await _selectNoticeType(ctx, 'card', messageId!);
      } else if (data.startsWith('notice_view_')) {
        final noticeId = int.tryParse(data.substring(12));
        if (noticeId != null) {
          await _showNoticeInfo(ctx, noticeId, messageId!);
        }
      } else if (data.startsWith('notice_toggle_')) {
        final noticeId = int.tryParse(data.substring(14));
        if (noticeId != null) {
          await _toggleNotice(ctx, noticeId, messageId!);
        }
      } else if (data.startsWith('notice_delete_')) {
        final noticeId = int.tryParse(data.substring(14));
        if (noticeId != null) {
          await _deleteNoticeConfirm(ctx, noticeId, messageId!);
        }
      } else if (data.startsWith('confirm_delete_notice_')) {
        final noticeId = int.tryParse(data.substring(22));
        if (noticeId != null) {
          await _confirmDeleteNotice(ctx, noticeId, messageId!);
        }
      } else if (data.startsWith('notice_edit_title_')) {
        final noticeId = int.tryParse(data.substring(18));
        if (noticeId != null) {
          await _promptNoticeEdit(ctx, noticeId, 'title', messageId!);
        }
      } else if (data.startsWith('notice_edit_text_')) {
        final noticeId = int.tryParse(data.substring(17));
        if (noticeId != null) {
          await _promptNoticeEdit(ctx, noticeId, 'text', messageId!);
        }
      } else if (data.startsWith('notice_edit_image_')) {
        final noticeId = int.tryParse(data.substring(18));
        if (noticeId != null) {
          await _promptNoticeEdit(ctx, noticeId, 'image', messageId!);
        }
      } else if (data.startsWith('notice_edit_')) {
        final noticeId = int.tryParse(data.substring(12));
        if (noticeId != null) {
          await _startNoticeEdit(ctx, noticeId, messageId!);
        }
      } else if (data == 'notice_skip_text') {
        // Пропустить текст, перейти к изображению
        final pending =
            DataSource.instance.getPendingNoticeCreation(telegramUserId);
        if (pending != null) {
          pending['text'] = null;
          pending['step'] = 'image';
          DataSource.instance.setPendingNoticeCreation(telegramUserId, pending);

          final keyboard = InlineKeyboard()
              .add('⏭ Пропустить', 'notice_skip_image')
              .row()
              .add('❌ Отмена', 'admin_notices');

          await ctx.api.editMessageText(
            ChatID(ctx.chat!.id),
            messageId!,
            '📢 *Создание уведомления*\n\n'
            '📝 Заголовок: *${_escapeMarkdown(pending["title"] as String? ?? "")}*\n\n'
            '🖼 Отправьте *URL изображения* (или пропустите):',
            parseMode: ParseMode.markdown,
            replyMarkup: keyboard,
          );
        }
      } else if (data == 'notice_skip_image') {
        // Пропустить изображение, создать уведомление
        final pending =
            DataSource.instance.getPendingNoticeCreation(telegramUserId);
        if (pending != null) {
          pending['image'] = null;
          await _createNoticeFromPending(ctx, telegramUserId, pending);
        }
      }
      // ============= Admin Users callbacks =============
      else if (data == 'admin_users') {
        await _showUsersList(ctx, messageId: messageId, edit: true);
      } else if (data.startsWith('admin_users_page_')) {
        final page = int.tryParse(data.substring(17)) ?? 0;
        await _showUsersList(ctx, messageId: messageId, edit: true, page: page);
      } else if (data.startsWith('admin_user_')) {
        final userId = data.substring(11);
        await _showUserInfo(ctx, userId, messageId!);
      } else if (data.startsWith('admin_block_user_')) {
        final userId = data.substring(17);
        await _blockUser(ctx, userId, messageId!);
      } else if (data.startsWith('admin_unblock_user_')) {
        final userId = data.substring(19);
        await _unblockUser(ctx, userId, messageId!);
      } else if (data.startsWith('admin_delete_user_')) {
        final userId = data.substring(18);
        await _deleteUserConfirm(ctx, userId, messageId!);
      } else if (data.startsWith('confirm_delete_user_')) {
        final userId = data.substring(20);
        await _confirmDeleteUser(ctx, userId, messageId!);
      }
      // ============= Admin Registration callbacks =============
      else if (data == 'admin_registration') {
        await _showRegistrationSettings(ctx, messageId: messageId, edit: true);
      } else if (data.startsWith('set_reg_mode_')) {
        final mode = data.substring(13);
        await _setRegistrationMode(ctx, mode, messageId!);
      } else if (data == 'admin_pending_registrations') {
        await _showPendingRegistrations(ctx, messageId: messageId, edit: true);
      } else if (data.startsWith('approve_registration_')) {
        final pendingId = int.tryParse(data.substring(21));
        if (pendingId != null) {
          await _approveRegistration(ctx, pendingId, messageId!);
        }
      } else if (data.startsWith('reject_registration_')) {
        final pendingId = int.tryParse(data.substring(20));
        if (pendingId != null) {
          await _rejectRegistration(ctx, pendingId, messageId!);
        }
      } else if (data == 'admin_invite_codes') {
        await _showInviteCodes(ctx, messageId: messageId, edit: true);
      } else if (data == 'create_invite_code_onetime') {
        await _createInviteCode(ctx, oneTime: true, messageId: messageId);
      } else if (data == 'create_invite_code_unlimited') {
        await _createInviteCode(ctx, oneTime: false, messageId: messageId);
      } else if (data.startsWith('delete_invite_code_')) {
        final codeId = int.tryParse(data.substring(19));
        if (codeId != null) {
          await _deleteInviteCode(ctx, codeId, messageId!);
        }
      } else if (data == 'admin_allowed_phones') {
        await _showAllowedPhonesPrompt(ctx, messageId!);
      } else {
        _log('Unknown callback data: $data');
      }

      _log('Callback handled successfully');
    } catch (e, stack) {
      _log('Error handling callback: $e');
      _log('Stack: $stack');
    }
  }

  /// Показать информацию об устройстве
  Future<void> _showDeviceInfo(
    Context ctx,
    String shortId,
    int messageId,
  ) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    if (user == null) return;

    final devices = await DataSource.instance.getUserDevices(user.id);
    final device = devices.where((d) => d.id.startsWith(shortId)).firstOrNull;

    if (device == null) {
      final keyboard = InlineKeyboard().add('« Назад', 'list_devices');

      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Устройство не найдено',
        replyMarkup: keyboard,
      );
      return;
    }

    final timeAgo = device.lastSeen != null
        ? _formatTimeAgo(device.lastSeen!)
        : 'неизвестно';

    final keyboard = InlineKeyboard()
        .add('✏️ Переименовать', 'rename_device_$shortId')
        .row()
        .add('🗑 Удалить', 'delete_device_$shortId')
        .row()
        .add('« Назад', 'list_devices');
    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '📱 *${_escapeMarkdown(device.name)}*\n\n'
      '🖥 Платформа: ${device.platform}\n'
      '🕐 Последняя активность: $timeAgo\n'
      '🔑 ID: `${device.id}`',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Запрос подтверждения удаления
  Future<void> _deleteDevice(
    Context ctx,
    String shortId,
    int messageId,
  ) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    if (user == null) return;

    final devices = await DataSource.instance.getUserDevices(user.id);
    final device = devices.where((d) => d.id.startsWith(shortId)).firstOrNull;

    if (device == null) {
      final keyboard = InlineKeyboard().add('« Назад', 'list_devices');

      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Устройство не найдено',
        replyMarkup: keyboard,
      );
      return;
    }

    final keyboard = InlineKeyboard()
        .add(
          '✅ Да, удалить',
          'confirm_delete_device_$shortId',
        )
        .row()
        .add('❌ Отмена', 'device_$shortId');

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '⚠️ *Удалить устройство?*\n\n'
      '📱 ${_escapeMarkdown(device.name)} (${device.platform})\n\n'
      'Это действие нельзя отменить.',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Подтверждение удаления
  Future<void> _confirmDelete(
    Context ctx,
    String shortId,
    int messageId,
  ) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    if (user == null) return;

    final devices = await DataSource.instance.getUserDevices(user.id);
    final device = devices.where((d) => d.id.startsWith(shortId)).firstOrNull;

    if (device == null) {
      final keyboard = InlineKeyboard().add('« Назад', 'list_devices');

      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Устройство не найдено',
        replyMarkup: keyboard,
      );
      return;
    }

    final escapedDeviceName = _escapeMarkdown(device.name);
    await DataSource.instance.removeDevice(device.id);

    final keyboard = InlineKeyboard()
        .add('📱 Мои устройства', 'list_devices')
        .row()
        .add('« Главное меню', 'main_menu');

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '✅ Устройство *$escapedDeviceName* удалено',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Начать переименование
  Future<void> _startRename(
    Context ctx,
    String shortId,
    int messageId,
  ) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    if (user == null) return;

    final devices = await DataSource.instance.getUserDevices(user.id);
    final device = devices.where((d) => d.id.startsWith(shortId)).firstOrNull;

    if (device == null) {
      final keyboard = InlineKeyboard().add('« Назад', 'list_devices');

      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Устройство не найдено',
        replyMarkup: keyboard,
      );
      return;
    }

    // Сохраняем состояние переименования
    DataSource.instance.setPendingRename(telegramUserId, device.id);

    final keyboard = InlineKeyboard().add('❌ Отмена', 'device_$shortId');

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '✏️ *Переименование устройства*\n\n'
      'Текущее имя: *${_escapeMarkdown(device.name)}*\n\n'
      'Отправьте новое имя для устройства:',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Обработка текстовых сообщений
  Future<void> _handleText(Context ctx) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final text = ctx.message?.text ?? '';
    final messageId = ctx.message?.messageId;

    // Пропускаем команды
    if (text.startsWith('/')) return;

    // Проверяем, есть ли ожидающее переименование профиля
    final pendingProfileId =
        DataSource.instance.getPendingProfileRename(telegramUserId);
    if (pendingProfileId != null) {
      // Удаляем сообщение пользователя
      if (messageId != null) {
        try {
          await ctx.api.deleteMessage(ChatID(ctx.chat!.id), messageId);
        } catch (_) {}
      }

      final newName = text.trim();
      if (newName.isEmpty || newName.length > 30) {
        final keyboard =
            InlineKeyboard().add('❌ Отмена', 'profile_$pendingProfileId');

        await ctx.reply(
          '❌ Имя должно быть от 1 до 30 символов',
          replyMarkup: keyboard,
        );
        return;
      }

      final profile =
          await DataSource.instance.getProfileById(pendingProfileId);
      if (profile != null) {
        final updatedProfile = profile.copyWith(name: newName);
        await DataSource.instance.updateProfile(updatedProfile);
      }
      DataSource.instance.clearPendingProfileRename(telegramUserId);

      final keyboard = InlineKeyboard()
          .add('👥 Профили', 'list_profiles')
          .row()
          .add('« Главное меню', 'main_menu');

      await ctx.reply(
        '✅ Профиль переименован в *${_escapeMarkdown(newName)}*',
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
      return;
    }

    // Проверяем, есть ли ожидающее переименование устройства
    final pendingDeviceId =
        DataSource.instance.getPendingRename(telegramUserId);
    if (pendingDeviceId != null) {
      // Удаляем сообщение пользователя
      if (messageId != null) {
        try {
          await ctx.api.deleteMessage(ChatID(ctx.chat!.id), messageId);
        } catch (_) {}
      }

      // Переименовываем устройство
      final newName = text.trim();
      if (newName.isEmpty || newName.length > 50) {
        final keyboard = InlineKeyboard().add('❌ Отмена', 'list_devices');

        await ctx.reply(
          '❌ Имя должно быть от 1 до 50 символов',
          replyMarkup: keyboard,
        );
        return;
      }

      await DataSource.instance.renameDevice(pendingDeviceId, newName);
      DataSource.instance.clearPendingRename(telegramUserId);

      final keyboard = InlineKeyboard()
          .add('📱 Мои устройства', 'list_devices')
          .row()
          .add('« Главное меню', 'main_menu');

      await ctx.reply(
        '✅ Устройство переименовано в *${_escapeMarkdown(newName)}*',
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
      return;
    }

    // Проверяем, есть ли ожидающее создание/редактирование уведомления
    final pendingNotice =
        DataSource.instance.getPendingNoticeCreation(telegramUserId);
    if (pendingNotice != null) {
      // Удаляем сообщение пользователя
      if (messageId != null) {
        try {
          await ctx.api.deleteMessage(ChatID(ctx.chat!.id), messageId);
        } catch (_) {}
      }

      final step = pendingNotice['step'] as String?;
      final inputText = text.trim();

      if (step == 'title') {
        // Сохраняем заголовок и запрашиваем текст
        pendingNotice['title'] = inputText;
        pendingNotice['step'] = 'text';
        DataSource.instance
            .setPendingNoticeCreation(telegramUserId, pendingNotice);

        final keyboard = InlineKeyboard()
            .add('⏭ Пропустить', 'notice_skip_text')
            .row()
            .add('❌ Отмена', 'admin_notices');

        await ctx.reply(
          '📢 *Создание уведомления*\n\n'
          '📝 Заголовок: *${_escapeMarkdown(inputText)}*\n\n'
          '✏️ Отправьте *текст* уведомления (или пропустите):',
          parseMode: ParseMode.markdown,
          replyMarkup: keyboard,
        );
        return;
      } else if (step == 'text') {
        // Сохраняем текст и запрашиваем изображение
        pendingNotice['text'] = inputText;
        pendingNotice['step'] = 'image';
        DataSource.instance
            .setPendingNoticeCreation(telegramUserId, pendingNotice);

        final keyboard = InlineKeyboard()
            .add('⏭ Пропустить', 'notice_skip_image')
            .row()
            .add('❌ Отмена', 'admin_notices');

        await ctx.reply(
          '📢 *Создание уведомления*\n\n'
          '📝 Заголовок: *${_escapeMarkdown(pendingNotice["title"] as String)}*\n'
          '💬 Текст: ${_escapeMarkdown(inputText)}\n\n'
          '🖼 Отправьте *URL изображения* (или пропустите):',
          parseMode: ParseMode.markdown,
          replyMarkup: keyboard,
        );
        return;
      } else if (step == 'image') {
        // Сохраняем изображение и создаём уведомление
        pendingNotice['image'] = inputText;
        await _createNoticeFromPending(ctx, telegramUserId, pendingNotice);
        return;
      } else if (step == 'invite_code') {
        // Проверяем и используем инвайт-код атомарно
        final code = inputText.toUpperCase().trim();
        final codeUsed = await DataSource.instance.useInviteCode(code);

        if (!codeUsed) {
          await ctx.reply(
            '❌ *Неверный или истёкший код*\n\n'
            'Попробуйте ещё раз или обратитесь к администратору.',
            parseMode: ParseMode.markdown,
          );
          return;
        }

        DataSource.instance.clearPendingNoticeCreation(telegramUserId);

        // Завершаем регистрацию
        await _completeRegistration(
          ctx,
          telegramUserId: telegramUserId,
          phone: pendingNotice['phone'] as String,
          firstName: pendingNotice['firstName'] as String?,
          lastName: pendingNotice['lastName'] as String?,
        );
        return;
      } else if (step == 'allowed_phones') {
        // Сохраняем список разрешённых телефонов
        final phones = inputText
            .split(RegExp(r'[,\n]'))
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .toList();

        await DataSource.instance.setAllowedPhones(phones);
        DataSource.instance.clearPendingNoticeCreation(telegramUserId);

        final keyboard = InlineKeyboard()
            .add('« Настройки регистрации', 'admin_registration');

        await ctx.reply(
          '✅ Список разрешённых телефонов обновлён\n\n'
          'Добавлено номеров: ${phones.length}',
          replyMarkup: keyboard,
        );
        return;
      } else if (step != null && step.startsWith('edit_')) {
        // Редактирование существующего уведомления
        final field = step.substring(5);
        final noticeId = pendingNotice['noticeId'] as int?;
        if (noticeId != null) {
          final notice = await DataSource.instance.getNoticeById(noticeId);
          if (notice != null) {
            Notice updatedNotice;
            if (field == 'title') {
              updatedNotice = notice.copyWith(title: Value(inputText));
            } else if (field == 'text') {
              updatedNotice = notice.copyWith(noticeText: Value(inputText));
            } else if (field == 'image') {
              updatedNotice = notice.copyWith(image: Value(inputText));
            } else {
              updatedNotice = notice;
            }
            await DataSource.instance.updateNotice(updatedNotice);
          }
          DataSource.instance.clearPendingNoticeCreation(telegramUserId);

          final keyboard = InlineKeyboard()
              .add('📢 К уведомлению', 'notice_view_$noticeId')
              .row()
              .add('« Список уведомлений', 'admin_notices');

          await ctx.reply(
            '✅ Уведомление обновлено',
            replyMarkup: keyboard,
          );
        }
        return;
      }
    }

    // Проверяем, есть ли ожидающий выбор для удаления (старый способ)
    final pending = DataSource.instance.getPendingRemoval(telegramUserId);
    if (pending != null) {
      // Удаляем сообщение пользователя
      if (messageId != null) {
        try {
          await ctx.api.deleteMessage(ChatID(ctx.chat!.id), messageId);
        } catch (_) {}
      }

      final index = int.tryParse(text);
      if (index == null || index < 1 || index > pending.length) {
        await ctx.reply(
          '❌ Неверный номер. Введите число от 1 до ${pending.length}\n'
          'Или используйте кнопки для управления устройствами.',
          replyMarkup: _mainMenuKeyboard(),
        );
        return;
      }

      final device = pending[index - 1];
      await DataSource.instance.removeDevice(device.id);
      DataSource.instance.clearPendingRemoval(telegramUserId);

      await ctx.reply(
        '✅ Устройство *${_escapeMarkdown(device.name)}* удалено',
        parseMode: ParseMode.markdown,
        replyMarkup: _mainMenuKeyboard(),
      );
    }
  }

  // ============= Методы управления профилями =============

  /// Показать список профилей
  Future<void> _showProfilesList(
    Context ctx, {
    int? messageId,
    bool edit = false,
  }) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    if (user == null) return;

    final profiles = await DataSource.instance.getProfilesForUser(user.id);

    var keyboard = InlineKeyboard();
    for (final profile in profiles) {
      final mainMark = profile.main ? ' ⭐' : '';
      final childMark = !profile.adult ? ' 👶' : '';
      keyboard = keyboard
          .add(
            '${profile.icon == 'l_1' ? '👤' : _iconEmoji(profile.icon)} ${profile.name}$mainMark$childMark',
            'profile_${profile.id}',
          )
          .row();
    }
    keyboard = keyboard.add('« Назад', 'main_menu');

    final text = '👥 *Профили* (${profiles.length}/8)\n\n'
        'Выберите профиль для управления:\n\n'
        '⭐ — основной профиль\n'
        '👶 — детский профиль';

    if (edit && messageId != null) {
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    } else {
      await ctx.reply(
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    }
  }

  /// Показать информацию о профиле
  Future<void> _showProfileInfo(
    Context ctx,
    int profileId,
    int messageId,
  ) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    if (user == null) return;

    final profile = await DataSource.instance.getProfileById(profileId);
    if (profile == null || profile.userId != user.id) {
      final keyboard = InlineKeyboard().add('« Назад', 'list_profiles');
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Профиль не найден',
        replyMarkup: keyboard,
      );
      return;
    }

    var keyboard = InlineKeyboard()
        .add('✏️ Переименовать', 'rename_profile_$profileId')
        .row()
        .add('🎨 Изменить иконку', 'change_icon_$profileId')
        .row()
        .add(
          profile.adult ? '👶 Сделать детским' : '👤 Сделать взрослым',
          'toggle_child_$profileId',
        )
        .row();

    // Кнопка удаления только для не-основных профилей
    if (!profile.main) {
      keyboard = keyboard.add('🗑 Удалить', 'delete_profile_$profileId').row();
    }

    keyboard = keyboard.add('« Назад', 'list_profiles');

    final mainMark = profile.main ? ' ⭐ (основной)' : '';
    final childMark = !profile.adult ? '\n👶 Детский профиль' : '';
    final escapedName = _escapeMarkdown(profile.name);
    final escapedIcon = _escapeMarkdown(profile.icon);

    final text = '${_iconEmoji(profile.icon)} *$escapedName*$mainMark'
        '$childMark\n'
        '🎨 Иконка: $escapedIcon';

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      text,
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Начать переименование профиля
  Future<void> _startProfileRename(
    Context ctx,
    int profileId,
    int messageId,
  ) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    if (user == null) return;

    final profile = await DataSource.instance.getProfileById(profileId);
    if (profile == null || profile.userId != user.id) {
      final keyboard = InlineKeyboard().add('« Назад', 'list_profiles');
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Профиль не найден',
        replyMarkup: keyboard,
      );
      return;
    }

    DataSource.instance.setPendingProfileRename(telegramUserId, profileId);

    final keyboard = InlineKeyboard().add('❌ Отмена', 'profile_$profileId');
    final escapedName = _escapeMarkdown(profile.name);

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '✏️ *Переименование профиля*\n\n'
      'Текущее имя: *$escapedName*\n\n'
      'Отправьте новое имя:',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Запрос подтверждения удаления профиля
  Future<void> _deleteProfile(
    Context ctx,
    int profileId,
    int messageId,
  ) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    if (user == null) return;

    final profile = await DataSource.instance.getProfileById(profileId);
    if (profile == null || profile.userId != user.id) {
      final keyboard = InlineKeyboard().add('« Назад', 'list_profiles');
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Профиль не найден',
        replyMarkup: keyboard,
      );
      return;
    }

    if (profile.main) {
      final keyboard = InlineKeyboard().add('« Назад', 'profile_$profileId');
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Нельзя удалить основной профиль',
        replyMarkup: keyboard,
      );
      return;
    }

    final profiles = await DataSource.instance.getProfilesForUser(user.id);
    if (profiles.length <= 1) {
      final keyboard = InlineKeyboard().add('« Назад', 'profile_$profileId');
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Нельзя удалить последний профиль',
        replyMarkup: keyboard,
      );
      return;
    }

    final keyboard = InlineKeyboard()
        .add('✅ Да, удалить', 'confirm_delete_profile_$profileId')
        .row()
        .add('❌ Отмена', 'profile_$profileId');
    final escapedName = _escapeMarkdown(profile.name);

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '⚠️ *Удалить профиль?*\n\n'
      '👤 $escapedName\n\n'
      '❗ Будут удалены все закладки и история просмотров этого профиля.\n'
      'Это действие нельзя отменить.',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Подтверждение удаления профиля
  Future<void> _confirmDeleteProfile(
    Context ctx,
    int profileId,
    int messageId,
  ) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    if (user == null) return;

    final profile = await DataSource.instance.getProfileById(profileId);
    if (profile == null || profile.userId != user.id) {
      final keyboard = InlineKeyboard().add('« Назад', 'list_profiles');
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Профиль не найден',
        replyMarkup: keyboard,
      );
      return;
    }

    final escapedName = _escapeMarkdown(profile.name);
    await DataSource.instance.deleteProfile(profileId);

    final keyboard = InlineKeyboard()
        .add('👥 Профили', 'list_profiles')
        .row()
        .add('« Главное меню', 'main_menu');

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '✅ Профиль *$escapedName* удалён',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Переключение детского режима
  Future<void> _toggleChildMode(
    Context ctx,
    int profileId,
    int messageId,
  ) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    if (user == null) return;

    final profile = await DataSource.instance.getProfileById(profileId);
    if (profile == null || profile.userId != user.id) {
      final keyboard = InlineKeyboard().add('« Назад', 'list_profiles');
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Профиль не найден',
        replyMarkup: keyboard,
      );
      return;
    }

    final updatedProfile = profile.copyWith(adult: !profile.adult);
    await DataSource.instance.updateProfile(updatedProfile);

    // Показываем обновлённую информацию о профиле
    await _showProfileInfo(ctx, profileId, messageId);
  }

  /// Показать выбор иконки
  Future<void> _showIconPicker(
    Context ctx,
    int profileId,
    int messageId,
  ) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    if (user == null) return;

    final profile = await DataSource.instance.getProfileById(profileId);
    if (profile == null || profile.userId != user.id) {
      final keyboard = InlineKeyboard().add('« Назад', 'list_profiles');
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Профиль не найден',
        replyMarkup: keyboard,
      );
      return;
    }

    // 8 иконок в 2 ряда по 4
    final keyboard = InlineKeyboard()
        .add('🍕', 'set_icon_${profileId}_1')
        .add('🥗', 'set_icon_${profileId}_2')
        .add('🥙', 'set_icon_${profileId}_3')
        .add('🥝', 'set_icon_${profileId}_4')
        .row()
        .add('🍕', 'set_icon_${profileId}_5')
        .add('🥗', 'set_icon_${profileId}_6')
        .add('🥙', 'set_icon_${profileId}_7')
        .add('🥝', 'set_icon_${profileId}_8')
        .row()
        .add('« Назад', 'profile_$profileId');

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '🎨 *Выберите иконку для профиля*\n\n'
      'Текущая: ${_escapeMarkdown(profile.icon)}',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Установить иконку профиля
  Future<void> _setProfileIcon(
    Context ctx,
    int profileId,
    String icon,
    int messageId,
  ) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final user = await DataSource.instance.findUserByTelegramId(telegramUserId);
    if (user == null) return;

    final profile = await DataSource.instance.getProfileById(profileId);
    if (profile == null || profile.userId != user.id) {
      final keyboard = InlineKeyboard().add('« Назад', 'list_profiles');
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Профиль не найден',
        replyMarkup: keyboard,
      );
      return;
    }

    final updatedProfile = profile.copyWith(icon: icon);
    await DataSource.instance.updateProfile(updatedProfile);

    // Показываем обновлённую информацию о профиле
    await _showProfileInfo(ctx, profileId, messageId);
  }

  // ============= Методы управления уведомлениями (Admin) =============

  /// Показать список уведомлений
  Future<void> _showNoticesList(
    Context ctx, {
    int? messageId,
    bool edit = false,
  }) async {
    final notices = await DataSource.instance.getAllNotices();

    var keyboard =
        InlineKeyboard().add('➕ Создать уведомление', 'notice_create').row();

    if (notices.isEmpty) {
      keyboard = keyboard.add('« Назад', 'admin_menu');

      const text = '📢 *Уведомления*\n\nУведомлений пока нет.';

      if (edit && messageId != null) {
        await ctx.api.editMessageText(
          ChatID(ctx.chat!.id),
          messageId,
          text,
          parseMode: ParseMode.markdown,
          replyMarkup: keyboard,
        );
      } else {
        await ctx.reply(
          text,
          parseMode: ParseMode.markdown,
          replyMarkup: keyboard,
        );
      }
      return;
    }

    for (final notice in notices.take(10)) {
      final status = notice.active ? '✅' : '❌';
      final title = notice.title ?? notice.noticeType;
      final shortTitle =
          title.length > 25 ? '${title.substring(0, 22)}...' : title;
      keyboard =
          keyboard.add('$status $shortTitle', 'notice_view_${notice.id}').row();
    }

    keyboard = keyboard.add('« Назад', 'admin_menu');

    final text = '📢 *Уведомления* (${notices.length})\n\n'
        '✅ — активно\n'
        '❌ — неактивно\n\n'
        'Выберите уведомление:';

    if (edit && messageId != null) {
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    } else {
      await ctx.reply(
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    }
  }

  /// Показать информацию об уведомлении
  Future<void> _showNoticeInfo(Context ctx, int noticeId, int messageId) async {
    final notice = await DataSource.instance.getNoticeById(noticeId);
    if (notice == null) {
      final keyboard = InlineKeyboard().add('« Назад', 'admin_notices');
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Уведомление не найдено',
        replyMarkup: keyboard,
      );
      return;
    }

    final status = notice.active ? '✅ Активно' : '❌ Неактивно';
    final toggleText = notice.active ? '❌ Выключить' : '✅ Включить';
    final expiresText = notice.expiresAt != null
        ? '\n⏰ Истекает: ${_formatDate(notice.expiresAt!)}'
        : '';

    final keyboard = InlineKeyboard()
        .add(toggleText, 'notice_toggle_${notice.id}')
        .row()
        .add('✏️ Редактировать', 'notice_edit_${notice.id}')
        .row()
        .add('🗑 Удалить', 'notice_delete_${notice.id}')
        .row()
        .add('« Назад', 'admin_notices');

    final escapedTitle = _escapeMarkdown(notice.title ?? 'Без заголовка');
    final escapedText = _escapeMarkdown(notice.noticeText ?? '');

    final text = '📢 *$escapedTitle*\n\n'
        '📝 ${escapedText.isEmpty ? "(без текста)" : escapedText}\n\n'
        '📊 Статус: $status\n'
        '🏷 Тип: ${notice.noticeType}\n'
        '📅 Создано: ${_formatDate(notice.createdAt)}'
        '$expiresText';

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      text,
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Начать создание уведомления
  Future<void> _startNoticeCreation(Context ctx, int messageId) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';

    DataSource.instance.setPendingNoticeCreation(telegramUserId, {
      'step': 'type',
    });

    final keyboard = InlineKeyboard()
        .add('📝 Простое (заголовок + текст)', 'notice_type_simple')
        .row()
        .add('🎬 Карточка (фильм/сериал)', 'notice_type_card')
        .row()
        .add('❌ Отмена', 'admin_notices');

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '📢 *Создание уведомления*\n\nВыберите тип уведомления:',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Выбор типа уведомления
  Future<void> _selectNoticeType(
    Context ctx,
    String type,
    int messageId,
  ) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';

    DataSource.instance.setPendingNoticeCreation(telegramUserId, {
      'step': 'title',
      'type': type,
    });

    final keyboard = InlineKeyboard().add('❌ Отмена', 'admin_notices');

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '📢 *Создание уведомления*\n\n'
      'Тип: *${type == "simple" ? "Простое" : "Карточка"}*\n\n'
      '✏️ Отправьте *заголовок* уведомления:',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Переключить активность уведомления
  Future<void> _toggleNotice(Context ctx, int noticeId, int messageId) async {
    final notice = await DataSource.instance.getNoticeById(noticeId);
    if (notice == null) return;

    await DataSource.instance
        .toggleNoticeActive(noticeId, active: !notice.active);
    await _showNoticeInfo(ctx, noticeId, messageId);
  }

  /// Запрос подтверждения удаления уведомления
  Future<void> _deleteNoticeConfirm(
    Context ctx,
    int noticeId,
    int messageId,
  ) async {
    final notice = await DataSource.instance.getNoticeById(noticeId);
    if (notice == null) {
      final keyboard = InlineKeyboard().add('« Назад', 'admin_notices');
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Уведомление не найдено',
        replyMarkup: keyboard,
      );
      return;
    }

    final keyboard = InlineKeyboard()
        .add('✅ Да, удалить', 'confirm_delete_notice_${notice.id}')
        .row()
        .add('❌ Отмена', 'notice_view_${notice.id}');

    final escapedTitle = _escapeMarkdown(notice.title ?? 'Без заголовка');

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '⚠️ *Удалить уведомление?*\n\n'
      '📢 $escapedTitle\n\n'
      'Это действие нельзя отменить.',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Подтверждение удаления уведомления
  Future<void> _confirmDeleteNotice(
    Context ctx,
    int noticeId,
    int messageId,
  ) async {
    final notice = await DataSource.instance.getNoticeById(noticeId);
    if (notice == null) {
      await _showNoticesList(ctx, messageId: messageId, edit: true);
      return;
    }

    final escapedTitle = _escapeMarkdown(notice.title ?? 'Без заголовка');
    await DataSource.instance.deleteNotice(noticeId);

    final keyboard = InlineKeyboard()
        .add('📢 Уведомления', 'admin_notices')
        .row()
        .add('« Админ меню', 'admin_menu');

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '✅ Уведомление *$escapedTitle* удалено',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Начать редактирование уведомления
  Future<void> _startNoticeEdit(
    Context ctx,
    int noticeId,
    int messageId,
  ) async {
    final notice = await DataSource.instance.getNoticeById(noticeId);
    if (notice == null) {
      await _showNoticesList(ctx, messageId: messageId, edit: true);
      return;
    }

    final keyboard = InlineKeyboard()
        .add('📝 Заголовок', 'notice_edit_title_$noticeId')
        .row()
        .add('💬 Текст', 'notice_edit_text_$noticeId')
        .row()
        .add('🖼 Изображение', 'notice_edit_image_$noticeId')
        .row()
        .add('« Назад', 'notice_view_$noticeId');

    final escapedTitle = _escapeMarkdown(notice.title ?? 'Без заголовка');

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '✏️ *Редактирование уведомления*\n\n'
      '📢 $escapedTitle\n\n'
      'Выберите, что редактировать:',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Запрос нового значения для редактирования
  Future<void> _promptNoticeEdit(
    Context ctx,
    int noticeId,
    String field,
    int messageId,
  ) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final notice = await DataSource.instance.getNoticeById(noticeId);
    if (notice == null) return;

    DataSource.instance.setPendingNoticeCreation(telegramUserId, {
      'step': 'edit_$field',
      'noticeId': noticeId,
    });

    final fieldNames = {
      'title': 'заголовок',
      'text': 'текст',
      'image': 'URL изображения',
    };

    final keyboard = InlineKeyboard().add('❌ Отмена', 'notice_edit_$noticeId');

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '✏️ Отправьте новый *${fieldNames[field]}*:',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Создать уведомление из pending state
  Future<void> _createNoticeFromPending(
    Context ctx,
    String telegramUserId,
    Map<String, dynamic> pending,
  ) async {
    final type = pending['type'] as String? ?? 'simple';
    final title = pending['title'] as String?;
    final text = pending['text'] as String?;
    final image = pending['image'] as String?;

    final notice = await DataSource.instance.createNotice(
      type: type,
      title: title,
      text: text,
      image: image,
    );

    DataSource.instance.clearPendingNoticeCreation(telegramUserId);

    final keyboard = InlineKeyboard()
        .add('📢 К уведомлению', 'notice_view_${notice.id}')
        .row()
        .add('« Список уведомлений', 'admin_notices');

    await ctx.reply(
      '✅ *Уведомление создано!*\n\n'
      '📝 Заголовок: *${_escapeMarkdown(title ?? "Без заголовка")}*\n'
      '${text != null ? "💬 Текст: ${_escapeMarkdown(text)}\n" : ""}'
      '${image != null ? "🖼 Изображение: есть\n" : ""}'
      '\n📊 Статус: ✅ Активно',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Экранирование специальных символов Markdown
  String _escapeMarkdown(String text) {
    return text
        .replaceAll(r'\', r'\\')
        .replaceAll('*', r'\*')
        .replaceAll('_', r'\_')
        .replaceAll('[', r'\[')
        .replaceAll(']', r'\]')
        .replaceAll('`', r'\`');
  }

  /// Эмодзи для иконки профиля
  String _iconEmoji(String icon) {
    switch (icon) {
      case 'l_1':
        return '🍕';
      case 'l_2':
        return '🥗';
      case 'l_3':
        return '🥙';
      case 'l_4':
        return '🥝';
      case 'l_5':
        return '🍕';
      case 'l_6':
        return '🥗';
      case 'l_7':
        return '🥙';
      case 'l_8':
        return '🥝';
      default:
        return '👤';
    }
  }

  /// Форматирование времени "X назад"
  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин. назад';
    if (diff.inHours < 24) return '${diff.inHours} ч. назад';
    if (diff.inDays < 7) return '${diff.inDays} дн. назад';
    return '${time.day}.${time.month}.${time.year}';
  }

  /// Форматирование даты
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  // ============= Методы управления пользователями (Admin) =============

  /// Количество пользователей на странице
  static const int _usersPerPage = 8;

  /// Показать список пользователей с пагинацией
  Future<void> _showUsersList(
    Context ctx, {
    int? messageId,
    bool edit = false,
    int page = 0,
  }) async {
    final users = await DataSource.instance.getAllUsers();

    var keyboard = InlineKeyboard();

    if (users.isEmpty) {
      keyboard = keyboard.add('« Назад', 'admin_menu');

      const text = '👥 *Пользователи*\n\nПользователей пока нет.';

      if (edit && messageId != null) {
        await ctx.api.editMessageText(
          ChatID(ctx.chat!.id),
          messageId,
          text,
          parseMode: ParseMode.markdown,
          replyMarkup: keyboard,
        );
      } else {
        await ctx.reply(
          text,
          parseMode: ParseMode.markdown,
          replyMarkup: keyboard,
        );
      }
      return;
    }

    final totalPages = (users.length / _usersPerPage).ceil();
    final startIndex = page * _usersPerPage;
    final endIndex = (startIndex + _usersPerPage).clamp(0, users.length);
    final pageUsers = users.sublist(startIndex, endIndex);

    for (final user in pageUsers) {
      final blocked = user.blocked ? '🚫 ' : '';
      final name = user.firstName ?? user.phone ?? user.id;
      final shortName = name.length > 20 ? '${name.substring(0, 17)}...' : name;
      // Используем полный user.id для избежания коллизий
      keyboard =
          keyboard.add('$blocked$shortName', 'admin_user_${user.id}').row();
    }

    // Кнопки пагинации
    if (totalPages > 1) {
      if (page > 0) {
        keyboard = keyboard.add('⬅️ Назад', 'admin_users_page_${page - 1}');
      }
      if (page < totalPages - 1) {
        keyboard = keyboard.add('➡️ Далее', 'admin_users_page_${page + 1}');
      }
      keyboard = keyboard.row();
    }

    keyboard = keyboard.add('« Назад', 'admin_menu');

    final text = '👥 *Пользователи* (${users.length})\n'
        '${totalPages > 1 ? "📄 Страница ${page + 1}/$totalPages\n" : ""}\n'
        '🚫 — заблокирован\n\n'
        'Выберите пользователя:';

    if (edit && messageId != null) {
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    } else {
      await ctx.reply(
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    }
  }

  /// Показать информацию о пользователе
  Future<void> _showUserInfo(
    Context ctx,
    String userId,
    int messageId,
  ) async {
    final user = await DataSource.instance.getUserById(userId);

    if (user == null) {
      final keyboard = InlineKeyboard().add('« Назад', 'admin_users');
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        '❌ Пользователь не найден',
        replyMarkup: keyboard,
      );
      return;
    }

    final devices = await DataSource.instance.getUserDevices(user.id);
    final profiles = await DataSource.instance.getProfilesForUser(user.id);

    final name = [user.firstName, user.lastName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');

    final blockedText = user.blocked ? '\n🚫 *ЗАБЛОКИРОВАН*' : '';

    var keyboard = InlineKeyboard();

    if (user.blocked) {
      keyboard = keyboard.add('✅ Разблокировать', 'admin_unblock_user_${user.id}');
    } else {
      keyboard = keyboard.add('🚫 Заблокировать', 'admin_block_user_${user.id}');
    }

    keyboard = keyboard
        .row()
        .add('🗑 Удалить', 'admin_delete_user_${user.id}')
        .row()
        .add('« Назад', 'admin_users');

    final text = '👤 *Пользователь*$blockedText\n\n'
        '${name.isNotEmpty ? '👋 Имя: *${_escapeMarkdown(name)}*\n' : ''}'
        '📧 Email: `${user.email}`\n'
        '📱 Телефон: `${user.phone ?? "не указан"}`\n'
        '📅 Зарегистрирован: ${_formatDate(user.createdAt)}\n\n'
        '📊 *Статистика:*\n'
        '• Устройств: ${devices.length}\n'
        '• Профилей: ${profiles.length}';

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      text,
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Заблокировать пользователя
  Future<void> _blockUser(Context ctx, String userId, int messageId) async {
    final user = await DataSource.instance.getUserById(userId);

    if (user == null) {
      await _showUsersList(ctx, messageId: messageId, edit: true);
      return;
    }

    await DataSource.instance.blockUser(user.id);
    await _showUserInfo(ctx, userId, messageId);
  }

  /// Разблокировать пользователя
  Future<void> _unblockUser(Context ctx, String userId, int messageId) async {
    final user = await DataSource.instance.getUserById(userId);

    if (user == null) {
      await _showUsersList(ctx, messageId: messageId, edit: true);
      return;
    }

    await DataSource.instance.unblockUser(user.id);
    await _showUserInfo(ctx, userId, messageId);
  }

  /// Запрос подтверждения удаления пользователя
  Future<void> _deleteUserConfirm(
    Context ctx,
    String userId,
    int messageId,
  ) async {
    final user = await DataSource.instance.getUserById(userId);

    if (user == null) {
      await _showUsersList(ctx, messageId: messageId, edit: true);
      return;
    }

    final name = user.firstName ?? user.phone ?? user.id;

    final keyboard = InlineKeyboard()
        .add('✅ Да, удалить', 'confirm_delete_user_${user.id}')
        .row()
        .add('❌ Отмена', 'admin_user_${user.id}');

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '⚠️ *Удалить пользователя?*\n\n'
      '👤 ${_escapeMarkdown(name)}\n\n'
      '❗ Будут удалены все данные пользователя:\n'
      '• Профили и закладки\n'
      '• История просмотров\n'
      '• Устройства\n\n'
      'Это действие нельзя отменить.',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Подтверждение удаления пользователя
  Future<void> _confirmDeleteUser(
    Context ctx,
    String userId,
    int messageId,
  ) async {
    final user = await DataSource.instance.getUserById(userId);

    if (user == null) {
      await _showUsersList(ctx, messageId: messageId, edit: true);
      return;
    }

    final name = user.firstName ?? user.phone ?? user.id;
    await DataSource.instance.deleteUserWithData(user.id);

    final keyboard = InlineKeyboard()
        .add('👥 Пользователи', 'admin_users')
        .row()
        .add('« Админ меню', 'admin_menu');

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      '✅ Пользователь *${_escapeMarkdown(name)}* удалён',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  // ============= Методы управления регистрацией (Admin) =============

  /// Показать настройки регистрации
  Future<void> _showRegistrationSettings(
    Context ctx, {
    int? messageId,
    bool edit = false,
  }) async {
    final mode = await DataSource.instance.getRegistrationMode();
    final pendingCount =
        (await DataSource.instance.getAllPendingRegistrations()).length;

    final modeNames = {
      'free': '✅ Свободная',
      'approval': '👨‍💼 Одобрение админа',
      'allowed_phones': '📱 Разрешённые номера',
      'invite_code': '🔐 Инвайт-код',
    };

    final currentMode = modeNames[mode] ?? 'Свободная';

    var keyboard = InlineKeyboard()
        .add('✅ Свободная', 'set_reg_mode_free')
        .row()
        .add('👨‍💼 Одобрение админа', 'set_reg_mode_approval')
        .row()
        .add('📱 Разрешённые номера', 'set_reg_mode_allowed_phones')
        .row()
        .add('🔐 Инвайт-код', 'set_reg_mode_invite_code')
        .row();

    if (mode == 'approval' && pendingCount > 0) {
      keyboard =
          keyboard.add('📝 Заявки ($pendingCount)', 'admin_pending_registrations').row();
    } else if (mode == 'approval') {
      keyboard = keyboard.add('📝 Заявки (0)', 'admin_pending_registrations').row();
    }

    if (mode == 'allowed_phones') {
      keyboard = keyboard.add('📱 Редактировать номера', 'admin_allowed_phones').row();
    }

    if (mode == 'invite_code') {
      keyboard = keyboard.add('🔐 Инвайт-коды', 'admin_invite_codes').row();
    }

    keyboard = keyboard.add('« Назад', 'admin_menu');

    final text = '🔐 *Настройки регистрации*\n\n'
        'Текущий режим: *$currentMode*\n\n'
        '📋 *Описание режимов:*\n'
        '• *Свободная* — любой может зарегистрироваться\n'
        '• *Одобрение* — требуется одобрение админа\n'
        '• *Разрешённые номера* — только указанные телефоны\n'
        '• *Инвайт-код* — нужен код для регистрации\n\n'
        'Выберите режим:';

    if (edit && messageId != null) {
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    } else {
      await ctx.reply(
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    }
  }

  /// Установить режим регистрации
  Future<void> _setRegistrationMode(
    Context ctx,
    String mode,
    int messageId,
  ) async {
    // Допустимые режимы регистрации
    const allowedModes = <String>{
      'free',
      'approval',
      'allowed_phones',
      'invite_code',
    };

    if (!allowedModes.contains(mode)) {
      _log('Попытка установить некорректный режим регистрации: "$mode"');
      // Не меняем настройки, просто показываем текущие
      await _showRegistrationSettings(ctx, messageId: messageId, edit: true);
      return;
    }

    await DataSource.instance.setRegistrationMode(mode);
    await _showRegistrationSettings(ctx, messageId: messageId, edit: true);
  }

  /// Показать список ожидающих регистраций
  Future<void> _showPendingRegistrations(
    Context ctx, {
    int? messageId,
    bool edit = false,
  }) async {
    final pending = await DataSource.instance.getAllPendingRegistrations();

    var keyboard = InlineKeyboard();

    if (pending.isEmpty) {
      keyboard = keyboard.add('« Назад', 'admin_registration');

      const text = '📝 *Заявки на регистрацию*\n\nЗаявок пока нет.';

      if (edit && messageId != null) {
        await ctx.api.editMessageText(
          ChatID(ctx.chat!.id),
          messageId,
          text,
          parseMode: ParseMode.markdown,
          replyMarkup: keyboard,
        );
      } else {
        await ctx.reply(
          text,
          parseMode: ParseMode.markdown,
          replyMarkup: keyboard,
        );
      }
      return;
    }

    var text = '📝 *Заявки на регистрацию* (${pending.length})\n\n';

    for (final reg in pending.take(5)) {
      final name = [reg.firstName, reg.lastName]
          .where((s) => s != null && s.isNotEmpty)
          .join(' ');
      final displayName = name.isNotEmpty ? name : reg.phone;

      text += '👤 *${_escapeMarkdown(displayName)}*\n'
          '📱 `${reg.phone}`\n'
          '📅 ${_formatDate(reg.createdAt)}\n\n';

      keyboard = keyboard
          .add('✅', 'approve_registration_${reg.id}')
          .add('❌', 'reject_registration_${reg.id}')
          .row();
    }

    keyboard = keyboard.add('« Назад', 'admin_registration');

    if (edit && messageId != null) {
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    } else {
      await ctx.reply(
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    }
  }

  /// Одобрить регистрацию
  Future<void> _approveRegistration(
    Context ctx,
    int pendingId,
    int messageId,
  ) async {
    final pending =
        await DataSource.instance.getPendingRegistrationById(pendingId);
    if (pending == null) {
      await _showPendingRegistrations(ctx, messageId: messageId, edit: true);
      return;
    }

    final user = await DataSource.instance.approveRegistration(pendingId);
    if (user == null) {
      await _showPendingRegistrations(ctx, messageId: messageId, edit: true);
      return;
    }

    // Уведомляем пользователя
    try {
      final keyboard = InlineKeyboard().add('▶️ Начать', 'main_menu');

      await _bot?.api.sendMessage(
        ChatID(int.parse(pending.telegramId)),
        '✅ *Ваша заявка одобрена!*\n\n'
        '👋 Добро пожаловать в Lampa Self-Hosted!\n\n'
        'Теперь вы можете добавить устройства и начать пользоваться сервисом.',
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    } catch (e) {
      _log('Failed to notify approved user: $e');
    }

    await _showPendingRegistrations(ctx, messageId: messageId, edit: true);
  }

  /// Отклонить регистрацию
  Future<void> _rejectRegistration(
    Context ctx,
    int pendingId,
    int messageId,
  ) async {
    final pending =
        await DataSource.instance.getPendingRegistrationById(pendingId);
    if (pending == null) {
      await _showPendingRegistrations(ctx, messageId: messageId, edit: true);
      return;
    }

    await DataSource.instance.deletePendingRegistration(pendingId);

    // Уведомляем пользователя
    try {
      await _bot?.api.sendMessage(
        ChatID(int.parse(pending.telegramId)),
        '❌ *Заявка отклонена*\n\n'
        'К сожалению, ваша заявка на регистрацию была отклонена администратором.',
        parseMode: ParseMode.markdown,
      );
    } catch (e) {
      _log('Failed to notify rejected user: $e');
    }

    await _showPendingRegistrations(ctx, messageId: messageId, edit: true);
  }

  /// Показать инвайт-коды
  Future<void> _showInviteCodes(
    Context ctx, {
    int? messageId,
    bool edit = false,
  }) async {
    final codes = await DataSource.instance.getAllInviteCodes();

    var keyboard = InlineKeyboard()
        .add('➕ Одноразовый код', 'create_invite_code_onetime')
        .row()
        .add('➕ Многоразовый код', 'create_invite_code_unlimited')
        .row();

    var text = '🔐 *Инвайт-коды*\n\n';

    if (codes.isEmpty) {
      text += 'Кодов пока нет.\n\n';
    } else {
      for (final code in codes.take(10)) {
        final typeIcon = code.oneTime ? '1️⃣' : '♾';
        final usesInfo = code.oneTime
            ? '(осталось: ${code.usesLeft})'
            : '(безлимит)';
        final expired = code.expiresAt != null &&
            DateTime.now().isAfter(code.expiresAt!);
        final status = expired ? '❌' : (code.usesLeft > 0 ? '✅' : '❌');

        text += '$status $typeIcon `${code.code}` $usesInfo\n';
        keyboard = keyboard
            .add('🗑 ${code.code}', 'delete_invite_code_${code.id}')
            .row();
      }
      text += '\n';
    }

    keyboard = keyboard.add('« Назад', 'admin_registration');

    if (edit && messageId != null) {
      await ctx.api.editMessageText(
        ChatID(ctx.chat!.id),
        messageId,
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    } else {
      await ctx.reply(
        text,
        parseMode: ParseMode.markdown,
        replyMarkup: keyboard,
      );
    }
  }

  /// Создать инвайт-код
  Future<void> _createInviteCode(
    Context ctx, {
    required bool oneTime,
    int? messageId,
  }) async {
    final code = await DataSource.instance.createInviteCode(
      oneTime: oneTime,
      usesLeft: oneTime ? 1 : DataSource.unlimitedUsesCount,
    );

    final typeText = oneTime ? 'одноразовый' : 'многоразовый';

    final keyboard = InlineKeyboard()
        .add('🔐 К списку кодов', 'admin_invite_codes')
        .row()
        .add('« Настройки регистрации', 'admin_registration');

    await ctx.api.sendMessage(
      ChatID(ctx.chat!.id),
      '✅ *Инвайт-код создан!*\n\n'
      '🔐 Код: `${code.code}`\n'
      '📋 Тип: $typeText\n\n'
      'Поделитесь этим кодом с пользователем для регистрации.',
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }

  /// Удалить инвайт-код
  Future<void> _deleteInviteCode(
    Context ctx,
    int codeId,
    int messageId,
  ) async {
    await DataSource.instance.deleteInviteCode(codeId);
    await _showInviteCodes(ctx, messageId: messageId, edit: true);
  }

  /// Показать запрос ввода разрешённых телефонов
  Future<void> _showAllowedPhonesPrompt(Context ctx, int messageId) async {
    final telegramUserId = ctx.from?.id.toString() ?? '';
    final currentPhones = await DataSource.instance.getAllowedPhones();

    DataSource.instance.setPendingNoticeCreation(telegramUserId, {
      'step': 'allowed_phones',
    });

    final keyboard = InlineKeyboard().add('❌ Отмена', 'admin_registration');

    var text = '📱 *Разрешённые номера телефонов*\n\n';
    if (currentPhones.isNotEmpty) {
      text += 'Текущий список:\n';
      for (final phone in currentPhones) {
        text += '• `$phone`\n';
      }
      text += '\n';
    }
    text += 'Отправьте список номеров телефонов, '
        'каждый номер с новой строки или через запятую:\n\n'
        'Пример:\n'
        '`+79001234567`\n'
        '`+79007654321`';

    await ctx.api.editMessageText(
      ChatID(ctx.chat!.id),
      messageId,
      text,
      parseMode: ParseMode.markdown,
      replyMarkup: keyboard,
    );
  }
}
