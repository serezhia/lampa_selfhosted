import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:lampa_server/sync_player_service.dart';

/// WebSocket /syncplayer/ws
Future<Response> onRequest(RequestContext context) async {
  final uid = context.request.uri.queryParameters['uid'];

  if (uid == null || uid.isEmpty) {
    return Response.json(
      body: {'error': 'uid required'},
      statusCode: 400,
    );
  }

  if (context.request.headers['upgrade']?.toLowerCase() != 'websocket') {
    return Response.json(
      body: {'error': 'WebSocket upgrade required'},
      statusCode: 400,
    );
  }

  return webSocketHandler((channel, protocol) {
    SyncPlayerService.instance.handleConnection(channel, uid);
  })(context);
}
