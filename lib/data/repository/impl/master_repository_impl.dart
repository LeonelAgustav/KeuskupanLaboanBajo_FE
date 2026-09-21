import 'dart:convert';
import 'package:drift/drift.dart';
import '../../local/app_database.dart';
import '../interfaces/paroki_repository.dart';
import '../interfaces/role_repository.dart';

class ParokiRepositoryImpl implements ParokiRepository {
  final AppDatabase db;
  ParokiRepositoryImpl(this.db);
  @override
  Future<List<Paroki>> getAll() => (db.select(db.parokis)..where((t) => t.deletedAt.isNull())).get();
  @override
  Future<Paroki?> getById(int id) => (db.select(db.parokis)..where((t) => t.id.equals(id))).getSingleOrNull();
  @override
  Future<int> create({required String nama, required String alamat, required int keuskupanId}) async {
    final id = (await db.into(db.parokis).insertReturning(ParokisCompanion.insert(nama: nama, alamat: alamat, keuskupanId: keuskupanId))).id;
    await db.enqueue('parokis', id.toString(), 'insert', jsonEncode({"id": id, "nama": nama, "alamat": alamat, "keuskupan_id": keuskupanId}));
    return id;
  }
  @override
  Future<void> update(int id, {String? nama, String? alamat, int? keuskupanId}) async {
    await (db.update(db.parokis)..where((t) => t.id.equals(id))).write(ParokisCompanion(
      nama: nama != null ? Value(nama) : const Value.absent(),
      alamat: alamat != null ? Value(alamat) : const Value.absent(),
      keuskupanId: keuskupanId != null ? Value(keuskupanId) : const Value.absent(),
      isSynced: const Value(false),
    ));
    await db.enqueue('parokis', id.toString(), 'update', '{"id":"$id"}');
  }
  @override
  Future<void> delete(int id) async {
    await (db.update(db.parokis)..where((t) => t.id.equals(id))).write(ParokisCompanion(deletedAt: Value(DateTime.now()), isSynced: const Value(false)));
    await db.enqueue('parokis', id.toString(), 'delete', '{"id":"$id"}');
  }
}

class KeuskupanRepositoryImpl implements KeuskupanRepository {
  final AppDatabase db;
  KeuskupanRepositoryImpl(this.db);
  @override
  Future<List<Keuskupan>> getAll() => (db.select(db.keuskupans)..where((t) => t.deletedAt.isNull())).get();
  @override
  Future<Keuskupan?> getById(int id) => (db.select(db.keuskupans)..where((t) => t.id.equals(id))).getSingleOrNull();
  @override
  Future<int> create({required String nama, required String alamat}) async {
    final id = (await db.into(db.keuskupans).insertReturning(KeuskupansCompanion.insert(nama: nama, alamat: alamat))).id;
    await db.enqueue('keuskupans', id.toString(), 'insert', jsonEncode({"id": id, "nama": nama, "alamat": alamat}));
    return id;
  }
  @override
  Future<void> update(int id, {String? nama, String? alamat}) async {
    await (db.update(db.keuskupans)..where((t) => t.id.equals(id))).write(KeuskupansCompanion(
      nama: nama != null ? Value(nama) : const Value.absent(),
      alamat: alamat != null ? Value(alamat) : const Value.absent(),
      isSynced: const Value(false),
    ));
    await db.enqueue('keuskupans', id.toString(), 'update', '{"id":"$id"}');
  }
  @override
  Future<void> delete(int id) async {
    await (db.update(db.keuskupans)..where((t) => t.id.equals(id))).write(KeuskupansCompanion(deletedAt: Value(DateTime.now()), isSynced: const Value(false)));
    await db.enqueue('keuskupans', id.toString(), 'delete', '{"id":"$id"}');
  }
}

class AkunRepositoryImpl implements AkunRepository {
  final AppDatabase db;
  AkunRepositoryImpl(this.db);
  @override
  Future<List<Akun>> getAll() => (db.select(db.akuns)..where((t) => t.deletedAt.isNull())).get();
  @override
  Future<Akun?> getById(int id) => (db.select(db.akuns)..where((t) => t.id.equals(id))).getSingleOrNull();
  @override
  Future<int> create({required String kode, required String nama, required int jenisId}) async {
    final id = (await db.into(db.akuns).insertReturning(AkunsCompanion.insert(kode: kode, nama: nama, jenisId: jenisId))).id;
    await db.enqueue('akuns', id.toString(), 'insert', jsonEncode({"id": id, "kode": kode, "nama": nama, "jenis_id": jenisId}));
    return id;
  }
  @override
  Future<void> update(int id, {String? kode, String? nama, int? jenisId}) async {
    await (db.update(db.akuns)..where((t) => t.id.equals(id))).write(AkunsCompanion(
      kode: kode != null ? Value(kode) : const Value.absent(),
      nama: nama != null ? Value(nama) : const Value.absent(),
      jenisId: jenisId != null ? Value(jenisId) : const Value.absent(),
      isSynced: const Value(false),
    ));
    await db.enqueue('akuns', id.toString(), 'update', '{"id":"$id"}');
  }
  @override
  Future<void> delete(int id) async {
    await (db.update(db.akuns)..where((t) => t.id.equals(id))).write(AkunsCompanion(deletedAt: Value(DateTime.now()), isSynced: const Value(false)));
    await db.enqueue('akuns', id.toString(), 'delete', '{"id":"$id"}');
  }
}

class JenisRepositoryImpl implements JenisRepository {
  final AppDatabase db;
  JenisRepositoryImpl(this.db);
  @override
  Future<List<Jeni>> getAll() => (db.select(db.jenis)..where((t) => t.deletedAt.isNull())).get();
  @override
  Future<Jeni?> getById(int id) => (db.select(db.jenis)..where((t) => t.id.equals(id))).getSingleOrNull();
  @override
  Future<int> create({required String nama}) async {
    final id = (await db.into(db.jenis).insertReturning(JenisCompanion.insert(nama: nama))).id;
    await db.enqueue('jenis', id.toString(), 'insert', jsonEncode({"id": id, "nama": nama}));
    return id;
  }
  @override
  Future<void> update(int id, {String? nama}) async {
    await (db.update(db.jenis)..where((t) => t.id.equals(id))).write(JenisCompanion(nama: nama != null ? Value(nama) : const Value.absent(), isSynced: const Value(false)));
    await db.enqueue('jenis', id.toString(), 'update', '{"id":"$id"}');
  }
  @override
  Future<void> delete(int id) async {
    await (db.update(db.jenis)..where((t) => t.id.equals(id))).write(JenisCompanion(deletedAt: Value(DateTime.now()), isSynced: const Value(false)));
    await db.enqueue('jenis', id.toString(), 'delete', '{"id":"$id"}');
  }
}

class RoleRepositoryImpl implements RoleRepository {
  final AppDatabase db;
  RoleRepositoryImpl(this.db);
  @override
  Future<List<Role>> getAll() => (db.select(db.roles)..where((t) => t.deletedAt.isNull())).get();
  @override
  Future<Role?> getById(int id) => (db.select(db.roles)..where((t) => t.id.equals(id))).getSingleOrNull();
  @override
  Future<int> create({required String nama}) async {
    final id = (await db.into(db.roles).insertReturning(RolesCompanion.insert(nama: nama))).id;
    await db.enqueue('roles', id.toString(), 'insert', jsonEncode({"id": id, "nama": nama}));
    return id;
  }
  @override
  Future<void> update(int id, {String? nama}) async {
    await (db.update(db.roles)..where((t) => t.id.equals(id))).write(RolesCompanion(
      nama: nama != null ? Value(nama) : const Value.absent(),
      isSynced: const Value(false),
    ));
    await db.enqueue('roles', id.toString(), 'update', '{"id":"$id"}');
  }
  @override
  Future<void> delete(int id) async {
    await (db.update(db.roles)..where((t) => t.id.equals(id))).write(RolesCompanion(deletedAt: Value(DateTime.now()), isSynced: const Value(false)));
    await db.enqueue('roles', id.toString(), 'delete', '{"id":"$id"}');
  }
}
