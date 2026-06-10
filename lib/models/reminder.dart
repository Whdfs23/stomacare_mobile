import 'package:hive/hive.dart';

part 'reminder.g.dart';

enum ReminderType { makan, obat, tidur, custom }

extension ReminderTypeExt on ReminderType {
  String get label {
    switch (this) {
      case ReminderType.makan:  return 'Jadwal Makan';
      case ReminderType.obat:   return 'Minum Obat';
      case ReminderType.tidur:  return 'Istirahat';
      case ReminderType.custom: return 'Custom';
    }
  }
  String get emoji {
    switch (this) {
      case ReminderType.makan:  return '🍽️';
      case ReminderType.obat:   return '💊';
      case ReminderType.tidur:  return '😴';
      case ReminderType.custom: return '🔔';
    }
  }
}

@HiveType(typeId: 2)
class Reminder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int typeIndex; // ReminderType.index

  @HiveField(3)
  int hour;

  @HiveField(4)
  int minute;

  /// Hari aktif: 1=Sen, 2=Sel, ..., 7=Min. Kosong = setiap hari
  @HiveField(5)
  List<int> activeDays;

  @HiveField(6)
  bool isEnabled;

  @HiveField(7)
  String? userId;

  Reminder({
    required this.id,
    required this.title,
    required this.typeIndex,
    required this.hour,
    required this.minute,
    this.activeDays = const [1, 2, 3, 4, 5, 6, 7],
    this.isEnabled = true,
    this.userId,
  });

  ReminderType get type => ReminderType.values[typeIndex.clamp(0, 3)];

  String get timeLabel {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type_index': typeIndex,
        'hour': hour,
        'minute': minute,
        'active_days': activeDays.join(','),
        'is_enabled': isEnabled,
        'user_id': userId,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'],
        title: json['title'] ?? '',
        typeIndex: json['type_index'] ?? 0,
        hour: json['hour'] ?? 8,
        minute: json['minute'] ?? 0,
        activeDays: ((json['active_days'] ?? '1,2,3,4,5,6,7') as String)
            .split(',')
            .where((s) => s.isNotEmpty)
            .map(int.parse)
            .toList(),
        isEnabled: json['is_enabled'] ?? true,
        userId: json['user_id'],
      );
}
