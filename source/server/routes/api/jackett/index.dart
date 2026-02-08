import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';

/// Прокси для Jackett API
/// Валидирует deviceToken и проксирует запрос в Jackett с реальным API ключом
///
/// URL формат: /api/jackett?apikey={deviceToken}&Query=...
///
/// Запрос проксируется в Jackett с заменой apikey на реальный ключ
Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;

  // Получаем deviceToken из параметра apikey
  final queryParams = context.request.uri.queryParameters;
  final deviceToken = queryParams['apikey'];

  if (deviceToken == null || deviceToken.isEmpty) {
    print('[JACKETT_PROXY] Missing apikey (deviceToken)');
    return Response.json(
      statusCode: 401,
      body: {'error': 'Unauthorized: Missing API key'},
    );
  }

  // Валидируем deviceToken
  try {
    final device = await DataSource.instance.getDeviceByToken(deviceToken);

    if (device == null) {
      print('[JACKETT_PROXY] Invalid deviceToken: $deviceToken');
      return Response.json(
        statusCode: 403,
        body: {'error': 'Forbidden: Invalid API key'},
      );
    }

    // Обновляем lastSeen
    await DataSource.instance.updateDeviceLastSeen(device.id);

    // Получаем реальный API ключ Jackett
    final jackettApiKey = Platform.environment['JACKETT_API_KEY'] ?? '';
    final jackettHost = Platform.environment['JACKETT_HOST'] ?? 'jackett';
    final jackettPort = Platform.environment['JACKETT_PORT'] ?? '9117';

    if (jackettApiKey.isEmpty) {
      print('[JACKETT_PROXY] JACKETT_API_KEY not configured');
      return Response.json(
        statusCode: 500,
        body: {'error': 'Server Error: Jackett not configured'},
      );
    }

    // Строим URL для Jackett с реальным apikey
    final newParams = Map<String, String>.from(queryParams);
    newParams['apikey'] = jackettApiKey;

    // Извлекаем путь после /api/jackett
    final pathSuffix =
        context.request.uri.path.replaceFirst('/api/jackett', '');
    final jackettPath =
        pathSuffix.isEmpty ? '/api/v2.0/indexers/all/results' : pathSuffix;

    final jackettUri = Uri.http(
      '$jackettHost:$jackettPort',
      jackettPath,
      newParams,
    );

    print('[JACKETT_PROXY] Proxying to: $jackettUri');

    // Проксируем запрос
    final client = HttpClient();
    try {
      final request = await client.openUrl(method.value, jackettUri);

      // Копируем заголовки (кроме host)
      context.request.headers.forEach((name, value) {
        if (name.toLowerCase() != 'host' &&
            name.toLowerCase() != 'content-length') {
          request.headers.add(name, value);
        }
      });

      // Для POST/PUT запросов передаём body
      if (method == HttpMethod.post || method == HttpMethod.put) {
        final body = await context.request.body();
        request.headers.contentLength = body.length;
        request.write(body);
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      // Формируем заголовки ответа
      final responseHeaders = <String, String>{};
      response.headers.forEach((name, values) {
        if (name.toLowerCase() != 'transfer-encoding') {
          responseHeaders[name] = values.join(', ');
        }
      });

      print('[JACKETT_PROXY] Response status: ${response.statusCode}');

      return Response(
        statusCode: response.statusCode,
        headers: responseHeaders,
        body: responseBody,
      );
    } finally {
      client.close();
    }
  } catch (e, stack) {
    print('[JACKETT_PROXY] Error: $e');
    print('[JACKETT_PROXY] Stack: $stack');
    return Response.json(
      statusCode: 500,
      body: {'error': 'Proxy Error: $e'},
    );
  }
}
