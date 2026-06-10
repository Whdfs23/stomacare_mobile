import 'package:flutter/foundation.dart'; // 👉 WAJIB UNTUK UTK CEK kIsWeb
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/reminder.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId   = 'stomacare_channel';
  static const _channelName = 'StomaCare Reminders';
  static const _channelDesc = 'Notifikasi jadwal makan, obat, dan kesehatan';

  Future<void> init() async {
    // Jika dijalankan di Web/Browser, matikan fungsi agar tidak crash!
    if (kIsWeb) return; 

    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      // UBAH BARIS INI:
      const android = AndroidInitializationSettings('@mipmap/launcher_icon');
      const ios     = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
    } catch (e) {
      debugPrint('Error init notification: $e');
    }
  }

  Future<void> requestPermission() async {
    if (kIsWeb) return; // Pelindung Web

    // 1. Minta izin memunculkan jendela notifikasi biasa
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // 👉 TAMBAHKAN BARIS INI: Minta izin Android untuk mengeksekusi alarm tepat waktu (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // ── Jadwal ulang semua reminder aktif ─────────────────────────────────────
  Future<void> scheduleReminder(Reminder reminder) async {
    if (kIsWeb) return; // Pelindung Web

    if (!reminder.isEnabled) {
      await cancelReminder(reminder.id);
      return;
    }

    // 👉 PERBAIKAN: Menambahkan const agar tidak kuning/warning
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      ),
      iOS: DarwinNotificationDetails(),
    );

    for (final day in reminder.activeDays) {
      final id = _notifId(reminder.id, day);
      final scheduledDate = _nextWeekday(day, reminder.hour, reminder.minute);

      await _plugin.zonedSchedule(
        id,
        '${reminder.type.emoji} ${reminder.title}',
        _bodyForType(reminder.type),
        scheduledDate,
        details,
        // 👉 PERBAIKAN: Dikembalikan ke exactAllowWhileIdle karena manifest sudah diisi izin
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelReminder(String reminderId) async {
    if (kIsWeb) return; // Pelindung Web
    for (int day = 1; day <= 7; day++) {
      await _plugin.cancel(_notifId(reminderId, day));
    }
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return; // Pelindung Web
    await _plugin.cancelAll();
  }

  // ── One-shot notifikasi langsung (untuk testing) ───────────────────────────
  Future<void> showInstant({
    required String title,
    required String body,
    int id = 9999,
  }) async {
    if (kIsWeb) return; // Pelindung Web
    await _plugin.show(
      id,
      title,
      body,
      // 👉 PERBAIKAN: Menambahkan const agar tidak kuning/warning
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ── Reminder khusus: jangan langsung tiduran setelah makan ───────────────
  Future<void> schedulePostMealReminder(DateTime mealTime) async {
    if (kIsWeb) return; // Pelindung Web

    // KHUSUS DEMO: Kita buat 5 DETIK setelah klik simpan agar langsung muncul di HP!
    final notifTime = DateTime.now().add(const Duration(seconds: 5)); 
    
    if (notifTime.isBefore(DateTime.now())) return; 

    final tzTime = tz.TZDateTime.from(notifTime, tz.local);
    
    await _plugin.zonedSchedule(
      mealTime.hashCode.abs(), 
      '😴 Ingat! Jangan langsung tiduran',
      'Sudah 2.5 jam sejak makan. Boleh istirahat sekarang, tapi hindari langsung berbaring ya!',
      tzTime,
      // 👉 PERBAIKAN: Menambahkan const agar tidak kuning/warning
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // 👉 PERBAIKAN: Dikembalikan ke exactAllowWhileIdle karena manifest sudah aman
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  int _notifId(String reminderId, int day) {
    return (reminderId.hashCode.abs() % 100000) * 10 + day;
  }

  tz.TZDateTime _nextWeekday(int weekday, int hour, int minute) {
    var now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day, hour, minute,
    );
    while (candidate.weekday != weekday || candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  String _bodyForType(ReminderType type) {
    switch (type) {
      case ReminderType.makan:
        return 'Waktunya makan! Jangan skip makan — penting banget untuk kesehatan lambungmu 🍽️';
      case ReminderType.obat:
        return 'Saatnya minum obat. Konsistensi adalah kunci pemulihan 💊';
      case ReminderType.tidur:
        return 'Waktunya istirahat. Tidur cukup membantu mengurangi risiko GERD 😴';
      case ReminderType.custom:
        return 'Pengingat dari StomaCare 🔔';
    }
  }
}