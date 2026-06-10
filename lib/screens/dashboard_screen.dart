import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/app_state.dart';
import '../models/food_entry.dart';
import 'catat_makanan_screen.dart';
import 'mood_log_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final state = AppState.instance;

  void _refresh() => setState(() {});

  String _mealTimeEmoji(String mealTime) {
    switch (mealTime) {
      case 'Pagi':    return '☀️';
      case 'Siang':   return '🍽️';
      case 'Malam':   return '🌙';
      case 'Camilan': return '🍪';
      default:        return '🍴';
    }
  }

  Color _mealTimeBg(String mealTime) {
    switch (mealTime) {
      case 'Pagi':    return const Color(0xFFFFF9C4);
      case 'Siang':   return const Color(0xFFE8F5E9);
      case 'Malam':   return const Color(0xFFEDE7F6);
      case 'Camilan': return const Color(0xFFFFF3E0);
      default:        return AppColors.mintLight;
    }
  }

  int get _todayRiskScore {
    final now = DateTime.now();
    final todayEntries = state.foodEntries.where((e) => e.date.year == now.year && e.date.month == now.month && e.date.day == now.day);
    if (todayEntries.isEmpty) return 0;
    final avg = todayEntries.map((e) => e.riskScore).reduce((a, b) => a + b) / todayEntries.length;
    return avg.round().clamp(0, 10);
  }

  String get _todayRiskStatus {
    final s = _todayRiskScore;
    if (s == 0) return 'Aman';
    if (s <= 3) return 'Ringan';
    if (s <= 6) return 'Sedang';
    return 'Berbahaya';
  }

  String get _todayMotivation {
    final st = _todayRiskStatus;
    if (st == 'Aman')     return 'Kondisi lambungmu terpantau baik hari ini.\nPertahankan pola makanmu!';
    if (st == 'Ringan')   return 'Ada sedikit gejala hari ini.\nJaga pola makanmu ya!';
    if (st == 'Sedang')   return 'Lambungmu butuh perhatian.\nHindari makanan pemicu hari ini.';
    return 'Kondisi lambung membutuhkan istirahat.\nMakan makanan ringan dan minum air putih.';
  }

  List<FoodEntry> get _recentEntries {
    final sorted = List<FoodEntry>.from(state.foodEntries)..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(3).toList();
  }

  List<String> get _suspectPemicu => state.foodEntries.where((e) => e.isHighRisk).map((e) => e.foodName).toSet().toList();

  String _getDietRecommendation() {
    final recentSymptoms = _recentEntries.expand((e) => e.symptoms).toSet();
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

  @override
  Widget build(BuildContext context) {
    // 💡 PENYELESAIAN UTAMA: ListenableBuilder mendengarkan state global
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final score    = _todayRiskScore;
        final status   = _todayRiskStatus;
        final weekly   = state.weeklyChartData;
        final pemicu   = _suspectPemicu;
        final recent   = _recentEntries;
        final dietRec  = _getDietRecommendation();
        final insight  = state.moodGerdInsight;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await state.loadAll();
                _refresh();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hi, ${state.userName}! 👋', style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.textGray)),
                            Text('Dashboard', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            // DI SINI FOTO PROFIL AKAN TAMPIL
                            _AvatarBadge(letter: state.userInitial, imageUrl: state.avatarUrl),
                            if (state.isSyncing)
                              Container(width: 14, height: 14, decoration: BoxDecoration(color: AppColors.orangeText, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _RiskScoreCard(score: score, status: status, motivation: _todayMotivation),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const CatatMakananScreen())); _refresh(); },
                        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                        label: Text('Tambah Catatan Baru', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                      ),
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodLogScreen())); _refresh(); },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9D5CF6)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            const Text('😴', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Catat Mood & Tidur', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)), Text('Stres & tidur mempengaruhi GERD', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70))])),
                            const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (insight.isNotEmpty) ...[
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: insight.startsWith('⚠️') || insight.startsWith('😴') ? AppColors.orangeBg : AppColors.mintBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: insight.startsWith('⚠️') || insight.startsWith('😴') ? AppColors.orangeText.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.3))),
                        child: Text(insight, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: insight.startsWith('⚠️') || insight.startsWith('😴') ? AppColors.orangeText : AppColors.primary)),
                      ),
                      const SizedBox(height: 20),
                    ],

                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.mintLight, width: 1.5)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [const Icon(Icons.tips_and_updates_rounded, color: AppColors.primary, size: 20), const SizedBox(width: 8), Text('Rekomendasi Diet Personal', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark))]),
                          const SizedBox(height: 10),
                          Text(dietRec, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMedium, height: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [const Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 20), const SizedBox(width: 8), Text('Tren Mingguan', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark))]),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 120,
                            child: BarChart(
                              BarChartData(
                                maxY: 10, minY: 0,
                                barTouchData: BarTouchData(enabled: true), gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (val, _) {
                                        final idx = val.toInt();
                                        if (idx < 0 || idx >= weekly.length) return const SizedBox();
                                        final isToday = idx == weekly.length - 1;
                                        return Text(weekly[idx].dayLabel, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: isToday ? FontWeight.w700 : FontWeight.w400, color: isToday ? AppColors.primary : AppColors.textGray));
                                      },
                                    ),
                                  ),
                                ),
                                barGroups: List.generate(weekly.length, (i) {
                                  final d = weekly[i];
                                  final barColor = d.riskScore >= 6 ? AppColors.barHigh : d.riskScore >= 3 ? AppColors.barMedium : AppColors.primary;
                                  return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: d.riskScore == 0 ? 0.4 : d.riskScore, color: barColor, width: 22, borderRadius: BorderRadius.circular(6))]);
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (pemicu.isNotEmpty) ...[
                      Text('Suspect Pemicu', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10, runSpacing: 10,
                        children: pemicu.map((name) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: AppColors.pinkBg, borderRadius: BorderRadius.circular(14)), child: Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.pinkText)))).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    Text('Catatan Terakhir', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    if (recent.isEmpty)
                      _EmptyEntries()
                    else
                      ...recent.map((e) => _RecentEntryItem(entry: e, emojiIcon: _mealTimeEmoji(e.mealTime), bgColor: _mealTimeBg(e.mealTime))),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => widget.onNavigate(1),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          backgroundColor: AppColors.mintBg,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Lihat Semua Riwayat', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
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

class _RiskScoreCard extends StatelessWidget {
  final int score; final String status; final String motivation;
  const _RiskScoreCard({required this.score, required this.status, required this.motivation});

  Color get _statusColor { if (status == 'Aman') return AppColors.badgeGreenText; if (status == 'Ringan' || status == 'Sedang') return AppColors.orangeText; return AppColors.pinkText; }
  Color get _statusBg { if (status == 'Aman') return AppColors.badgeGreenBg; if (status == 'Ringan' || status == 'Sedang') return AppColors.orangeBg; return AppColors.pinkBg; }
  Color get _ringColor { if (status == 'Aman') return AppColors.primary; if (status == 'Ringan' || status == 'Sedang') return AppColors.orangeText; return AppColors.pinkText; }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text('Risk Score Hari Ini', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textGray)),
          const SizedBox(height: 18),
          SizedBox(
            width: 140, height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(width: 140, height: 140, child: CircularProgressIndicator(value: score / 10.0, strokeWidth: 12, backgroundColor: const Color(0xFFE8F5EE), valueColor: AlwaysStoppedAnimation<Color>(_ringColor), strokeCap: StrokeCap.round)),
                Text('$score', style: GoogleFonts.plusJakartaSans(fontSize: 52, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: _statusBg, borderRadius: BorderRadius.circular(20)), child: Text('Status: $status', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: _statusColor))),
          const SizedBox(height: 12),
          Text(motivation, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textGray, height: 1.5)),
        ],
      ),
    );
  }
}

class _EmptyEntries extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 32), decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [const Text('🍽️', style: TextStyle(fontSize: 36)), const SizedBox(height: 8), Text('Belum ada catatan hari ini', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textGray)), const SizedBox(height: 4), Text('Mulai catat makananmu!', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textLight))]),
    );
  }
}

class _RecentEntryItem extends StatelessWidget {
  final FoodEntry entry; final String emojiIcon; final Color bgColor;
  const _RecentEntryItem({required this.entry, required this.emojiIcon, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy', 'id').format(entry.date);
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(emojiIcon, style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(entry.foodName, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)), Text('$dateStr · Nyeri: ${entry.painLevel}/10', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGray))])),
        ],
      ),
    );
  }
}