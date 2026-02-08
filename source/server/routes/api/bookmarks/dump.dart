import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';
import 'package:lampa_server/database/database.dart' as db;

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final profile = context.read<db.Profile?>();
  if (profile == null) {
    return Response(statusCode: 401, body: 'No profile selected');
  }

  final bookmarks = await DataSource.instance.getBookmarks(profile.id);
  final version = await DataSource.instance.getBookmarkVersion(profile.id);

  // Возвращаем закладки с data как строкой JSON (как в оригинале)
  return Response.json(
    body: {
      'bookmarks': bookmarks.map((b) {
        return {
          'id': b.id,
          'cid': b.id,
          'card_id': b.cardId,
          'type': b.type,
          'data': b.data, // already JSON string
          'profile': b.profileId,
          'time': b.time,
        };
      }).toList(),
      'version': version,
    },
  );
}
