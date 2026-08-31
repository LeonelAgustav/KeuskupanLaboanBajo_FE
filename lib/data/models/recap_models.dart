/// Model classes for recap/report query results.
/// These are plain Dart classes (not Drift tables) used to hold aggregated data.

class RecapKeuskupanResult {
  final double totalDebit;
  final double totalKredit;
  double get saldo => totalDebit - totalKredit;

  const RecapKeuskupanResult({
    required this.totalDebit,
    required this.totalKredit,
  });
}

class RecapParokiSummary {
  final String parokiId;
  final String parokiNama;
  final double totalDebit;
  final double totalKredit;
  double get saldo => totalDebit - totalKredit;

  const RecapParokiSummary({
    required this.parokiId,
    required this.parokiNama,
    required this.totalDebit,
    required this.totalKredit,
  });
}

class RecapAkunDetail {
  final String akunId;
  final String akunKode;
  final String akunNama;
  final String jenisId;
  final String jenisNama;
  final double totalDebit;
  final double totalKredit;
  double get saldo => totalDebit - totalKredit;

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
