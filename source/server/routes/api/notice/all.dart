import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';

/// GET /api/notice/all
/// Возвращает список активных уведомлений в формате Lampa
/// Публичный endpoint (без авторизации)
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  try {
    final notices = await DataSource.instance.getNoticesForApi();

    return Response.json(
      body: {
        'secuses': true,
        'notice': notices,
      },
    );
  } catch (e) {
    print('[NOTICE/ALL] Error: $e');
    return Response.json(
      body: {
        'secuses': false,
        'notice': <dynamic>[],
      },
    );
  }
}
