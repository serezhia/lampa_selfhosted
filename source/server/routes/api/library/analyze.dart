import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:lampa_server/data_source.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final magnetUri = body['magnet_uri'] as String?;
    final type = body['type'] as String?;
    final season = body['season'] as int?;
    final episode = body['episode'] as int?;
    final providedFileIndex = body['file_index'] as int?;

    if (magnetUri == null || magnetUri.isEmpty) {
      return Response.json(
        body: {'error': 'Missing magnet_uri'},
        statusCode: HttpStatus.badRequest,
      );
    }

    const torrServerUrl = 'http://torrserver:8090';

    // 1. Add torrent to TorrServer
    final addResponse = await http.post(
      Uri.parse('$torrServerUrl/torrents'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'action': 'add',
        'link': magnetUri,
        'save_to_db': true,
      }),
    );

    if (addResponse.statusCode != 200) {
      throw Exception('Failed to add torrent to TorrServer');
    }

    final addData = jsonDecode(addResponse.body) as Map<String, dynamic>;
    final hash = addData['hash'] as String?;

    if (hash == null) {
      throw Exception('No hash returned from TorrServer');
    }

    // 2. Wait for metadata
    Map<String, dynamic>? torrentInfo;
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(const Duration(seconds: 2));

      final getResponse = await http.post(
        Uri.parse('$torrServerUrl/torrents'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'get',
          'hash': hash,
        }),
      );

      if (getResponse.statusCode == 200) {
        final decoded = jsonDecode(getResponse.body);
        List<dynamic>? torrents;
        if (decoded is List) {
          torrents = decoded;
        } else if (decoded is Map<String, dynamic>) {
          torrents = [decoded];
        }

        if (torrents != null && torrents.isNotEmpty) {
          final t = torrents.first as Map<String, dynamic>;
          if (t['file_stats'] != null && (t['file_stats'] as List).isNotEmpty) {
            torrentInfo = t;
            break;
          }
        }
      }
    }

    if (torrentInfo == null) {
      throw Exception('Failed to get torrent metadata from TorrServer');
    }

    // 3. Find file index
    final fileStats = torrentInfo['file_stats'] as List<dynamic>;
    var fileIndex = providedFileIndex ?? 1;
    var fileSize = 0;

    if (providedFileIndex == null) {
      if (type == 'movie') {
        for (final f in fileStats) {
          final stat = f as Map<String, dynamic>;
          final length = stat['length'] as int? ?? 0;
          if (length > fileSize) {
            fileSize = length;
            fileIndex = stat['id'] as int? ?? 1;
          }
        }
      } else if (type == 'tv') {
        final s = season?.toString().padLeft(2, '0');
        final e = episode?.toString().padLeft(2, '0');
        var found = false;

        for (final f in fileStats) {
          final stat = f as Map<String, dynamic>;
          final path = (stat['path'] as String? ?? '').toLowerCase();

          if (s != null && e != null) {
            if (path.contains('s$s') && path.contains('e$e') ||
                path.contains('s${s}e$e') ||
                path.contains('${s}x$e')) {
              fileIndex = stat['id'] as int? ?? 1;
              fileSize = stat['length'] as int? ?? 0;
              found = true;
              break;
            }
          }
        }

        if (!found) {
          for (final f in fileStats) {
            final stat = f as Map<String, dynamic>;
            final length = stat['length'] as int? ?? 0;
            if (length > fileSize) {
              fileSize = length;
              fileIndex = stat['id'] as int? ?? 1;
            }
          }
        }
      }
    }

    // 4. Construct stream URL and run ffprobe
    final streamUrl =
        '$torrServerUrl/stream?link=${Uri.encodeComponent(magnetUri)}&index=$fileIndex&play=true';

    final transcoding = DataSource.instance.transcoding;
    final info = await transcoding.ffprobe(streamUrl);

    return Response.json(body: info.toJson());
  } catch (e) {
    print('[API] Analyze error: $e');
    return Response.json(
      body: {'error': 'Failed to analyze media: $e'},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
