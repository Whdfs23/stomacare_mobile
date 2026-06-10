import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';
import 'riwayat_screen.dart';
import 'profile_screen.dart';
import 'reminder_screen.dart';
import 'mood_log_screen.dart';
import 'catat_makanan_screen.dart';
import 'about_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(onNavigate: (i) => setState(() => _currentIndex = i)),
      RiwayatScreen(onAdd: () => setState(() => _currentIndex = 0)),
      const AboutScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      
      // ── Speed-dial FAB ───────────────────────────────────────────────────
      floatingActionButton: Padding(
        // PERBAIKAN: Menaikkan posisi tombol plus agar tidak menimpa menu bawah
        padding: const EdgeInsets.only(bottom: 20.0), 
        child: _SpeedDial(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      // ── Bottom Navigation Bar ─────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Row(
              // PERBAIKAN: Membagi ruang secara rata, tanpa menyisakan blank space
              mainAxisAlignment: MainAxisAlignment.spaceAround, 
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'Home', isActive: _currentIndex == 0, onTap: () => setState(() => _currentIndex = 0)),
                _NavItem(icon: Icons.menu_book_rounded, label: 'Riwayat', isActive: _currentIndex == 1, onTap: () => setState(() => _currentIndex = 1)),
                _NavItem(icon: Icons.info_outline_rounded, label: 'About', isActive: _currentIndex == 2, onTap: () => setState(() => _currentIndex = 2)),
                _NavItem(icon: Icons.notifications_outlined, label: 'Reminder', isActive: false, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderScreen()))),
                _NavItem(icon: Icons.person_outline_rounded, label: 'Profil', isActive: _currentIndex == 3, onTap: () => setState(() => _currentIndex = 3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeedDial extends StatefulWidget {
  @override
  State<_SpeedDial> createState() => _SpeedDialState();
}

class _SpeedDialState extends State<_SpeedDial> with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _ctrl;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _rotateAnim = Tween<double>(begin: 0, end: 0.375).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  void _navigate(Widget screen) {
    _toggle();
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_open) ...[
          _SpeedDialItem(emoji: '😊', label: 'Catat Mood & Tidur', color: const Color(0xFF7C3AED), onTap: () => _navigate(const MoodLogScreen())),
          const SizedBox(height: 10),
          _SpeedDialItem(emoji: '🍽️', label: 'Catat Makanan', color: AppColors.primary, onTap: () => _navigate(const CatatMakananScreen())),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          child: RotationTransition(turns: _rotateAnim, child: const Icon(Icons.add_rounded, size: 28)),
        ),
      ],
    );
  }
}

class _SpeedDialItem extends StatelessWidget {
  final String emoji, label; final Color color; final VoidCallback onTap;
  const _SpeedDialItem({required this.emoji, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))]),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon; final String label; final bool isActive; final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textGray;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: color, fontWeight: isActive ? FontWeight.w800 : FontWeight.w500)),
        ],
      ),
    );
  }
}