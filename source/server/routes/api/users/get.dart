import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/database/database.dart' as db;

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get &&
      context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  try {
    final user = context.read<db.User>();

    // Возвращаем данные пользователя в формате, который ожидает клиент
    return Response.json(
      body: {
        'secuses': true,
        'user': {
          'id': user.id,
          'email': user.email,
          'premium': user.premium,
          'created_at': user.createdAt.millisecondsSinceEpoch,
          'telegram_id': user.telegramId,
          'first_name': user.firstName,
          'last_name': user.lastName,
        },
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 401,
      body: {'secuses': false, 'text': 'Not authorized'},
    );
  }
}
