import '../../local/app_database.dart';

abstract class JurnalRepository {
  Future<List<Jurnal>> getAll();
  Future<Jurnal?> getById(String id);
  Future<String> create({
    required String keuskupanId,
    required DateTime tanggal,
    String? deskripsi,
    String? noBukti,
    List<DetilJurnalsCompanion> detils = const [],
  });
  Future<void> update(String id, {String? keuskupanId, DateTime? tanggal, String? deskripsi, String? noBukti});
  Future<void> delete(String id); // soft delete
  Future<int> pendingCount();
  Future<List<DetilJurnal>> getDetils(String jurnalId);
}
