import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/app_state.dart';
import '../models/food_entry.dart';
import 'catat_makanan_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final state = AppState();

  void _refresh() => setState(() {});

  String _mealTimeEmoji(String mealTime) {
    switch (mealTime) {
      case 'Pagi':   return '☀️';
      case 'Siang':  return '🍽️';
      case 'Malam':  return '🌙';
      case 'Camilan': return '🍪';
      default:        return '🍴';
    }
  }

  Color _mealTimeBg(String mealTime) {
    switch (mealTime) {
      case 'Pagi':   return const Color(0xFFFFF9C4);
      case 'Siang':  return const Color(0xFFE8F5E9);
      case 'Malam':  return const Color(0xFFEDE7F6);
      case 'Camilan': return const Color(0xFFFFF3E0);
      default:        return AppColors.mintLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final score   = state.todayRiskScore;
    final status  = state.todayRiskStatus;
    final weekly  = state.weeklyData;
    final pemicu  = state.suspectPemicu;
    final recent  = state.recentEntries;
    final dietRec = state.getDietRecommendation();
    final username = state.username;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => _refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hi, $username! 👋',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: AppColors.textGray,
                            )),
                        Text('Dashboard',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            )),
                      ],
                    ),
                    _AvatarBadge(letter: username[0].toUpperCase()),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Risk Score Card ─────────────────────────────────────────
                _RiskScoreCard(
                    score: score, status: status, motivation: state.todayMotivation),
                const SizedBox(height: 16),

                // ── Tambah Catatan ──────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const CatatMakananScreen()));
                      _refresh();
                    },
                    icon: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 22),
                    label: Text('Tambah Catatan Baru',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Diet Recommendation Card ────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.mintLight, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tips_and_updates_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Rekomendasi Diet Personal',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              )),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(dietRec,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textMedium,
                            height: 1.5,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Weekly Trend ────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.show_chart_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Tren Mingguan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: BarChart(
                          BarChartData(
                            maxY: 10,
                            minY: 0,
                            barTouchData: BarTouchData(enabled: true),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, _) {
                                    final idx = val.toInt();
                                    if (idx < 0 || idx >= weekly.length) {
                                      return const SizedBox();
                                    }
                                    final isToday = idx == weekly.length - 1;
                                    return Text(
                                      weekly[idx].dayLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: isToday
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: isToday
                                            ? AppColors.primary
                                            : AppColors.textGray,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: List.generate(weekly.length, (i) {
                              final d = weekly[i];
                              final barColor = d.riskScore >= 6
                                  ? AppColors.barHigh
                                  : d.riskScore >= 3
                                      ? AppColors.barMedium
                                      : AppColors.primary;
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: d.riskScore == 0 ? 0.4 : d.riskScore,
                                    color: barColor,
                                    width: 22,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Suspect Pemicu ──────────────────────────────────────────
                if (pemicu.isNotEmpty) ...[
                  Text('Suspect Pemicu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      )),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: pemicu
                        .map((name) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.pinkBg,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.pinkText,
                                  )),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Catatan Terakhir ────────────────────────────────────────
                Text('Catatan Terakhir',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    )),
                const SizedBox(height: 12),
                ...recent.map((entry) => _RecentEntryItem(
                      entry: entry,
                      emojiIcon: _mealTimeEmoji(entry.mealTime),
                      bgColor: _mealTimeBg(entry.mealTime),
                    )),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => widget.onNavigate(1),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.primary.withOpacity(0.3), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      backgroundColor: AppColors.mintBg,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Lihat Semua Riwayat',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sub widgets ──────────────────────────────────────────────────────────────

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

class _RiskScoreCard extends StatelessWidget {
  final int score;
  final String status;
  final String motivation;
  const _RiskScoreCard(
      {required this.score, required this.status, required this.motivation});

  Color get _statusColor {
    if (status == 'Aman')       return AppColors.badgeGreenText;
    if (status == 'Ringan')     return AppColors.orangeText;
    if (status == 'Sedang')     return AppColors.orangeText;
    return AppColors.pinkText;
  }

  Color get _statusBg {
    if (status == 'Aman')   return AppColors.badgeGreenBg;
    if (status == 'Ringan') return AppColors.orangeBg;
    if (status == 'Sedang') return AppColors.orangeBg;
    return AppColors.pinkBg;
  }

  Color get _ringColor {
    if (status == 'Aman')   return AppColors.primary;
    if (status == 'Ringan') return AppColors.orangeText;
    if (status == 'Sedang') return AppColors.orangeText;
    return AppColors.pinkText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text('Risk Score Hari Ini',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textGray,
              )),
          const SizedBox(height: 18),
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 10.0,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFE8F5EE),
                  valueColor: AlwaysStoppedAnimation<Color>(_ringColor),
                  strokeCap: StrokeCap.round,
                ),
                Text(score.toString(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Status: $status',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _statusColor,
                )),
          ),
          const SizedBox(height: 12),
          Text(motivation,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textGray,
                height: 1.5,
              )),
        ],
      ),
    );
  }
}

class _RecentEntryItem extends StatelessWidget {
  final FoodEntry entry;
  final String emojiIcon;
  final Color bgColor;
  const _RecentEntryItem({
    required this.entry,
    required this.emojiIcon,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy', 'id').format(entry.date);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emojiIcon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.foodName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    )),
                Text('$dateStr · Nyeri: ${entry.painLevel}/10',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textGray,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
