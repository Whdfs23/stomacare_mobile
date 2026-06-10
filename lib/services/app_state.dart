import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Wajib ditambahkan
import '../models/food_entry.dart';
import '../models/mood_log.dart';
import '../models/reminder.dart';
import 'supabase_service.dart';
import 'storage_service.dart';
import 'notification_service.dart';

/// AppState V2 — ChangeNotifier, sumber kebenaran UI.
/// Data flow: Hive (lokal) ←sync→ Supabase (cloud).
/// Semua write: lokal dulu (instant UI), lalu cloud background.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  // ── State ─────────────────────────────────────────────────────────────────
  List<FoodEntry> _foodEntries = [];
  List<MoodLog>   _moodLogs   = [];
  List<Reminder>  _reminders  = [];
  bool _isSyncing = false;

  // 👉 PERUBAHAN: State Global untuk Foto Profil
  String? avatarUrl;

  List<FoodEntry> get foodEntries   => List.unmodifiable(_foodEntries);
  List<MoodLog>   get moodLogs      => List.unmodifiable(_moodLogs);
  List<Reminder>  get reminders     => List.unmodifiable(_reminders);
  bool            get isSyncing     => _isSyncing;

  // ── Auth shortcuts ────────────────────────────────────────────────────────
  bool   get isLoggedIn => SupabaseService.instance.isLoggedIn;
  String get userName   => SupabaseService.instance.userName;
  String get userEmail  => SupabaseService.instance.userEmail;
  String get userInitial => userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

  // 👉 PERUBAHAN: Fungsi untuk memperbarui foto profil dan menyimpannya ke LOKAL
  void updateAvatarUrl(String url) {
    avatarUrl = url;
    StorageService.instance.saveAvatarUrl(url); // Simpan ke brankas HP
    notifyListeners();
  }

  // ── Init setelah login ────────────────────────────────────────────────────
  Future<void> loadAll() async {
    // 1. Load lokal dulu — instant
    avatarUrl    = StorageService.instance.getAvatarUrl(); // Ambil foto dari brankas HP
    _foodEntries = StorageService.instance.getFoodEntries();
    _moodLogs    = StorageService.instance.getMoodLogs();
    _reminders   = StorageService.instance.getReminders();
    notifyListeners();

    // 2. Sync dari Supabase di background
    _syncFromCloud();
  }

  Future<void> _syncFromCloud() async {
    if (!SupabaseService.instance.isLoggedIn) return;
    _isSyncing = true;
    notifyListeners();
    try {
      // 👉 PERUBAHAN: Sinkronisasi URL foto profil dari database Supabase
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profileData = await Supabase.instance.client.from('profiles').select('avatar_url').eq('id', user.id).maybeSingle();
        if (profileData != null && profileData['avatar_url'] != null) {
          final fetchedUrl = profileData['avatar_url'] as String;
          if (avatarUrl != fetchedUrl) {
             avatarUrl = fetchedUrl;
             StorageService.instance.saveAvatarUrl(fetchedUrl); // Pastikan lokal terupdate
          }
        }
      }

      final remoteFoods     = await SupabaseService.instance.fetchFoodEntries();
      final remoteMoods     = await SupabaseService.instance.fetchMoodLogs();
      final remoteReminders = await SupabaseService.instance.fetchReminders();

      await StorageService.instance.syncFoodEntries(remoteFoods);
      await StorageService.instance.syncMoodLogs(remoteMoods);
      await StorageService.instance.syncReminders(remoteReminders);

      _foodEntries = StorageService.instance.getFoodEntries();
      _moodLogs    = StorageService.instance.getMoodLogs();
      _reminders   = StorageService.instance.getReminders();

      // Re-schedule semua notifikasi
      await NotificationService.instance.cancelAll();
      for (final r in _reminders.where((r) => r.isEnabled)) {
        await NotificationService.instance.scheduleReminder(r);
      }
    } catch (e) {
      debugPrint('Sync error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // ── FOOD ENTRY CRUD ───────────────────────────────────────────────────────

  Future<void> addFoodEntry(FoodEntry entry) async {
    entry.userId = SupabaseService.instance.currentUserId;
    await StorageService.instance.saveFoodEntry(entry);
    _foodEntries = StorageService.instance.getFoodEntries();
    notifyListeners();

    // Cloud background
    SupabaseService.instance.upsertFoodEntry(entry).catchError((e) {
      debugPrint('Cloud upsert food error: $e');
    });

    // Notif post-meal
    await NotificationService.instance.schedulePostMealReminder(entry.date);
  }

  Future<void> deleteFoodEntry(FoodEntry entry) async {
    await StorageService.instance.deleteFoodEntry(entry.id);
    _foodEntries = StorageService.instance.getFoodEntries();
    notifyListeners();

    SupabaseService.instance.deleteFoodEntry(entry.id).catchError((e) {
      debugPrint('Cloud delete food error: $e');
    });
  }

  // ── MOOD LOG CRUD ─────────────────────────────────────────────────────────

  Future<void> addMoodLog(MoodLog log) async {
    log.userId = SupabaseService.instance.currentUserId;
    await StorageService.instance.saveMoodLog(log);
    _moodLogs = StorageService.instance.getMoodLogs();
    notifyListeners();

    SupabaseService.instance.upsertMoodLog(log).catchError((e) {
      debugPrint('Cloud upsert mood error: $e');
    });
  }

  Future<void> deleteMoodLog(MoodLog log) async {
    await StorageService.instance.deleteMoodLog(log.id);
    _moodLogs = StorageService.instance.getMoodLogs();
    notifyListeners();

    SupabaseService.instance.deleteMoodLog(log.id).catchError((e) {
      debugPrint('Cloud delete mood error: $e');
    });
  }

  // ── REMINDER CRUD ─────────────────────────────────────────────────────────

  Future<void> addReminder(Reminder reminder) async {
    reminder.userId = SupabaseService.instance.currentUserId;
    await StorageService.instance.saveReminder(reminder);
    _reminders = StorageService.instance.getReminders();
    notifyListeners();

    await NotificationService.instance.scheduleReminder(reminder);

    SupabaseService.instance.upsertReminder(reminder).catchError((e) {
      debugPrint('Cloud upsert reminder error: $e');
    });
  }

  Future<void> toggleReminder(Reminder reminder) async {
    reminder.isEnabled = !reminder.isEnabled;
    await StorageService.instance.saveReminder(reminder);
    _reminders = StorageService.instance.getReminders();
    notifyListeners();

    if (reminder.isEnabled) {
      await NotificationService.instance.scheduleReminder(reminder);
    } else {
      await NotificationService.instance.cancelReminder(reminder.id);
    }

    SupabaseService.instance.upsertReminder(reminder).catchError((_) {});
  }

  Future<void> deleteReminder(Reminder reminder) async {
    await NotificationService.instance.cancelReminder(reminder.id);
    await StorageService.instance.deleteReminder(reminder.id);
    _reminders = StorageService.instance.getReminders();
    notifyListeners();

    SupabaseService.instance.deleteReminder(reminder.id).catchError((_) {});
  }

  // ── Computed / Analytics ──────────────────────────────────────────────────

  /// Risk score rata-rata 7 hari terakhir (0–10)
  double get weeklyAvgRisk {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recent = _foodEntries.where((e) => e.date.isAfter(cutoff)).toList();
    if (recent.isEmpty) return 0;
    return recent.map((e) => e.riskScore).reduce((a, b) => a + b) / recent.length;
  }

  /// Data 7 hari untuk bar chart
  List<WeeklyData> get weeklyChartData {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final entries = _foodEntries.where((e) =>
          e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day);
      final avg = entries.isEmpty
          ? 0.0
          : entries.map((e) => e.riskScore).reduce((a, b) => a + b) /
              entries.length;
      return WeeklyData(
        dayOffset: i,
        dayLabel: _dayLabel(day.weekday),
        riskScore: avg,
      );
    });
  }

  String _dayLabel(int weekday) {
    const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return labels[(weekday - 1) % 7];
  }

  /// Korelasi mood & GERD — insight untuk dashboard
  String get moodGerdInsight {
    if (_moodLogs.isEmpty || _foodEntries.isEmpty) return '';
    final recent = _moodLogs.take(7).toList();
    final highStress = recent.where((m) => m.stressLevel >= 7).length;
    final shortSleep = recent.where((m) => m.sleepDurationHours < 6).length;
    if (highStress >= 3) {
      return '⚠️ Kamu sering stres belakangan ini. Stres dapat memperparah gejala GERD.';
    }
    if (shortSleep >= 3) {
      return '😴 Tidurmu kurang dari 6 jam beberapa hari ini. Istirahat cukup penting untuk lambung!';
    }
    return '✅ Pola tidur & stresmu terlihat baik minggu ini. Pertahankan!';
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await NotificationService.instance.cancelAll();
    _foodEntries = [];
    _moodLogs    = [];
    _reminders   = [];
    
    // 👉 PERUBAHAN: Reset foto di memori state dan lokal saat logout
    avatarUrl    = null; 
    await StorageService.instance.clearAvatarUrl();
    
    notifyListeners();
    await SupabaseService.instance.signOut();
  }
}