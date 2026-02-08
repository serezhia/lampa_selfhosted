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
    // Prefer VOD playlist (pre-generated with all segments) over FFmpeg's
    final vodFile = File(session.vodPlaylistPath);
    if (vodFile.existsSync()) {
      filePath = session.vodPlaylistPath;
    } else {
      filePath = session.playlistPath;
    }
    contentType = 'application/vnd.apple.mpegurl';
  } else if (filename.endsWith('.ts')) {
    // Extract segment number from filename (segment_XXX.ts)
    final match = RegExp(r'segment_(\d+)\.ts').firstMatch(filename);
    if (match == null) {
      return Response.json(
        body: {'error': 'Invalid segment filename'},
        statusCode: HttpStatus.badRequest,
      );
    }

    final segmentNumber = int.parse(match.group(1)!);
    filePath = '${session.outputDir}/$filename';
    contentType = 'video/mp2t';

    // Check if segment exists, if not - trigger seek and wait
    var segmentFile = File(filePath);
    if (!segmentFile.existsSync()) {
      print('[API] Segment $segmentNumber not ready, triggering seek');
      final ready = await transcoding.seekToSegment(streamId, segmentNumber);
      if (!ready) {
        print('[API] Segment $segmentNumber seek failed');
        return Response.json(
          body: {'error': 'Segment not ready', 'segment': segmentNumber},
          statusCode: HttpStatus.serviceUnavailable,
        );
      }
    }

    // Wait for segment file to actually exist (max 60 seconds)
    // seekToSegment may return true when FFmpeg is generating nearby
    const maxWait = Duration(seconds: 60);
    const checkInterval = Duration(milliseconds: 200);
    final deadline = DateTime.now().add(maxWait);

    while (!segmentFile.existsSync() && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(checkInterval);
    }

    if (!segmentFile.existsSync()) {
      print('[API] Segment $segmentNumber timeout waiting for file');
      return Response.json(
        body: {'error': 'Segment generation timeout', 'segment': segmentNumber},
        statusCode: HttpStatus.serviceUnavailable,
      );
    }

    print('[API] Serving segment $segmentNumber');
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
