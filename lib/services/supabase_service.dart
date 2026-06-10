import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_entry.dart';
import '../models/mood_log.dart';
import '../models/reminder.dart';

/// Singleton wrapper untuk semua operasi Supabase.
/// SupabaseService hanya dipanggil kalau ada koneksi internet.
/// Kalau offline, StorageService (Hive) yang handle.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ── AUTH ──────────────────────────────────────────────────────────────────

  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => currentUser?.id;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> updateProfile({required String name}) async {
    await _client.auth.updateUser(UserAttributes(data: {'name': name}));
  }

  String get userName =>
      currentUser?.userMetadata?['name'] as String? ??
      currentUser?.email?.split('@').first ??
      'User';

  String get userEmail => currentUser?.email ?? '';

  // ── FOOD ENTRIES ─────────────────────────────────────────────────────────

  Future<List<FoodEntry>> fetchFoodEntries() async {
    final uid = currentUserId;
    if (uid == null) return [];
    final data = await _client
        .from('food_entries')
        .select()
        .eq('user_id', uid)
        .order('date', ascending: false);
    return (data as List).map((e) => FoodEntry.fromJson(e)).toList();
  }

  Future<void> upsertFoodEntry(FoodEntry entry) async {
    final uid = currentUserId;
    if (uid == null) return;
    entry.userId = uid;
    await _client.from('food_entries').upsert(entry.toJson());
  }

  Future<void> deleteFoodEntry(String id) async {
    await _client.from('food_entries').delete().eq('id', id);
  }

  // ── MOOD LOGS ─────────────────────────────────────────────────────────────

  Future<List<MoodLog>> fetchMoodLogs() async {
    final uid = currentUserId;
    if (uid == null) return [];
    final data = await _client
        .from('mood_logs')
        .select()
        .eq('user_id', uid)
        .order('date', ascending: false);
    return (data as List).map((e) => MoodLog.fromJson(e)).toList();
  }

  Future<void> upsertMoodLog(MoodLog log) async {
    final uid = currentUserId;
    if (uid == null) return;
    log.userId = uid;
    await _client.from('mood_logs').upsert(log.toJson());
  }

  Future<void> deleteMoodLog(String id) async {
    await _client.from('mood_logs').delete().eq('id', id);
  }

  // ── REMINDERS ─────────────────────────────────────────────────────────────

  Future<List<Reminder>> fetchReminders() async {
    final uid = currentUserId;
    if (uid == null) return [];
    final data = await _client
        .from('reminders')
        .select()
        .eq('user_id', uid);
    return (data as List).map((e) => Reminder.fromJson(e)).toList();
  }

  Future<void> upsertReminder(Reminder reminder) async {
    final uid = currentUserId;
    if (uid == null) return;
    reminder.userId = uid;
    await _client.from('reminders').upsert(reminder.toJson());
  }

  Future<void> deleteReminder(String id) async {
    await _client.from('reminders').delete().eq('id', id);
  }
}
