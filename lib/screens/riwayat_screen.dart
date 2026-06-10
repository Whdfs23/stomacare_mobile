import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/app_state.dart';
import '../models/food_entry.dart';
import 'catat_makanan_screen.dart';

class RiwayatScreen extends StatefulWidget {
  final VoidCallback onAdd;
  const RiwayatScreen({super.key, required this.onAdd});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  int _visibleCount = 5;

  String _mealTimeEmoji(String t) {
    switch (t) {
      case 'Pagi':    return '☀️';
      case 'Siang':   return '🍽️';
      case 'Malam':   return '🌙';
      case 'Camilan': return '🍪';
      default:        return '🍴';
    }
  }

  Map<String, List<FoodEntry>> _groupByDate(List<FoodEntry> entries) {
    final Map<String, List<FoodEntry>> grouped = {};
    for (final e in entries) {
      final key = DateFormat('dd MMM yyyy', 'id').format(e.date);
      grouped.putIfAbsent(key, () => []).add(e);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    // 💡 PENYELESAIAN UTAMA: Merangkul layar dengan ListenableBuilder
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final allEntries = List<FoodEntry>.from(state.foodEntries)
          ..sort((a, b) => b.date.compareTo(a.date));

        final visible = allEntries.take(_visibleCount).toList();
        final grouped = _groupByDate(visible);
        final keys    = grouped.keys.toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Riwayat', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          Text('Pantau semua catatan makanmu.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textGray)),
                        ],
                      ),
                      // FOTO PROFIL OTOMATIS TAMPIL DI SINI
                      _AvatarBadge(letter: state.userInitial, imageUrl: state.avatarUrl),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => setState(() {}),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: keys.length + 1,
                      itemBuilder: (ctx, idx) {
                        if (idx == keys.length) {
                          return Column(
                            children: [
                              if (_visibleCount < allEntries.length) ...[
                                const SizedBox(height: 12),
                                Center(
                                  child: OutlinedButton(
                                    onPressed: () => setState(() => _visibleCount += 5),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      backgroundColor: AppColors.mintBg,
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                    ),
                                    child: Text('Muat Lebih Banyak', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                  ),
                                ),
                              ] else if (allEntries.isEmpty) ...[
                                const SizedBox(height: 60),
                                Column(
                                  children: [
                                    const Icon(Icons.inbox_rounded, color: AppColors.textLight, size: 52),
                                    const SizedBox(height: 12),
                                    Text('Belum ada catatan', style: GoogleFonts.plusJakartaSans(color: AppColors.textGray, fontSize: 15)),
                                  ],
                                ),
                              ],
                            ],
                          );
                        }

                        final dateKey = keys[idx];
                        final dayEntries = grouped[dateKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: AppColors.mintBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.mintLight, width: 1)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 14),
                                  const SizedBox(width: 6),
                                  Text(dateKey, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...dayEntries.map((e) => _EntryCard(
                                  entry: e,
                                  emoji: _mealTimeEmoji(e.mealTime),
                                  onEdit: () async {
                                    await Navigator.push(context, MaterialPageRoute(builder: (_) => CatatMakananScreen(entryToEdit: e)));
                                    setState(() {}); 
                                  },
                                  onDelete: () {
                                    AppState.instance.deleteFoodEntry(e);
                                    setState(() {});
                                  },
                                )),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class _EntryCard extends StatelessWidget {
  final FoodEntry entry; final String emoji; final VoidCallback onDelete; final VoidCallback onEdit;
  const _EntryCard({required this.entry, required this.emoji, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final painColor = entry.painLevel == 0 ? AppColors.badgeGreenBg : entry.painLevel <= 4 ? AppColors.orangeBg : AppColors.pinkBg;
    final painTxtClr = entry.painLevel == 0 ? AppColors.badgeGreenText : entry.painLevel <= 4 ? AppColors.orangeText : AppColors.pinkText;

    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(child: Text(entry.foodName, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: painColor, borderRadius: BorderRadius.circular(8)),
                child: Text('Nyeri: ${entry.painLevel}/10', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: painTxtClr)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: entry.symptoms.map((s) {
              final isNormal = s == 'Tidak Ada';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: isNormal ? AppColors.inputBg : AppColors.pinkBg, borderRadius: BorderRadius.circular(8)),
                child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: isNormal ? AppColors.textGray : AppColors.pinkText)),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.mintBg, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [const Icon(Icons.edit_outlined, color: AppColors.primary, size: 16), const SizedBox(width: 4), Text('Edit', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))]),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      title: Text('Hapus Catatan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                      content: Text('Yakin menghapus "${entry.foodName}"?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                        ElevatedButton(onPressed: () { Navigator.pop(context); onDelete(); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkText), child: const Text('Hapus', style: TextStyle(color: Colors.white))),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.pinkBg, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [const Icon(Icons.delete_outline_rounded, color: AppColors.pinkText, size: 16), const SizedBox(width: 4), Text('Hapus', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.pinkText))]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String letter;
  final String? imageUrl;
  const _AvatarBadge({required this.letter, this.imageUrl});
  
  @override
  Widget build(BuildContext context) {
    // Trik memaksa Flutter merefresh gambar dengan menambahkan argumen timestamp palsu
    final String? refreshedImageUrl = imageUrl != null 
        ? '$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}' 
        : null;

    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: AppColors.mintLight, 
        shape: BoxShape.circle, 
        border: Border.all(color: AppColors.primary, width: 2),
        image: refreshedImageUrl != null 
            ? DecorationImage(image: NetworkImage(refreshedImageUrl), fit: BoxFit.cover) 
            : null,
      ),
      child: imageUrl == null 
          ? Center(child: Text(letter, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary))) 
          : null,
    );
  }
}