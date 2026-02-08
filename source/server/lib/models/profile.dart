/// Модель профиля
class Profile {
  /// Конструктор
  Profile({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    this.main = false,
    this.child = false,
  });

  /// Создает объект из JSON
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      main: json['main'] as bool? ?? false,
      child: json['child'] as bool? ?? false,
    );
  }

  /// ID профиля
  final int id;

  /// ID пользователя
  final String userId;

  /// Имя профиля
  final String name;

  /// Иконка
  final String icon;

  /// Основной профиль
  final bool main;

  /// Детский профиль
  final bool child;

  /// Копирование с изменениями
  Profile copyWith({
    int? id,
    String? userId,
    String? name,
    String? icon,
    bool? main,
    bool? child,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      main: main ?? this.main,
      child: child ?? this.child,
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'icon': icon,
      'main': main,
      'child': child,
    };
  }
}
