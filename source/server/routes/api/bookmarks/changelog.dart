import 'dart:convert';

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

  final sinceStr = context.request.uri.queryParameters['since'];
  final since = int.tryParse(sinceStr ?? '0') ?? 0;

  final changes =
      await DataSource.instance.getBookmarkChanges(profile.id, since);
  final currentVersion =
      await DataSource.instance.getBookmarkVersion(profile.id);

  return Response.json(
    body: {
      'secuses': true,
      'changelog': changes.map((c) {
        if (c.action == 'remove') {
          // При удалении все поля кроме action, version, entity_id, updated_at = null
          return {
            'action': 'remove',
            'version': c.version,
            'entity_id': c.entityId.toString(),
            'updated_at': c.time,
            'id': null,
            'cid': null,
            'type': null,
            'data': null,
            'card_id': null,
            'profile': null,
            'time': null,
            'card_title': null,
            'card_type': null,
            'lid': null,
            'card_poster': null,
          };
        }

        // При добавлении - полная информация
        var dataMap = <String, dynamic>{};
        try {
          dataMap = jsonDecode(c.data) as Map<String, dynamic>;
        } catch (_) {
          dataMap = {};
        }

        return {
          'action': 'add',
          'version': c.version,
          'entity_id': c.entityId.toString(),
          'updated_at': c.time,
          'id': c.entityId,
          'cid': profile.id,
          'type': c.type,
          'data': c.data,
          'card_id': c.cardId?.toString(),
          'profile': profile.id,
          'time': c.time,
          'card_title': dataMap['title'] ?? dataMap['original_title'],
          'card_type': _getCardType(dataMap),
          'lid': profile.id,
          'card_poster': dataMap['poster_path'],
        };
      }).toList(),
      'version': currentVersion,
    },
  );
}

String _getCardType(Map<String, dynamic> data) {
  // Определяем тип карточки по данным
  if (data['number_of_seasons'] != null ||
      data['first_air_date'] != null ||
      data['name'] != null && data['title'] == null) {
    return 'tv';
  }
  return 'movie';
}
