import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/sync_player_service.dart';

/// GET /syncplayer/rooms - список публичных комнат
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final rooms = SyncPlayerService.instance.getPublicRooms();

  return Response.json(
    body: {
      'success': true,
      'rooms': rooms.map((r) => r.toJson()).toList(),
    },
  );
}
