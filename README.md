<div align="center">

# 📌 Pindea

**Local-First Modular Notes with Seamless Peer-to-Peer LAN Synchronization**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Drift SQLite](https://img.shields.io/badge/Database-Drift%20SQLite-003B57?logo=sqlite&logoColor=white)](https://drift.simonbinder.eu)
[![Riverpod](https://img.shields.io/badge/State-Riverpod%202.x-black)](https://riverpod.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20Android%20%7C%20Linux-4CAF50)](#platform-support)
[![Tests](https://img.shields.io/badge/Tests-24%2F24%20Passed-brightgreen)](#pengujian--kualitas)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

*Pindea adalah aplikasi pencatatan modular cerdas yang mengutamakan privasi 100%, beroperasi secara offline-first, dan memungkinkan sinkronisasi data antar perangkat dalam satu jaringan Wi-Fi lokal (LAN) tanpa bergantung pada server cloud pihak ketiga.*

</div>

---

## 🌟 Mengapa Pindea?

Di era modern, sebagian besar aplikasi catatan bergantung pada server cloud eksternal yang menyimpan data sensitif pengguna, rentan terhadap downtime internet, dan sering kali menerapkan model langganan berulang.

**Pindea dibangun dengan filosofi berbeda:**
1. **Privasi Mutlak (*Zero Cloud Leak*)**: Seluruh catatan tersimpan secara lokal di database SQLite perangkat Anda.
2. **Kemandirian Jaringan**: Tetap berfungsi 100% tanpa internet. Sinkronisasi multi-perangkat berjalan langsung melalui jaringan Wi-Fi lokal (*peer-to-peer LAN*).
3. **Pengalaman Visual yang Taktil**: Menggabungkan antarmuka minimalis modern dengan pengalaman taktil memo fisik meja kerja (*Stacked Sticky Notes*).

---

## ✨ Fitur-Fitur Utama

### 1. 📑 Stacked Sticky Notes (Quick Notes)
- **Tumpukan Memo Berlapis (*Layered Paper Stack*)**: Menampilkan catatan yang di-pin layaknya tumpukan kertas post-it fisik di atas meja dengan bayangan lembut dan rotasi sudut alami (-2° dan +1.7°).
- **Pin Fisik (*Top-Center Pushpin*)**: Jangkar visual paku payung realistis dengan gradien radial dan pencahayaan dinamis di bagian tengah atas memo.
- **Interaksi Seketika**:
  - Draf checklist dapat langsung dicentang/di-toggle dari layar utama tanpa harus membuka editor penuh.
  - Geser (swipe horizontal) ke kiri atau kanan untuk berpindah antar catatan yang di-pin secara mulus.
- **Palet Pastel Pindea**: 8 varian warna pastel lembut (*Yellow, Green, Blue, Pink, Orange, Purple, Teal, Gray*) yang beradaptasi optimal di tema Terang maupun Gelap.

### 2. 📝 Editor Blok Modular (*Modular Block Canvas*)
- Format catatan berbasis blok dinamis dengan urutan pecahan (*fractional indexing*):
  - **Text / Paragraf**: Penulisan bebas tanpa hambatan container kartu.
  - **Subjudul (Heading)**: Penataan hierarki catatan yang tegas.
  - **Interactive Checklist**: Daftar tugas yang rapi dengan indikator selesai tercoret (*strikethrough*).
  - **Poin Daftar (Bullet)**: Ringkasan daftar poin berbobot.
  - **Tautan Web (Link)**: Penyimpanan tautan referensi web yang mudah diakses.
  - **Media Gambar (Image)**: Integrasi pemilih gambar dari galeri perangkat atau penyimpanan lokal (*local file storage*), tersimpan permanen di direktori aman aplikasi.
- **Floating Bottom Dock Toolbar**: Akses satu ketukan untuk menyisipkan blok baru, undo/redo, dan pengelolaan blok.

### 3. 🔄 Sinkronisasi Peer-to-Peer LAN (Tanpa Cloud)
- **Server Internal Shelf**: Setiap instance Pindea dapat bertindak sebagai Hub maupun Klien sinkronisasi dalam jaringan Wi-Fi yang sama.
- **Pairing Aman via QR Code**: Proses pemasangan perangkat yang cepat dan aman dengan verifikasi PIN kriptografi.
- **Resolusi Konflik HLC (*Hybrid Logical Clock*)**: Melacak perubahan operasi per-blok menggunakan HLC terdistribusi (terinspirasi dari konsep CRDT), memastikan penggabungan data yang konsisten tanpa tumpang-tindih.

### 4. 🎨 Sistem Desain Tersentralisasi (*Design Tokens*)
- Dibangun dengan arsitektur token tanpa hardcoding nilai warna, ukuran, atau tipografi:
  - `AppColors`: Manajemen palet warna semantik, kontras aksesibilitas, dan warna pastel.
  - `AppDimensions`: Konsistensi padding, radius sudut, dan margin layar.
  - `AppTypography`: Skala tipografi modern berbasis Google Fonts *Inter* dan *Space Mono*.
- Dukungan penuh untuk mode **Terang (*Light Mode*)** dan **Gelap (*Dark Mode*)**.

### 5. 🗑️ Kotak Sampah & Manajemen Cadangan
- Fitur *soft delete* yang aman dengan layar pemulihan (*Trash Screen*) khusus.
- Ekspor catatan ke format **Markdown (`.md`)** dan cadangan seluruh ruang kerja ke format **JSON**.

---

## 🏗️ Arsitektur Proyek

Struktur direktori dirancang dengan prinsip modularitas tinggi dan pemisahan tanggung jawab (*Separation of Concerns*):

```text
lib/
├── core/
│   ├── crypto/            # Hybrid Logical Clock (HLC) & Kriptografi PIN
│   ├── database/          # Drift SQLite (Workspace & Device Database)
│   ├── theme/             # Token Desain (AppColors, AppDimensions, AppTypography)
│   └── utils/             # Fractional Indexing & Utilitas Umum
├── features/
│   ├── notes/             # Modul Catatan (Domain, Data Repository, Editor, Trash)
│   └── sync/              # Modul Sinkronisasi LAN (Hub Server, Client Engine, QR Pairing)
├── shared/
│   └── widgets/           # Komponen UI Terpusat (AppCard, AppButton, PinnedStickyStack, dll.)
└── main.dart              # Entry Point Aplikasi & Layar Utama (Home Screen)
```

---

## 🚀 Memulai (*Getting Started*)

### Prasyarat
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi `>= 3.11.5`)
- [Dart SDK](https://dart.dev/get-dart)
- C++ Build Tools (untuk Windows Desktop) atau Android Studio / SDK (untuk Android)

### Instalasi & Menjalankan Aplikasi

1. **Clone repositori ini**:
   ```bash
   git clone https://github.com/tholeteplok/Pindea.git
   cd Pindea
   ```

2. **Pasang seluruh dependensi**:
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**:
   - Untuk **Windows**:
     ```bash
     flutter run -d windows
     ```
   - Untuk **Android**:
     ```bash
     flutter run -d android
     ```

---

## 🧪 Pengujian & Kualitas Kode

Proyek ini dilengkapi dengan rangkaian pengujian komprehensif (Unit Test, Integration Test, dan Widget Test):

- **Menjalankan seluruh test suite**:
  ```bash
  flutter test
  ```
  *(Status: 24/24 tests lulus 100%)*

- **Menjalankan analisis lint**:
  ```bash
  flutter analyze
  ```
  *(Status: 0 issues / bersih)*

---

## 🔒 Privasi & Keamanan

Pindea secara ketat mengabaikan data sensitif dari version control:
- Berkas kredensial seperti `google-services.json`, `GoogleService-Info.plist`, `*.keystore`, `*.jks`, `key.properties`, dan `.env*` diproteksi secara absolut di `.gitignore`.
- Tidak ada data analitik pihak ketiga atau pelacak telemetri yang ditanamkan dalam aplikasi.

---

## 📄 Lisensi

Proyek ini dirilis di bawah lisensi [MIT License](LICENSE). Bebas digunakan, dipelajari, dan dikembangkan lebih lanjut.
