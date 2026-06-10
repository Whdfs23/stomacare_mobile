import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_colors.dart';
import '../models/mood_log.dart';
import '../services/app_state.dart';

class MoodLogScreen extends StatefulWidget {
  const MoodLogScreen({super.key});
  @override
  State<MoodLogScreen> createState() => _MoodLogScreenState();
}

class _MoodLogScreenState extends State<MoodLogScreen> {
  int _selectedMood = 2; // neutral
  TimeOfDay _sleepTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime  = const TimeOfDay(hour: 6, minute: 0);
  int _stressLevel = 3;
  final _notesCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _sleepDuration {
    final bed  = _sleepTime.hour  * 60 + _sleepTime.minute;
    var   wake = _wakeTime.hour   * 60 + _wakeTime.minute;
    if (wake <= bed) wake += 24 * 60;
    return (wake - bed) / 60.0;
  }

  String get _sleepInsight {
    final h = _sleepDuration;
    if (h < 5)   return '😰 Tidur sangat kurang! Risiko GERD meningkat signifikan.';
    if (h < 6)   return '⚠️ Kurang tidur. Usahakan minimal 7 jam untuk lambung sehat.';
    if (h < 7)   return '🔶 Tidur cukup, tapi bisa lebih baik.';
    if (h <= 9)  return '✅ Durasi tidur ideal untuk kesehatan lambung!';
    return '😪 Terlalu lama tidur bisa mempengaruhi asam lambung juga.';
  }

  String get _stressInsight {
    if (_stressLevel >= 8) return '🚨 Stres tinggi! Kortisol meningkatkan produksi asam lambung.';
    if (_stressLevel >= 5) return '⚠️ Stres sedang. Coba teknik relaksasi seperti napas dalam.';
    return '✅ Level stres terkendali. Bagus!';
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final log = MoodLog(
      id: const Uuid().v4(),
      date: DateTime.now(),
      moodIndex: _selectedMood,
      sleepHour: _sleepTime.hour,
      sleepMinute: _sleepTime.minute,
      wakeHour: _wakeTime.hour,
      wakeMinute: _wakeTime.minute,
      stressLevel: _stressLevel,
      notes: _notesCtrl.text.trim(),
    );
    await AppState.instance.addMoodLog(log);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log mood berhasil disimpan ✅'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Catat Mood & Tidur',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Mood Picker ───────────────────────────────────────────────
            _SectionCard(
              title: 'Bagaimana perasaanmu hari ini?',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(MoodLevel.values.length, (i) {
                  final mood     = MoodLevel.values[i];
                  final selected = _selectedMood == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      // PERBAIKAN: Melebarkan container agar teks tidak kepotong (overflow)
                      width: 60, height: 74, 
                      decoration: BoxDecoration(
                        color: selected ? AppColors.mintBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(mood.emoji, style: TextStyle(
                              fontSize: selected ? 24 : 20)),
                          const SizedBox(height: 2),
                          // Memastikan teks lebih kecil agar muat
                          Text(mood.label,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8, 
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textGray,
                              )),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // ── Tidur ─────────────────────────────────────────────────────
            _SectionCard(
              title: '😴 Tidur Malam',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _TimePicker(
                        label: 'Jam Tidur',
                        time: _sleepTime,
                        onChanged: (t) => setState(() => _sleepTime = t),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _TimePicker(
                        label: 'Jam Bangun',
                        time: _wakeTime,
                        onChanged: (t) => setState(() => _wakeTime = t),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _sleepDuration < 6
                          ? AppColors.pinkBg
                          : AppColors.mintBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_sleepInsight,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: _sleepDuration < 6
                                    ? AppColors.pinkText
                                    : AppColors.primary,
                              )),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Durasi: ${_sleepDuration.toStringAsFixed(1)} jam',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: AppColors.textGray),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Stres ─────────────────────────────────────────────────────
            _SectionCard(
              title: '🧠 Level Stres Hari Ini',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Santai',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: AppColors.textGray)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: _stressLevel >= 7
                              ? AppColors.pinkBg
                              : _stressLevel >= 4
                                  ? AppColors.orangeBg
                                  : AppColors.mintBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('$_stressLevel / 10',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14, fontWeight: FontWeight.w700,
                              color: _stressLevel >= 7
                                  ? AppColors.pinkText
                                  : _stressLevel >= 4
                                      ? AppColors.orangeText
                                      : AppColors.primary,
                            )),
                      ),
                      Text('Sangat Stres',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: AppColors.textGray)),
                    ],
                  ),
                  Slider(
                    value: _stressLevel.toDouble(),
                    min: 0, max: 10,
                    divisions: 10,
                    activeColor: _stressLevel >= 7
                        ? AppColors.pinkText
                        : _stressLevel >= 4
                            ? AppColors.orangeText
                            : AppColors.primary,
                    onChanged: (v) => setState(() => _stressLevel = v.round()),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _stressLevel >= 7
                          ? AppColors.pinkBg
                          : AppColors.mintBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(_stressInsight,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: _stressLevel >= 7
                              ? AppColors.pinkText
                              : AppColors.primary,
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Notes ─────────────────────────────────────────────────────
            _SectionCard(
              title: '📝 Catatan (opsional)',
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: 'Ceritakan lebih lanjut tentang harimu...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: AppColors.textLight),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Save button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded, color: Colors.white),
                label: Text('Simpan Log',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              )),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;
  const _TimePicker({required this.label, required this.time, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.mintBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mintLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: AppColors.textGray)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 6),
                Text('$h:$m',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}