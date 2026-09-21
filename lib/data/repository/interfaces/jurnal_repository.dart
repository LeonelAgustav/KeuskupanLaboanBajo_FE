import '../../local/app_database.dart';

abstract class JurnalRepository {
  Future<List<Jurnal>> getAll();
  Future<Jurnal?> getById(String id);
  Future<String> create({
    required int keuskupanId,
    required DateTime tanggal,
    String? deskripsi,
    String? noBukti,
    List<DetilJurnalsCompanion> detils = const [],
  });
  Future<void> update(String id, {int? keuskupanId, DateTime? tanggal, String? deskripsi, String? noBukti});
  Future<void> delete(String id); // soft delete
  Future<int> pendingCount();
  Future<List<DetilJurnal>> getDetils(String jurnalId);
}
