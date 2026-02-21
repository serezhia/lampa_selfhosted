import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/services/download_service.dart';
import 'package:lampa_server/services/library_transcoding_service.dart';
import 'package:lampa_server/telegram_bot.dart';

/// Custom entrypoint for dart_frog server
/// This starts the Telegram bot alongside the HTTP server
Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  // Start Telegram bot in background
  unawaited(TelegramBotService.instance.start());

  // Initialize Download Service
  DownloadService.instance.init();

  // Initialize Library Transcoding Service
  LibraryTranscodingService.instance.init();

  // Start HTTP server
  return serve(handler, ip, port);
}
