import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../services/app_state.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  bool _obscurePass    = true;
  bool _isLoading      = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); 
    super.dispose();
  }

  Future<void> _register() async {
    final name    = _nameCtrl.text.trim();
    final email   = _emailCtrl.text.trim();
    final pass    = _passCtrl.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Semua kolom isian wajib diisi.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter.');
      return;
    }

    setState(() { _error = null; _isLoading = true; });
    try {
      // PERBAIKAN: Menghapus variabel 'res' yang tidak terpakai
      await Supabase.instance.client.auth.signUp(
        email: email, password: pass, data: {'name': name},
      );
      
      await Supabase.instance.client.auth.signInWithPassword(email: email, password: pass);
      await AppState.instance.loadAll();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (_) => false);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        bottom: false,
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  // ── BAGIAN ATAS (HIJAU): Login Link ──
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 70, 24, 40),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.badgeGreenText, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 16),
                        Text('Sudah Punya Akun?',
                            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        // PERBAIKAN: Mengganti withOpacity menjadi white70 menghindari warning
                        Text('Masuk dan lanjutkan memantau\nkesehatan lambungmu',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white70, height: 1.5)),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          ),
                          child: Text('Login Sekarang',
                              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),

                  // ── BAGIAN BAWAH (PUTIH): Form Register ──
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daftar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 32, fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              )),
                          const SizedBox(height: 6),
                          Text('Buat akun StomaCare gratis',
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textLight)),
                          const SizedBox(height: 32),

                          _buildField(controller: _nameCtrl, hint: 'Username', icon: Icons.person_rounded),
                          const SizedBox(height: 16),
                          _buildField(controller: _emailCtrl, hint: 'E-mail', icon: Icons.email_rounded, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          _buildField(
                            controller: _passCtrl,
                            hint: 'Password (min. 6 karakter)',
                            icon: _obscurePass ? Icons.visibility_off : Icons.visibility,
                            obscure: _obscurePass,
                            onIconTap: () => setState(() => _obscurePass = !_obscurePass),
                          ),

                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            _ErrorBanner(message: _error!),
                          ],

                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity, height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _register,
                              icon: _isLoading ? const SizedBox() : const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLight,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              label: _isLoading
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                  : Text('Daftar Sekarang',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({required TextEditingController controller, required String hint, required IconData icon, bool obscure = false, VoidCallback? onIconTap, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: TextField(
        controller: controller, obscureText: obscure, keyboardType: keyboardType,
        style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint, hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.w500),
          suffixIcon: GestureDetector(onTap: onIconTap, child: Icon(icon, color: AppColors.textGray, size: 22)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.pinkBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.pinkText, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.pinkText))),
        ],
      ),
    );
  }
}