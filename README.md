# Aplikasi Pendamping Beauty & Self Care
## My Daily Glam

My Daily Glam adalah aplikasi pendamping kecantikan dan perawatan diri (self-care) yang dirancang untuk membantu pengguna mengelola rutinitas harian, inventaris produk kecantikan, dengan estetika yang "Girly & Cheerful".

## Fitur Aplikasi

1. Sistem Autentikasi: Login dan Register menggunakan Firebase Auth untuk keamanan data pengguna.
2. Dashboard Personal: Pusat kendali kecantikan yang menampilkan ringkasan Mood harian dan entri Jurnal terbaru secara real-time.
3. Jurnal Perawatan Diri: Ruang khusus untuk mencatat rutinitas perawatan kulit dan tubuh.
4. Manajemen Produk (REST API):
   * Mengelola koleksi kosmetik dengan data yang diambil dari MockAPI.io.
   * Tampilan list produk yang dinamis dan detail produk yang mendalam.
5. Glam Wishlist: Tempat khusus untuk menyimpan produk impian untuk referensi belanja masa depan.
6. Mood Tracker Harian: Melacak kesehatan mental dan kebahagiaan pengguna setiap hari dengan antarmuka yang interaktif.

### 

## 1. Persiapan Awal

### a. pusbec.yaml

Buka file `pubspec.yaml`, lalu tambahkan:

```yaml
dependencies:

  # Firebase & Database
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  intl: ^0.19.0

  # API & Networking
  image_picker: ^1.0.7
  http: ^1.2.1

  # UI & Components
  table_calendar: ^3.1.1
  google_fonts: ^6.2.1

  # Animation & Assets
  lottie: ^3.1.0
```

Lalu jalankan:

```bash
flutter pub get
```

### b. Struktur Folder

```
lib/
 ┣ models/
 ┃ ┗ product_model.dart
 ┣ services/
 ┃ ┣ api_service.dart
 ┃ ┗ auth_service.dart
 ┣ views/
 ┃ ┣ auth/
 ┃ ┃ ┣ login_page.dart
 ┃ ┃ ┗ register_page.dart
 ┃ ┣ mood/
 ┃ ┃ ┗ mood_tracker_page.dart
 ┃ ┣ pages/
 ┃ ┃ ┣ add_journal_page.dart
 ┃ ┃ ┣ add_wishlist_page.dart
 ┃ ┃ ┣ journal_page.dart
 ┃ ┃ ┗ wishlist_page.dart
 ┃ ┣ products/
 ┃ ┃ ┣ add_product_page.dart
 ┃ ┃ ┣ product_detail_page.dart
 ┃ ┃ ┗ product_list_page.dart
 ┃ ┣ dashboard_page.dart
 ┃ ┗ exit_helper.dart
 ┣ firebase_options.dart
 ┗ main.dart

## 2. Demo Aplikasi

https://drive.google.com/drive/folders/1N3Zc8Ne46UWOpE2QIQz2RF5kCRHWt0OT?usp=drive_link

```

---
