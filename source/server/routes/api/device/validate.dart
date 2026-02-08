import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';

/// Endpoint для валидации deviceToken
/// Используется nginx для проверки токена перед проксированием в Jackett
///
/// Входные данные (headers):
/// - X-Device-Token: токен устройства для проверки
///
/// Возвращает:
/// - 200 + X-Jackett-ApiKey header: токен валиден
/// - 401: токен отсутствует
/// - 403: токен невалиден
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  // Получаем токен из заголовка (nginx передаёт его из query string apikey)
  final deviceToken = context.request.headers['x-device-token'] ??
      context.request.uri.queryParameters['apikey'];

  if (deviceToken == null || deviceToken.isEmpty) {
    print('[VALIDATE] Missing device token');
    return Response(statusCode: 401, body: 'Unauthorized: Missing Token');
  }

  try {
    // Проверяем существует ли устройство с таким токеном
    final device = await DataSource.instance.getDeviceByToken(deviceToken);

    if (device == null) {
      print('[VALIDATE] Invalid device token: $deviceToken');
      return Response(statusCode: 403, body: 'Forbidden: Invalid Token');
    }

    // Обновляем lastSeen для устройства
    await DataSource.instance.updateDeviceLastSeen(device.id);

    // Получаем реальный API ключ Jackett из переменных окружения
    final jackettApiKey = Platform.environment['JACKETT_API_KEY'] ?? '';

    if (jackettApiKey.isEmpty) {
      print('[VALIDATE] JACKETT_API_KEY not configured');
      return Response(
        statusCode: 500,
        body: 'Server Error: Jackett API key not configured',
      );
    }

    print('[VALIDATE] Token valid for device: ${device.id}');

    // Возвращаем реальный API key в заголовке
    return Response(
      headers: {
        'X-Jackett-ApiKey': jackettApiKey,
        'X-Device-Id': device.id,
        'X-User-Id': device.userId,
      },
      body: 'OK',
    );
  } catch (e) {
    print('[VALIDATE] Error: $e');
    return Response(statusCode: 500, body: 'Server Error');
  }
}
