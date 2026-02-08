/// Модель пользователя
class User {
  /// Конструктор
  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.premium,
    required this.createdAt,
    this.telegramId,
    this.phone,
    this.firstName,
    this.lastName,
  });

  /// Создает объект из JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String,
      premium: json['premium'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      telegramId: json['telegram_id'] as String?,
      phone: json['phone'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
    );
  }

  /// ID пользователя
  final String id;

  /// Email
  final String email;

  /// Хэш пароля
  final String passwordHash;

  /// Окончание премиума (timestamp)
  final int premium;

  /// Дата создания
  final DateTime createdAt;

  /// Telegram ID (для авторизации через бота)
  final String? telegramId;

  /// Номер телефона
  final String? phone;

  /// Имя пользователя
  final String? firstName;

  /// Фамилия пользователя
  final String? lastName;

  /// Копирование с изменением полей
  User copyWith({
    String? id,
    String? email,
    String? passwordHash,
    int? premium,
    DateTime? createdAt,
    String? telegramId,
    String? phone,
    String? firstName,
    String? lastName,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      premium: premium ?? this.premium,
      createdAt: createdAt ?? this.createdAt,
      telegramId: telegramId ?? this.telegramId,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'premium': premium,
      'created_at': createdAt.toIso8601String(),
      'telegram_id': telegramId,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}
