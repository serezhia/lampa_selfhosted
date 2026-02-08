import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/telegram_bot.dart';

/// Custom entrypoint for dart_frog server
/// This starts the Telegram bot alongside the HTTP server
Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  // Start Telegram bot in background
  unawaited(TelegramBotService.instance.start());

  // Start HTTP server
  return serve(handler, ip, port);
}
