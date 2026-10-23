# Keuskupan Labuan Bajo - Frontend (FE)

Sistem Jurnal Keuangan Keuskupan Labuan Bajo - Offline First (Flutter).

## Fitur Utama
- **Offline First**: Drift SQLite lokal + enkripsi SQLCipher.
- **Sync Engine**: Auto push queue + pull background, resolusi konflik `no_bukti` duplikat & deduplikasi data master.
- **Responsive UI**: Web & Mobile (Android/iOS).
- **Rekap & Ekspor**: Weekly / Monthly / Yearly tables + export PDF.

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
