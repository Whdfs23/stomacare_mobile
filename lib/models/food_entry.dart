class FoodEntry {
  final String id;
  final DateTime date;
  final String mealTime; // 'Pagi', 'Siang', 'Malam', 'Camilan'
  final String foodName;
  final String drink;
  final String portion;
  final List<String> symptoms;
  final int painLevel;
  final String stomachCondition;
  final String notes;

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

  bool get isHighRisk => riskScore >= 6;
  bool get isMediumRisk => riskScore >= 3 && riskScore < 6;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mealTime': mealTime,
      'foodName': foodName,
      'drink': drink,
      'portion': portion,
      'symptoms': symptoms.join('|'),
      'painLevel': painLevel,
      'stomachCondition': stomachCondition,
      'notes': notes,
    };
  }

  factory FoodEntry.fromMap(Map<String, dynamic> map) {
    return FoodEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      mealTime: map['mealTime'],
      foodName: map['foodName'],
      drink: map['drink'],
      portion: map['portion'],
      symptoms: (map['symptoms'] as String)
          .split('|')
          .where((s) => s.isNotEmpty)
          .toList(),
      painLevel: map['painLevel'],
      stomachCondition: map['stomachCondition'],
      notes: map['notes'],
    );
  }
}

class WeeklyData {
  final int dayOffset; // 0 = today, -1 = yesterday, etc.
  final String dayLabel;
  final double riskScore;
  WeeklyData({
    required this.dayOffset,
    required this.dayLabel,
    required this.riskScore,
  });
}
