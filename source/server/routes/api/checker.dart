import 'package:dart_frog/dart_frog.dart';

/// Эндпоинт /api/checker
///
/// Lampa использует этот эндпоинт для проверки доступности сервера.
/// Клиент отправляет POST с timestamp (double) в body, сервер возвращает его обратно.
Future<Response> onRequest(RequestContext context) async {
  // Стандартные заголовки как у оригинального CUB
  final headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, PUT, POST, DELETE, OPTIONS',
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    'Pragma': 'no-cache',
    'Expires': '0',
    'Content-Type': 'text/html; charset=utf-8',
  };

  // CORS preflight
  if (context.request.method == HttpMethod.options) {
    return Response(headers: headers);
  }

  // Читаем body - там просто double число как текст
  final body = await context.request.body();

  // Возвращаем то же самое число
  return Response(
    body: body,
    headers: headers,
  );
}
