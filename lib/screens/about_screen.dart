import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  final List<Map<String, String>> timPengembang = const [
    {
      'name': 'Navista Andara Putri',
      'role': 'Product Owner & Researcher',
      'nim': '2440506059'
    },
    {
      'name': 'Widyadana Hussin F.',
      'role': 'Lead Mobile Developer',
      'nim': '2440506054'
    },
    {
      'name': 'Zulfa Nashihin',
      'role': 'Database & Supabase Expert',
      'nim': '2420506036'
    },
    {
      'name': 'Yofi Widiyanto',
      'role': 'UI/UX Designer & Tester',
      'nim': '2420506039'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tentang Kami', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              Text('Misi di Balik Layar StomaCare', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textGray)),
              const SizedBox(height: 30),

              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: AppColors.primaryAccent, shape: BoxShape.circle), child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 24)),
                    const SizedBox(height: 16),
                    Text('Visi & Misi Kami', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    Text(
                      'StomaCare dikembangkan untuk memberikan platform pemantauan mandiri yang valid bagi penderita GERD. Melalui korelasi pola makan dan gejala medis harian, kami bertujuan membantu pengguna memahami kondisi lambung mereka secara lebih terstruktur untuk kualitas hidup yang lebih baik.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGray, height: 1.6),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Text('TIM PENGEMBANG', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textGray, letterSpacing: 1.2)),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
                ),
                itemCount: timPengembang.length,
                itemBuilder: (context, index) {
                  final anggota = timPengembang[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(radius: 18, backgroundColor: AppColors.inputBg, child: Icon(Icons.person_rounded, color: AppColors.textGray, size: 20)),
                        const Spacer(),
                        Text(anggota['name']!, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text(anggota['role']!, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        Text('NPM. ${anggota['nim']!}', style: GoogleFonts.plusJakartaSans(fontSize: 9, color: AppColors.textGray)),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 30),
              Center(
                child: Text('Universitas Tidar · Teknologi Informasi © 2026', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textLight)),
              )
            ],
          ),
        ),
      ),
    );
  }
}