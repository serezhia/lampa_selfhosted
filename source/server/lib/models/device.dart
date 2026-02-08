/// Модель устройства
class Device {
  /// Конструктор
  Device({
    required this.id,
    required this.userId,
    required this.name,
    required this.platform,
    required this.token,
    required this.lastSeen,
  });

  /// Создает объект из JSON
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      platform: json['platform'] as String,
      token: json['token'] as String,
      lastSeen: json['last_seen'] as int,
    );
  }

  /// ID устройства
  final String id;

  /// ID пользователя
  final String userId;

  /// Имя устройства
  final String name;

  /// Платформа
  final String platform;

  /// Токен авторизации
  final String token;

  /// Время последней активности
  final int lastSeen;

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'platform': platform,
      'token': token,
      'last_seen': lastSeen,
    };
  }
}
