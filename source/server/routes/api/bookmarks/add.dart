import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';
import 'package:lampa_server/database/database.dart' as db;

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final profile = context.read<db.Profile?>();
  if (profile == null) {
    return Response(statusCode: 401, body: 'No profile selected');
  }

  try {
    final contentType = context.request.headers['content-type'] ?? '';
    Map<String, dynamic> body;

    if (contentType.contains('application/x-www-form-urlencoded')) {
      final rawBody = await context.request.body();
      final params = Uri.splitQueryString(rawBody);

      // Клиент отправляет: type, data (JSON строка с карточкой), card_id, id
      // Нужно собрать все эти поля в правильный объект
      final type = params['type'] ?? 'like';
      final cardId = int.tryParse(params['card_id'] ?? '0') ?? 0;
      final bookmarkId = int.tryParse(params['id'] ?? '0') ?? 0;

      // data - это JSON строка с данными карточки
      var cardData = <String, dynamic>{};
      if (params.containsKey('data')) {
        try {
          cardData = jsonDecode(params['data']!) as Map<String, dynamic>;
        } catch (e) {
          cardData = {};
        }
      }

      body = {
        'type': type,
        'card_id': cardId,
        'id': bookmarkId,
        'data': cardData,
      };
    } else {
      body = await context.request.json() as Map<String, dynamic>;
    }

    final bookmark = await DataSource.instance.addBookmark(profile.id, body);

    // Parse data from bookmark
    Map<String, dynamic> cardData;
    try {
      cardData = jsonDecode(bookmark.data) as Map<String, dynamic>;
    } catch (_) {
      cardData = {};
    }

    // Формируем ответ как у оригинального сервера
    return Response.json(
      body: {
        'secuses': true,
        'bookmark': {
          'id': bookmark.id,
          'cid': bookmark.id,
          'lid': bookmark.id, // local id
          'type': bookmark.type,
          'card_id': bookmark.cardId,
          'data': bookmark.data, // data как JSON строка!
          'profile': bookmark.profileId,
          'time': bookmark.time,
          'card_title': cardData['title'] ?? cardData['name'] ?? '',
          'card_type': cardData['first_air_date'] != null ? 'tv' : 'movie',
          'card_poster': cardData['poster_path'] ?? '',
        },
        'write': 'insert',
      },
    );
  } catch (e) {
    return Response(statusCode: 400, body: e.toString());
  }
}
