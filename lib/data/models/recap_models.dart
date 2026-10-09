/// Model classes for recap/report query results.
/// These are plain Dart classes (not Drift tables) used to hold aggregated data.
/// Backend uses debit/kredit; UI uses Pendapatan/Pengeluaran terminology.
/// Mapping: Pendapatan = Kredit (income goes to credit), Pengeluaran = Debit (expense goes to debit).

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
