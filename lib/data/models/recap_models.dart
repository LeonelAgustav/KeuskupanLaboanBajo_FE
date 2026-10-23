class RecapKeuskupanResult {
  final double totalDebit;
  final double totalKredit;
  double get saldo => totalKredit - totalDebit; // Saldo = Pendapatan (kredit) - Pengeluaran (debit)
  double get totalPendapatan => totalKredit; // Pendapatan = Kredit
  double get totalPengeluaran => totalDebit; // Pengeluaran = Debit

  const RecapKeuskupanResult({
    required this.totalDebit,
    required this.totalKredit,
  });
}

class RecapParokiSummary {
  final int parokiId;
  final String parokiNama;
  final double totalDebit;
  final double totalKredit;
  double get saldo => totalKredit - totalDebit; // Saldo = Pendapatan (kredit) - Pengeluaran (debit)
  double get totalPendapatan => totalKredit;
  double get totalPengeluaran => totalDebit;

  const RecapParokiSummary({
    required this.parokiId,
    required this.parokiNama,
    required this.totalDebit,
    required this.totalKredit,
  });
}

class RecapAkunDetail {
  final int akunId;
  final String akunKode;
  final String akunNama;
  final int jenisId;
  final String jenisNama;
  final double totalDebit;
  final double totalKredit;
  double get saldo => totalKredit - totalDebit; // Saldo = Pendapatan (kredit) - Pengeluaran (debit)
  double get totalPendapatan => totalKredit;
  double get totalPengeluaran => totalDebit;

  const RecapAkunDetail({
    required this.akunId,
    required this.akunKode,
    required this.akunNama,
    required this.jenisId,
    required this.jenisNama,
    required this.totalDebit,
    required this.totalKredit,
  });
}

/// Rekap bulanan untuk satu bulan dalam tahunan (YTD).
class MonthlyRecap {
  final int bulan; // 1-12
  final double totalDebit;
  final double totalKredit;
  
  double get saldo => totalKredit - totalDebit; // Saldo = Pendapatan (kredit) - Pengeluaran (debit)
  double get totalPendapatan => totalKredit;
  double get totalPengeluaran => totalDebit;
  
  String get namaBulan {
    const names = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return names[bulan];
  }

  const MonthlyRecap({
    required this.bulan,
    required this.totalDebit,
    required this.totalKredit,
  });
}

/// Rekap mingguan untuk satu bulan (W1-5).
class WeeklyRecap {
  final int minggu; // 1-5
  final double totalDebit;
  final double totalKredit;

  double get saldo => totalKredit - totalDebit; // Saldo = Pendapatan (kredit) - Pengeluaran (debit)
  double get totalPendapatan => totalKredit;
  double get totalPengeluaran => totalDebit;

  String get namaMinggu => 'Minggu $minggu';
  String get rentang {
    const ranges = ['', '1-7', '8-14', '15-21', '22-28', '29-31'];
    return ranges[minggu];
  }

  const WeeklyRecap({
    required this.minggu,
    required this.totalDebit,
    required this.totalKredit,
  });
}

/// Satu baris Neraca Saldo = satu akun. Semua angka sudah bertanda sisi normal
/// akun (prefix kode 1/5 = debit normal, 2/3/4 = kredit normal), jadi 4 laporan
/// ISAK 35 (Neraca Saldo, Neraca, Lap Aktivitas, Aset Neto) cukup turunan dari list ini.
class NeracaSaldoBaris {
  final String kode;
  final String nama;
  final bool debitNormal;

  /// Akumulasi sebelum tanggal awal (= saldo awal / "periode lalu" di Excel).
  final double awalTanpa;
  final double awalDengan;

  /// Mutasi dalam periode laporan.
  final double mutTanpa;
  final double mutDengan;

  const NeracaSaldoBaris({
    required this.kode,
    required this.nama,
    required this.debitNormal,
    this.awalTanpa = 0,
    this.awalDengan = 0,
    this.mutTanpa = 0,
    this.mutDengan = 0,
  });

  double get saldoAwal => awalTanpa + awalDengan;
  double get perubahan => mutTanpa + mutDengan;
  double get saldoAkhir => saldoAwal + perubahan;

  /// 1 Aset, 2 Liabilitas, 3 Aset Neto, 4 Penerimaan, 5 Beban.
  String get grup => kode.isEmpty ? '' : kode[0];

  /// Akun laba-rugi (Excel: JENIS.posisi = 'LR').
  bool get isLabaRugi => grup == '4' || grup == '5';
}

/// Satu baris tampilan laporan (dipakai layar & PDF). [nums] boleh null = sel kosong.
class LaporanRow {
  final String label;
  final List<double?> nums;
  final bool isHeader; // kelompok (mis. PENDAPATAN)
  final bool isTotal; // baris total/subtotal
  const LaporanRow(
    this.label, {
    this.nums = const [],
    this.isHeader = false,
    this.isTotal = false,
  });
}

/// Satu laporan siap render: judul kolom + baris.
class LaporanTabel {
  final List<String> headers;
  final List<LaporanRow> rows;
  const LaporanTabel(this.headers, this.rows);
}

/// Satu baris mutasi dalam Buku Besar.
class BukuBesarMutasi {
  final DateTime tanggal;
  final String? noBukti;
  final String? uraian;
  final double debit;
  final double kredit;
  final double saldo; // running balance

  const BukuBesarMutasi({
    required this.tanggal,
    this.noBukti,
    this.uraian,
    required this.debit,
    required this.kredit,
    required this.saldo,
  });
}

/// Hasil query Buku Besar untuk satu akun dalam satu periode.
class BukuBesarResult {
  final int akunId;
  final String akunKode;
  final String akunNama;
  final double saldoAwal;
  final List<BukuBesarMutasi> mutasi;
  final double saldoAkhir;

  const BukuBesarResult({
    required this.akunId,
    required this.akunKode,
    required this.akunNama,
    required this.saldoAwal,
    required this.mutasi,
    required this.saldoAkhir,
  });
}
