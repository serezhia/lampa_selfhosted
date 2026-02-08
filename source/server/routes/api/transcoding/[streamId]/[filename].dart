import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';

/// GET /api/transcoding/[streamId]/playlist.m3u8
/// GET /api/transcoding/[streamId]/segment_XXX.ts
/// GET /api/transcoding/[streamId]/subtitles.vtt
/// Serve HLS playlist and segments
Future<Response> onRequest(
  RequestContext context,
  String streamId,
  String filename,
) async {
  if (context.request.method != HttpMethod.get) {
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

  // Determine file path
  String filePath;
  String contentType;

  if (filename == 'playlist.m3u8' || filename.endsWith('.m3u8')) {
    filePath = session.playlistPath;
    contentType = 'application/vnd.apple.mpegurl';
  } else if (filename.endsWith('.ts')) {
    filePath = '${session.outputDir}/$filename';
    contentType = 'video/mp2t';
  } else if (filename == 'subtitles.vtt' || filename.endsWith('.vtt')) {
    filePath = session.subtitlesPath;
    contentType = 'text/vtt';
  } else {
    return Response.json(
      body: {'error': 'Unknown file type'},
      statusCode: HttpStatus.badRequest,
    );
  }

  final file = File(filePath);
  if (!file.existsSync()) {
    return Response.json(
      body: {'error': 'File not found'},
      statusCode: HttpStatus.notFound,
    );
  }

  // Update heartbeat on file access
  transcoding.heartbeat(streamId);

  final bytes = file.readAsBytesSync();

  return Response.bytes(
    body: bytes,
    headers: {
      'Content-Type': contentType,
      'Access-Control-Allow-Origin': '*',
      'Cache-Control': 'no-cache',
    },
  );
}
