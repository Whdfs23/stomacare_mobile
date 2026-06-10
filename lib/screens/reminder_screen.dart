import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_colors.dart';
import '../models/reminder.dart';
import '../services/app_state.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});
  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  @override
  Widget build(BuildContext context) {
    final reminders = AppState.instance.reminders;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Reminder',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            )),
        actions: [
          TextButton.icon(
            onPressed: _showAddReminderSheet,
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            label: Text('Tambah',
                style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: reminders.isEmpty
          ? _EmptyState(onAdd: _showAddReminderSheet)
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final r = reminders[i];
                return _ReminderCard(
                  reminder: r,
                  onToggle: () => AppState.instance.toggleReminder(r)
                      .then((_) => setState(() {})),
                  onDelete: () => _confirmDelete(r),
                );
              },
            ),
    );
  }

  void _confirmDelete(Reminder r) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Hapus Reminder',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text('Hapus reminder "${r.title}"?',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textGray)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(color: AppColors.textGray)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppState.instance.deleteReminder(r)
                  .then((_) => setState(() {}));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoutRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Hapus',
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showAddReminderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddReminderSheet(
        onSaved: () => setState(() {}),
      ),
    );
  }
}

// ── Add Reminder Bottom Sheet ─────────────────────────────────────────────────

class _AddReminderSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddReminderSheet({required this.onSaved});
  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final _titleCtrl = TextEditingController();
  ReminderType _type = ReminderType.makan;
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);
  List<int> _activeDays = [1, 2, 3, 4, 5, 6, 7];
  bool _isSaving = false;

  final _dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  void dispose() { _titleCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    final r = Reminder(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      typeIndex: _type.index,
      hour: _time.hour,
      minute: _time.minute,
      activeDays: _activeDays,
    );
    await AppState.instance.addReminder(r);
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final h = _time.hour.toString().padLeft(2, '0');
    final m = _time.minute.toString().padLeft(2, '0');
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Tambah Reminder',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                )),
            const SizedBox(height: 16),

            // Judul
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputBg, borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _titleCtrl,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Nama reminder (contoh: Sarapan)',
                  hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14, color: AppColors.textLight),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Tipe
            Text('Tipe',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: AppColors.textGray)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ReminderType.values.map((t) {
                final sel = _type == t;
                return GestureDetector(
                  onTap: () => setState(() => _type = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.mintBg : AppColors.inputBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? AppColors.primary : Colors.transparent,
                          width: 1.5),
                    ),
                    child: Text('${t.emoji} ${t.label}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? AppColors.primary : AppColors.textGray,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Waktu
            Row(
              children: [
                Text('Jam',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.textGray)),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context, initialTime: _time,
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.light(
                              primary: AppColors.primary),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setState(() => _time = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.mintBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.mintLight),
                    ),
                    child: Text('$h:$m',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Hari aktif
            Text('Hari Aktif',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: AppColors.textGray)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final day = i + 1;
                final active = _activeDays.contains(day);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (active) _activeDays.remove(day);
                    else _activeDays.add(day);
                  }),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.inputBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(_dayLabels[i],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : AppColors.textGray,
                          )),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('Simpan Reminder',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reminder Card ─────────────────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  const _ReminderCard({required this.reminder, required this.onToggle,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final r = reminder;
    final dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: r.isEnabled ? Colors.white : AppColors.inputBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: r.isEnabled
            ? [BoxShadow(color: Colors.black.withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, 2))]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: r.isEnabled ? AppColors.mintBg : AppColors.inputBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(r.type.emoji,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: r.isEnabled
                          ? AppColors.textDark
                          : AppColors.textLight,
                    )),
                const SizedBox(height: 2),
                Text(r.type.label,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: AppColors.textGray)),
                const SizedBox(height: 6),
                Wrap(spacing: 4, runSpacing: 4,
                  children: (r.activeDays.isEmpty
                      ? List.generate(7, (i) => i + 1)
                      : r.activeDays)
                    .map((d) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: r.isEnabled
                            ? AppColors.mintBg : AppColors.inputBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(dayLabels[d - 1],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10, fontWeight: FontWeight.w600,
                            color: r.isEnabled
                                ? AppColors.primary
                                : AppColors.textLight,
                          )),
                    )).toList(),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(r.timeLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: r.isEnabled
                        ? AppColors.primary
                        : AppColors.textLight,
                  )),
              const SizedBox(height: 4),
              Switch(
                value: r.isEnabled,
                onChanged: (_) => onToggle(),
                activeColor: AppColors.primary,
              ),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.textLight, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔔', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('Belum ada reminder',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              )),
          const SizedBox(height: 8),
          Text('Tambah jadwal makan atau minum obatmu',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, color: AppColors.textGray)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text('Tambah Reminder',
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
