keuskupanlaboanbajo_fe
=======================

Frontend Flutter untuk sistem keuangan Keuskupan Labuan Bajo.
Aplikasi jurnal akuntansi offline-first dengan sinkronisasi data ke backend.

FITUR UTAMA
-----------
- Autentikasi (login) disimpan aman via flutter_secure_storage
- Jurnal akuntansi (pencatatan transaksi)
- Master data: paroki, jenis, akun
- Rekap laporan keuangan
- Dashboard
- Sinkronisasi data online/offline (local DB + push ke server)
- Deteksi koneksi internet via connectivity_plus

TEKNOLOGI & ARSITEKTUR
----------------------
- Flutter / Dart
- State management: flutter_bloc (Bloc/Cubit)
- Database lokal: drift + drift_flutter (SQLite)
- Code generation: build_runner, drift_dev
- Arsitektur: Clean Architecture terstruktur per folder
  - lib/core        : auth, di, errors, network, storage, sync, theme, utils
  - lib/data         : models, local (dao, migrations), remote (dto, mappers), repository
  - lib/features     : auth, dashboard, debug, jurnal, master, recap, settings, sync
  - lib/shared       : navigation, providers, widgets
- Dependensi utama: drift, flutter_bloc, http, flutter_secure_storage,
  connectivity_plus, crypto, uuid

DEPENDENSI (pubspec.yaml)
-------------------------
- cupertino_icons ^1.0.8
- drift ^2.34.3
- drift_flutter ^0.3.1
- uuid ^4.6.0
- connectivity_plus ^7.3.1
- flutter_secure_storage ^11.0.0
- http ^1.6.0
- flutter_bloc ^9.1.1
- crypto ^3.0.7

Dev: flutter_lints, drift_dev, build_runner

MENJALANKAN PROYEK
------------------
1. pastikan Flutter SDK terinstall (SDK >= ^3.10.0)
2. install dependensi:
   flutter pub get
3. (opsional) regenerasi kode drift DB:
   dart run build_runner build --delete-conflicting-outputs
4. jalankan aplikasi:
   flutter run

STRUKTUR DATA / DB LOCAL
------------------------
Database drift (SQLite) digenerate ke lib/generated, dikelola lewat
lib/data/local/app_database.dart.
Tabel utama: jurnal + master (keuskupan, paroki, jenis, akun).

SINKRONISASI (SYNC)
-------------------
- Push data lokal ke server: POST /api/v1/sync/push
- Perbaikan teknis terdokumentasi di docs/sync_error_log.md
  (CORS OPTIONS 401, FK keuskupan_id kosong, dll)

DOKUMEN
-------
- docs/sync_error_log.md : log error & perbaikan sinkronisasi

TESTING
-------
- test/        : unit test
- integration_test/ : integration test
jalankan: flutter test

ASSETS
------
- assets/fonts, assets/icons, assets/images
