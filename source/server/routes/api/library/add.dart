import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart' as drift;
import 'package:lampa_server/data_source.dart';
import 'package:lampa_server/database/database.dart' as db;
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final user = context.read<db.User>();

  try {
    final contentType = context.request.headers['content-type'] ?? '';
    Map<String, dynamic> body;

    if (contentType.contains('application/x-www-form-urlencoded')) {
      final rawBody = await context.request.body();
      final params = Uri.splitQueryString(rawBody);

      body = {
        'tmdb_id': int.tryParse(params['tmdb_id'] ?? ''),
        'type': params['type'],
        'season': int.tryParse(params['season'] ?? ''),
        'episode': int.tryParse(params['episode'] ?? ''),
        'title': params['title'],
        'poster': params['poster'],
        'magnet_uri': params['magnet_uri'],
      };
    } else {
      body = await context.request.json() as Map<String, dynamic>;
    }

    final tmdbId = body['tmdb_id'] is int
        ? body['tmdb_id'] as int
        : int.tryParse(body['tmdb_id']?.toString() ?? '');
    final type = body['type']?.toString();
    final season = body['season'] is int
        ? body['season'] as int
        : int.tryParse(body['season']?.toString() ?? '');
    final episode = body['episode'] is int
        ? body['episode'] as int
        : int.tryParse(body['episode']?.toString() ?? '');
    final title = body['title']?.toString();
    final poster = body['poster']?.toString();
    final magnetUri = body['magnet_uri']?.toString();

    if (tmdbId == null || type == null || title == null || magnetUri == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing required fields'},
      );
    }

    final id = const Uuid().v4();

    final item = await DataSource.instance.db.insertLibraryItem(
      db.LibraryItemsCompanion.insert(
        id: id,
        userId: user.id,
        tmdbId: tmdbId,
        type: type,
        season: drift.Value(season),
        episode: drift.Value(episode),
        title: title,
        poster: drift.Value(poster),
        magnetUri: magnetUri,
        status: 'pending',
      ),
    );

    return Response.json(
      body: {
        'success': true,
        'item': {
          'id': item.id,
          'tmdb_id': item.tmdbId,
          'type': item.type,
          'season': item.season,
          'episode': item.episode,
          'title': item.title,
          'poster': item.poster,
          'magnet_uri': item.magnetUri,
          'status': item.status,
          'progress': item.progress,
          'error_message': item.errorMessage,
          'created_at': item.createdAt.toIso8601String(),
        },
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'error': e.toString()},
    );
  }
}
