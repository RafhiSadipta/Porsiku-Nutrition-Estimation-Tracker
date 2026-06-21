# 🍱 Porsiku — Nutrition Estimation & Tracker

Porsiku adalah aplikasi pelacak nutrisi berbasis AI. Cukup foto makananmu, dan
Porsiku akan mengenali jenis makanan beserta porsinya, mengestimasi nilai gizinya
(kalori, protein, lemak, karbohidrat), lalu mencatatnya ke dalam jurnal konsumsi
harian untuk dibandingkan dengan target gizi pribadimu.

## ✨ Fitur Utama

- 📸 **Deteksi Makanan dari Gambar** — ambil/unggah foto, AI mengenali makanan & porsinya.
- 🔢 **Estimasi Nutrisi Otomatis** — kalori, protein, lemak, dan karbohidrat per porsi.
- 🎙️ **Input Suara & Teks** — catat makanan lewat ucapan (speech-to-text) atau ketik manual.
- 📊 **Barcode Scanner** — pindai produk kemasan untuk mendapatkan info gizi.
- 🎯 **Target Gizi Harian** — perhitungan kebutuhan kalori & makro berdasarkan profil pengguna.
- 📈 **Analitik & Ringkasan Mingguan** — grafik perkembangan konsumsi gizi.
- 🍳 **Pencarian Resep** — temukan resep beserta detail nutrisinya.
- 💾 **Simpan Makanan (Saved Meal)** — simpan menu favorit untuk pencatatan cepat.
- 🔐 **Autentikasi** — registrasi/login email & Google Sign-Up dengan JWT.

## 🏗️ Arsitektur

Proyek ini terdiri dari dua bagian:

```
Porsiku-Nutrition-Estimation-Tracker/
├── porsiku/    # Frontend — aplikasi mobile Flutter
└── backend/    # Backend — REST API Go (Gin + GORM + MySQL)
```

### Frontend (`porsiku/`)
- **Flutter** (Dart SDK ^3.7.2)
- Library utama: `http`, `image_picker`, `camera`, `mobile_scanner`,
  `fl_chart`, `flutter_sound`, `flutter_secure_storage`, `google_fonts`,
  `flutter_screenutil`, `lottie`, `jwt_decoder`.

### Backend (`backend/`)
- **Go** 1.24 dengan framework **Gin**
- **GORM** + **MySQL** sebagai ORM & database
- Autentikasi berbasis **JWT**
- Integrasi layanan eksternal:
  - **OpenRouter** (model `google/gemma-3-27b-it`) — deteksi makanan & estimasi nutrisi
  - **AssemblyAI** — speech-to-text untuk input suara
  - **Spoonacular** — pencarian resep & info produk barcode

## 🚀 Menjalankan Proyek

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.7.2)
- [Go](https://go.dev/dl/) 1.24+
- MySQL Server

### 1. Backend

```bash
cd backend
```

Buat file `.env` di dalam folder `backend/`:

```env
# Database
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASS=yourpassword
DB_NAME=porsiku

# Server
PORT=8080

# Auth
JWT_SECRET=your_jwt_secret

# Layanan eksternal
OPENROUTER_API_KEY=your_openrouter_key
ASSEMBLYAI_API_KEY=your_assemblyai_key
SPOONACULAR_API_KEY=your_spoonacular_key
```

Jalankan server:

```bash
go mod download
go run main.go
```

Server berjalan di `http://localhost:8080`. Tabel database akan dibuat otomatis
melalui AutoMigrate saat pertama kali dijalankan.

### 2. Frontend

```bash
cd porsiku
flutter pub get
flutter run
```

> **Catatan:** `baseUrl` API di `lib/services/api_service.dart` saat ini menunjuk ke
> deployment produksi (Railway). Untuk pengembangan lokal, ubah `baseUrl` menjadi
> alamat backend lokalmu (mis. `http://10.0.2.2:8080/api` untuk emulator Android).

## 📡 Ringkasan Endpoint API

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/register` | Registrasi pengguna |
| POST | `/api/login` | Login |
| POST | `/api/google-signup` | Daftar via Google |
| POST | `/api/detect_food` | Deteksi makanan dari gambar |
| POST | `/api/nutri-estimation` | Estimasi nutrisi |
| POST | `/api/konsumsi` | Catat konsumsi |
| GET | `/api/konsumsi/:id_user` | Riwayat konsumsi pengguna |
| GET | `/api/daily_target/:id` | Target gizi harian |
| POST | `/api/resep` | Cari resep |
| GET | `/api/produk` | Info produk dari barcode |
| GET | `/api/analytics/:id_user` | Data analitik |
| GET | `/api/analytics/summary/:id_user` | Ringkasan mingguan |

*Sebagian besar endpoint memerlukan header `Authorization: Bearer <token>`.*

## 🛠️ Tech Stack

**Frontend:** Flutter · Dart
**Backend:** Go · Gin · GORM · MySQL · JWT
**AI / API:** OpenRouter (Gemma) · AssemblyAI · Spoonacular
**Deployment:** Railway

---

Dibuat sebagai proyek estimasi & pelacakan nutrisi. Kontribusi dan masukan dipersilakan.
