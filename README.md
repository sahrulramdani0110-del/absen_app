# AbsensiKu 📋

Sistem absensi digital multi-platform untuk sekolah dan organisasi. Dibangun dengan satu backend REST API yang melayani dua platform sekaligus — aplikasi web (Next.js) dan aplikasi mobile Android (Flutter).

---

## 📱 Platform

| Platform | Teknologi | Fitur Khusus |
|----------|-----------|--------------|
| Web | Next.js 14 + Tailwind CSS | Progressive Web App (PWA) |
| Mobile Android | Flutter + GetX | Kamera Selfie + GPS Validasi Lokasi |
| Backend | Node.js + Express + MySQL | REST API + JWT Auth |

---

## ✨ Fitur Utama

- **Autentikasi** — Register dan login dengan JWT, role admin dan member
- **Manajemen Kelas** — Buat organisasi, kelas, dan kelola anggota
- **Sesi Absensi** — Admin buka/tutup sesi dengan pengaturan lokasi dan radius GPS
- **Check-in** — Absensi dengan validasi lokasi GPS dan foto selfie (mobile)
- **Deteksi Terlambat** — Status hadir/terlambat otomatis berdasarkan waktu check-in
- **Rekap Kehadiran** — Statistik dan tabel rekap per sesi secara real-time
- **Riwayat** — Pengguna dapat melihat riwayat absensi pribadi

---

## 🗂️ Struktur Repository

```
absen_app/
├── backend/              # Node.js + Express REST API
├── web/
│   └── absensi-web/      # Next.js 14 App
└── mobile/
    └── absensi_mobile/   # Flutter Android App
```

---

## 🛠️ Tech Stack

### Backend
- **Runtime:** Node.js v24
- **Framework:** Express.js
- **Database:** MySQL 8
- **Auth:** JSON Web Token (JWT)
- **Password:** bcryptjs
- **Dependencies:** mysql2, cors, dotenv, multer

### Web (Next.js)
- **Framework:** Next.js 14 (App Router)
- **Styling:** Tailwind CSS
- **HTTP Client:** Axios
- **State:** React Hooks + js-cookie
- **Notifikasi:** react-hot-toast
- **Icon:** lucide-react

### Mobile (Flutter)
- **Framework:** Flutter 3.x / Dart 3.x
- **State Management:** GetX
- **HTTP Client:** Dio
- **Local Storage:** GetStorage
- **Kamera:** image_picker *(platform-specific)*
- **GPS:** geolocator *(platform-specific)*
- **Permission:** permission_handler

---

## 🚀 Cara Menjalankan

### Prasyarat

Pastikan sudah terinstall:
- [Node.js](https://nodejs.org/) v18+
- [MySQL](https://www.mysql.com/) 8.x
- [Flutter](https://flutter.dev/) 3.x
- [Git](https://git-scm.com/)

### 1. Clone Repository

```bash
git clone https://github.com/username/absen_app.git
cd absen_app
```

### 2. Setup Database

Buka MySQL dan jalankan SQL berikut:

```sql
CREATE DATABASE absensi_db;
USE absensi_db;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  role ENUM('admin','member') DEFAULT 'member',
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE organizations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  address TEXT,
  logo_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE kelas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  org_id INT NOT NULL,
  name VARCHAR(300) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

CREATE TABLE kelas_members (
  id INT AUTO_INCREMENT PRIMARY KEY,
  kelas_id INT NOT NULL,
  user_id INT NOT NULL,
  role ENUM('leader','member') DEFAULT 'member',
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_kelas_user (kelas_id, user_id),
  FOREIGN KEY (kelas_id) REFERENCES kelas(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  kelas_id INT NOT NULL,
  created_by INT,
  title VARCHAR(150) NOT NULL,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NULL DEFAULT NULL,
  latitude DOUBLE,
  longitude DOUBLE,
  radius_meters FLOAT DEFAULT 100,
  status ENUM('open','closed') DEFAULT 'open',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (kelas_id) REFERENCES kelas(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE attendances (
  id INT AUTO_INCREMENT PRIMARY KEY,
  session_id INT NOT NULL,
  user_id INT NOT NULL,
  checked_in_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  latitude DOUBLE,
  longitude DOUBLE,
  photo_url TEXT,
  status ENUM('hadir','terlambat','izin','alpha') DEFAULT 'hadir',
  device_type ENUM('mobile','web','desktop'),
  UNIQUE KEY uq_session_user (session_id, user_id),
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### 3. Jalankan Backend

```bash
cd backend
npm install
```

Buat file `.env`:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=absensi_db
JWT_SECRET=ganti_dengan_secret_yang_panjang
PORT=3000
```

```bash
npm run dev
```

Backend berjalan di `http://localhost:3000`

### 4. Jalankan Web

```bash
cd web/absensi-web
npm install
```

Buat file `.env.local`:

```env
NEXT_PUBLIC_API_URL=http://localhost:3000
```

Buat file `jsconfig.json`:

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

```bash
npm run dev
```

Web berjalan di `http://localhost:3001`

### 5. Jalankan Mobile (Android)

Sesuaikan IP backend di `mobile/absensi_mobile/lib/config/app_config.dart`:

```dart
// Untuk emulator Android
static const String baseUrl = 'http://10.0.2.2:3000';

// Untuk device fisik (ganti dengan IP komputer kamu)
// static const String baseUrl = 'http://192.168.1.xxx:3000';
```

```bash
cd mobile/absensi_mobile
flutter pub get
flutter run
```

---

## 📡 Endpoint API

| Method | Endpoint | Auth | Deskripsi |
|--------|----------|------|-----------|
| POST | `/api/auth/register` | ✗ | Registrasi user baru |
| POST | `/api/auth/login` | ✗ | Login dan dapat token JWT |
| GET | `/api/auth/profile` | ✓ | Profil user yang login |
| POST | `/api/organisasi` | ✓ | Buat organisasi |
| GET | `/api/organisasi` | ✓ | List organisasi |
| POST | `/api/kelas` | ✓ | Buat kelas |
| GET | `/api/kelas` | ✓ | List kelas |
| POST | `/api/kelas/:id/anggota` | ✓ | Tambah anggota kelas |
| GET | `/api/kelas/:id/anggota` | ✓ | List anggota kelas |
| DELETE | `/api/kelas/:id/anggota/:uid` | ✓ | Hapus anggota |
| POST | `/api/absensi/sesi` | ✓ | Buka sesi absensi |
| GET | `/api/absensi/sesi` | ✓ | List sesi |
| PATCH | `/api/absensi/sesi/:id/tutup` | ✓ | Tutup sesi |
| POST | `/api/absensi/checkin` | ✓ | Check-in absensi |
| GET | `/api/absensi/sesi/:id/rekap` | ✓ | Rekap per sesi |
| GET | `/api/absensi/riwayat` | ✓ | Riwayat absensi user |
