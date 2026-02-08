import 'dart:convert';
import 'dart:math';

import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:lampa_server/data_source.dart';
import 'package:lampa_server/database/database.dart' as db;

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  try {
    String? code;

    // Определяем формат данных
    final contentType = context.request.headers['content-type'] ?? '';

    String? platform;
    String? name;

    if (contentType.contains('application/json')) {
      // JSON формат
      final body = await context.request.json() as Map<String, dynamic>;
      code = body['code']?.toString();
      platform = body['platform']?.toString();
      name = body['name']?.toString();
    } else {
      // Form-urlencoded формат (Lampa отправляет так)
      final bodyText = await context.request.body();
      final params = Uri.splitQueryString(bodyText);
      code = params['code'];
      platform = params['platform'];
      name = params['name'];
    }

    if (code == null || code.isEmpty) {
      return Response.json(statusCode: 400, body: {'error': 'Code required'});
    }

    final user = await DataSource.instance.findUserByCode(code);

    if (user == null) {
      return Response.json(
        statusCode: 403,
        body: {'error': 'Invalid code'},
      );
    }

    final token = _generateToken();
    final profile = await DataSource.instance.getMainProfile(user.id);

    // Register device
    final deviceName = name?.isNotEmpty ?? false ? name! : 'Device';
    final devicePlatform =
        platform?.isNotEmpty ?? false ? platform! : 'unknown';

    await DataSource.instance.db.insertDevice(
      db.DevicesCompanion(
        id: Value(token),
        userId: Value(user.id),
        name: Value(deviceName),
        platform: Value(devicePlatform),
        token: Value(token),
      ),
    );

    return Response.json(
      body: {
        'token': token,
        'email': user.email,
        'profile': profile != null
            ? {
                'id': profile.id,
                'user_id': profile.userId,
                'name': profile.name,
                'icon': profile.icon,
                'main': profile.main,
                'child': !profile.adult,
              }
            : null,
        'premium': user.premium,
        'id': user.id,
      },
    );
  } catch (e) {
    return Response.json(statusCode: 400, body: {'error': e.toString()});
  }
}

String _generateToken() {
  final random = Random.secure();
  final values = List<int>.generate(32, (i) => random.nextInt(256));
  return base64Url.encode(values).replaceAll('=', '');
}
