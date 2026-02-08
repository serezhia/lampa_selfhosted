import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';
import 'package:lampa_server/database/database.dart' as db;

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final user = context.read<db.User>();
  final device = context.read<db.Device>();

  // Update device last seen timestamp
  await DataSource.instance.updateDeviceLastSeen(device.id);

  final profiles = await DataSource.instance.getProfilesForUser(user.id);

  return Response.json(
    body: {
      'secuses': true, // Lampa likely expects this specific typo/field
      'profiles': profiles.map((p) {
        return {
          'id': p.id,
          'user_id': p.userId,
          'name': p.name,
          'icon': p.icon,
          'main': p.main,
          'child': !p.adult,
        };
      }).toList(),
    },
  );
}
