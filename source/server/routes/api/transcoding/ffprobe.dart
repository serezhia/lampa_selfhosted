import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';

/// GET /api/transcoding/ffprobe?media=URL
/// Analyze media file and return stream information
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final mediaUrl = context.request.uri.queryParameters['media'];

  if (mediaUrl == null || mediaUrl.isEmpty) {
    return Response.json(
      body: {'error': 'Missing media parameter'},
      statusCode: HttpStatus.badRequest,
    );
  }

  try {
    final transcoding = DataSource.instance.transcoding;
    final info = await transcoding.ffprobe(mediaUrl);

    return Response.json(body: info.toJson());
  } catch (e) {
    print('[API] FFprobe error: $e');
    return Response.json(
      body: {'error': 'Failed to analyze media: $e'},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
