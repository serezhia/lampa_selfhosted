import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';
import 'package:lampa_server/database/database.dart';

Future<Response> onRequest(
  RequestContext context,
  String key,
  String type,
) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }

  final profile = context.read<Profile?>();
  if (profile == null) {
    return Response(statusCode: 401, body: 'Unauthorized: Profile required');
  }

  final storageData = await DataSource.instance.getStorageData(profile.id, key);

  dynamic data;
  if (storageData != null) {
    try {
      data = jsonDecode(storageData.data);
    } catch (_) {}
  }

  // Если данных нет, возвращаем пустой массив или объект в зависимости от типа
  if (data == null) {
    if (type.startsWith('array_')) {
      data = <dynamic>[];
    } else {
      data = <String, dynamic>{};
    }
  }

  return Response.json(
    body: {
      'data': data,
    },
  );
}
