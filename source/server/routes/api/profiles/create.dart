import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';
import 'package:lampa_server/database/database.dart' as db;

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
      // Form data may contain 'data' field with JSON or direct fields
      if (params.containsKey('data')) {
        body = jsonDecode(params['data']!) as Map<String, dynamic>;
      } else {
        body = params.map(MapEntry.new);
      }
    } else {
      body = await context.request.json() as Map<String, dynamic>;
    }

    final name = body['name'].toString();

    // Validation (max 8 profiles)
    final currentProfiles =
        await DataSource.instance.getProfilesForUser(user.id);
    if (currentProfiles.length >= 8) {
      return Response.json(
        statusCode: 400,
        body: {'secuses': false, 'text': 'Limit reached'},
      );
    }

    // Create
    final profile = await DataSource.instance.createProfile(user.id, name);

    return Response.json(
      body: {
        'secuses': true,
        'profile': {
          'id': profile.id,
          'user_id': profile.userId,
          'name': profile.name,
          'icon': profile.icon,
          'main': profile.main,
          'child': !profile.adult,
        },
      },
    );
  } catch (e) {
    return Response(statusCode: 400, body: e.toString());
  }
}
