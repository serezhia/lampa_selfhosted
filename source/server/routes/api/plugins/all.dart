import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';
import 'package:lampa_server/database/database.dart';

Future<Response> onRequest(RequestContext context) async {
  final user = context.read<User?>();

  if (user == null) {
    return Response.json(
      body: {
        'secuses': true,
        'plugins': <dynamic>[],
      },
    );
  }

  final plugins = await DataSource.instance.getUserPlugins(user.id);

  return Response.json(
    body: {
      'secuses': true,
      'plugins': plugins
          .map(
            (p) => {
              'url': p.url,
              'status': p.status,
              'name': p.name ?? p.url.split('/').last,
              'author': 'Self-Hosted',
            },
          )
          .toList(),
    },
  );
}
