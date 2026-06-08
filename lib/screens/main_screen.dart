import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';
import 'riwayat_screen.dart';
import 'about_screen.dart';
import 'login_screen.dart';
import '../services/app_state.dart';

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

  void _onTabTapped(int index) {
    if (index == 3) {
      _showLogoutDialog();
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text('Yakin ingin keluar dari StomaCare?',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textGray)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textGray, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              AppState().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoutRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Logout',
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(onNavigate: (i) => setState(() => _currentIndex = i)),
      RiwayatScreen(onAdd: () => setState(() => _currentIndex = 0)),
      const AboutScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  onTap: () => _onTabTapped(0),
                ),
                _NavItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Riwayat',
                  isActive: _currentIndex == 1,
                  onTap: () => _onTabTapped(1),
                ),
                _NavItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About',
                  isActive: _currentIndex == 2,
                  onTap: () => _onTabTapped(2),
                ),
                _NavItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  isActive: false,
                  isRed: true,
                  onTap: () => _onTabTapped(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isRed;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRed
        ? AppColors.logoutRed
        : isActive
            ? AppColors.primary
            : AppColors.textGray;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: color,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              )),
        ],
      ),
    );
  }
}
