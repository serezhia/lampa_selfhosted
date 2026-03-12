import 'package:dart_frog/dart_frog.dart';
import 'package:lampa_server/data_source.dart';
import 'package:lampa_server/database/database.dart' as db;

Handler middleware(Handler handler) {
  return (context) async {
    final path = context.request.uri.path;
    final method = context.request.method.value;
    print('[MIDDLEWARE] $method $path');

    // Skip auth for public endpoints
    if (context.request.uri.path.contains('/device/add') ||
        context.request.uri.path.contains('/device/validate') ||
        context.request.uri.path.contains('/checker') ||
        context.request.uri.path.contains('/config') ||
        context.request.uri.path.contains('/transcoding/') ||
        context.request.uri.path.contains('/library/play/') ||
        context.request.uri.path.contains('/jackett') ||
        context.request.uri.path.contains('/notice/')) {
      print('[MIDDLEWARE] Public endpoint, skipping auth');
      return handler(context);
    }

    // For downloads and plugins, try to get user/profile but don't require it
    if (context.request.uri.path.contains('/downloads/') ||
        context.request.uri.path.contains('/plugins/all')) {
      print('[MIDDLEWARE] Optional auth endpoint');
      final token = context.request.headers['token'];
      final profileIdStr = context.request.headers['profile'];
      print('[MIDDLEWARE] token=$token, profile=$profileIdStr');

      db.User? user;
      db.Profile? profile;
      if (token != null && token.isNotEmpty) {
        try {
          final device = await DataSource.instance.getDeviceByToken(token);
          print('[MIDDLEWARE] Device found: ${device?.id}');
          if (device != null) {
            user = await DataSource.instance.db.getUserById(device.userId);
            if (profileIdStr != null) {
              final profileId = int.tryParse(profileIdStr);
              if (profileId != null) {
                profile = await DataSource.instance.getProfileById(profileId);
                print('[MIDDLEWARE] Profile found: ${profile?.id}');
              }
            }
          }
        } catch (e) {
          print('[MIDDLEWARE] Auth error (ignored): $e');
        }
      }

      print('[MIDDLEWARE] Passing user: ${user?.id}, profile: ${profile?.id}');
      return handler(
        context
            .provide<db.User?>(() => user)
            .provide<db.Profile?>(() => profile),
      );
    }

    final token = context.request.headers['token'];

    if (token == null || token.isEmpty) {
      return Response(statusCode: 401, body: 'Unauthorized: Missing Token');
    }

    // Find device by token
    try {
      final device = await DataSource.instance.getDeviceByToken(token);

      if (device == null) {
        return Response(statusCode: 401, body: 'Unauthorized: Invalid Token');
      }

      final user = await DataSource.instance.db.getUserById(device.userId);

      if (user == null) {
        return Response(statusCode: 401, body: 'Unauthorized: User not found');
      }

      // Check if user is blocked
      if (user.blocked) {
        return Response(statusCode: 403, body: 'Forbidden: User is blocked');
      }

      // Check for profile header
      final profileIdStr = context.request.headers['profile'];
      db.Profile? profile;
      if (profileIdStr != null) {
        final profileId = int.tryParse(profileIdStr);
        if (profileId != null) {
          profile = await DataSource.instance.getProfileById(profileId);
          // Verify profile belongs to user
          if (profile != null && profile.userId != user.id) {
            profile = null;
          }
        }
      }

      // Inject dependencies
      return handler(
        context
            .provide<db.User>(() => user)
            .provide<db.Profile?>(() => profile)
            .provide<db.Device>(() => device),
      );
    } catch (e) {
      return Response(statusCode: 401, body: 'Unauthorized: Invalid Token');
    }
  };
}
