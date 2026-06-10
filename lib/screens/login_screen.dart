import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../services/app_state.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure   = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email dan password wajib diisi.');
      return;
    }
    setState(() { _error = null; _isLoading = true; });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await AppState.instance.loadAll();
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainScreen()));
    } on AuthException catch (e) {
      setState(() => _error = _friendlyError(e.message));
    } catch (e) {
      setState(() => _error = 'Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String msg) {
    if (msg.contains('Invalid login')) return 'Email atau password salah.';
    if (msg.contains('Email not confirmed')) return 'Email belum dikonfirmasi. Cek inbox kamu.';
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        // CustomScrollView memastikan UI merespon Keyboard dengan sempurna
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  // ── BAGIAN ATAS (PUTIH): Form Login ──
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 60, 32, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Login',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 32, fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              )),
                          const SizedBox(height: 6),
                          Text('Masuk ke akun StomaCare kamu',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14, color: AppColors.textLight)),
                          const SizedBox(height: 40),

                          _buildField(
                            controller: _emailCtrl,
                            hint: 'E-mail',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            controller: _passwordCtrl,
                            hint: 'Password',
                            icon: _obscure ? Icons.visibility_off : Icons.visibility,
                            obscure: _obscure,
                            onIconTap: () => setState(() => _obscure = !_obscure),
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {}, 
                              child: Text('Lupa password?', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w600))
                            ),
                          ),

                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            _ErrorBanner(message: _error!),
                            const SizedBox(height: 12),
                          ],

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity, height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _login,
                              icon: _isLoading ? const SizedBox() : const Icon(Icons.login_rounded, color: Colors.white, size: 20),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLight,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              label: _isLoading
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                  : Text('Login',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
                                      )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── BAGIAN BAWAH (HIJAU): Register Link ──
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 50),
                    child: Column(
                      children: [
                        const Text('👋', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text('Halo, Selamat Datang!',
                            style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('Belum punya akun?\nDaftar sekarang dan mulai pantau\nkesehatan lambungmu.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white70, height: 1.5)),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          ),
                          child: Text('Daftar Sekarang',
                              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ],
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
          hintText: hint, hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textLight, fontSize: 14, fontWeight: FontWeight.w500),
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