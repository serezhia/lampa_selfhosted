import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

/// GET /api/config - Публичная конфигурация для клиента
///
/// Возвращает настройки, необходимые клиенту (без секретов).
Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      body: {'error': 'Method not allowed'},
      statusCode: 405,
    );
  }

  // Читаем публичные настройки из окружения
  final telegramBotName =
      Platform.environment['TELEGRAM_BOT_NAME'] ?? '@lampa_bot';
  final baseUrl = Platform.environment['BASE_URL'] ?? '';

  return Response.json(
    body: {
      'telegram_bot': telegramBotName,
      'base_url': baseUrl,
      'version': '1.0.0',
    },
  );
}
