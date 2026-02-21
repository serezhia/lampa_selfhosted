import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';
import 'package:lampa_server/database/database.dart' as db;
import 'package:lampa_server/services/download_service.dart';
import 'package:lampa_server/services/library_transcoding_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.delete &&
      context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final user = context.read<db.User>();

  try {
    String? id;

    // Try to get id from query params first
    id = context.request.uri.queryParameters['id'];

    // If not in query params, try body
    if (id == null) {
      final contentType = context.request.headers['content-type'] ?? '';
      if (contentType.contains('application/json')) {
        final body = await context.request.json() as Map<String, dynamic>;
        id = body['id'] as String?;
      } else if (contentType.contains('application/x-www-form-urlencoded')) {
        final rawBody = await context.request.body();
        final params = Uri.splitQueryString(rawBody);
        id = params['id'];
      }
    }

    if (id == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing required field: id'},
      );
    }

    final item = await DataSource.instance.db.getLibraryItemById(id);

    if (item == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Item not found'},
      );
    }

    if (item.userId != user.id) {
      return Response.json(
        statusCode: 403,
        body: {'error': 'Forbidden'},
      );
    }

    // Cancel active download if any
    DownloadService.instance.cancelDownload(id);

    // Cancel active transcoding if any
    LibraryTranscodingService.instance.cancelTranscoding(id);

    // Delete files from disk
    DownloadService.instance.deleteFiles(id);

    await DataSource.instance.db.deleteLibraryItem(id);

    return Response.json(
      body: {
        'success': true,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': e.toString()},
    );
  }
}
