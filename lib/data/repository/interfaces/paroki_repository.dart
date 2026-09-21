import '../../local/app_database.dart';

abstract class ParokiRepository {
  Future<List<Paroki>> getAll();
  Future<Paroki?> getById(int id);
  Future<int> create({required String nama, required String alamat, required int keuskupanId});
  Future<void> update(int id, {String? nama, String? alamat, int? keuskupanId});
  Future<void> delete(int id);
}

abstract class KeuskupanRepository {
  Future<List<Keuskupan>> getAll();
  Future<Keuskupan?> getById(int id);
  Future<int> create({required String nama, required String alamat});
  Future<void> update(int id, {String? nama, String? alamat});
  Future<void> delete(int id);
}

abstract class AkunRepository {
  Future<List<Akun>> getAll();
  Future<Akun?> getById(int id);
  Future<int> create({required String kode, required String nama, required int jenisId});
  Future<void> update(int id, {String? kode, String? nama, int? jenisId});
  Future<void> delete(int id);
}

abstract class JenisRepository {
  Future<List<Jeni>> getAll();
  Future<Jeni?> getById(int id);
  Future<int> create({required String nama});
  Future<void> update(int id, {String? nama});
  Future<void> delete(int id);
}
