import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/app_state.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TENTANG KAMI',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 1.4,
                          )),
                      Text('StomaCare',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          )),
                    ],
                  ),
                  _AvatarBadge(
                      letter: AppState().username[0].toUpperCase()),
                ],
              ),
              const SizedBox(height: 28),

              // ── Hero text ────────────────────────────────────────────────
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Kami Peduli pada\n',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        height: 1.3,
                      ),
                    ),
                    TextSpan(
                      text: 'Kesehatan Lambungmu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Platform digital kesehatan pencernaan yang membantu kamu memahami, memantau, dan menjaga kondisi lambung setiap harinya.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.textGray,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),

              // ── Visi ────────────────────────────────────────────────────
              _InfoCard(
                icon: Icons.remove_red_eye_outlined,
                title: 'Visi',
                content:
                    'Menjadi platform kesehatan lambung digital terpercaya di Indonesia yang membantu masyarakat menjalani hidup lebih sehat.',
              ),
              const SizedBox(height: 14),

              // ── Misi ────────────────────────────────────────────────────
              _InfoCard(
                icon: Icons.track_changes_rounded,
                title: 'Misi',
                isBullet: true,
                bullets: const [
                  'Menyediakan informasi medis yang akurat.',
                  'Membantu pengguna mencatat pola makan.',
                  'Mendorong gaya hidup sehat lambung.',
                ],
              ),
              const SizedBox(height: 24),

              // ── Fitur Utama ──────────────────────────────────────────────
              Text('Fitur Utama',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  )),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Food Diary',
                      desc:
                          'Catat makanan dan gejala yang dirasakan dengan mudah.',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Cek Gejala',
                      desc:
                          'Kenali gejala maag dan GERD sejak dini.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Tim Pengembang ───────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Text('Tim Pengembang',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                    const SizedBox(height: 4),
                    Text('Kelompok 4 — Web & Mobile',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.white60,
                        )),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      children: const [
                        _DeveloperCard(
                            name: 'Yofi Widiyanto', role: 'UI/UX Designer'),
                        _DeveloperCard(
                            name: 'Zulfa Nashihin', role: 'Frontend Dev'),
                        _DeveloperCard(
                            name: 'Widyadana H.', role: 'Backend Dev'),
                        _DeveloperCard(
                            name: 'Navista A. P.', role: 'Database & Docs'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Footer ──────────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Text('StomaCare v1.0.0',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textLight,
                        )),
                    const SizedBox(height: 4),
                    Text('© 2026 Kelompok 4 — Universitas Tidar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textLight,
                        )),
                  ],
                ),
              ),
            ],
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? content;
  final bool isBullet;
  final List<String>? bullets;

  const _InfoCard({
    required this.icon,
    required this.title,
    this.content,
    this.isBullet = false,
    this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.mintBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              )),
          const SizedBox(height: 8),
          if (!isBullet && content != null)
            Text(content!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.textGray,
                  height: 1.6,
                )),
          if (isBullet && bullets != null)
            ...bullets!.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Icon(Icons.circle,
                            color: AppColors.primary, size: 6),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(b,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: AppColors.textGray,
                              height: 1.5,
                            )),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureCard(
      {required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 10),
          Text(title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              )),
          const SizedBox(height: 6),
          Text(desc,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textGray,
                height: 1.5,
              )),
        ],
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  final String name;
  final String role;
  const _DeveloperCard({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar circle
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white54, size: 30),
          ),
          const SizedBox(height: 8),
          Text(name,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              )),
          const SizedBox(height: 2),
          Text(role,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.white70,
              )),
        ],
      ),
    );
  }
}
