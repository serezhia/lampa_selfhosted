import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';

/// POST /api/transcoding/start
/// Start a new transcoding session
/// Body: { "src": "media_url", "audioIndex": 0, "subtitleIndex": null }
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.body();
    final json = jsonDecode(body) as Map<String, dynamic>;

    final src = json['src'] as String?;
    final audioIndex = json['audioIndex'] as int? ?? 0;
    final subtitleIndex = json['subtitleIndex'] as int?;
    final duration = (json['duration'] as num?)?.toDouble();

    if (src == null || src.isEmpty) {
      return Response.json(
        body: {'error': 'Missing src parameter'},
        statusCode: HttpStatus.badRequest,
      );
    }

    print('[API] Starting transcoding for: $src');
    print('[API] Audio index: $audioIndex, Subtitle index: $subtitleIndex');

    final transcoding = DataSource.instance.transcoding;
    final session = await transcoding.startSession(
      sourceUrl: src,
      audioIndex: audioIndex,
      subtitleIndex: subtitleIndex,
      duration: duration,
    );

    final response = <String, dynamic>{
      'streamId': session.streamId,
      'playlistUrl': transcoding.getPlaylistUrl(session.streamId),
    };

    if (session.duration != null) {
      response['duration'] = session.duration;
    }

    if (subtitleIndex != null) {
      response['subtitlesUrl'] = transcoding.getSubtitlesUrl(session.streamId);
    }

    return Response.json(body: response);
  } catch (e) {
    print('[API] Start transcoding error: $e');
    return Response.json(
      body: {'error': 'Failed to start transcoding: $e'},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
