import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/database/database.dart' as db;

/// Template for a standard authenticated API route.
/// Location: source/server/routes/api/your_feature/action.dart
Future<Response> onRequest(RequestContext context) async {
  // 1. Access injected profile (provided by routes/api/_middleware.dart)
  final profile = context.read<db.Profile?>();
  if (profile == null) {
    return Response.json(statusCode: 401, body: {'error': 'Unauthorized'});
  }

  final request = context.request;

  // 2. Validate HTTP Method
  if (request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Method not allowed'},
    );
  }

  try {
    // 3. Parse request body
    final body = await request.json() as Map<String, dynamic>;
    final someParam = body['some_param'];

    if (someParam == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing some_param'},
      );
    }

    // 4. Perform logic using singletons
    // final dbInstance = db.DataSource.instance;
    // await dbInstance.doSomething(profile.id, someParam);

    // 5. Return standard success response
    return Response.json(body: {'success': true, 'data': {}});
  } catch (e) {
    print('[API/YourFeature] Error: $e');
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error'},
    );
  }
}
