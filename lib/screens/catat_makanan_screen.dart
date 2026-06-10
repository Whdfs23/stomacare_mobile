import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/app_state.dart';
import '../models/food_entry.dart';

class CatatMakananScreen extends StatefulWidget {
  final FoodEntry? entryToEdit;
  const CatatMakananScreen({super.key, this.entryToEdit});

  @override
  State<CatatMakananScreen> createState() => _CatatMakananScreenState();
}

class _CatatMakananScreenState extends State<CatatMakananScreen> {
  String _selectedMealTime = 'Pagi';
  DateTime _selectedDate = DateTime.now();
  final _foodCtrl      = TextEditingController();
  final _drinkCtrl     = TextEditingController();
  String _portion      = 'Normal';
  Set<String> _selectedSymptoms = {};
  double _painLevel    = 0;
  final _conditionCtrl = TextEditingController();
  final _notesCtrl     = TextEditingController();
  
  // PENANDA LOADING AGAR USER TIDAK SPAM KLIK
  bool _isSaving = false; 

  static const List<String> _mealTimes = ['Pagi', 'Siang', 'Malam', 'Camilan'];
  static const List<String> _portions  = ['Sedikit', 'Normal', 'Banyak'];
  static const List<String> _symptoms  = ['Mual', 'Kembung', 'Nyeri Ulu Hati', 'Heartburn', 'Sendawa', 'Diare', 'Tidak Ada'];

  @override
  void initState() {
    super.initState();
    if (widget.entryToEdit != null) {
      final e = widget.entryToEdit!;
      _selectedMealTime = e.mealTime;
      _selectedDate = e.date;
      _foodCtrl.text = e.foodName;
      _drinkCtrl.text = e.drink;
      _portion = e.portion;
      _selectedSymptoms = e.symptoms.toSet();
      _painLevel = e.painLevel.toDouble();
      _conditionCtrl.text = e.stomachCondition;
      _notesCtrl.text = e.notes;
    }
  }

  String get _painLabel {
    if (_painLevel == 0)  return 'Tidak Ada';
    if (_painLevel <= 2)  return 'Sangat Ringan';
    if (_painLevel <= 4)  return 'Ringan';
    if (_painLevel <= 6)  return 'Sedang';
    if (_painLevel <= 8)  return 'Berat';
    return 'Berat Sekali';
  }

  Color get _painColor {
    if (_painLevel == 0)  return AppColors.badgeGreenText;
    if (_painLevel <= 3)  return AppColors.orangeText;
    if (_painLevel <= 6)  return const Color(0xFFD97706);
    return AppColors.pinkText;
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: _selectedDate, firstDate: DateTime(2024), lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)), child: child!),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (_foodCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama makanan wajib diisi!'), backgroundColor: AppColors.pinkText));
      return;
    }

    setState(() => _isSaving = true); // Tampilkan Loading Muter-muter

    final entryId = widget.entryToEdit != null ? widget.entryToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString();

    final entry = FoodEntry(
      id: entryId,
      date: _selectedDate,
      mealTime: _selectedMealTime,
      foodName: _foodCtrl.text.trim(),
      drink: _drinkCtrl.text.trim(),
      portion: _portion,
      symptoms: _selectedSymptoms.isEmpty ? ['Tidak Ada'] : _selectedSymptoms.toList(),
      painLevel: _painLevel.toInt(),
      stomachCondition: _conditionCtrl.text.trim().isEmpty ? 'Normal' : _conditionCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    try {
      if (widget.entryToEdit != null) {
        await AppState.instance.deleteFoodEntry(widget.entryToEdit!);
      }
      await AppState.instance.addFoodEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.entryToEdit != null ? 'Catatan berhasil diperbarui! ✅' : 'Catatan berhasil disimpan! ✅'), backgroundColor: AppColors.primary));
        Navigator.pop(context, true); // Kembali ke Riwayat
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan catatan.'), backgroundColor: AppColors.pinkText));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id').format(_selectedDate);
    final isEditMode = widget.entryToEdit != null; 

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(isEditMode ? 'Edit Catatan' : 'Catat Makanan', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGray)),
                  const SizedBox(height: 4),
                  Text(isEditMode ? 'Perbarui Data 📝' : 'Halo, ${AppState.instance.userName}! 👋', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 24),

                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Waktu Makan', required: true),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 3.2,
                          children: _mealTimes.map((t) {
                            final isSelected = _selectedMealTime == t;
                            String emoji = t == 'Pagi' ? '☀️' : t == 'Siang' ? '🍽️' : t == 'Malam' ? '🌙' : '🍪';
                            return GestureDetector(
                              onTap: () => setState(() => _selectedMealTime = t),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(color: isSelected ? AppColors.primary : const Color(0xFFF1F5F1), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent)),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(emoji, style: const TextStyle(fontSize: 16)), const SizedBox(width: 6), Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textMedium))]),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Tanggal', required: true),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [Expanded(child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate), style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.textDark))), const Icon(Icons.calendar_today_outlined, color: AppColors.textGray, size: 18)]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Makanan', required: true),
                        const SizedBox(height: 10),
                        _AppTextField(controller: _foodCtrl, hint: 'cth: Nasi goreng...', maxLines: 2),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_FieldLabel('Minuman'), const SizedBox(height: 8), _AppTextField(controller: _drinkCtrl, hint: 'cth: Air putih...')])),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Porsi'),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(12)),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _portion, isExpanded: true,
                                        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textDark),
                                        items: _portions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                                        onChanged: (v) => setState(() => _portion = v!),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Gejala Setelah Makan'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: _symptoms.map((s) {
                            final isSelected = _selectedSymptoms.contains(s);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (s == 'Tidak Ada') { _selectedSymptoms.clear(); _selectedSymptoms.add('Tidak Ada'); } 
                                  else { _selectedSymptoms.remove('Tidak Ada'); isSelected ? _selectedSymptoms.remove(s) : _selectedSymptoms.add(s); }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(color: isSelected ? AppColors.pinkBg : AppColors.inputBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? AppColors.pinkText : Colors.transparent, width: 1.5)),
                                child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppColors.pinkText : AppColors.textMedium)),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _FieldLabel('Tingkat Nyeri'),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.orangeBg, borderRadius: BorderRadius.circular(8)),
                              child: Column(children: [Text(_painLevel.toInt().toString(), style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: _painColor)), Text(_painLabel, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: _painColor, fontWeight: FontWeight.w600))]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(activeTrackColor: AppColors.primary, thumbColor: AppColors.primary, overlayColor: AppColors.primary.withValues(alpha: 0.15), thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10), trackHeight: 5),
                          child: Slider(value: _painLevel, min: 0, max: 10, divisions: 10, onChanged: (v) => setState(() => _painLevel = v)),
                        ),
                        const SizedBox(height: 24),
                        _FieldLabel('Kondisi Lambung (Opsional)'),
                        const SizedBox(height: 8),
                        _AppTextField(controller: _conditionCtrl, hint: 'cth: Buruk...'),
                        const SizedBox(height: 16),
                        _FieldLabel('Catatan Tambahan (Opsional)'),
                        const SizedBox(height: 8),
                        _AppTextField(controller: _notesCtrl, hint: 'Opsional...', maxLines: 3),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, -4))]),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0),
                    child: _isSaving 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                        : Text(isEditMode ? 'Simpan Perubahan' : 'Simpan', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child; const _SectionCard({required this.child});
  @override Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: child);
}

class _FieldLabel extends StatelessWidget {
  final String text; final bool required; const _FieldLabel(this.text, {this.required = false});
  @override Widget build(BuildContext context) => Row(children: [Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)), if (required) const Text(' *', style: TextStyle(color: AppColors.pinkText, fontSize: 14))]);
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller; final String hint; final int maxLines;
  const _AppTextField({required this.controller, required this.hint, this.maxLines = 1});
  @override Widget build(BuildContext context) => TextField(controller: controller, maxLines: maxLines, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textDark), decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textLight), filled: true, fillColor: AppColors.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)));
}