import '../../models/recap_models.dart';

abstract class RecapRepository {
  /// Total debit & kredit seluruh keuskupan dalam periode tertentu.
  Future<RecapKeuskupanResult> getKeuskupanRecap(
    String keuskupanId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Ringkasan per paroki: list semua paroki beserta total debit & kredit.
  /// Paroki tanpa transaksi tetap muncul dengan nilai 0.
  Future<List<RecapParokiSummary>> getParokiRecapList(
    String keuskupanId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Rincian per akun dalam satu paroki, di-group berdasarkan jenis akun.
  Future<List<RecapAkunDetail>> getParokiRecapDetail(
    String parokiId,
    DateTime startDate,
    DateTime endDate,
  );
}
