import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_entry.dart';
import '../models/mood_log.dart';
import '../models/reminder.dart';

/// Hive-based local storage — offline-first, selalu tersedia.
/// Ini sumber kebenaran utama di device. Supabase sinkron di atas ini.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _foodBox     = 'food_entries';
  static const _moodBox     = 'mood_logs';
  static const _reminderBox = 'reminders';
  
  // 👉 TAMBAHAN UNTUK PROFIL: Gunakan box khusus user/setting
  static const _userBox     = 'user_settings';

  /// Panggil sekali di main() sebelum runApp
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FoodEntryAdapter());
    Hive.registerAdapter(MoodLogAdapter());
    Hive.registerAdapter(ReminderAdapter());
    
    await Hive.openBox<FoodEntry>(_foodBox);
    await Hive.openBox<MoodLog>(_moodBox);
    await Hive.openBox<Reminder>(_reminderBox);
    await Hive.openBox<String>(_userBox); // Buka brankas untuk foto profil
  }

  // ── USER SETTINGS (PROFIL) ────────────────────────────────────────────────
  
  Box<String> get _user => Hive.box<String>(_userBox);

  void saveAvatarUrl(String url) {
    _user.put('avatar_url', url);
  }

  String? getAvatarUrl() {
    return _user.get('avatar_url');
  }

  Future<void> clearAvatarUrl() async {
    await _user.delete('avatar_url');
  }

  // ── FOOD ENTRIES ─────────────────────────────────────────────────────────

  Box<FoodEntry> get _food => Hive.box<FoodEntry>(_foodBox);

  List<FoodEntry> getFoodEntries() {
    final list = _food.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> saveFoodEntry(FoodEntry entry) async {
    await _food.put(entry.id, entry);
  }

  Future<void> deleteFoodEntry(String id) async {
    await _food.delete(id);
  }

  /// Sync dari Supabase — replace semua entry lokal milik user ini
  Future<void> syncFoodEntries(List<FoodEntry> remote) async {
    await _food.clear();
    for (final e in remote) {
      await _food.put(e.id, e);
    }
  }

  // ── MOOD LOGS ─────────────────────────────────────────────────────────────

  Box<MoodLog> get _mood => Hive.box<MoodLog>(_moodBox);

  List<MoodLog> getMoodLogs() {
    final list = _mood.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> saveMoodLog(MoodLog log) async {
    await _mood.put(log.id, log);
  }

  Future<void> deleteMoodLog(String id) async {
    await _mood.delete(id);
  }

  Future<void> syncMoodLogs(List<MoodLog> remote) async {
    await _mood.clear();
    for (final l in remote) {
      await _mood.put(l.id, l);
    }
  }

  // ── REMINDERS ─────────────────────────────────────────────────────────────

  Box<Reminder> get _reminders => Hive.box<Reminder>(_reminderBox);

  List<Reminder> getReminders() => _reminders.values.toList();

  Future<void> saveReminder(Reminder reminder) async {
    await _reminders.put(reminder.id, reminder);
  }

  Future<void> deleteReminder(String id) async {
    await _reminders.delete(id);
  }

  Future<void> syncReminders(List<Reminder> remote) async {
    await _reminders.clear();
    for (final r in remote) {
      await _reminders.put(r.id, r);
    }
  }
}