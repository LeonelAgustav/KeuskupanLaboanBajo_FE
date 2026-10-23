import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../local/app_database.dart';
import '../../../core/utils/sanitizer.dart';
import '../interfaces/paroki_repository.dart';
import '../interfaces/role_repository.dart';

class ParokiRepositoryImpl implements ParokiRepository {
  final AppDatabase db;
  ParokiRepositoryImpl(this.db);
  @override
  Future<List<Paroki>> getAll() => (db.select(db.parokis)..where((t) => t.deletedAt.isNull())).get();
  @override
  Future<Paroki?> getById(String uuid) => (db.select(db.parokis)..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  @override
  Future<Paroki?> create({required String nama, required String alamat, required int keuskupanId}) async {
    final cleanNama = InputSanitizer.sanitizeText(nama) ?? nama;
    final cleanAlamat = InputSanitizer.sanitizeText(alamat) ?? alamat;
    final uuid = const Uuid().v4();
    final localId = DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;
    final inserted = await (db.into(db.parokis).insertReturning(ParokisCompanion.insert(
      uuid: Value(uuid),
      id: Value(localId),
      nama: cleanNama,
      alamat: cleanAlamat,
      keuskupanId: keuskupanId,
    )));
    await db.enqueue('parokis', uuid, 'insert', jsonEncode({"id": localId, "uuid": uuid, "nama": cleanNama, "alamat": cleanAlamat, "keuskupan_id": keuskupanId}));
    return inserted;
  }
  @override
  Future<void> update(String uuid, {String? nama, String? alamat, int? keuskupanId}) async {
    final cleanNama = nama != null ? InputSanitizer.sanitizeText(nama) : null;
    final cleanAlamat = alamat != null ? InputSanitizer.sanitizeText(alamat) : null;
    await (db.update(db.parokis)..where((t) => t.uuid.equals(uuid))).write(ParokisCompanion(
      nama: cleanNama != null ? Value(cleanNama) : const Value.absent(),
      alamat: cleanAlamat != null ? Value(cleanAlamat) : const Value.absent(),
      keuskupanId: keuskupanId != null ? Value(keuskupanId) : const Value.absent(),
      isSynced: const Value(false),
    ));
    await db.enqueue('parokis', uuid, 'update', '{"uuid":"$uuid"}');
  }
  @override
  Future<void> delete(String uuid) async {
    await (db.update(db.parokis)..where((t) => t.uuid.equals(uuid))).write(ParokisCompanion(deletedAt: Value(DateTime.now()), isSynced: const Value(false)));
    await db.enqueue('parokis', uuid, 'delete', '{"uuid":"$uuid"}');
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
    final cleanNama = InputSanitizer.sanitizeText(nama) ?? nama;
    final cleanAlamat = InputSanitizer.sanitizeText(alamat) ?? alamat;
    final uuid = const Uuid().v4();
    final id = (await db.into(db.keuskupans).insertReturning(KeuskupansCompanion.insert(uuid: Value(uuid), nama: cleanNama, alamat: cleanAlamat))).id;
    await db.enqueue('keuskupans', uuid, 'insert', jsonEncode({"id": id, "uuid": uuid, "nama": cleanNama, "alamat": cleanAlamat}));
    return id;
  }
  @override
  Future<void> update(int id, {String? nama, String? alamat}) async {
    final cleanNama = nama != null ? InputSanitizer.sanitizeText(nama) : null;
    final cleanAlamat = alamat != null ? InputSanitizer.sanitizeText(alamat) : null;
    await (db.update(db.keuskupans)..where((t) => t.id.equals(id))).write(KeuskupansCompanion(
      nama: cleanNama != null ? Value(cleanNama) : const Value.absent(),
      alamat: cleanAlamat != null ? Value(cleanAlamat) : const Value.absent(),
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
    final cleanKode = InputSanitizer.sanitizeText(kode) ?? kode;
    final cleanNama = InputSanitizer.sanitizeText(nama) ?? nama;
    final uuid = const Uuid().v4();
    final id = (await db.into(db.akuns).insertReturning(AkunsCompanion.insert(uuid: Value(uuid), kode: cleanKode, nama: cleanNama, jenisId: jenisId))).id;
    await db.enqueue('akuns', uuid, 'insert', jsonEncode({"id": id, "uuid": uuid, "kode": cleanKode, "nama": cleanNama, "jenis_id": jenisId}));
    return id;
  }
  @override
  Future<void> update(int id, {String? kode, String? nama, int? jenisId}) async {
    final cleanKode = kode != null ? InputSanitizer.sanitizeText(kode) : null;
    final cleanNama = nama != null ? InputSanitizer.sanitizeText(nama) : null;
    await (db.update(db.akuns)..where((t) => t.id.equals(id))).write(AkunsCompanion(
      kode: cleanKode != null ? Value(cleanKode) : const Value.absent(),
      nama: cleanNama != null ? Value(cleanNama) : const Value.absent(),
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
    final cleanNama = InputSanitizer.sanitizeText(nama) ?? nama;
    final uuid = const Uuid().v4();
    final id = (await db.into(db.jenis).insertReturning(JenisCompanion.insert(uuid: Value(uuid), nama: cleanNama))).id;
    await db.enqueue('jenis', uuid, 'insert', jsonEncode({"id": id, "uuid": uuid, "nama": cleanNama}));
    return id;
  }
  @override
  Future<void> update(int id, {String? nama}) async {
    final cleanNama = nama != null ? InputSanitizer.sanitizeText(nama) : null;
    await (db.update(db.jenis)..where((t) => t.id.equals(id))).write(JenisCompanion(nama: cleanNama != null ? Value(cleanNama) : const Value.absent(), isSynced: const Value(false)));
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
    final cleanNama = InputSanitizer.sanitizeText(nama) ?? nama;
    final id = (await db.into(db.roles).insertReturning(RolesCompanion.insert(nama: cleanNama))).id;
    await db.enqueue('roles', id.toString(), 'insert', jsonEncode({"id": id, "nama": cleanNama}));
    return id;
  }
  @override
  Future<void> update(int id, {String? nama}) async {
    final cleanNama = nama != null ? InputSanitizer.sanitizeText(nama) : null;
    await (db.update(db.roles)..where((t) => t.id.equals(id))).write(RolesCompanion(
      nama: cleanNama != null ? Value(cleanNama) : const Value.absent(),
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
