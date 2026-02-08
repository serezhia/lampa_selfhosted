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

    Map<String, dynamic>? bookmarksData;

    if (contentType.contains('multipart/form-data')) {
      // Парсим multipart/form-data
      final formData = await context.request.formData();
      final file = formData.files['file'];

      if (file != null) {
        final bytes = await file.readAsBytes();
        final jsonStr = utf8.decode(bytes);
        bookmarksData = jsonDecode(jsonStr) as Map<String, dynamic>;
      }
    } else if (contentType.contains('application/json')) {
      bookmarksData = await context.request.json() as Map<String, dynamic>;
    } else if (contentType.contains('application/x-www-form-urlencoded')) {
      final rawBody = await context.request.body();
      final params = Uri.splitQueryString(rawBody);
      if (params.containsKey('data')) {
        bookmarksData = jsonDecode(params['data']!) as Map<String, dynamic>;
      }
    }

    if (bookmarksData == null) {
      return Response.json(
        statusCode: 400,
        body: {'secuses': false, 'text': 'No data provided'},
      );
    }

    // Синхронизируем закладки
    final bookmarksList = bookmarksData['bookmarks'] as List<dynamic>? ?? [];

    // Удаляем текущие закладки профиля
    final currentBookmarks = await DataSource.instance.getBookmarks(profile.id);
    for (final b in currentBookmarks) {
      await DataSource.instance.db.deleteBookmark(b.id);
    }

    // Добавляем новые
    for (final item in bookmarksList) {
      if (item is Map<String, dynamic>) {
        final cardIdVal = item['card_id'];
        final cardId = cardIdVal is int
            ? cardIdVal
            : int.tryParse(cardIdVal.toString()) ?? 0;

        final typeVal = item['type'];
        final type = (typeVal != null && typeVal.toString() != 'null')
            ? typeVal.toString()
            : 'like';

        final dataVal = item['data'];
        String dataStr;
        if (dataVal is String) {
          dataStr = dataVal;
        } else if (dataVal is Map) {
          dataStr = jsonEncode(dataVal);
        } else {
          dataStr = jsonEncode(item);
        }

        await DataSource.instance.addBookmark(profile.id, {
          'type': type,
          'card_id': cardId,
          'data': dataStr,
          'time': item['time'] as int? ?? DateTime.now().millisecondsSinceEpoch,
        });
      }
    }

    final version = await DataSource.instance.getBookmarkVersion(profile.id);

    return Response.json(body: {'secuses': true, 'version': version});
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'secuses': false, 'text': e.toString()},
    );
  }
}
