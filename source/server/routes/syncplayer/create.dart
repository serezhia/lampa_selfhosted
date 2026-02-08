import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/sync_player_service.dart';

/// POST /syncplayer/create - создание комнаты
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final uid = context.request.uri.queryParameters['uid'];
  if (uid == null || uid.isEmpty) {
    return Response.json(
      body: {'error': 'uid required'},
      statusCode: 400,
    );
  }

  final room = SyncPlayerService.instance.createRoom(uid);

  return Response.json(
    body: {
      'success': true,
      'room_id': room.id,
      'is_public': room.isPublic,
    },
  );
}
