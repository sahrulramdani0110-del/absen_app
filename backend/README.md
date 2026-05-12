# Absensi Digital — Backend API

REST API untuk sistem absensi digital berbasis Node.js + Express + MySQL.

## Instalasi

```bash
npm install
```

Salin file `.env.example` menjadi `.env` dan sesuaikan isinya:

```bash
cp .env.example .env
```

Jalankan server:

```bash
# mode production
npm start

# mode development (auto-reload)
npm run dev
```

---

## Endpoint API

### Auth
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/auth/register` | Daftar user baru |
| POST | `/api/auth/login` | Login, mendapat token JWT |
| GET | `/api/auth/profile` | Profil user yang sedang login |

### Organisasi
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/organisasi` | Buat organisasi baru |
| GET | `/api/organisasi` | List semua organisasi |
| GET | `/api/organisasi/:id` | Detail organisasi |

### Kelas
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/kelas` | Buat kelas baru |
| GET | `/api/kelas` | List semua kelas |
| GET | `/api/kelas/:id` | Detail kelas |
| POST | `/api/kelas/:id/anggota` | Tambah anggota ke kelas |
| GET | `/api/kelas/:id/anggota` | List anggota kelas |
| DELETE | `/api/kelas/:kelas_id/anggota/:user_id` | Hapus anggota dari kelas |

### Absensi
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/absensi/sesi` | Buka sesi absensi |
| GET | `/api/absensi/sesi` | List sesi (filter: ?kelas_id=) |
| PATCH | `/api/absensi/sesi/:id/tutup` | Tutup sesi |
| POST | `/api/absensi/checkin` | Check-in absensi |
| GET | `/api/absensi/sesi/:id/rekap` | Rekap per sesi |
| GET | `/api/absensi/riwayat` | Riwayat absensi user login |

---

## Autentikasi

Semua endpoint kecuali `/register` dan `/login` membutuhkan header:

```
Authorization: Bearer <token>
```

---

## Contoh Request

### Register
```json
POST /api/auth/register
{
  "name": "Budi Santoso",
  "email": "budi@email.com",
  "password": "password123",
  "role": "admin"
}
```

### Login
```json
POST /api/auth/login
{
  "email": "budi@email.com",
  "password": "password123"
}
```

### Buka Sesi Absensi
```json
POST /api/absensi/sesi
{
  "kelas_id": 1,
  "title": "Absensi Senin Pagi",
  "start_time": "2026-05-12 08:00:00",
  "latitude": -6.9175,
  "longitude": 107.6191,
  "radius_meters": 100
}
```

### Check-in
```json
POST /api/absensi/checkin
{
  "session_id": 1,
  "latitude": -6.9176,
  "longitude": 107.6192,
  "photo_url": "https://...",
  "device_type": "mobile"
}
```
