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
    int cId;
    String type;

    if (contentType.contains('application/x-www-form-urlencoded')) {
      final rawBody = await context.request.body();
      final params = Uri.splitQueryString(rawBody);

      // Клиент отправляет: type, card_id как отдельные поля формы
      type = params['type'] ?? 'like';
      cId = int.tryParse(params['card_id'] ?? '0') ?? 0;
    } else {
      final body = await context.request.json() as Map<String, dynamic>;
      final cardId = body['card_id'];
      type = body['type']?.toString() ?? 'like';
      cId = cardId is int ? cardId : int.tryParse(cardId.toString()) ?? 0;
    }

    await DataSource.instance.removeBookmark(profile.id, cId, type);

    return Response.json(body: {'secuses': true});
  } catch (e) {
    return Response(statusCode: 400, body: e.toString());
  }
}
