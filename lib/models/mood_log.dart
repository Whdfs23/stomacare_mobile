import 'package:hive/hive.dart';

part 'mood_log.g.dart';

/// Mood level enum
enum MoodLevel { veryBad, bad, neutral, good, veryGood }

extension MoodLevelExt on MoodLevel {
  String get label {
    switch (this) {
      case MoodLevel.veryBad:  return 'Sangat Buruk';
      case MoodLevel.bad:      return 'Buruk';
      case MoodLevel.neutral:  return 'Biasa';
      case MoodLevel.good:     return 'Baik';
      case MoodLevel.veryGood: return 'Sangat Baik';
    }
  }
  String get emoji {
    switch (this) {
      case MoodLevel.veryBad:  return '😣';
      case MoodLevel.bad:      return '😟';
      case MoodLevel.neutral:  return '😐';
      case MoodLevel.good:     return '😊';
      case MoodLevel.veryGood: return '😄';
    }
  }
  int get value => index;
}

@HiveType(typeId: 1)
class MoodLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  /// 0–4 maps to MoodLevel enum index
  @HiveField(2)
  int moodIndex;

  /// Jam tidur malam (jam:menit)
  @HiveField(3)
  int sleepHour;

  @HiveField(4)
  int sleepMinute;

  /// Jam bangun pagi (jam:menit)
  @HiveField(5)
  int wakeHour;

  @HiveField(6)
  int wakeMinute;

  /// Level stres 0–10
  @HiveField(7)
  int stressLevel;

  /// Catatan opsional
  @HiveField(8)
  String notes;

  @HiveField(9)
  String? userId;

  MoodLog({
    required this.id,
    required this.date,
    required this.moodIndex,
    required this.sleepHour,
    required this.sleepMinute,
    required this.wakeHour,
    required this.wakeMinute,
    required this.stressLevel,
    required this.notes,
    this.userId,
  });

  MoodLevel get mood => MoodLevel.values[moodIndex.clamp(0, 4)];

  /// Durasi tidur dalam jam (desimal)
  double get sleepDurationHours {
    final bedTime  = sleepHour * 60 + sleepMinute;
    var   wakeTime = wakeHour  * 60 + wakeMinute;
    if (wakeTime <= bedTime) wakeTime += 24 * 60; // melewati tengah malam
    return (wakeTime - bedTime) / 60.0;
  }

  bool get isSleepRiskyForGerd => sleepDurationHours < 6 || stressLevel >= 7;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'mood_index': moodIndex,
        'sleep_hour': sleepHour,
        'sleep_minute': sleepMinute,
        'wake_hour': wakeHour,
        'wake_minute': wakeMinute,
        'stress_level': stressLevel,
        'notes': notes,
        'user_id': userId,
      };

  factory MoodLog.fromJson(Map<String, dynamic> json) => MoodLog(
        id: json['id'],
        date: DateTime.parse(json['date']),
        moodIndex: json['mood_index'] ?? 2,
        sleepHour: json['sleep_hour'] ?? 22,
        sleepMinute: json['sleep_minute'] ?? 0,
        wakeHour: json['wake_hour'] ?? 6,
        wakeMinute: json['wake_minute'] ?? 0,
        stressLevel: json['stress_level'] ?? 0,
        notes: json['notes'] ?? '',
        userId: json['user_id'],
      );
}
