import 'package:hive/hive.dart';

part 'food_entry.g.dart';

@HiveType(typeId: 0)
class FoodEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String mealTime;

  @HiveField(3)
  String foodName;

  @HiveField(4)
  String drink;

  @HiveField(5)
  String portion;

  @HiveField(6)
  List<String> symptoms;

  @HiveField(7)
  int painLevel;

  @HiveField(8)
  String stomachCondition;

  @HiveField(9)
  String notes;

  @HiveField(10)
  String? userId;

  FoodEntry({
    required this.id,
    required this.date,
    required this.mealTime,
    required this.foodName,
    required this.drink,
    required this.portion,
    required this.symptoms,
    required this.painLevel,
    required this.stomachCondition,
    required this.notes,
    this.userId,
  });

  int get riskScore {
    int score = painLevel;
    if (symptoms.contains('Nyeri Ulu Hati')) score += 2;
    if (symptoms.contains('Heartburn')) score += 2;
    if (symptoms.contains('Mual')) score += 1;
    if (symptoms.contains('Diare')) score += 1;
    if (symptoms.contains('Kembung')) score += 1;
    if (stomachCondition == 'Buruk') score += 1;
    return score.clamp(0, 10);
  }

  bool get isHighRisk   => riskScore >= 6;
  bool get isMediumRisk => riskScore >= 3 && riskScore < 6;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'meal_time': mealTime,
        'food_name': foodName,
        'drink': drink,
        'portion': portion,
        'symptoms': symptoms.join('|'),
        'pain_level': painLevel,
        'stomach_condition': stomachCondition,
        'notes': notes,
        'user_id': userId,
      };

  factory FoodEntry.fromJson(Map<String, dynamic> json) => FoodEntry(
        id: json['id'],
        date: DateTime.parse(json['date']),
        mealTime: json['meal_time'] ?? json['mealTime'] ?? '',
        foodName: json['food_name'] ?? json['foodName'] ?? '',
        drink: json['drink'] ?? '',
        portion: json['portion'] ?? 'Normal',
        symptoms: ((json['symptoms'] ?? '') as String)
            .split('|')
            .where((s) => s.isNotEmpty)
            .toList(),
        painLevel: json['pain_level'] ?? json['painLevel'] ?? 0,
        stomachCondition:
            json['stomach_condition'] ?? json['stomachCondition'] ?? 'Normal',
        notes: json['notes'] ?? '',
        userId: json['user_id'],
      );

  Map<String, dynamic> toMap() => toJson();
  factory FoodEntry.fromMap(Map<String, dynamic> map) => FoodEntry.fromJson(map);
}

class WeeklyData {
  final int dayOffset;
  final String dayLabel;
  final double riskScore;
  WeeklyData({
    required this.dayOffset,
    required this.dayLabel,
    required this.riskScore,
  });
}
