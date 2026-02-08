import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';

/// POST /api/transcoding/[streamId]/stop
/// Stop a transcoding session
Future<Response> onRequest(RequestContext context, String streamId) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  print('[API] Stopping transcoding session: $streamId');

  final transcoding = DataSource.instance.transcoding;
  await transcoding.stopSession(streamId);

  return Response.json(body: {'status': 'stopped'});
}
