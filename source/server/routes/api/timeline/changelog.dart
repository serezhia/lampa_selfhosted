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

  final timelineMap = await DataSource.instance.getTimeline(profile.id);
  final currentVersion =
      await DataSource.instance.getTimelineVersion(profile.id);

  // Фильтруем только изменения после since версии
  // Note: In the new schema we don't track per-entry version,
  // so we return all entries if since < currentVersion
  final changedTimelines = <String, Map<String, dynamic>>{};
  if (since < currentVersion) {
    for (final entry in timelineMap.entries) {
      changedTimelines[entry.key] = {
        'percent': entry.value.percent,
        'time': entry.value.time,
        'duration': entry.value.duration,
      };
    }
  }

  return Response.json(
    body: {
      'timelines': changedTimelines,
      'version': currentVersion,
    },
  );
}
