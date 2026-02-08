import 'dart:convert';

/// Модель закладки
class Bookmark {
  /// Конструктор
  Bookmark({
    required this.id,
    required this.cid,
    required this.cardId,
    required this.type,
    required this.data,
    required this.profileId,
    required this.time,
  });

  /// Создает объект из JSON (при загрузке из файла data сохранён как объект)
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    final dataVal = json['data'];
    // data может прийти как строка (из старого формата) или как объект
    Map<String, dynamic> dataMap;
    if (dataVal is String) {
      dataMap = jsonDecode(dataVal) as Map<String, dynamic>;
    } else {
      dataMap = dataVal as Map<String, dynamic>;
    }

    return Bookmark(
      id: json['id'] as int,
      cid: json['cid'] as int,
      cardId: json['card_id'] as int,
      type: json['type'] as String,
      data: dataMap,
      profileId: json['profile'] as int,
      time: json['time'] as int,
    );
  }

  /// Уникальный ID
  final int id;

  /// ID клиента (Client ID)
  final int cid;

  /// ID карточки (контента)
  final int cardId;

  /// Тип контента
  final String type;

  /// Данные закладки
  final Map<String, dynamic> data;

  /// ID профиля
  final int profileId;

  /// Временная метка создания
  final int time;

  /// Преобразование в JSON для сохранения в файл (data как объект)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cid': cid,
      'card_id': cardId,
      'type': type,
      'data': data,
      'profile': profileId,
      'time': time,
    };
  }

  /// Преобразование в JSON для API ответа (data как строка, как в оригинале)
  Map<String, dynamic> toApiJson() {
    return {
      'id': id,
      'cid': cid,
      'card_id': cardId,
      'type': type,
      'data': jsonEncode(data),
      'profile': profileId,
      'time': time,
    };
  }
}
