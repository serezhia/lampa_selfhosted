import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';

/// POST /api/transcoding/[streamId]/heartbeat
/// Keep the transcoding session alive
Future<Response> onRequest(RequestContext context, String streamId) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final transcoding = DataSource.instance.transcoding;
  final session = transcoding.getSession(streamId);

  if (session == null) {
    return Response.json(
      body: {'error': 'Session not found'},
      statusCode: HttpStatus.notFound,
    );
  }

  transcoding.heartbeat(streamId);

  return Response.json(body: {'status': 'ok'});
}
