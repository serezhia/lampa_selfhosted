// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:lampa_server/database/database.dart';
import 'package:lampa_server/services/transcoding_service.dart';

/// Источник данных для приложения (Singleton)
/// Обёртка над Drift базой данных
class DataSource {
  DataSource._() {
    _db = AppDatabase();
    _initServices();
  }

  static final DataSource instance = DataSource._();

  late final AppDatabase _db;
  late final TranscodingService _transcoding;

  AppDatabase get db => _db;
  TranscodingService get transcoding => _transcoding;

  /// Инициализация сервисов
  Future<void> _initServices() async {
    final baseUrl = Platform.environment['BASE_URL'] ?? 'http://localhost:8080';
    final transcodingDir =
        Platform.environment['TRANSCODING_DIR'] ?? '/app/transcoding';

    // Initialize transcoding service
    _transcoding = TranscodingService(
      outputDir: transcodingDir,
      baseUrl: baseUrl,
    );
  }

  // ============= Временные коды для авторизации =============

  final Map<String, _TempCode> _tempCodes = {};
  final Map<String, List<Device>> _pendingRemovals = {};
  final Map<String, String> _pendingRenames = {};
  final Map<String, int> _pendingProfileRenames = {};
  final Map<String, int> _pendingProfileEdits = {};

  String generateTempCode(String userId) {
    _tempCodes.removeWhere((_, v) => v.userId == userId);

    final random = Random.secure();
    String code;
    do {
      code = (100000 + random.nextInt(900000)).toString();
    } while (_tempCodes.containsKey(code));

    _tempCodes[code] = _TempCode(
      userId: userId,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );

    return code;
  }

  Future<User?> findUserByCode(String code) async {
    final tempCode = _tempCodes[code];
    if (tempCode != null) {
      if (DateTime.now().isBefore(tempCode.expiresAt)) {
        _tempCodes.remove(code);
        return _db.getUserById(tempCode.userId);
      } else {
        _tempCodes.remove(code);
        return null;
      }
    }

    return null;
  }

  // ============= User methods =============

  Future<User?> findUserByTelegramId(String telegramId) =>
      _db.getUserByTelegramId(telegramId);

  Future<User> createUserFromContact({
    required String telegramId,
    required String phone,
    String? firstName,
    String? lastName,
  }) async {
    final existingUser = await findUserByTelegramId(telegramId);
    if (existingUser != null) return existingUser;

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final emailPhone = cleanPhone.startsWith('+') ? cleanPhone : '+$cleanPhone';

    final newUser = await _db.insertUser(
      UsersCompanion(
        id: Value('tg_$telegramId'),
        email: Value(emailPhone),
        passwordHash: const Value(''),
        premium: Value(
          DateTime.now()
              .add(const Duration(days: 36500))
              .millisecondsSinceEpoch,
        ),
        createdAt: Value(DateTime.now()),
        telegramId: Value(telegramId),
        phone: Value(cleanPhone),
        firstName: Value(firstName),
        lastName: Value(lastName),
      ),
    );

    final profileName = firstName ?? 'Watch';
    await _db.insertProfile(
      ProfilesCompanion(
        userId: Value(newUser.id),
        name: Value(profileName),
        icon: const Value('l_1'),
        main: const Value(true),
      ),
    );

    return newUser;
  }

  Future<bool> isUserRegistered(String telegramId) async =>
      (await findUserByTelegramId(telegramId)) != null;

  // ============= Device methods =============

  Future<List<Device>> getUserDevices(String userId) =>
      _db.getDevicesByUserId(userId);

  Future<Device?> getDeviceByToken(String token) => _db.getDeviceByToken(token);

  Future<void> addDevice(Device device) async {
    await _db.insertDevice(
      DevicesCompanion(
        id: Value(device.id),
        userId: Value(device.userId),
        name: Value(device.name),
        platform: Value(device.platform),
        token: Value(device.token),
      ),
    );
  }

  Future<void> removeDevice(String deviceId) => _db.deleteDevice(deviceId);

  Future<void> renameDevice(String deviceId, String newName) async {
    final device = await _db.getDeviceById(deviceId);
    if (device != null) {
      await _db.updateDevice(device.copyWith(name: newName));
    }
  }

  Future<void> updateDeviceLastSeen(String deviceId) =>
      _db.updateDeviceLastSeen(deviceId);

  void setPendingRemoval(String telegramUserId, List<Device> devicesList) {
    _pendingRemovals[telegramUserId] = devicesList;
  }

  List<Device>? getPendingRemoval(String telegramUserId) =>
      _pendingRemovals[telegramUserId];

  void clearPendingRemoval(String telegramUserId) {
    _pendingRemovals.remove(telegramUserId);
  }

  void setPendingRename(String telegramUserId, String deviceId) {
    _pendingRenames[telegramUserId] = deviceId;
  }

  String? getPendingRename(String telegramUserId) =>
      _pendingRenames[telegramUserId];

  void clearPendingRename(String telegramUserId) {
    _pendingRenames.remove(telegramUserId);
  }

  // ============= Profile pending methods =============

  void setPendingProfileRename(String telegramUserId, int profileId) {
    _pendingProfileRenames[telegramUserId] = profileId;
  }

  int? getPendingProfileRename(String telegramUserId) =>
      _pendingProfileRenames[telegramUserId];

  void clearPendingProfileRename(String telegramUserId) {
    _pendingProfileRenames.remove(telegramUserId);
  }

  void setPendingProfileEdit(String telegramUserId, int profileId) {
    _pendingProfileEdits[telegramUserId] = profileId;
  }

  int? getPendingProfileEdit(String telegramUserId) =>
      _pendingProfileEdits[telegramUserId];

  void clearPendingProfileEdit(String telegramUserId) {
    _pendingProfileEdits.remove(telegramUserId);
  }

  void clearAllPendingStates(String telegramUserId) {
    clearPendingRemoval(telegramUserId);
    clearPendingRename(telegramUserId);
    clearPendingProfileRename(telegramUserId);
    clearPendingProfileEdit(telegramUserId);
    clearPendingNoticeCreation(telegramUserId);
  }

  // ============= Profile methods =============

  Future<List<Profile>> getProfilesForUser(String userId) =>
      _db.getProfilesByUserId(userId);

  Future<Profile?> getMainProfile(String userId) => _db.getMainProfile(userId);

  Future<Profile?> getProfileById(int id) => _db.getProfileById(id);

  Future<Profile> createProfile(String userId, String name) async {
    final profiles = await _db.getProfilesByUserId(userId);
    final iconNum = (profiles.length % 8) + 1;

    return _db.insertProfile(
      ProfilesCompanion(
        userId: Value(userId),
        name: Value(name),
        icon: Value('l_$iconNum'),
      ),
    );
  }

  /// Обновляет профиль
  Future<void> updateProfile(Profile profile) => _db.updateProfile(profile);

  /// Удаляет профиль и все связанные данные
  Future<void> deleteProfile(int profileId) async {
    // Удаляем связанные данные
    await _db.deleteBookmarksByProfileId(profileId);
    await _db.deleteTimelineByProfileId(profileId);
    await _db.deleteBookmarkChangesByProfileId(profileId);
    await _db.deleteProfileVersion(profileId);
    // Удаляем сам профиль
    await _db.deleteProfile(profileId);
  }

  // ============= Bookmark methods =============

  Future<List<Bookmark>> getBookmarks(int profileId) =>
      _db.getBookmarksByProfileId(profileId);

  Future<Bookmark> addBookmark(int profileId, Map<String, dynamic> data) async {
    final cardIdVal = data['card_id'];
    final cardId =
        cardIdVal is int ? cardIdVal : int.tryParse(cardIdVal.toString()) ?? 0;

    final typeVal = data['type'];
    final type = (typeVal != null && typeVal.toString() != 'null')
        ? typeVal.toString()
        : 'like';

    final dataVal = data['data'];
    final dataStr =
        dataVal is String ? dataVal : jsonEncode(dataVal as Map? ?? {});

    final now = DateTime.now().millisecondsSinceEpoch;

    final bookmark = await _db.insertBookmark(
      BookmarksCompanion(
        profileId: Value(profileId),
        type: Value(type),
        cardId: Value(cardId),
        data: Value(dataStr),
        time: Value(now),
      ),
    );

    // Update version and add change
    final version = await _db.incrementBookmarkVersion(profileId);
    await _db.insertBookmarkChange(
      BookmarkChangesCompanion(
        profileId: Value(profileId),
        version: Value(version),
        action: const Value('add'),
        entityId: Value(bookmark.id),
        type: Value(type),
        cardId: Value(cardId),
        data: Value(dataStr),
        time: Value(now),
      ),
    );

    return bookmark;
  }

  Future<void> removeBookmark(int profileId, int cardId, String type) async {
    final bookmark =
        await _db.getBookmarkByProfileTypeCard(profileId, type, cardId);
    if (bookmark == null) return;

    await _db.deleteBookmark(bookmark.id);

    final version = await _db.incrementBookmarkVersion(profileId);
    await _db.insertBookmarkChange(
      BookmarkChangesCompanion(
        profileId: Value(profileId),
        version: Value(version),
        action: const Value('remove'),
        entityId: Value(bookmark.id),
        time: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<int> getBookmarkVersion(int profileId) async {
    final pv = await _db.getProfileVersion(profileId);
    return pv?.bookmarkVersion ?? 0;
  }

  Future<List<BookmarkChange>> getBookmarkChanges(
    int profileId,
    int sinceVersion,
  ) =>
      _db.getBookmarkChanges(profileId, sinceVersion);

  // ============= Timeline methods =============

  Future<Map<String, TimelineEntry>> getTimeline(int profileId) async {
    final entries = await _db.getTimelineByProfileId(profileId);
    return {for (final e in entries) e.hash: e};
  }

  Future<void> updateTimeline(
    int profileId,
    String hash,
    Map<String, dynamic> data,
  ) async {
    await _db.upsertTimelineEntry(
      TimelineEntriesCompanion(
        profileId: Value(profileId),
        hash: Value(hash),
        percent: Value((data['percent'] as num?)?.toDouble() ?? 0),
        time: Value((data['time'] as num?)?.toDouble() ?? 0),
        duration: Value((data['duration'] as num?)?.toDouble() ?? 0),
        updatedAt: Value(DateTime.now()),
      ),
    );

    await _db.incrementTimelineVersion(profileId);
  }

  Future<int> getTimelineVersion(int profileId) async {
    final pv = await _db.getProfileVersion(profileId);
    return pv?.timelineVersion ?? 0;
  }

  // ============= Admin & Notice methods =============

  /// Получить список телефонов администраторов из окружения
  static List<String> get adminPhones {
    final envPhones = Platform.environment['TELEGRAM_ADMIN_PHONES'] ?? '';
    if (envPhones.isEmpty) return [];
    return envPhones
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  /// Проверка, является ли пользователь администратором
  Future<bool> isAdmin(String telegramId) async {
    final phones = adminPhones;
    if (phones.isEmpty) return false;

    final user = await findUserByTelegramId(telegramId);
    if (user == null || user.phone == null) return false;
    final phone = user.phone!.replaceAll(RegExp(r'[^\d]'), '');
    return phones.any(
      (admin) => admin.replaceAll(RegExp(r'[^\d]'), '') == phone,
    );
  }

  /// Получить все уведомления (для админки)
  Future<List<Notice>> getAllNotices() => _db.getAllNotices();

  /// Получить активные уведомления (для API)
  Future<List<Notice>> getActiveNotices() => _db.getActiveNotices();

  /// Получить уведомление по ID
  Future<Notice?> getNoticeById(int id) => _db.getNoticeById(id);

  /// Создать уведомление
  Future<Notice> createNotice({
    required String type,
    String? title,
    String? text,
    String? image,
    String? data,
    DateTime? expiresAt,
  }) {
    return _db.insertNotice(
      NoticesCompanion(
        noticeType: Value(type),
        title: Value(title),
        noticeText: Value(text),
        image: Value(image),
        data: Value(data),
        expiresAt: Value(expiresAt),
      ),
    );
  }

  /// Обновить уведомление
  Future<void> updateNotice(Notice notice) => _db.updateNotice(notice);

  /// Удалить уведомление
  Future<void> deleteNotice(int id) => _db.deleteNotice(id);

  /// Включить/выключить уведомление
  Future<void> toggleNoticeActive(int id, {required bool active}) =>
      _db.toggleNoticeActive(id, active: active);

  /// Форматировать уведомления для Lampa API (/notice/all)
  /// Возвращает список в формате, ожидаемом клиентом Lampa
  Future<List<Map<String, dynamic>>> getNoticesForApi() async {
    final notices = await getActiveNotices();
    return notices.map((n) {
      if (n.noticeType == 'card' && n.data != null) {
        // Card-type: data содержит полную структуру для Lampa
        return {
          'data': n.data,
          'time': n.createdAt.millisecondsSinceEpoch,
          'date': n.createdAt.toIso8601String(),
          'viewed': false,
        };
      } else {
        // Simple-type: формируем структуру с произвольным контентом
        final cardData = {
          'card': {
            'title': n.title ?? '',
            'name': n.title ?? '',
            'poster': n.image,
            'img': n.image,
          },
          'type': 'notice',
          'text': n.noticeText ?? '',
        };
        return {
          'data': jsonEncode(cardData),
          'time': n.createdAt.millisecondsSinceEpoch,
          'date': n.createdAt.toIso8601String(),
          'viewed': false,
        };
      }
    }).toList();
  }

  // Pending states for notice creation in Telegram bot
  final Map<String, Map<String, dynamic>> _pendingNoticeCreation = {};

  void setPendingNoticeCreation(
    String telegramUserId,
    Map<String, dynamic> state,
  ) {
    _pendingNoticeCreation[telegramUserId] = state;
  }

  Map<String, dynamic>? getPendingNoticeCreation(String telegramUserId) =>
      _pendingNoticeCreation[telegramUserId];

  void clearPendingNoticeCreation(String telegramUserId) {
    _pendingNoticeCreation.remove(telegramUserId);
  }

  // ============= Legacy compatibility =============
  // Эти свойства нужны для обратной совместимости с существующим кодом

  List<User> get users => throw UnimplementedError('Use async methods');
  List<Profile> get profiles => throw UnimplementedError('Use async methods');
  List<Device> get devices => throw UnimplementedError('Use async methods');
}

class _TempCode {
  _TempCode({required this.userId, required this.expiresAt});

  final String userId;
  final DateTime expiresAt;
}
