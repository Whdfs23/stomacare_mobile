import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  void _login() async {
    setState(() { _error = null; _isLoading = true; });
    await Future.delayed(const Duration(milliseconds: 600));
    if (_usernameCtrl.text.trim().isEmpty || _passwordCtrl.text.trim().isEmpty) {
      setState(() { _error = 'Username dan password wajib diisi.'; _isLoading = false; });
      return;
    }
    AppState().login(_usernameCtrl.text.trim());
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
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
            // ── Form card ──────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Login',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        )),
                    const SizedBox(height: 6),
                    Text('Masuk ke akun StomaCare kamu',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.textGray,
                        )),
                    const SizedBox(height: 36),

                    // Username
                    _buildTextField(
                      controller: _usernameCtrl,
                      hint: 'Username',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),

                    // Password
                    _buildTextField(
                      controller: _passwordCtrl,
                      hint: 'Password',
                      icon: _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      obscure: _obscurePassword,
                      onIconTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('Lupa password?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          )),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 12),
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

                    const SizedBox(height: 28),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _login,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.login_rounded, color: Colors.white),
                        label: Text('Login',
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

            // ── Green bottom section ────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  const Text('👋', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 10),
                  Text('Halo, Selamat Datang!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 4),
                  Text('Belum punya akun?',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(
                    'Daftar sekarang dan mulai pantau\nkesehatan lambungmu.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: Colors.white60),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                    ),
                    child: Text('Daftar Sekarang',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                  ),
                ],
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
