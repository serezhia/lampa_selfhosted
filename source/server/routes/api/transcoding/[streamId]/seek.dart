import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';

/// POST /api/transcoding/[streamId]/seek
/// Seek to a specific time position, triggering FFmpeg restart if needed
/// Body: { "time": 125.5 }
Future<Response> onRequest(RequestContext context, String streamId) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.body();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final time = (json['time'] as num?)?.toDouble() ?? 0;

    final transcoding = DataSource.instance.transcoding;
    final session = transcoding.getSession(streamId);

    if (session == null) {
      return Response.json(
        body: {'error': 'Session not found'},
        statusCode: HttpStatus.notFound,
      );
    }

    final segmentNumber = session.getSegmentForTime(time);
    print('[API] Seek to time $time (segment $segmentNumber)');

    final ready = await transcoding.seekToSegment(streamId, segmentNumber);

    return Response.json(
      body: {
        'success': true,
        'segment': segmentNumber,
        'ready': ready,
      },
    );
  } catch (e) {
    print('[API] Seek error: $e');
    return Response.json(
      body: {'error': 'Seek failed: $e'},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
