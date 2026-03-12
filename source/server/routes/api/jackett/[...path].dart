import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';

/// Прокси для Jacred API - обработка всех вложенных путей (совместим с Jackett)
/// /api/jackett/[...] -> http://jacred:9117/[...]
///
/// Параметр [path] - все части пути после /api/jackett/
Future<Response> onRequest(RequestContext context, String path) async {
  final method = context.request.method;

  // Получаем deviceToken из параметра apikey
  final queryParams = context.request.uri.queryParameters;
  final deviceToken = queryParams['apikey'];

  if (deviceToken == null || deviceToken.isEmpty) {
    print('[JACRED_PROXY] Missing apikey (deviceToken)');
    return Response.json(
      statusCode: 401,
      body: {'error': 'Unauthorized: Missing API key'},
    );
  }

  // Валидируем deviceToken
  try {
    final device = await DataSource.instance.getDeviceByToken(deviceToken);

    if (device == null) {
      print('[JACRED_PROXY] Invalid deviceToken: $deviceToken');
      return Response.json(
        statusCode: 403,
        body: {'error': 'Forbidden: Invalid API key'},
      );
    }

    // Обновляем lastSeen
    await DataSource.instance.updateDeviceLastSeen(device.id);

    // Получаем реальный API ключ Jacred
    final jacredApiKey = Platform.environment['JACRED_API_KEY'] ?? '';
    final jacredHost = Platform.environment['JACRED_HOST'] ?? 'jacred';
    final jacredPort = Platform.environment['JACRED_PORT'] ?? '9117';

    if (jacredApiKey.isEmpty) {
      print('[JACRED_PROXY] JACRED_API_KEY not configured');
      return Response.json(
        statusCode: 500,
        body: {'error': 'Server Error: Jacred not configured'},
      );
    }

    // Строим URL для Jacred с реальным apikey
    final newParams = Map<String, String>.from(queryParams);
    newParams['apikey'] = jacredApiKey;

    // path содержит остаток пути после /api/jackett/
    final jacredPath = '/$path';

    final jacredUri = Uri.http(
      '$jacredHost:$jacredPort',
      jacredPath,
      newParams,
    );

    print('[JACRED_PROXY] Proxying to: $jacredUri');

    // Проксируем запрос
    final client = HttpClient();
    try {
      final request = await client.openUrl(method.value, jacredUri);

      // Копируем заголовки (кроме host, content-length, accept-encoding)
      // Важно: не передаём accept-encoding чтобы не получить сжатый ответ
      context.request.headers.forEach((name, value) {
        final lowerName = name.toLowerCase();
        if (lowerName != 'host' &&
            lowerName != 'content-length' &&
            lowerName != 'accept-encoding') {
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

      // Формируем заголовки ответа (исключаем transfer-encoding и content-encoding,
      // т.к. мы уже декодировали ответ)
      final responseHeaders = <String, String>{};
      response.headers.forEach((name, values) {
        final lowerName = name.toLowerCase();
        if (lowerName != 'transfer-encoding' &&
            lowerName != 'content-encoding') {
          responseHeaders[name] = values.join(', ');
        }
      });

      print('[JACRED_PROXY] Response status: ${response.statusCode}');

      return Response(
        statusCode: response.statusCode,
        headers: responseHeaders,
        body: responseBody,
      );
    } finally {
      client.close();
    }
  } catch (e, stack) {
    print('[JACRED_PROXY] Error: $e');
    print('[JACRED_PROXY] Stack: $stack');
    return Response.json(
      statusCode: 500,
      body: {'error': 'Proxy Error: $e'},
    );
  }
}
