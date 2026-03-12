import 'package:televerse/televerse.dart';
import 'package:lampa_server/database/database.dart' as db;

/// Template for adding a new Telegram Bot command.
/// Location: Typically integrated into source/server/lib/telegram_bot.dart
void registerCustomCommands(Bot bot) {
  // Register a new command, e.g., /status
  bot.command('status', (ctx) async {
    final telegramId = ctx.from?.id;
    if (telegramId == null) return;

    try {
      // 1. Check if user exists in the database
      // final user = await db.DataSource.instance.getUserByTelegramId(telegramId.toString());
      // if (user == null) {
      //   await ctx.reply('Пожалуйста, сначала зарегистрируйтесь с помощью команды /start');
      //   return;
      // }

      // 2. Perform business logic
      final statusMessage = 'Ваш сервер работает отлично!\nID: $telegramId';

      // 3. Reply to user (Use Russian for UI/Bot responses)
      await ctx.reply(statusMessage);
    } catch (e) {
      print('[TelegramBot] Error in /status command: $e');
      await ctx.reply('Произошла ошибка при выполнении команды.');
    }
  });

  // Example of handling inline keyboard callbacks
  bot.callbackQuery('action_name', (ctx) async {
    // Handle button click
    await ctx.answerCallbackQuery(text: 'Действие выполнено!');
  });
}
