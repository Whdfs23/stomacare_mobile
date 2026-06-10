import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../services/app_state.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final state = AppState.instance;
  
  // Menggunakan Uint8List agar support di Web & Mobile
  Uint8List? _profileImageBytes; 
  String? _avatarUrlDb;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  bool _isMealReminderActive = true;
  bool _isMedsReminderActive = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client.from('profiles').select('avatar_url').eq('id', user.id).maybeSingle();
        if (data != null && data['avatar_url'] != null) {
          if (mounted) setState(() => _avatarUrlDb = data['avatar_url']);
        }
      }
    } catch (e) {
      debugPrint('Error load avatar: $e');
    }
  }

  Future<void> _pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 50,
    );
    
    if (pickedFile != null) {
      // Baca sebagai bytes agar support di Web
      final bytes = await pickedFile.readAsBytes();
      
      setState(() {
        _isUploading = true;
        _profileImageBytes = bytes; 
      });
      
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          final ext = pickedFile.name.split('.').last;
          final fileName = '${user.id}_avatar.$ext'; 

          // Gunakan uploadBinary untuk kompatibilitas Web & Mobile
          await Supabase.instance.client.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

          final publicUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName) + '?t=${DateTime.now().millisecondsSinceEpoch}';

          await Supabase.instance.client.from('profiles').update({'avatar_url': publicUrl}).eq('id', user.id);

          // 👉 PERBAIKAN KRUSIAL: Beritahu AppState agar foto menyebar ke Dashboard & Riwayat!
          AppState.instance.updateAvatarUrl(publicUrl);

          setState(() => _avatarUrlDb = publicUrl);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil tersimpan! ✅'), backgroundColor: AppColors.primary));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
        }
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showProfilePictureOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: Text('Pilih dari Galeri', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
              onTap: () { Navigator.pop(ctx); _pickProfileImage(); },
            ),
            if (_profileImageBytes != null || _avatarUrlDb != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.pinkText),
                title: Text('Hapus Foto', style: GoogleFonts.plusJakartaSans(color: AppColors.pinkText, fontWeight: FontWeight.w600)),
                onTap: () { 
                  Navigator.pop(ctx); 
                  setState(() { _profileImageBytes = null; _avatarUrlDb = null; }); 
                  // Reset juga di state global
                  AppState.instance.updateAvatarUrl(''); 
                },
              ),
          ],
        ),
      ),
    );
  }

  void _refresh() => setState(() {});

  void _openAccountInfoDialog() {
    final userCtrl = TextEditingController(text: state.userName);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Informasi Akun', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Pengguna', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGray)),
                const SizedBox(height: 6),
                TextField(controller: userCtrl, decoration: InputDecoration(filled: true, fillColor: AppColors.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                const SizedBox(height: 14),
                Text('E-mail Pengguna', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGray)),
                const SizedBox(height: 6),
                Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)), child: Text(state.userEmail, style: GoogleFonts.plusJakartaSans(color: AppColors.textMedium))),
              ],
            ),
            actions: [
              TextButton(onPressed: isSaving ? null : () => Navigator.pop(ctx), child: Text('Batal', style: TextStyle(color: AppColors.textGray))),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  if (userCtrl.text.trim().isNotEmpty) {
                    setDialogState(() => isSaving = true);
                    try {
                      await SupabaseService.instance.updateProfile(name: userCtrl.text.trim());
                      
                      if (mounted) { 
                        Navigator.pop(ctx); 
                        _refresh(); 
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama berhasil diperbarui ✅'))); 
                      }
                    } catch (e) {
                      setDialogState(() => isSaving = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _openNotificationModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Atur Pengingat', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 18),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: Text('Pengingat Makan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14)), subtitle: Text('Mencegah skip makan pemicu asam lambung', style: GoogleFonts.plusJakartaSans(fontSize: 12)), value: _isMealReminderActive, activeColor: AppColors.primary, onChanged: (v) { setState(() => _isMealReminderActive = v); setModalState(() {}); }),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: Text('Alarm Obat', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14)), subtitle: Text('Notifikasi rutin konsumsi obat lambung', style: GoogleFonts.plusJakartaSans(fontSize: 12)), value: _isMedsReminderActive, activeColor: AppColors.primary, onChanged: (v) { setState(() => _isMedsReminderActive = v); setModalState(() {}); }),
            ],
          ),
        ),
      ),
    );
  }

  void _openPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keamanan & Sandi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(obscureText: true, decoration: InputDecoration(hintText: 'Kata Sandi Lama', filled: true, fillColor: AppColors.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            const SizedBox(height: 10),
            TextField(obscureText: true, decoration: InputDecoration(hintText: 'Kata Sandi Baru', filled: true, fillColor: AppColors.inputBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: TextStyle(color: AppColors.textGray))),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sandi diubah!'), backgroundColor: AppColors.primary)); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text('Yakin ingin keluar?', style: GoogleFonts.plusJakartaSans(color: AppColors.textGray)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: AppColors.textGray))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); 
              await state.logout();
              
              if (!mounted) return;
              
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.logoutRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Logout', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

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
              Text('Profil & Pengaturan', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              Text('Kelola akun & info kesehatanmu', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textGray)),
              const SizedBox(height: 28),

              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: _showProfilePictureOptions,
                          child: Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.mintBg, shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 3),
                              image: _profileImageBytes != null
                                  ? DecorationImage(image: MemoryImage(_profileImageBytes!), fit: BoxFit.cover)
                                  : _avatarUrlDb != null
                                      ? DecorationImage(image: NetworkImage(_avatarUrlDb!), fit: BoxFit.cover)
                                      : null,
                            ),
                            child: (_profileImageBytes == null && _avatarUrlDb == null)
                                ? Center(child: Text(state.userInitial, style: GoogleFonts.plusJakartaSans(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.primary)))
                                : null,
                          ),
                        ),
                        if (_isUploading)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          )
                        else
                          GestureDetector(
                            onTap: _showProfilePictureOptions,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(state.userName, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text(state.userEmail, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textGray)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.divider)),
                child: Column(
                  children: [
                    _MenuTile(icon: Icons.person_outline_rounded, title: 'Informasi Akun', subtitle: 'Detail personal, email, dan nama', onTap: _openAccountInfoDialog),
                    const Divider(height: 1, thickness: 1, color: AppColors.inputBg),
                    _MenuTile(icon: Icons.notifications_active_outlined, title: 'Notifikasi', subtitle: 'Atur pengingat makan dan obat', onTap: _openNotificationModal),
                    const Divider(height: 1, thickness: 1, color: AppColors.inputBg),
                    _MenuTile(icon: Icons.privacy_tip_outlined, title: 'Keamanan & Privasi', subtitle: 'Ubah password dan privasi data', onTap: _openPrivacyDialog),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  onPressed: _showLogoutDialog,
                  icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                  label: Text('Keluar dari Akun', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.logoutRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.mintBg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 22)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)), const SizedBox(height: 2), Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textGray))])),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 24),
          ],
        ),
      ),
    );
  }
}