import 'dart:convert';

import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:lampa_server/data_source.dart';

/// Сервис WebSocket
class SocketService {
  SocketService._();

  /// Singleton instance
  static final SocketService instance = SocketService._();

  final Map<WebSocketChannel, String> _channelUsers = {}; // Channel -> UserId
  final Map<WebSocketChannel, int> _channelProfiles =
      {}; // Channel -> ProfileId
  final Map<WebSocketChannel, String> _channelDeviceIds =
      {}; // Channel -> DeviceUID
  final Map<WebSocketChannel, String> _channelNames =
      {}; // Channel -> DeviceName

  /// Обработка подключения
  void handleConnection(WebSocketChannel channel) {
    channel.stream.listen(
      (message) => _onMessage(channel, message),
      onDone: () => _removeClient(channel),
      onError: (e) => _removeClient(channel),
    );
  }

  void _removeClient(WebSocketChannel channel) {
    _channelUsers.remove(channel);
    _channelProfiles.remove(channel);
    _channelDeviceIds.remove(channel);
    _channelNames.remove(channel);
  }

  Future<void> _onMessage(WebSocketChannel channel, dynamic message) async {
    if (message == 'ping') {
      channel.sink.add('pong');
      return;
    }

    try {
      final json = jsonDecode(message.toString()) as Map<String, dynamic>;

      // Обновляем состояние подключения при каждом запросе
      // Если токен невалиден — logoff уже отправлен, прерываем обработку
      final isValid = await _updateConnectionInfo(channel, json);
      if (!isValid) return;

      final method = json['method'];

      switch (method) {
        case 'start':
        case 'init':
        // Просто обновление статуса (уже сделано выше)

        case 'check_token':
          await _handleCheckToken(channel, json);

        case 'devices':
          _handleDevices(channel);

        case 'timeline':
          await _handleTimeline(channel, json);

        case 'bookmarks':
          _handleBookmarks(channel, json);

        case 'open':
        case 'other':
          _handleDirectMessage(channel, json);
      }
    } catch (e) {
      // ignore: avoid_print
      print('WS Error: $e');
    }
  }

  /// Обновляем привязку канала к пользователю, профилю и устройству
  /// Возвращает false если токен невалиден
  Future<bool> _updateConnectionInfo(
    WebSocketChannel channel,
    Map<String, dynamic> json,
  ) async {
    // 1. Auth via Token
    if (json.containsKey('account') && json['account'] != null) {
      final account = json['account'] as Map<String, dynamic>;
      final token = account['token'];
      final email = account['email']?.toString();

      if (token != null) {
        // Ищем устройство по токену
        final device =
            await DataSource.instance.getDeviceByToken(token.toString());
        if (device != null) {
          _channelUsers[channel] = device.userId;

          // 2. Profile
          if (account['profile'] != null) {
            final profileData = account['profile'];
            if (profileData is Map && profileData.containsKey('id')) {
              _channelProfiles[channel] = profileData['id'] as int;
            } else if (profileData is int) {
              _channelProfiles[channel] = profileData;
            }
          }
        } else {
          // Токен есть, но устройство не найдено — разлогиниваем
          channel.sink.add(
            jsonEncode({
              'method': 'logoff',
              'data': {'email': email ?? ''},
            }),
          );
          return false;
        }
      }
    }

    // 3. Device Info
    if (json.containsKey('device_id')) {
      _channelDeviceIds[channel] = json['device_id'].toString();
    }
    if (json.containsKey('name')) {
      _channelNames[channel] = json['name'].toString();
    }
    return true;
  }

  /// Проверка валидности токена
  Future<void> _handleCheckToken(
    WebSocketChannel channel,
    Map<String, dynamic> json,
  ) async {
    // Получаем токен из запроса
    final account = json['account'] as Map<String, dynamic>?;
    final token = account?['token']?.toString();
    final email = account?['email']?.toString();

    if (token == null) {
      // Нет токена — отправляем logoff
      channel.sink.add(
        jsonEncode({
          'method': 'logoff',
          'data': {'email': email ?? ''},
        }),
      );
      return;
    }

    // Проверяем токен в БД
    final device = await DataSource.instance.getDeviceByToken(token);

    if (device == null) {
      // Токен не найден в БД — отправляем logoff
      channel.sink.add(
        jsonEncode({
          'method': 'logoff',
          'data': {'email': email ?? ''},
        }),
      );
    }
    // Если токен валиден — молчим (клиент остаётся залогиненным)
  }

  /// Отправить список устройств
  void _handleDevices(WebSocketChannel channel) {
    final userId = _channelUsers[channel];
    if (userId == null) return;

    final devicesList = <Map<String, dynamic>>[];

    _channelUsers.forEach((otherChannel, otherUserId) {
      if (otherUserId == userId) {
        final uid = _channelDeviceIds[otherChannel];
        final name = _channelNames[otherChannel];
        // UID клиента (device_id) отличается от ID устройства в базе (token).
        // Lampa использует 'uid' для адресации сообщений
        if (uid != null && name != null) {
          devicesList.add({
            'uid': uid,
            'device_id': uid,
            'name': name,
          });
        }
      }
    });

    channel.sink.add(
      jsonEncode({
        'method': 'devices',
        'data': devicesList,
      }),
    );
  }

  /// Прямая отправка команды другому устройству (open, other->play)
  void _handleDirectMessage(
    WebSocketChannel channel,
    Map<String, dynamic> json,
  ) {
    final userId = _channelUsers[channel];
    if (userId == null) return;

    final targetUid = json['uid'];
    final params = json['params'];
    if (targetUid == null) return;

    WebSocketChannel? targetChannel;
    _channelDeviceIds.forEach((ch, uid) {
      if (uid == targetUid && _channelUsers[ch] == userId) {
        targetChannel = ch;
      }
    });

    if (targetChannel != null) {
      // Отправляем с method: open/other и данными внутри data
      targetChannel!.sink.add(
        jsonEncode({
          'method': json['method'],
          'data': params ?? json['data'], // params обычно, но fallback на data
        }),
      );
    }
  }

  Future<void> _handleTimeline(
    WebSocketChannel channel,
    Map<String, dynamic> json,
  ) async {
    final userId = _channelUsers[channel];
    if (userId == null) return;

    // Клиент Lampa отправляет данные в поле 'params' для timeline
    final rawData = json['params'] ?? json['data'];

    if (rawData != null && rawData is Map<String, dynamic>) {
      final entryData = Map<String, dynamic>.from(rawData);

      if (!entryData.containsKey('profile') &&
          _channelProfiles.containsKey(channel)) {
        entryData['profile'] = _channelProfiles[channel];
      }

      if (!entryData.containsKey('profile')) {
        return;
      }

      final profileId = entryData['profile'] as int;
      final hash = entryData['hash'] as String?;

      if (hash == null) return;

      // Update timeline in database
      await DataSource.instance.updateTimeline(profileId, hash, {
        'percent': entryData['percent'],
        'time': entryData['time'],
        'duration': entryData['duration'],
      });

      _broadcast(
        channel,
        userId,
        {
          'method': 'timeline',
          'data': entryData, // Отправляем обратно как data, так ждет клиент
        },
      );
    }
  }

  void _handleBookmarks(WebSocketChannel channel, Map<String, dynamic> json) {
    final userId = _channelUsers[channel];
    if (userId != null) {
      _broadcast(
        channel,
        userId,
        {'method': 'bookmarks', 'data': <Map<String, dynamic>>{}},
      );
    }
  }

  void _broadcast(
    WebSocketChannel sender,
    String userId,
    Map<String, dynamic> packet,
  ) {
    final msg = jsonEncode(packet);
    _channelUsers.forEach((client, clientUserId) {
      if (client != sender && clientUserId == userId) {
        client.sink.add(msg);
      }
    });
  }
}
