# 📌 Flutter Attendance App

Aplikasi absensi sederhana berbasis **Flutter**, menggunakan:

- 📍 **Geolocator + Geocoding** → cek lokasi & alamat
- 📸 **Image Picker** → ambil selfie absensi
- 💾 **Shared Preferences** → simpan data lokal
- 🗂️ **Path Provider** → simpan foto secara persisten di storage aplikasi

---

## 🚀 Fitur Utama

- Login sederhana (dummy):
  - **Email:** `jayasaleh@gmail.com`
  - **Password:** `jayasaleh123`
  - Nama default: `Jaya Saleh`
- Ambil lokasi saat ini dan cek jarak ke kantor
- Validasi **radius 100 meter** dari kantor
- Ambil selfie dengan kamera depan
- Simpan data absensi (lokasi, alamat, timestamp, status, foto)
- Riwayat absensi tersimpan secara lokal
- Riwayat absensi bisa dihapus semua dan jika dihapus maka hari ini harus absen juga
- Logout untuk kembali ke halaman login

---

## 📂 Struktur Folder

```
lib/
 ┣ main.dart                 # Entry point aplikasi
 ┣ pages/
 ┃ ┣ login_page.dart         # Halaman login
 ┃ ┣ attendance_page.dart    # Halaman absensi
 ┃ ┗ history_page.dart       # Riwayat absensi
 ┣ models/
 ┃ ┗ attendance_record.dart  # Model data absensi
 ┣ services/
 ┃ ┣ storage_service.dart    # Penyimpanan lokal (SharedPreferences)
 ┃ ┗ location_service.dart   # Layanan lokasi (geolocator + geocoding)
```

---

## ⚙️ Persiapan

### Download langsung

#### 1. Extract File

#### 2. Install dependencies

```bash
flutter pub get
```

#### 3. Jalankan aplikasi

```bash
flutter run
```

### Github

#### 1. Clone project

```bash
git clone https://github.com/jayasaleh/attendance-app-tht
cd attendance-app-tht-master
```

#### 2. Install dependencies

```bash
flutter pub get
```

#### 3. Jalankan aplikasi

```bash
flutter run
```

---

## 🧭 Cara Pakai

1. Login dengan akun dummy:
   ```
   Email: jayasaleh@gmail.com
   Password: jayasaleh123
   ```
2. Masuk ke halaman absensi
3. pastikan berada dalam radius 100m dari kantor dan Klik **Refresh Lokasi**
4. Klik **Ambil Foto**
5. Klik **Absen Sekarang**
6. Lihat riwayat absensi via tombol **History**
7. Hapus semua riwayat absensi tombol **Clear** di pojok kanan atas di screen riwayat
8. Logout dengan ikon keluar di pojok kanan atas

---

## 🛠️ Dependency

- flutter: sdk: flutter
- geolocator
- geocoding
- image_picker
- shared_preferences
- path_provider
- intl

---
