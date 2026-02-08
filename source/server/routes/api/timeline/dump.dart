// ignore_for_file: lines_longer_than_80_chars

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

  final timelineMap = await DataSource.instance.getTimeline(profile.id);
  final version = await DataSource.instance.getTimelineVersion(profile.id);

  // Convert entries to JSON
  // Lampa ожидает формат: {timelines: {hash: {percent, time, duration}, ...}, version: N}
  final jsonMap = timelineMap.map((key, value) => MapEntry(key, {
        'percent': value.percent,
        'time': value.time,
        'duration': value.duration,
      }),);

  return Response.json(
    body: {
      'timelines': jsonMap,
      'version': version,
    },
  );
}
