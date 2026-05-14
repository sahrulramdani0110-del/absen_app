# AbsensiKu — Flutter Mobile App (Android)

Aplikasi absensi digital mobile untuk Android, dibuat dengan Flutter + GetX.

---

## Cara Menjalankan

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Sesuaikan IP Backend
Edit file `lib/config/app_config.dart`:
```dart
// Untuk emulator Android
static const String baseUrl = 'http://10.0.2.2:3000';

// Untuk device fisik (ganti dengan IP komputer kamu)
static const String baseUrl = 'http://192.168.1.xxx:3000';
```

Cek IP komputer kamu dengan:
```bash
# Windows
ipconfig

# Mac/Linux
ifconfig
```

### 3. Jalankan App
```bash
# Pastikan emulator/device sudah connect
flutter devices

# Run
flutter run
```

---

## Platform-Specific Features

### Kamera (Selfie Absensi)
- Package: `image_picker`
- Lokasi: `lib/presentation/controllers/absensi_controller.dart` → `takeSelfie()`
- Screen: `lib/presentation/screens/absensi/checkin_screen.dart`
- Izin: `CAMERA` di AndroidManifest.xml

### GPS (Validasi Lokasi)
- Package: `geolocator`
- Lokasi: `lib/presentation/controllers/absensi_controller.dart` → `getLocation()`
- Screen: `lib/presentation/screens/absensi/checkin_screen.dart`
- Izin: `ACCESS_FINE_LOCATION` di AndroidManifest.xml

---

## Struktur Penting

| File | Fungsi |
|------|--------|
| `lib/main.dart` | Entry point |
| `lib/config/app_config.dart` | URL backend & routes |
| `lib/data/providers/api_provider.dart` | Dio HTTP client + token interceptor |
| `lib/presentation/controllers/auth_controller.dart` | Login, register, logout |
| `lib/presentation/controllers/absensi_controller.dart` | GPS, kamera, check-in |
| `lib/routes/app_pages.dart` | Semua routes & bindings |

---

## Build APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`
