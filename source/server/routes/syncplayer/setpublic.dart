import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/sync_player_service.dart';

/// POST /syncplayer/setpublic - изменение видимости комнаты
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final params = context.request.uri.queryParameters;
  final uid = params['uid'];
  final roomId = params['roomId'];
  final isPublicStr = params['isPublic'];

  if (uid == null || roomId == null || isPublicStr == null) {
    return Response.json(
      body: {'error': 'uid, roomId, isPublic required'},
      statusCode: 400,
    );
  }

  final isPublic = isPublicStr == 'true';
  final success = SyncPlayerService.instance.setRoomPublic(
    roomId,
    uid,
    isPublic: isPublic,
  );

  if (!success) {
    return Response.json(
      body: {'error': 'Not allowed or room not found'},
      statusCode: 403,
    );
  }

  return Response.json(
    body: {
      'success': true,
      'is_public': isPublic,
    },
  );
}
