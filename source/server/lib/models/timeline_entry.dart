/// Запись в таймлайне (история просмотра)
class TimelineEntry {
  /// Конструктор
  TimelineEntry({
    required this.hash,
    required this.percent,
    required this.time,
    required this.duration,
    required this.profileId,
    required this.updatedAt,
    this.version = 0,
  });

  /// Создает объект из JSON
  factory TimelineEntry.fromJson(Map<String, dynamic> json) {
    return TimelineEntry(
      hash: json['hash'] as String,
      percent: (json['percent'] as num).toDouble(),
      time: json['time'] as int,
      duration: json['duration'] as int,
      profileId: json['profile'] as int,
      updatedAt:
          json['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      version: json['version'] as int? ?? 0,
    );
  }

  /// Хэш контента
  final String hash;

  /// Процент просмотра
  final double percent;

  /// Текущее время просмотра (в секундах или мс)
  final int time;

  /// Длительность контента
  final int duration;

  /// ID профиля
  final int profileId;

  /// Время обновления
  final int updatedAt;

  /// Версия записи
  final int version;

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'percent': percent,
      'time': time,
      'duration': duration,
      'profile': profileId,
      'updated_at': updatedAt,
      'version': version,
    };
  }
}
