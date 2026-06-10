import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart'; <--- PERBAIKAN 1: Baris ini sudah dihapus karena tidak terpakai
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart'; 
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/app_state.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'theme/app_colors.dart';

const _supabaseUrl  = 'https://fwxcurmukfswczbuawmh.supabase.co'; 
const _supabaseKey  = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3eGN1cm11a2Zzd2N6YnVhd21oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA5MTcyNDAsImV4cCI6MjA5NjQ5MzI0MH0.u2bcYIXEF_cXQX6BvczPKn0dMYGDQPTz07ie8KrDCjU'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Hive local storage
  await StorageService.init();

  // 2. Notifikasi
  await NotificationService.instance.init();
  
  if (!kIsWeb) {
    await NotificationService.instance.requestPermission();
  }

  // 3. Supabase
  // 👉 PERBAIKAN 2: Mengganti anonKey menjadi publishableKey
  await Supabase.initialize(
    url: _supabaseUrl, 
    publishableKey: _supabaseKey, 
  );

  // 4. Locale Indonesia
  await initializeDateFormatting('id');

  // 5. Cek sesi — kalau sudah login, load data langsung
  final session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    await AppState.instance.loadAll();
  }

  runApp(StomaCareApp(isLoggedIn: session != null));
}

class StomaCareApp extends StatelessWidget {
  final bool isLoggedIn;
  const StomaCareApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StomaCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          surface: AppColors.background,
        ),
        fontFamily: 'PlusJakartaSans',
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
        ),
        sliderTheme: const SliderThemeData(
          trackHeight: 6,
        ),
      ),
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}