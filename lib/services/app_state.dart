import '../models/food_entry.dart';

class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // ─── Auth ─────────────────────────────────────────────────────────────────
  String username = 'zulfa';
  bool isLoggedIn = false;

  void login(String user) {
    username = user;
    isLoggedIn = true;
  }

  void logout() {
    isLoggedIn = false;
  }

  // ─── Sample Data ───────────────────────────────────────────────────────────
  List<FoodEntry> entries = [
    FoodEntry(
      id: '1',
      date: DateTime(2026, 5, 7, 20, 0),
      mealTime: 'Malam',
      foodName: 'Sup Ayam Bening',
      drink: 'Teh Tawar Hangat',
      portion: 'Normal',
      symptoms: ['Tidak Ada'],
      painLevel: 1,
      stomachCondition: 'Baik',
      notes: '',
    ),
    FoodEntry(
      id: '2',
      date: DateTime(2026, 5, 7, 12, 0),
      mealTime: 'Siang',
      foodName: 'Nasi Padang Lauk Rendang',
      drink: 'Es Teh Manis',
      portion: 'Banyak',
      symptoms: ['Nyeri Ulu Hati', 'Sendawa', 'Kembung'],
      painLevel: 7,
      stomachCondition: 'Buruk',
      notes: 'Terlalu pedas',
    ),
    FoodEntry(
      id: '3',
      date: DateTime(2026, 5, 7, 7, 0),
      mealTime: 'Pagi',
      foodName: 'Bubur Sumsum Hangat',
      drink: 'Air Putih',
      portion: 'Normal',
      symptoms: ['Tidak Ada'],
      painLevel: 0,
      stomachCondition: 'Baik',
      notes: '',
    ),
    FoodEntry(
      id: '4',
      date: DateTime(2026, 5, 6, 12, 0),
      mealTime: 'Siang',
      foodName: 'Roti Gandum & Telur Rebus',
      drink: 'Air Putih',
      portion: 'Normal',
      symptoms: ['Tidak Ada'],
      painLevel: 0,
      stomachCondition: 'Baik',
      notes: '',
    ),
    FoodEntry(
      id: '5',
      date: DateTime(2026, 5, 6, 18, 0),
      mealTime: 'Siang',
      foodName: 'Ayam Geprek Cabai 10',
      drink: 'Es Jeruk',
      portion: 'Normal',
      symptoms: ['Nyeri Ulu Hati', 'Mual', 'Diare', 'Heartburn'],
      painLevel: 9,
      stomachCondition: 'Buruk',
      notes: 'Sangat pedas, menyesal',
    ),
    FoodEntry(
      id: '6',
      date: DateTime(2026, 5, 5, 7, 0),
      mealTime: 'Pagi',
      foodName: 'Oatmeal + Pisang',
      drink: 'Susu Rendah Lemak',
      portion: 'Normal',
      symptoms: ['Tidak Ada'],
      painLevel: 0,
      stomachCondition: 'Baik',
      notes: '',
    ),
  ];

  // ─── Computed ──────────────────────────────────────────────────────────────
  int get todayRiskScore {
    final now = DateTime.now();
    final todayEntries = entries.where((e) =>
        e.date.year == now.year &&
        e.date.month == now.month &&
        e.date.day == now.day);
    if (todayEntries.isEmpty) return 0;
    final avg = todayEntries.map((e) => e.riskScore).reduce((a, b) => a + b) /
        todayEntries.length;
    return avg.round().clamp(0, 10);
  }

  String get todayRiskStatus {
    final score = todayRiskScore;
    if (score == 0) return 'Aman';
    if (score <= 3) return 'Ringan';
    if (score <= 6) return 'Sedang';
    return 'Berbahaya';
  }

  String get todayMotivation {
    final status = todayRiskStatus;
    if (status == 'Aman') return 'Kondisi lambungmu terpantau baik hari ini.\nPertahankan pola makanmu!';
    if (status == 'Ringan') return 'Ada sedikit gejala hari ini.\nJaga pola makanmu ya!';
    if (status == 'Sedang') return 'Lambungmu butuh perhatian.\nHindari makanan pemicu hari ini.';
    return 'Kondisi lambung membutuhkan istirahat.\nMakan makanan ringan dan minum air putih.';
  }

  List<FoodEntry> get recentEntries {
    final sorted = List<FoodEntry>.from(entries)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(3).toList();
  }

  List<String> get suspectPemicu {
    return entries
        .where((e) => e.isHighRisk)
        .map((e) => e.foodName)
        .toSet()
        .toList();
  }

  List<WeeklyData> get weeklyData {
    final now = DateTime.now();
    final List<WeeklyData> result = [];
    for (int i = -6; i <= 0; i++) {
      final day = now.add(Duration(days: i));
      final dayEntries = entries.where((e) =>
          e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day);
      double score = 0;
      if (dayEntries.isNotEmpty) {
        score = dayEntries.map((e) => e.riskScore.toDouble()).reduce((a, b) => a + b) /
            dayEntries.length;
      }
      result.add(WeeklyData(
        dayOffset: i,
        dayLabel: day.day.toString().padLeft(2, '0'),
        riskScore: score,
      ));
    }
    return result;
  }

  void addEntry(FoodEntry entry) {
    entries.insert(0, entry);
  }

  String getDietRecommendation() {
    final recentSymptoms = recentEntries
        .expand((e) => e.symptoms)
        .toSet()
        .toList();

    if (recentSymptoms.contains('Heartburn') || recentSymptoms.contains('Nyeri Ulu Hati')) {
      return '🔴 Hindari makanan asam & pedas hari ini. Minum air hangat setelah makan dan istirahat cukup.';
    }
    if (recentSymptoms.contains('Kembung') || recentSymptoms.contains('Sendawa')) {
      return '🟡 Kurangi minuman bersoda & makanan bergas. Makan perlahan dan dalam porsi kecil.';
    }
    if (recentSymptoms.contains('Mual')) {
      return '🟡 Pilih makanan ringan seperti bubur atau roti. Hindari makanan berlemak tinggi hari ini.';
    }
    if (recentSymptoms.contains('Diare')) {
      return '🟠 Perbanyak air putih, konsumsi makanan BRAT (Banana, Rice, Applesauce, Toast).';
    }
    return '🟢 Lambungmu dalam kondisi baik! Pertahankan pola makan sehat. Minum 8 gelas air per hari.';
  }
}
