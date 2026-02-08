import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:lampa_server/socket_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.headers['upgrade']?.toLowerCase() == 'websocket') {
    return webSocketHandler((channel, protocol) {
      SocketService.instance.handleConnection(channel);
    })(context);
  }

  return Response(body: 'Lampa Self-Hosted Server Active. Use API endpoints.');
}
