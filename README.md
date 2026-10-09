# Keuskupan Labuan Bajo - Frontend (FE)

Sistem Jurnal Keuangan Keuskupan Labuan Bajo - Offline First (Flutter).

## Fitur Utama
- **Offline First**: Drift SQLite lokal + enkripsi SQLCipher.
- **Sync Engine**: Auto push queue + pull background, resolusi konflik `no_bukti` duplikat & deduplikasi data master.
- **Responsive UI**: Web & Mobile (Android/iOS).
- **Rekap & Ekspor**: Weekly / Monthly / Yearly tables + export PDF.

## Dependency (`pubspec.yaml`)

### Runtime
| Package | Versi | Fungsi | Dipakai di |
|---------|-------|--------|------------|
| `drift` | ^2.34.3 | Database lokal SQLite type-safe (query builder) | Seluruh layer data |
| `drift_flutter` | ^0.3.1 | Integrasi Drift dengan Flutter (path DB, web WASM) | `app_database.dart` |
| `sqlcipher_flutter_libs` | ^0.7.0+eol | Native lib SQLCipher → enkripsi database | `AppDatabase.encrypted` |
| `uuid` | ^4.6.0 | Generate ID unik untuk jurnal (cuid-style) | `jurnal_repository_impl.dart` |
| `connectivity_plus` | ^7.3.1 | Deteksi status online/offline perangkat | `connectivity_service.dart` |
| `flutter_secure_storage` | ^11.0.0 | Simpan token JWT di penyimpanan aman (Keychain/Keystore) | `token_storage.dart` |
| `http` | ^1.6.0 | HTTP client untuk request ke BE | `sync_service.dart`, auth, master |
| `flutter_bloc` | ^9.1.1 | Manajemen state (Cubit pattern) | `jurnal_cubit.dart` |
| `crypto` | ^3.0.7 | Utilitas hashing / kripto | `db_key_service.dart` |
| `shared_preferences` | ^2.5.5 | Preferensi ringan (timestamp `last_pull`) | `sync_service.dart` |
| `path_provider` | ^2.1.5 | Path direktori dokumen (lokasi file DB) | `main.dart` |
| `fl_chart` | ^1.2.0 | Grafik untuk dashboard & rekap | Dashboard / Rekap |
| `pdf` | ^3.11.3 | Generate dokumen PDF rekap | `pdf_export.dart` |
| `printing` | ^5.14.3 | Preview & cetak/simpan PDF | `pdf_export.dart` |
| `cupertino_icons` | ^1.0.8 | Set ikon gaya iOS | UI |

### Dev
| Package | Versi | Fungsi |
|---------|-------|--------|
| `flutter_lints` | ^6.0.0 | Aturan lint kualitas kode |
| `drift_dev` | ^2.34.0 | Code generator Drift (`app_database.g.dart`) |
| `build_runner` | ^2.15.1 | Menjalankan codegen (`dart run build_runner build`) |

> Catatan: `sqlcipher_flutter_libs` versi `+eol` adalah rilis terakhir (end-of-life). Aman dipakai sekarang; kalau perlu update besar, pertimbangkan migrasi ke paket pengganti.

## Cara Menjalankan
1. Masuk ke direktori `keuskupanlaboanbajo_fe/`.
2. Ambil dependensi:
   ```bash
   flutter pub get
   ```
3. Sesuaikan IP server BE di `lib/core/config/api_config.dart` (harus sama dengan IP laptop, satu WiFi):
   ```dart
   return kIsWeb ? 'http://localhost:8080' : 'http://<IP_LAPTOP>:8080';
   ```
4. Jalankan aplikasi di perangkat:
   ```bash
   flutter run -d <device_id>
   ```
