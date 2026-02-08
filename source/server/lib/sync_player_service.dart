import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

/// Комната для совместного просмотра
class SyncRoom {
  SyncRoom({
    required this.id,
    required this.hostUid,
    this.isPublic = true,
  });

  final String id;
  final String hostUid;
  bool isPublic;
  final Set<String> members = {};
  final Map<String, WebSocketChannel> channels = {};

  /// Текущее состояние медиа (для новых участников)
  Map<String, dynamic>? currentMedia;
  double? currentTime;
  Timer? _cleanupTimer;
  bool? isPlaying;

  Map<String, dynamic> toJson() => {
        'room_id': id,
        'host_uid': hostUid,
        'is_public': isPublic,
        'member_count': members.length,
      };
}

/// Сервис для управления комнатами совместного просмотра
class SyncPlayerService {
  SyncPlayerService._();

  static final SyncPlayerService instance = SyncPlayerService._();

  final Map<String, SyncRoom> _rooms = {};
  final Map<WebSocketChannel, String> _channelToRoom = {};
  final Map<WebSocketChannel, String> _channelToUid = {};
  final Random _random = Random();

  /// Генерация 6-значного кода комнаты
  String _generateRoomId() {
    String id;
    do {
      id = (100000 + _random.nextInt(900000)).toString();
    } while (_rooms.containsKey(id));
    return id;
  }

  /// Создание комнаты
  SyncRoom createRoom(String hostUid) {
    final id = _generateRoomId();
    final room = SyncRoom(id: id, hostUid: hostUid);
    room.members.add(hostUid);
    _rooms[id] = room;
    print('[SyncPlayer] Room $id created by $hostUid');
    return room;
  }

  /// Получение комнаты по ID
  SyncRoom? getRoom(String roomId) => _rooms[roomId];

  /// Список публичных комнат
  List<SyncRoom> getPublicRooms() {
    return _rooms.values.where((r) => r.isPublic).toList();
  }

  /// Изменение видимости комнаты
  bool setRoomPublic(String roomId, String uid, {required bool isPublic}) {
    final room = _rooms[roomId];
    if (room == null) return false;
    if (room.hostUid != uid) return false;
    room.isPublic = isPublic;
    print('[SyncPlayer] Room $roomId public: $isPublic');
    return true;
  }

  /// Обработка WebSocket подключения
  void handleConnection(WebSocketChannel channel, String uid) {
    _channelToUid[channel] = uid;

    channel.stream.listen(
      (message) => _onMessage(channel, uid, message),
      onDone: () => _onDisconnect(channel, uid),
      onError: (e) => _onDisconnect(channel, uid),
    );

    print('[SyncPlayer] WebSocket connected: $uid');
  }

  void _onMessage(WebSocketChannel channel, String uid, dynamic message) {
    if (message == 'ping') {
      channel.sink.add('pong');
      return;
    }

    try {
      final json = jsonDecode(message.toString()) as Map<String, dynamic>;
      final action = json['action'] as String?;
      final roomId = json['room_id'] as String?;

      print('[SyncPlayer] Message from $uid: $action');

      switch (action) {
        case 'create_room':
          _handleCreateRoom(channel, uid, json);

        case 'join_room':
          _handleJoinRoom(channel, uid, roomId, json);

        case 'leave_room':
          _handleLeaveRoom(channel, uid);

        case 'sync_state':
          _handleSyncState(channel, uid, roomId, json);

        case 'play_pause':
          _handlePlayPause(channel, uid, roomId, json);

        case 'media_offer':
          _handleMediaOffer(channel, uid, roomId, json);

        case 'request_media':
          _handleRequestMedia(channel, uid, roomId);

        case 'player_closed':
          _handlePlayerClosed(channel, uid, roomId);
      }
    } catch (e) {
      print('[SyncPlayer] Error: $e');
    }
  }

  void _onDisconnect(WebSocketChannel channel, String uid) {
    final roomId = _channelToRoom[channel];
    if (roomId != null) {
      _leaveRoom(channel, uid, roomId);
    }
    _channelToUid.remove(channel);
    _channelToRoom.remove(channel);
    print('[SyncPlayer] WebSocket disconnected: $uid');
  }

  void _handleCreateRoom(
    WebSocketChannel channel,
    String uid,
    Map<String, dynamic> json,
  ) {
    // Если уже в комнате - выходим
    final existingRoomId = _channelToRoom[channel];
    if (existingRoomId != null) {
      _leaveRoom(channel, uid, existingRoomId);
    }

    // Проверяем, передан ли room_id (например, создали через HTTP)
    final requestedRoomId = json['room_id'] as String?;
    SyncRoom? room;

    print(
      '[SyncPlayer] _handleCreateRoom: uid=$uid, requestedRoomId=$requestedRoomId',
    );
    print(
      '[SyncPlayer] _handleCreateRoom: existing rooms=${_rooms.keys.toList()}',
    );

    if (requestedRoomId != null && requestedRoomId.isNotEmpty) {
      if (_rooms.containsKey(requestedRoomId)) {
        final existing = _rooms[requestedRoomId]!;
        print(
          '[SyncPlayer] _handleCreateRoom: found room, hostUid=${existing.hostUid}',
        );
        if (existing.hostUid == uid) {
          room = existing;
          print('[SyncPlayer] Host $uid reclaimed room ${room.id}');
        } else {
          print(
            '[SyncPlayer] _handleCreateRoom: hostUid mismatch, creating new room',
          );
        }
      } else {
        print(
          '[SyncPlayer] _handleCreateRoom: room $requestedRoomId not found in _rooms',
        );
      }
    }

    // Если комнаты нет или это не наш ID - создаем новую
    if (room == null) {
      room = createRoom(uid);
      print('[SyncPlayer] Created new room ${room.id} for $uid');
    }

    // Отменяем таймер очистки, если есть
    room._cleanupTimer?.cancel();
    room._cleanupTimer = null;

    // Убедимся что uid в members
    room.members.add(uid);
    room.channels[uid] = channel;
    _channelToRoom[channel] = room.id;

    _send(channel, {
      'action': 'room_created',
      'success': true,
      'room_id': room.id,
      'is_host': true,
      'is_public': room.isPublic,
      'member_count': room.members.length,
    });
  }

  void _handleJoinRoom(
    WebSocketChannel channel,
    String uid,
    String? roomId,
    Map<String, dynamic> json,
  ) {
    if (roomId == null || roomId.isEmpty) {
      _send(channel, {'action': 'error', 'message': 'Room ID required'});
      return;
    }

    final room = _rooms[roomId];
    if (room == null) {
      _send(channel, {'action': 'error', 'message': 'Room not found'});
      return;
    }

    // Если уже в другой комнате - выходим
    final existingRoom = _channelToRoom[channel];
    if (existingRoom != null && existingRoom != roomId) {
      _leaveRoom(channel, uid, existingRoom);
    }

    // Отменяем таймер очистки, если есть
    room._cleanupTimer?.cancel();
    room._cleanupTimer = null;

    room.members.add(uid);
    room.channels[uid] = channel;
    _channelToRoom[channel] = roomId;

    // Проверяем, вернулся ли хост
    final isHost = uid == room.hostUid;

    // Уведомляем нового участника
    _send(channel, {
      'action': 'room_joined',
      'success': true,
      'room_id': roomId,
      'is_host': isHost,
      'host_uid': room.hostUid,
      'member_count': room.members.length,
    });

    // Уведомляем остальных
    _broadcastToRoom(
      roomId,
      {
        'action': 'user_joined',
        'user_id': uid,
        'member_count': room.members.length,
      },
      exclude: uid,
    );

    // Отправляем текущее состояние медиа новому участнику
    if (room.currentMedia != null) {
      _send(channel, {
        'action': 'media_offer',
        'media': room.currentMedia,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    print('[SyncPlayer] $uid joined room $roomId');
  }

  void _handleLeaveRoom(WebSocketChannel channel, String uid) {
    final roomId = _channelToRoom[channel];
    if (roomId != null) {
      _leaveRoom(channel, uid, roomId);
    }
    _send(channel, {'action': 'left_room'});
  }

  void _leaveRoom(WebSocketChannel channel, String uid, String roomId) {
    final room = _rooms[roomId];
    if (room == null) return;

    room.members.remove(uid);
    room.channels.remove(uid);
    _channelToRoom.remove(channel);

    // Уведомляем остальных
    _broadcastToRoom(roomId, {
      'action': 'user_left',
      'user_id': uid,
      'member_count': room.members.length,
    });

    // Если комната пуста - запускаем таймер на удаление
    if (room.members.isEmpty) {
      print(
        '[SyncPlayer] Room $roomId is empty. Scheduling removal in 10 minutes.',
      );
      room._cleanupTimer?.cancel();
      room._cleanupTimer = Timer(const Duration(minutes: 10), () {
        if (_rooms.containsKey(roomId) && _rooms[roomId]!.members.isEmpty) {
          _rooms.remove(roomId);
          print('[SyncPlayer] Room $roomId closed (timeout)');
        }
      });
    } else if (room.hostUid == uid) {
      // Если хост ушёл, но кто-то остался - пока оставляем старую логику или меняем?
      // По запросу пользователя "комнаты очищались через 10 минут если там 0 человек"
      // Можно оставить комнату "осиротевшей", но не закрывать.
      // Но если хост ушел, управлять некому.
      // Для простоты пока оставим закрытие, если хост ушел НЕ последним.
      // Но если хост был последним (room.members.isEmpty), сработает ветка выше.

      _broadcastToRoom(roomId, {
        'action': 'room_closed',
        'reason': 'host_left',
      });
      _rooms.remove(roomId);
      print('[SyncPlayer] Room $roomId closed (host left)');
    }

    print('[SyncPlayer] $uid left room $roomId');
  }

  void _handleSyncState(
    WebSocketChannel channel,
    String uid,
    String? roomId,
    Map<String, dynamic> json,
  ) {
    if (roomId == null) return;
    final room = _rooms[roomId];
    if (room == null) return;

    // Только хост может синхронизировать
    if (room.hostUid != uid) return;

    room
      ..currentTime = (json['time'] as num?)?.toDouble()
      ..isPlaying = json['is_playing'] as bool?;

    _broadcastToRoom(
      roomId,
      {
        'action': 'sync_state',
        'time': json['time'],
        'is_playing': json['is_playing'],
      },
      exclude: uid,
    );
  }

  void _handlePlayPause(
    WebSocketChannel channel,
    String uid,
    String? roomId,
    Map<String, dynamic> json,
  ) {
    if (roomId == null) return;
    final room = _rooms[roomId];
    if (room == null) return;

    // Только хост
    if (room.hostUid != uid) return;

    room
      ..currentTime = (json['time'] as num?)?.toDouble()
      ..isPlaying = json['is_playing'] as bool?;

    _broadcastToRoom(
      roomId,
      {
        'action': 'play_pause',
        'time': json['time'],
        'is_playing': json['is_playing'],
      },
      exclude: uid,
    );
  }

  void _handleMediaOffer(
    WebSocketChannel channel,
    String uid,
    String? roomId,
    Map<String, dynamic> json,
  ) {
    if (roomId == null) return;
    final room = _rooms[roomId];
    if (room == null) return;

    // Только хост
    if (room.hostUid != uid) return;

    room.currentMedia = json['media'] as Map<String, dynamic>?;

    _broadcastToRoom(
      roomId,
      {
        'action': 'media_offer',
        'media': json['media'],
        'playlist': json['playlist'],
        'timestamp': json['timestamp'],
      },
      exclude: uid,
    );

    print('[SyncPlayer] Media offer from $uid in room $roomId');
  }

  void _handleRequestMedia(
    WebSocketChannel channel,
    String uid,
    String? roomId,
  ) {
    if (roomId == null) return;
    final room = _rooms[roomId];
    if (room == null) return;

    // Отправляем запрос хосту
    final hostChannel = room.channels[room.hostUid];
    if (hostChannel != null) {
      _send(hostChannel, {
        'action': 'request_media',
        'user_id': uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  void _handlePlayerClosed(
    WebSocketChannel channel,
    String uid,
    String? roomId,
  ) {
    if (roomId == null) return;
    final room = _rooms[roomId];
    if (room == null) return;

    // Только хост
    if (room.hostUid != uid) return;

    room
      ..currentMedia = null
      ..currentTime = null
      ..isPlaying = null;

    _broadcastToRoom(
      roomId,
      {
        'action': 'player_closed',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      exclude: uid,
    );
  }

  void _send(WebSocketChannel channel, Map<String, dynamic> data) {
    try {
      channel.sink.add(jsonEncode(data));
    } catch (e) {
      print('[SyncPlayer] Send error: $e');
    }
  }

  void _broadcastToRoom(
    String roomId,
    Map<String, dynamic> data, {
    String? exclude,
  }) {
    final room = _rooms[roomId];
    if (room == null) return;

    final message = jsonEncode(data);
    for (final entry in room.channels.entries) {
      if (entry.key != exclude) {
        try {
          entry.value.sink.add(message);
        } catch (e) {
          print('[SyncPlayer] Broadcast error to ${entry.key}: $e');
        }
      }
    }
  }
}
