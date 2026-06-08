# 🌿 StomaCare

Aplikasi mobile pencatatan makanan dan kesehatan lambung berbasis Flutter.

## Fitur
- ✅ Login & Registrasi akun
- 📊 Dashboard dengan Risk Score & Tren Mingguan
- 🍽️ Catat makanan, minuman, gejala, dan tingkat nyeri
- 📋 Riwayat catatan dikelompokkan per tanggal
- 💡 Rekomendasi diet personal berdasarkan gejala
- ℹ️ Halaman About Us dengan profil tim

## Cara Menjalankan

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0

### Langkah-langkah

```bash
# 1. Masuk ke folder project
cd stomacare

# 2. Install dependencies
flutter pub get

# 3. Jalankan aplikasi
flutter run
```

### Build APK (Android)
```bash
flutter build apk --release
```
APK tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`

### Build iOS
```bash
flutter build ios --release
```

## Struktur Proyek

```
lib/
├── main.dart                  # Entry point
├── theme/
│   └── app_colors.dart        # Color constants
├── models/
│   └── food_entry.dart        # Data model
├── services/
│   └── app_state.dart         # State management
└── screens/
    ├── login_screen.dart
    ├── register_screen.dart
    ├── main_screen.dart        # Bottom nav scaffold
    ├── dashboard_screen.dart
    ├── catat_makanan_screen.dart
    ├── riwayat_screen.dart
    └── about_screen.dart
```

## Color Palette
| Warna | Hex | Kegunaan |
|-------|-----|---------|
| Forest Green | `#2E5C45` | Tombol utama, aksen |
| Mint Light | `#EAF5EE` | Background card |
| Pink Pastel | `#FFE4E6` | Badge gejala/peringatan |
| Orange | `#FFF3CD` | Badge risiko sedang |

## Dependencies
```yaml
google_fonts: ^6.1.0   # Plus Jakarta Sans font
fl_chart: ^0.68.0      # Bar chart tren mingguan
intl: ^0.19.0          # Locale Indonesia untuk tanggal
```
