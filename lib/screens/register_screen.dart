import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/app_state.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  void _register() async {
    setState(() { _error = null; _isLoading = true; });
    await Future.delayed(const Duration(milliseconds: 600));
    if (_usernameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.trim().isEmpty) {
      setState(() {
        _error = 'Semua field wajib diisi.';
        _isLoading = false;
      });
      return;
    }
    if (_passwordCtrl.text.trim().length < 6) {
      setState(() {
        _error = 'Password minimal 6 karakter.';
        _isLoading = false;
      });
      return;
    }
    AppState().login(_usernameCtrl.text.trim());
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Green top section ───────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('✅', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Sudah Punya Akun?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    'Masuk dan lanjutkan memantau\nkesehatan lambungmu',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()));
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                    ),
                    child: Text('Login Sekarang',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                  ),
                ],
              ),
            ),

            // ── Form ────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daftar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        )),
                    const SizedBox(height: 6),
                    Text('Buat akun StomaCare gratis',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.textGray,
                        )),
                    const SizedBox(height: 28),

                    _buildTextField(
                      controller: _usernameCtrl,
                      hint: 'Username',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _emailCtrl,
                      hint: 'E-mail',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _passwordCtrl,
                      hint: 'Password (min. 6 karakter)',
                      icon: _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      obscure: _obscurePassword,
                      onIconTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.pinkBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.pinkText, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppColors.pinkText,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _register,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.person_add_outlined,
                                color: Colors.white),
                        label: Text('Daftar Sekarang',
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    VoidCallback? onIconTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 15, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 15, color: AppColors.textLight),
          suffixIcon: GestureDetector(
            onTap: onIconTap,
            child: Icon(icon, color: AppColors.textGray, size: 20),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
    );
  }
}
