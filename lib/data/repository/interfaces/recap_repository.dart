import '../../models/recap_models.dart';

abstract class RecapRepository {
  /// Total debit & kredit seluruh keuskupan dalam periode tertentu.
  /// [parokiId] jika > 0, filter hanya ke paroki tertentu (untuk MEMBER).
  Future<RecapKeuskupanResult> getKeuskupanRecap(
    int keuskupanId,
    DateTime startDate,
    DateTime endDate, {
    int? parokiId,
  });

  /// Ringkasan per paroki: list paroki beserta total debit & kredit.
  /// [parokiId] jika > 0, hanya return 1 paroki tsb (untuk MEMBER).
  /// Paroki tanpa transaksi tetap muncul dengan nilai 0.
  Future<List<RecapParokiSummary>> getParokiRecapList(
    int keuskupanId,
    DateTime startDate,
    DateTime endDate, {
    int? parokiId,
  });

  /// Rincian per akun dalam satu paroki, di-group berdasarkan jenis akun.
  Future<List<RecapAkunDetail>> getParokiRecapDetail(
    int parokiId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Rekap bulanan untuk satu tahun (12 bulan) - untuk mode Tahunan (YTD).
  /// [parokiId] jika > 0, filter hanya ke paroki tertentu.
  Future<List<MonthlyRecap>> getMonthlyRecap(
    int keuskupanId,
    int year, {
    int? parokiId,
  });

  /// Rekap mingguan untuk satu bulan (W1-5).
  /// [parokiId] jika > 0, filter hanya ke paroki tertentu.
  Future<List<WeeklyRecap>> getWeeklyRecap(
    int keuskupanId,
    int year,
    int month, {
    int? parokiId,
  });

  /// Neraca Saldo per akun (saldo awal, mutasi, saldo akhir; split per jenis pembatasan).
  /// Basis untuk Neraca, Laporan Aktivitas, dan Aset Neto.
  Future<List<NeracaSaldoBaris>> getNeracaSaldo(
    int keuskupanId,
    DateTime startDate,
    DateTime endDate, {
    int? parokiId,
  });

  /// Buku Besar: saldo awal, mutasi, saldo akhir untuk satu akun dalam range tanggal.
  /// Running balance mengikuti sisi normal akun (kode awalan 1/5: debit; 2/3/4: kredit).
  /// [parokiId] jika > 0, filter hanya ke paroki tertentu.
  Future<BukuBesarResult> getBukuBesar(
    int keuskupanId,
    int akunId,
    DateTime startDate,
    DateTime endDate, {
    int? parokiId,
  });
}
