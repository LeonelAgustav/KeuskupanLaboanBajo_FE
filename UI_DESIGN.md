# UI Design — Aplikasi Keuskupan Labuan Bajo (Merged v2.0, Light Mode)

Dokumen desain UI tunggal (referensi) untuk aplikasi pembukuan keuskupan.
Versi gabungan: **tema light** (krem/ungu/emas) + **best practices** dari Design System v2.0
(6 tab, terminologi Pendapatan/Pengeluaran, Plus Jakarta Sans, Dashboard-First).

---

## 1. Identitas Visual & Tema (Light)

### 1.1 Palet Warna

| Token | Hex | Pemakaian |
|-------|-----|-----------|
| `krem` (background) | `#FAF6F0` | latar seluruh app, hangat kertas |
| `deepPurple` (primary) | `#5B2E7C` | ungu rohani, AppBar, FAB, tab aktif, tombol utama |
| `goldEmas` (secondary) | `#C9A227` | aksen premium, ikon, badge, indikator pending |
| `hijauPendapatan` | `#2E7D6E` | **Pendapatan (+)** — label UI, nominal hijau |
| `merahPengeluaran` | `#C96F2E` | **Pengeluaran (-)** — label UI, nominal merah |
| `darkText` | `#3A2E2E` | teks utama, netral hangat |
| `abuHangat` | `#8A7F7A` | teks sekunder, placeholder |

> Catatan: Backend tetap pakai kolom `debit`/`kredit`. Hanya **label UI** yang berubah:
> - `Debit` → **Pendapatan (+)** (warna `hijauPendapatan`)
> - `Kredit` → **Pengeluaran (-)** (warna `merahPengeluaran`)

### 1.2 Tipografi

- **Font**: **Plus Jakarta Sans** (embed asset di `assets/fonts/PlusJakartaSans/`, offline-first, **tanpa** dependency `google_fonts`).
- **Weight**:
  - `extrabold` (800) — nominal besar (KPI, total)
  - `bold` (700) — judul halaman, nama paroki, tombol aksi
  - `semibold` (600) — label form, status badge, tab label
  - `regular` (400) — body, deskripsi, helper text
- Angka nominal **selalu** pakai `fontFeatures: [FontFeature.tabularFigures()]` biar rata & konsisten.

### 1.3 Gaya & Nuansa

- **Card radius 16**, bayangan lembut (`elevation: 1`), background `krem`.
- **Aksen emas tipis** pada AppBar bottom border (width 2) & TabBar indikator (width 3).
- Ikon konsisten: `dashboard`, `book`, `bar_chart`, `settings`, `person`, `church`, `account_balance_wallet`.
- Bahasa UI **Indonesia**, salam pembuka ramah di Dashboard.
- Logo: ikon `church` dalam lingkaran gradient `deepPurple` → `goldEmas`.

---

## 2. Navigasi Utama

### 2.1 Mobile — Bottom Navigation Bar (6 Tab)

```
┌─────────────────────────────┐
│         KONTEN              │
│                             │
├─────────────────────────────┤
│ 🏠  📖  📊  ⚙️  👤         │  ← NavigationBar
│ Ber Jnl Rek Mas Pro        │
└─────────────────────────────┘
```

| Index | Tab | Ikon | Label |
|-------|-----|------|-------|
| 0 | **Beranda** | `dashboard` | Beranda |
| 1 | **Jurnal** | `book` | Jurnal |
| 2 | **Rekap** | `bar_chart` | Rekap |
| 3 | **Master** | `settings` | Master |
| 4 | **Pengaturan** | `tune` | Pengat. |
| 5 | **Profil** | `person` | Profil |

- FAB di tab **Jurnal** (ikon `add`, warna `deepPurple`).
- Indikator sync global (cloud + angka pending) di AppBar tiap halaman data.

### 2.2 Web / Lebar > 700px — NavigationRail

```
┌──────┬─────────────────────────────┐
│ 🏠   │                             │
│ 📖   │                             │
│ 📊   │        KONTEN               │
│ ⚙️   │      (maxWidth 900)         │
│ 👤   │                             │
└──────┴─────────────────────────────┘
```

- `NavigationRail` kiri, `labelType: all`, background `krem`.
- Konten `Center` + `ConstrainedBox(maxWidth: 900)`.

---

## 3. Penjelasan Tiap Page

### 3.1 Beranda (Tab 0) — **Dashboard-First Arrival**

**Tujuan:** ringkasan kas, pendapatan bulanan, aksi cepat, status sync — sekali lihat.

**Komponen (top-down):**

1. **Greeting Card** — gradient `deepPurple` → `goldEmas`, teks putih.
   - Ikon `church` putih (lingkaran `CircleAvatar` bg `Colors.white24`).
   - "Selamat datang, [Nama/Role]" (`fontWeight: bold`, size 17).
   - Tanggal Indonesia: "Senin, 15 September 2026" (`weekdayNamesId`, `monthNamesId`).
   - Log sync kecil di bawah (biru, size 11) kalau ada.

2. **KPI Cards (3 kolom, `SummaryRow`)** — `Expanded` sama lebar, `Card` radius 12.
   - **Pendapatan Bulan Ini** — hijau (`hijauPendapatan`), ikon `arrow_upward`, nominal `extrabold`.
   - **Pengeluaran Bulan Ini** — merah (`merahPengeluaran`), ikon `arrow_downward`.
   - **Saldo Kas** — emas (`goldEmas` tapi pakai `emasTeks` #8A6D1D untuk kontras), ikon `account_balance_wallet`.

3. **Quick Actions** — 2 `FilledButton.icon` full-width (wrap `Row` spacing 12).
   - **"Catat Pendapatan"** → buka Form Jurnal prefill jenis = Pendapatan.
   - **"Catat Pengeluaran"** → buka Form Jurnal prefill jenis = Pengeluaran.

4. **Mini Chart** — `fl_chart` BarChart 6 bulan terakhir (Pendapatan vs Pengeluaran). Placeholder kalau data kosong.

5. **Sync Status Card** — `Card` + `ListTile`.
   - Leading: ikon cloud besar (hijau synced / oranye `goldEmas` pending), size 32.
   - Title: "X Jurnal tersimpan (lokal)".
   - Subtitle: "Pending sync: N".
   - Trailing: `IconButton(sync)` → `_doSync()`.

6. **Pull-to-refresh** (`RefreshIndicator` di `ListView`) → `_doSync()`.

---

### 3.2 Jurnal (Tab 1) — **Frictionless Entry**

#### 3.2.1 Daftar Jurnal

- **Search bar** (`TextField` prefix `search`, suffix `clear`) — cari no bukti / deskripsi / tanggal.
- **Filter status** — `SegmentedButton<int>`: `Semua (0)` / `Pendapatan (1)` / `Pengeluaran (2)` / `Pending (3)` / `Synced (4)`.
- **ListView** card per jurnal:
  - Baris 1: Tanggal (tebal) + **No Bukti** (`Chip` emas, bold).
  - Baris 2: Deskripsi.
  - Baris 3: Badge status (`✓ Synced` hijau / `⏳ Pending` oranye) + Badge jenis (Pendapatan hijau / Pengeluaran merah) + "N detil".
  - Trailing: `IconButton(delete)` → konfirmasi soft delete.
  - Tap card → Detail Jurnal.
- **Empty state**: ikon `book` abu + "Belum ada jurnal" + tombol "Catat Transaksi" → FAB action.
- **FAB** `FloatingActionButton.extended` (ikon `add`, label "Jurnal") → buka Form Jurnal.

#### 3.2.3 Form Jurnal (1 halaman scroll, 2 Section)

**Section 1 — Info Umum**
- **Jenis Transaksi** — `SegmentedButton<String>`: `Pendapatan (+)` / `Pengeluaran (-)` (wajib, default Pendapatan).
- **Keuskupan** — `DropdownButtonFormField` (wajib).
- **Tanggal** — `ListTile` picker + `Wrap` chips: "Hari ini" / "Kemarin" (default hari ini).
- **Deskripsi** — `TextFormField` maxLines 2.
- **No Bukti** — `TextFormField`, auto-generate `JB/YYYY/MM/NNN` (editable).

**Section 2 — Detil (baris dinamis)**
- Header row: "Detil Jurnal *" + `IconButton(add_circle)`.
- Per baris `Card`:
  - Row: "Detil N" + `IconButton(delete)` kalau >1 baris.
  - **Akun** — dropdown (filter by jenis transaksi: Pendapatan → akun tipe Pendapatan, dst).
  - **Paroki** — dropdown.
  - **Nominal** — satu `TextFormField` prefix `Rp`, `keyboardType: number`, `inputFormatters: [_RibuanFormatter()]`, label kontekstual:
    - Jenis Pendapatan → "Jumlah Pendapatan" (masuk kolom kredit backend).
    - Jenis Pengeluaran → "Jumlah Pengeluaran" (masuk kolom debit backend).
- **Live Balance Check** (di bawah detil) — `Container` banner:
  - Seimbang (Total Pendapatan == Total Pengeluaran) → hijau "✓ Seimbang".
  - Tidak seimbang tapi ada nominal → oranye "Selisih Rp X (boleh disimpan draft)".
  - Nol → abu "Belum ada nominal".
- **Warning Master kosong** — kalau Akun/Paroki kosong: card oranye "Isi lewat menu Master dulu".
- **Actions** — `FilledButton.icon` full-width hijau (`hijauPendapatan`): "Simpan Lokal" → Snackbar hijau "Jurnal disimpan lokal ✓ (pending sync)".

**Fitur pendukung:**
- Auto no bukti `JB/YYYY/MM/NNN` (hitung count jurnal bulan tsb + 1).
- Duplikat jurnal (dari Detail → tombol salin).
- Auto-save draft (SharedPreferences) + konfirmasi "Buang perubahan?" saat back (`PopScope`).
- Quick chips tanggal.
- Balanced check live.

#### 3.2.4 Detail Jurnal

- Header card: status sync + tanggal + no bukti besar.
- Info label: Keuskupan, Deskripsi, **Jenis** (badge Pendapatan/Pengeluaran), ID.
- Tabel detil: `Kode - Nama Akun` | Paroki | **Pendapatan** (hijau, kanan) | **Pengeluaran** (merah, kanan).
- Footer: **Total Pendapatan / Total Pengeluaran / Cek Balance** ✓.

---

### 3.3 Rekap (Tab 2) — **Laporan Konsolidasi**

#### 3.3.1 Rekap Keuskupan

- **MonthYearPicker** (panah + dropdown bulan Indonesia).
- Dropdown Keuskupan (jika >1).
- **SummaryRow** (3 card): Pendapatan (hijau), Pengeluaran (merah), **Saldo Kas** (emas).
- **Rekap Per Paroki** — `ParokiRecapCard`: ikon `church` ungu, nama, Pendapatan/Pengeluaran, chevron → Detail Paroki.
- **Empty state**: ikon gereja abu + "Belum ada data" + tombol "Buka Master".
- **AppBar actions**: `IconButton(picture_as_pdf)` → **Export PDF** (disabled kalau kosong).
- Pull-to-refresh.

#### 3.3.2 Rekap Detail Paroki

- AppBar: nama paroki + MonthYearPicker + **Export PDF**.
- **SummaryRow**.
- **Rincian Per Akun** — Group by **Jenis** (Pendapatan / Beban):
  - Header grup: nama jenis UPPERCASE (bg `ungu` 8% opacity) + Subtotal Pendapatan (hijau) / Pengeluaran (merah).
  - Baris akun: `KODE - Nama` | Pendapatan (hijau, kanan) | Pengeluaran (merah, kanan).
- Export PDF (grouped).

---

### 3.4 Master (Tab 3) — **4 Sub-tab**

`TabBar` di `AppBar` (indikator emas tebal, label putih/semi-bold).

| Sub-tab | Ikon | Fitur |
|---------|------|-------|
| **Keuskupan** | `account_balance` | CRUD: nama, alamat. Hapus → konfirmasi soft delete. |
| **Paroki** | `church` | CRUD: nama, alamat, **Keuskupan** (dropdown, butuh Keuskupan dulu). Guard empty: "Buat Keuskupan dulu". |
| **Jenis** | `category` | CRUD: nama (Pendapatan/Beban). |
| **Akun** | `book_outlined` | CRUD: kode (unik), nama, **Jenis** (dropdown, butuh Jenis dulu). Subtitle: nama jenis (bukan ID). |

- Setiap tab: `ElevatedButton.icon` "Tambah" di atas list.
- List `ListTile` leading icon per entitas.
- Hapus → `confirmHapus()` dialog → soft delete (deleted_at + sync queue).

---

### 3.5 Pengaturan (Tab 4)

- **Sinkronisasi**: status online/pending/retry, tombol "Sinkron Sekarang".
- **Keamanan**: info JWT (access/refresh), tombol "Tes Koneksi BE".
- **Database**: profil Drift native (mobile) / WASM (web), versi skema.
- **Tentang**: logo, versi app, info keuskupan.
- (Logout nanti pas login aktif).

---

### 3.6 Profil (Tab 5) — **Placeholder (Login nanti)**

- Kosong dulu. Nanti: info user, ganti PIN, logout.

---

### 3.7 Login (Folder kosong — nanti)

- Layar login terpisah, token ke `flutter_secure_storage`.
- Offline-first: login pertama butuh internet; berikutnya pakai refresh token.
- Tema light sama.

---

## 4. Komponen Reusable (Upgrade)

| Komponen | Fungsi | Detail |
|----------|--------|--------|
| `MonthYearPicker` | Pilih periode | Panah + dropdown bulan Indonesia |
| `SummaryRow` / `SummaryCard` | 3 KPI nominal | Pendapatan hijau, Pengeluaran merah, Saldo emas |
| `ParokiRecapCard` | Ringkas per paroki | Ikon church + Pendapatan/Pengeluaran |
| `SyncIndicator` | Status sinkron | Cloud hijau/oranye + angka pending |
| `formatRupiah` | Format nominal | `Rp 1.000.000`, tabular figures |
| `JenisTransaksiSegment` | Pilih jenis | `SegmentedButton` Pendapatan (+) / Pengeluaran (-) |
| `_RibuanFormatter` | Input formatter | `1000000` → `1.000.000` saat ketik |

---

## 5. Pedoman UX

- **Offline-first**: setiap simpan langsung `is_synced=0`, notif "pending sync" jelas; auto-push saat online.
- **Feedback visual**: loading = spinner, error = ikon merah + tombol retry, sukses = Snackbar hijau.
- **Responsive**: satu codebase app+web, konten center `maxWidth 900` di layar lebar.
- **Aksesibilitas**: kontras teks vs krem memadai (emas teks pakai `emasTeks` #8A6D1D), ukuran teks 12–16, tappable minimal 48px.
- **Konsisten**: semua nominal pakai `formatRupiah`; warna Pendapatan/Pengeluaran/Saldo konsisten lintas page.

---

## 6. Roadmap Implementasi (Urut Prioritas)

| Fase | Scope | Catatan |
|------|-------|---------|
| **1** | **Tema light + font Plus Jakarta Sans** (`theme.dart`, `pubspec.yaml` + font asset `assets/fonts/PlusJakartaSans/`) | Fondasi |
| **2** | **Navigasi 6 tab** (update `main.dart` `HomeTabs` + `MasterScreen` 4 sub-tab + `tabBarTheme`) | Struktur |
| **3** | **Terminologi UI** — ganti label Debit/Kredit → Pendapatan/Pengeluaran di semua layar (label, badge, nominal, tooltip) | Semantik |
| **4** | **Dashboard** — Greeting, KPI 3 kolom, Quick Actions, Mini Chart, Sync Card | Core UX |
| **5** | **Jurnal** — Form 1 halaman (SegmentedButton jenis), daftar search/filter, detail, auto no bukti, duplikat, draft | Heavy |
| **6** | **Rekap** — MonthYearPicker, SummaryRow, grouping per jenis, Export PDF | Reporting |
| **7** | **Master** — 4 sub-tab, CRUD, guard dependensi | Data mgmt |
| **8** | **Pengaturan + Polish** — tabular figures, empty states, ornament emas | Finish |
| **9** | **Login** (aktifkan `AuthGate` + `LoginScreen`) — pas BE ready | Auth |

---

## 7. Catatan Teknis (Backlog)

- **Offline-first** tetap: semua write → SQLite lokal (`is_synced=0`) + `sync_queues`. Sync otomatis saat online.
- **Soft delete** sudah ada (`deleted_at` + sync queue) — hapus pakai konfirmasi.
- **Sync conflict** (Fase 4+): last-write-wins + badge oranye "konflik" di daftar.
- **Audit trail** (butuh auth BE): kolom `created_by` di skema + tampil di detail.
- **App lock PIN/biometrik** (opsional Settings).
- **Rekap tahunan YTD** (toggle picker bulan/tahun).

---

*Dokumen desain referensi — implementasi bertahap mulai Fase 1.*