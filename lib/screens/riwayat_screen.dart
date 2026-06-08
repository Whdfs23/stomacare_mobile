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

  // Group entries by date
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
    final allEntries = List<FoodEntry>.from(AppState().entries)
      ..sort((a, b) => b.date.compareTo(a.date));

    final visible = allEntries.take(_visibleCount).toList();
    final grouped = _groupByDate(visible);
    final keys    = grouped.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── Header ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Riwayat',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              )),
                          Text('Pantau semua catatan makanmu.',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13, color: AppColors.textGray)),
                        ],
                      ),
                      _AvatarBadge(
                          letter: AppState().username[0].toUpperCase()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── List ───────────────────────────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => setState(() {}),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: keys.length + 1,
                      itemBuilder: (ctx, idx) {
                        if (idx == keys.length) {
                          // Load more / end
                          return Column(
                            children: [
                              if (_visibleCount < allEntries.length) ...[
                                const SizedBox(height: 12),
                                Center(
                                  child: OutlinedButton(
                                    onPressed: () => setState(
                                        () => _visibleCount += 5),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: AppColors.primary
                                              .withOpacity(0.4)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      backgroundColor: AppColors.mintBg,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 12),
                                    ),
                                    child: Text('Muat Lebih Banyak',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        )),
                                  ),
                                ),
                              ] else if (allEntries.isEmpty) ...[
                                const SizedBox(height: 60),
                                Column(
                                  children: [
                                    const Icon(Icons.inbox_rounded,
                                        color: AppColors.textLight, size: 52),
                                    const SizedBox(height: 12),
                                    Text('Belum ada catatan',
                                        style: GoogleFonts.plusJakartaSans(
                                            color: AppColors.textGray,
                                            fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text('Tambah catatan pertamamu!',
                                        style: GoogleFonts.plusJakartaSans(
                                            color: AppColors.textLight,
                                            fontSize: 13)),
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
                            // Date header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.mintBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.mintLight, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      color: AppColors.primary, size: 14),
                                  const SizedBox(width: 6),
                                  Text(dateKey,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...dayEntries.map((e) => _EntryCard(
                                  entry: e,
                                  emoji: _mealTimeEmoji(e.mealTime),
                                  onDelete: () {
                                    AppState().entries.remove(e);
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

            // ── FAB ────────────────────────────────────────────────────────
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CatatMakananScreen()),
                  );
                  setState(() {});
                },
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Entry Card ───────────────────────────────────────────────────────────────

class _EntryCard extends StatelessWidget {
  final FoodEntry entry;
  final String emoji;
  final VoidCallback onDelete;
  const _EntryCard(
      {required this.entry, required this.emoji, required this.onDelete});

  Color _painBadgeColor(int pain) {
    if (pain == 0)  return AppColors.badgeGreenBg;
    if (pain <= 4)  return AppColors.orangeBg;
    if (pain <= 7)  return const Color(0xFFFFE5CC);
    return AppColors.pinkBg;
  }

  Color _painTextColor(int pain) {
    if (pain == 0)  return AppColors.badgeGreenText;
    if (pain <= 4)  return AppColors.orangeText;
    if (pain <= 7)  return const Color(0xFFD97706);
    return AppColors.pinkText;
  }

  @override
  Widget build(BuildContext context) {
    final painColor   = _painBadgeColor(entry.painLevel);
    final painTxtClr  = _painTextColor(entry.painLevel);
    final cond        = entry.stomachCondition;
    final condColor   = (cond == 'Buruk')
        ? AppColors.pinkText
        : AppColors.badgeGreenText;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(entry.foodName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    )),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: painColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Nyeri: ${entry.painLevel}/10',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: painTxtClr,
                    )),
              ),
            ],
          ),

          if (entry.drink.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.local_drink_outlined,
                    color: AppColors.textLight, size: 14),
                const SizedBox(width: 5),
                Text(entry.drink,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: AppColors.textGray)),
              ],
            ),
          ],

          const SizedBox(height: 10),

          // Symptoms
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: entry.symptoms.map((s) {
              final isNormal = s == 'Tidak Ada';
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isNormal ? AppColors.inputBg : AppColors.pinkBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(s,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isNormal ? AppColors.textGray : AppColors.pinkText,
                    )),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (cond.isNotEmpty)
                Text('Kondisi: $cond',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: condColor,
                      fontWeight: FontWeight.w600,
                    )),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      title: Text('Hapus Catatan',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700)),
                      content: Text(
                          'Yakin ingin menghapus catatan "${entry.foodName}"?',
                          style: GoogleFonts.plusJakartaSans()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Batal',
                              style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textGray)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pinkText,
                          ),
                          child: Text('Hapus',
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.textLight, size: 20),
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
  const _AvatarBadge({required this.letter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.mintLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Center(
        child: Text(letter,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            )),
      ),
    );
  }
}
