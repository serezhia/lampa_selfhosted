import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:path/path.dart' as p;

Future<Response> onRequest(
  RequestContext context,
  String id,
  String path,
) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  const hlsDir = '/app/library/hls';
  final filePath = p.join(hlsDir, id, path);

  final file = File(filePath);
  if (!file.existsSync()) {
    return Response(statusCode: 404, body: 'File not found');
  }

  final ext = p.extension(filePath).toLowerCase();
  var contentType = 'application/octet-stream';

  if (ext == '.m3u8') {
    contentType = 'application/vnd.apple.mpegurl';
  } else if (ext == '.ts') {
    contentType = 'video/mp2t';
  }

  return Response.bytes(
    body: file.readAsBytesSync(),
    headers: {
      'Content-Type': contentType,
      'Access-Control-Allow-Origin': '*',
    },
  );
}
