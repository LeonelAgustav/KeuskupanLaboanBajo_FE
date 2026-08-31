import '../../local/app_database.dart';

abstract class ParokiRepository {
  Future<List<Paroki>> getAll();
  Future<Paroki?> getById(String id);
  Future<String> create({required String nama, required String alamat, required String keuskupanId});
  Future<void> update(String id, {String? nama, String? alamat, String? keuskupanId});
  Future<void> delete(String id);
}

abstract class KeuskupanRepository {
  Future<List<Keuskupan>> getAll();
  Future<Keuskupan?> getById(String id);
  Future<String> create({required String nama, required String alamat});
  Future<void> update(String id, {String? nama, String? alamat});
  Future<void> delete(String id);
}

abstract class AkunRepository {
  Future<List<Akun>> getAll();
  Future<Akun?> getById(String id);
  Future<String> create({required String kode, required String nama, required String jenisId});
  Future<void> update(String id, {String? kode, String? nama, String? jenisId});
  Future<void> delete(String id);
}

abstract class JenisRepository {
  Future<List<Jeni>> getAll();
  Future<Jeni?> getById(String id);
  Future<String> create({required String nama});
  Future<void> update(String id, {String? nama});
  Future<void> delete(String id);
}
