import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../local/app_database.dart';
import '../interfaces/paroki_repository.dart';

class ParokiRepositoryImpl implements ParokiRepository {
  final AppDatabase db;
  final _uuid = const Uuid();
  ParokiRepositoryImpl(this.db);
  @override
  Future<List<Paroki>> getAll() => (db.select(db.parokis)..where((t) => t.deletedAt.isNull())).get();
  @override
  Future<Paroki?> getById(String id) => (db.select(db.parokis)..where((t) => t.id.equals(id))).getSingleOrNull();
  @override
  Future<String> create({required String nama, required String alamat, required String keuskupanId}) async {
    final id = _uuid.v4();
    await db.into(db.parokis).insert(ParokisCompanion.insert(id: id, nama: nama, alamat: alamat, keuskupanId: keuskupanId));
    await db.enqueue('parokis', id, 'insert', jsonEncode({"id": id, "nama": nama, "alamat": alamat, "keuskupan_id": keuskupanId}));
    return id;
  }
  @override
  Future<void> update(String id, {String? nama, String? alamat, String? keuskupanId}) async {
    await (db.update(db.parokis)..where((t) => t.id.equals(id))).write(ParokisCompanion(
      nama: nama != null ? Value(nama) : const Value.absent(),
      alamat: alamat != null ? Value(alamat) : const Value.absent(),
      keuskupanId: keuskupanId != null ? Value(keuskupanId) : const Value.absent(),
      isSynced: const Value(false),
    ));
    await db.enqueue('parokis', id, 'update', '{"id":"$id"}');
  }
  @override
  Future<void> delete(String id) async {
    await (db.update(db.parokis)..where((t) => t.id.equals(id))).write(ParokisCompanion(deletedAt: Value(DateTime.now()), isSynced: const Value(false)));
    await db.enqueue('parokis', id, 'delete', '{"id":"$id"}');
  }
}

class KeuskupanRepositoryImpl implements KeuskupanRepository {
  final AppDatabase db;
  final _uuid = const Uuid();
  KeuskupanRepositoryImpl(this.db);
  @override
  Future<List<Keuskupan>> getAll() => (db.select(db.keuskupans)..where((t) => t.deletedAt.isNull())).get();
  @override
  Future<Keuskupan?> getById(String id) => (db.select(db.keuskupans)..where((t) => t.id.equals(id))).getSingleOrNull();
  @override
  Future<String> create({required String nama, required String alamat}) async {
    final id = _uuid.v4();
    await db.into(db.keuskupans).insert(KeuskupansCompanion.insert(id: id, nama: nama, alamat: alamat));
    await db.enqueue('keuskupans', id, 'insert', jsonEncode({"id": id, "nama": nama, "alamat": alamat}));
    return id;
  }
  @override
  Future<void> update(String id, {String? nama, String? alamat}) async {
    await (db.update(db.keuskupans)..where((t) => t.id.equals(id))).write(KeuskupansCompanion(
      nama: nama != null ? Value(nama) : const Value.absent(),
      alamat: alamat != null ? Value(alamat) : const Value.absent(),
      isSynced: const Value(false),
    ));
    await db.enqueue('keuskupans', id, 'update', '{"id":"$id"}');
  }
  @override
  Future<void> delete(String id) async {
    await (db.update(db.keuskupans)..where((t) => t.id.equals(id))).write(KeuskupansCompanion(deletedAt: Value(DateTime.now()), isSynced: const Value(false)));
    await db.enqueue('keuskupans', id, 'delete', '{"id":"$id"}');
  }
}

class AkunRepositoryImpl implements AkunRepository {
  final AppDatabase db;
  final _uuid = const Uuid();
  AkunRepositoryImpl(this.db);
  @override
  Future<List<Akun>> getAll() => (db.select(db.akuns)..where((t) => t.deletedAt.isNull())).get();
  @override
  Future<Akun?> getById(String id) => (db.select(db.akuns)..where((t) => t.id.equals(id))).getSingleOrNull();
  @override
  Future<String> create({required String kode, required String nama, required String jenisId}) async {
    final id = _uuid.v4();
    await db.into(db.akuns).insert(AkunsCompanion.insert(id: id, kode: kode, nama: nama, jenisId: jenisId));
    await db.enqueue('akuns', id, 'insert', jsonEncode({"id": id, "kode": kode, "nama": nama, "jenis_id": jenisId}));
    return id;
  }
  @override
  Future<void> update(String id, {String? kode, String? nama, String? jenisId}) async {
    await (db.update(db.akuns)..where((t) => t.id.equals(id))).write(AkunsCompanion(
      kode: kode != null ? Value(kode) : const Value.absent(),
      nama: nama != null ? Value(nama) : const Value.absent(),
      jenisId: jenisId != null ? Value(jenisId) : const Value.absent(),
      isSynced: const Value(false),
    ));
    await db.enqueue('akuns', id, 'update', '{"id":"$id"}');
  }
  @override
  Future<void> delete(String id) async {
    await (db.update(db.akuns)..where((t) => t.id.equals(id))).write(AkunsCompanion(deletedAt: Value(DateTime.now()), isSynced: const Value(false)));
    await db.enqueue('akuns', id, 'delete', '{"id":"$id"}');
  }
}

class JenisRepositoryImpl implements JenisRepository {
  final AppDatabase db;
  final _uuid = const Uuid();
  JenisRepositoryImpl(this.db);
  @override
  Future<List<Jeni>> getAll() => (db.select(db.jenis)..where((t) => t.deletedAt.isNull())).get();
  @override
  Future<Jeni?> getById(String id) => (db.select(db.jenis)..where((t) => t.id.equals(id))).getSingleOrNull();
  @override
  Future<String> create({required String nama}) async {
    final id = _uuid.v4();
    await db.into(db.jenis).insert(JenisCompanion.insert(id: id, nama: nama));
    await db.enqueue('jenis', id, 'insert', jsonEncode({"id": id, "nama": nama}));
    return id;
  }
  @override
  Future<void> update(String id, {String? nama}) async {
    await (db.update(db.jenis)..where((t) => t.id.equals(id))).write(JenisCompanion(nama: nama != null ? Value(nama) : const Value.absent(), isSynced: const Value(false)));
    await db.enqueue('jenis', id, 'update', '{"id":"$id"}');
  }
  @override
  Future<void> delete(String id) async {
    await (db.update(db.jenis)..where((t) => t.id.equals(id))).write(JenisCompanion(deletedAt: Value(DateTime.now()), isSynced: const Value(false)));
    await db.enqueue('jenis', id, 'delete', '{"id":"$id"}');
  }
}
