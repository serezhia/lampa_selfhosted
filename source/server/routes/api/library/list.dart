import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';
import 'package:lampa_server/database/database.dart' as db;

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final user = context.read<db.User>();

  try {
    final items = await DataSource.instance.db.getLibraryItemsByUserId(user.id);

    return Response.json(
      body: {
        'success': true,
        'items': items
            .map(
              (item) => {
                'id': item.id,
                'tmdb_id': item.tmdbId,
                'type': item.type,
                'season': item.season,
                'episode': item.episode,
                'title': item.title,
                'poster': item.poster,
                'magnet_uri': item.magnetUri,
                'audio_index': item.audioIndex,
                'subtitle_index': item.subtitleIndex,
                'status': item.status,
                'progress': item.progress,
                'error_message': item.errorMessage,
                'created_at': item.createdAt.toIso8601String(),
              },
            )
            .toList(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': e.toString()},
    );
  }
}
