# UI Design — Aplikasi Keuskupan Labuan Bajo

Dokumen desain UI (rekomendasi) untuk aplikasi pembukuan keuskupan.
Versi sekarang Material 3 seed `deepPurple`; dokumen ini usul upgrade visual
bertema keuskupan agar lebih khidmat, hangat, dan profesional.

---

## 1. Identitas Visual & Tema

### 1.1 Palet Warna (Nuansa Liturgis)

Ganti tema flat-ungu jadi palet tergambar dari liturgi & alam Flores.

| Token | Hex | Pemakaian |
|-------|-----|-----------|
| `krem` (background) | `#FAF6F0` | latar seluruh app, hangat kertas |
| `deepPurple` (utama) | `#5B2E7C` | ungu rohani, AppBar, tombol utama, aksen |
| `goldEmas` (sekunder) | `#C9A227` | aksen premium, ikon, highlight, badge |
| `hijauEucalyptus` | `#2E7D6E` | aksen pembukuan/saldo, "harapan" |
| `biruLaut` | `#2563A8` | kategori/akun debit |
| `orangeKhas` | `#C96F2E` | khas warna alam & peringatan |
| `darkText` | `#3A2E2E` | teks utama, netral hangat |
| `abuHangat` | `#8A7F7A` | teks sekunder |

### 1.2 Tipografi
- Judul/page: **serif** (Salib/Khitan Roma) — terasa klasik, resmi, rohani.
- Isi/data/angka: **sans-serif** (Roboto/Inter) — jelas & mudah dibaca, format Rupiah tegas.
- Angka nominal selalu pakai `fontFeatures: [tabularFigures]` biar rata & konsisten.

### 1.3 Gaya & Nuansa
- **Card radius 16, bayangan lembut, background krem** — bukan putih polos.
- **Aksen "menyeberang"** tipis emas pada header/AppBar (ingat ukir gereja).
- Ikon konsisten: buku, gereja, dompet, salib — bukan ikon generik.
- Bahasa UI **Indonesia**, salam pembuka ramah di dashboard.
- Logo/aplikasi: ikon `church` dalam lingkaran gradient ungu→emas.

---

## 2. Navigasi Utama

```
[Web / lebar > 700px]          [Mobile]
┌──────┬────────────────┐      ┌─────────────────────┐
│ 🏛️  │                │      │   Konten Halaman    │
│ Dash │                │      │                     │
│ 📖   │    KONTEN      │      │                     │
│ ✚    │   (max 900)   │      │                     │
│ 📊   │                │      ├─────────────────────┤
│ ⚙️   │                │      │ 📖 ✚ 📊 ⚙️         │
└──────┴────────────────┘      └─────────────────────┘
```

- **4 tab konsisten**: Dashboard (🏛️), Jurnal (📖), Rekap (✚/📊), Settings (⚙️).
- Web → `NavigationRail` kiri (dengan label), konten center `maxWidth 900`.
- Mobile → `NavigationBar` bawah.
- Indikator sync global (ikon cloud + angka pending) ada di AppBar tiap halaman data.

---

## 3. Penjelasan Tiap Page

### 3.1 Dashboard — `Dashboard (Tab 1)`
**Tujuan:** ringkasan keadaan keuangan & sinkronisasi dalam sekali lihat.

Desain baru:
- **Greeting Card** — "Selamat datang, Admin 💒" + tanggal liturgi, background gradient ungu→emas, teks putih. Nuansa rohani.
- **Kartu Angka Besar (KPI):**
  - Jumlah Jurnal bulan ini
  - Total Debit, Total Kredit, Saldo (iklan dengan ikon)
- **Status Sync Card** — ikon cloud besar: hijau (ter-sync) / oranye (pending N) + tombol "Sync Sekarang".
- **Aksi cepat:** tombol "Buat Jurnal Baru", "Lihat Rekap".
- Pull-to-refresh + auto-sync saat online.

---

### 3.2 Jurnal — `Jurnal (Tab 2)`
**Pencatatan transaksi offline-first.**

#### 3.2.1 Daftar Jurnal
- Search bar khusus (cari no bukti / deskripsi / tanggal).
- Filter: bulan, status sync (semua / pending / synced).
- List card per jurnal:
  - Baris atas: tanggal (merah/berat) + **No Bukti** (bold, chip emas).
  - Deskripsi, ikon status (`✓ sync` hijau / `pending` oranye) + `n detil`.
  - Tombol hapus (ikon sampah) kiri, tap card → detail.
- FAB besar "+ Jurnal" (ungu, icon + putih).

#### 3.2.2 Form Jurnal
- Stepper multi-langkah biar simpel:
  1. **Info Umum**: Keuskupan (dropdown), Tanggal (picker), Deskripsi, No Bukti.
  2. **Detil** (& plus baris dinamis): Akun (dropdown), Paroki (dropdown), Debit, Kredit.
     - Per baris kartu berkode warna: kolom Debit dibingkai biru, Kredit hijau.
     - Auto-jumlah detil tampil live di bawah.
- Tombol **"Simpan Offline"** hijau + notif "Jurnal disimpan lokal ✓ (pending sync)".
- Snackbar sukses hijau, gagal merah.

#### 3.2.3 Detail Jurnal
- Header card: status sync + tanggal + no bukti besar.
- Info label (`Keuskupan`, `Deskripsi`, `ID`) rapi.
- Tabel detil "dokumen akuntansi": kode akun + nama, paroki, **Debit** (biru kanan), **Kredit** (hijau kanan).
- Footer: **Total Debit / Total Kredit / Balance check** — seimbang (debit=kredit) ditandai ✓ hijau.

---

### 3.3 Rekap — `Rekap (Tab 3)`
**Laporan keuangan per periode.**

#### 3.3.1 Rekap Keuskupan
- **MonthYearPicker** rapi: `‹ Februari 2026 ›` dengan tombol panah & dropdown bulan/tahun.
- Dropdown Keuskupan (jika >1).
- **Summary Row** — 3 kartu besar: Total Debit (biru), Total Kredit (hijau), **Saldo** (emas) + ikon.
- **"Rekap Per Paroki"** — section header tebal. List `ParokiRecapCard`: ikon gereja ungu, nama paroki, Debit/Kredit terformat, chevron → detail.
- Empty state ramah: ikon gereja abu + "Belum ada data" + tombol seed.
- Pull-to-refresh. FAB "Seed Sample" hanya kalau kosong.

#### 3.3.2 Rekap Detail Paroki
- AppBar nama paroki, MonthYearPicker, Summary Row.
- **"Rincian Per Akun"** dikelompokkan per **jenis** (Pendapatan/Beban):
  - Group header ungu muda: nama jenis uppercase + subtotal D/K.
  - Tiap baris akun: `kode - nama`, nominal Debit (biru) & Kredit (hijau).
- Nuansa "laporan resmi" — tabel rata kanan, garis pemisah halus.

---

### 3.4 Settings — `Settings (Tab 4)`
- **Sync**: status online/pending/retry, tombol "Sync Now".
- **Auth**: info JWT (access/refresh), tombol tes koneksi.
- **Database**: profil drift native (mobile) / WASM (web).
- **Tentang**: logo, versi app, informasi keuskupan.
- Tampilan: tile dengan ikon seksi, section terpisah (Koneksi / Keamanan / Tentang).

---

### 3.5 Auth / Login (folder kosong — usul desain)
**Tujuan:** masuk & jaga kredensial.

- Layar pusat: logo lingkaran ungu→emas, judul "Keuskupan Labuan Bajo".
- Kartu login putih radius besar: field **Email / Username** + **Password** (toggle mata), tombol "Masuk" ungu penuh.
- Ceklis "Ingat saya" + link "Butuh bantuan?".
- Nuansa: background gradient krem, ornament liturgis tipis.

---

### 3.6 Master Data (folder kosong — usul desain)
**Tujuan:** kelola data tetap (paroki, akun, jenis, keuskupan).

- Tab/switcher: **Keuskupan | Paroki | Akun | Jenis**.
- List tiap entitas: card nama + keterangan, tombol tambah/ubah/hapus.
- Floating "Tambah" membuka form (nama, kode, alamat) validasi wajib.

---

## 4. Komponen Reusable (usul upgrade)

| Komponen | Fungsi | Model Visual |
|----------|--------|--------------|
| `MonthYearPicker` | pilih periode | panah + bulan Indonesia (Januari–Desember) |
| `SummaryCard` / `SummaryRow` | 3 KPI nominal | debit biru, kredit hijau, saldo emas |
| `ParokiRecapCard` | ringkas per paroki | ikon church + debit/kredit |
| `AkunDetailTile` | rincian per akun | kode-nama, nominal rata kanan |
| `SyncIndicator` | status sinkron | cloud hijau/oranye + angka pending |
| `formatRupiah` | format nominal | `Rp 1.000.000`, tabular figures |

---

## 5. Pedoman UX

- **Offline-first**: setiap simpan langsung `is_synced=0`, notif "pending sync" jelas; auto-push saat online.
- **Feedback visual**: loading = spinner, error = ikon merah + tombol retry, sukses = Snackbar hijau.
- **Responsive**: satu codebase app+web, konten center `maxWidth 900` di layar lebar.
- **Aksesibilitas dasar**: kontras teks vs krem memadai, ukuran teks 12–16, tappable minimal 48px.
- **Konsisten**: semua nominal pakai `formatRupiah`; warna debit/kredit/saldo konsisten lintas page (biru/hijau/emas).

---

## 6. Roadmap Implementasi (urutan prioritas)

1. Ganti tema di `main.dart` → palet keuskupan + serif judul.
2. Upgrade **Dashboard** → greeting + KPI cards.
3. Upgrade **Rekap** → tabel laporan resmi + grouping akun.
4. Upgrade **Form/Daftar Jurnal** → stepper + search/filter.
5. Bangun **Login** (auth).
6. Bangun **Master Data** (paroki, akun, jenis).
7. Polish: tabular figures, ornament emas, empty states ramah.
8. Export / cetak laporan (PDF/CSV) di Rekap.
9. Onboarding / guard master data (first-run).

---

## 7. Rekomendasi Review UI/UX (tambahan)

Hasil review desain di atas untuk konteks aplikasi keuangan keuskupan
(entry harian berulang, data resmi/audit, user non-teknis, konektivitas terbatas).

### 7.1 Prioritas Tinggi

1. **Balanced check live di form jurnal** — tampilkan "Debit = Kredit?" sebelum simpan
   (bukan hanya di detail). Izinkan simpan unbalanced sebagai draft dengan warning oranye —
   offline-first, info akun lawan belum tentu ada saat itu.
2. **Input angka Rupiah** — `keyboardType: number`, pemisah ribuan otomatis saat mengetik
   (`1.000.000`). Format tampilan saja tidak cukup; yang sering salah adalah input.
3. **Export / cetak laporan (PDF/CSV)** — laporan bulanan tercetak kebutuhan resmi keuskupan
   (audit/pelaporan). Tambahkan di Rekap.
4. **Login tidak boleh memblok mode offline** — offline-first tapi auth JWT: saat offline,
   app tetap terbuka untuk input (token tersimpan / PIN lokal). Sinkron saat online kembali.
5. **Hapus tombol "Seed Sample" dari UI produksi** — risiko data palsu tercampur data asli.
   Hanya aktif di `kDebugMode`.

### 7.2 Perbaikan Desain

6. **Kontras emas** — `#C9A227` di atas krem kontras rendah (~2.5:1). Emas hanya untuk
   aksen/ikon/border; teks nominal saldo pakai emas gelap `#8A6D1D` atau hijau.
7. **Form jurnal 1 halaman, bukan stepper** — pencatatan berulang tiap hari; stepper = banyak
   tap. Satu halaman scroll dengan 2 section (Info + Detil), tombol Simpan selalu terjangkau.
8. **Ikon tab Rekap** — pakai bar chart (📊), bukan ✚. Salib cukup untuk greeting/logo.
9. **Emoji `💒` di greeting** — ganti dengan ikon `church` dari font; app resmi keuskupan
   sebaiknya tanpa emoji.
10. **App lock (PIN/biometrik)** opsional di Settings — data keuangan di perangkat bersama.

### 7.3 Rekomendasi Fungsional

11. **Onboarding / guard master data** — dropdown Akun & Paroki kosong membuat user baru
    bingung. Deteksi master data kosong → layar panduan "Isi Paroki & Akun dulu" + CTA.
12. **Tombol duplikat jurnal** — transaksi berulang (listrik, gaji, persembahan). Detail →
    "Salin" → form terisi. Hemat entry terbesar.
13. **Nomor bukti auto-generate** — format `JB/2026/09/001`, tetap bisa diedit manual.
14. **Hapus = soft delete + Undo** — Snackbar "Undo" 5 detik + arsip, jangan hard delete.
    Salah hapus di keuangan sulit dipulihkan.
15. **Auto-save draft form** — simpan draft lokal per perubahan; crash/back tidak sengaja
    tidak boleh menghilangkan entry.
16. **Konflik sync** — dua device mengedit jurnal sama: aturan last-write-wins + penanda
    "konflik" oranye di list. Status sync saja tidak cukup.
17. **Audit trail ringan** — kolom `created_by` + `updated_at` disiapkan di skema sejak awal
    (migrasi belakangan mahal), tampil di detail jurnal.
18. **Quick chips tanggal** — "Hari ini | Kemarin" di form, default hari ini.
19. **Konfirmasi buang perubahan** — form berisi isian + back → dialog "Buang perubahan?".
20. **Rekap tahunan (YTD)** — gereja melapor tahunan; tambahkan view tahunan setelah bulanan.

### 7.4 Ditunda (YAGNI)

Dark mode, multi-bahasa, skeleton loading, animasi kompleks, multi-currency,
approval workflow multi-level, chart grafik — tambahkan saat kebutuhan nyata muncul.

*Dokumen desain rekomendasi — implementasi bertahap dimulai dari #1.*
