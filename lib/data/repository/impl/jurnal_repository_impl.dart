import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../local/app_database.dart';
import '../../../core/auth/token_storage.dart';
import '../../../core/utils/sanitizer.dart';
import '../interfaces/jurnal_repository.dart';

class JurnalRepositoryImpl implements JurnalRepository {
  final AppDatabase db;
  final TokenStorageI tokenStorage;
  final _uuid = const Uuid();
  JurnalRepositoryImpl(this.db, {required this.tokenStorage});

  Future<int?> _getParokiId() async => await tokenStorage.getCurrentParokiId();

  Future<int?> _getUserId() async => await tokenStorage.getCurrentUserId();

  @override
  Future<List<Jurnal>> getAll() async {
    final parokiId = await _getParokiId();
    // MEMBER hanya bisa lihat jurnal milik paroki mereka
    if (parokiId != null && parokiId > 0) {
      final jurnalIds = (await (db.select(db.detilJurnals)
        ..where((t) => t.parokiId.equals(parokiId) & t.deletedAt.isNull()))
        .get()).map((d) => d.jurnalId).toSet().toList();
      if (jurnalIds.isEmpty) return [];
      return (db.select(db.jurnals)
        ..where((t) => t.deletedAt.isNull() & t.id.isIn(jurnalIds))
        ..orderBy([(t) => OrderingTerm.desc(t.tanggal)])).get();
    }
    return (db.select(db.jurnals)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.tanggal)])).get();
  }

  @override
  Future<Jurnal?> getById(String id) => (db.select(db.jurnals)..where((t) => t.id.equals(id))).getSingleOrNull();

  @override
  Future<List<DetilJurnal>> getDetils(String jurnalId) =>
      (db.select(db.detilJurnals)..where((t) => t.jurnalId.equals(jurnalId) & t.deletedAt.isNull())).get();

  @override
  Future<String> create({
    required int keuskupanId,
    required DateTime tanggal,
    String? deskripsi,
    String? noBukti,
    List<DetilJurnalsCompanion> detils = const [],
  }) async {
    final userId = await _getUserId();
    final cleanDeskripsi = InputSanitizer.sanitizeText(deskripsi);
    final cleanNoBukti = InputSanitizer.sanitizeText(noBukti);
    final id = _uuid.v4();
    await db.transaction(() async {
      await db.into(db.jurnals).insert(JurnalsCompanion.insert(
        id: id,
        keuskupanId: keuskupanId,
        tanggal: tanggal,
        deskripsi: Value(cleanDeskripsi),
        noBukti: Value(cleanNoBukti),
        createdBy: Value(userId),
      ));
      await db.enqueue('jurnals', id, 'insert', jsonEncode({"id": id, "keuskupan_id": keuskupanId, "tanggal": tanggal.toIso8601String(), "deskripsi": cleanDeskripsi, "no_bukti": cleanNoBukti, "created_by": userId}));
      for (final d in detils) {
        final comp = d.copyWith(jurnalId: Value(id));
        final detilId = (await db.into(db.detilJurnals).insertReturning(comp)).id;
        final detilPayload = jsonEncode({
          "id": detilId,
          "jurnal_id": id,
          "akun_id": comp.akunId.value,
          "paroki_id": comp.parokiId.value,
          "debit": comp.debit.present ? comp.debit.value : 0,
          "kredit": comp.kredit.present ? comp.kredit.value : 0,
          "keterangan": comp.keterangan.present ? comp.keterangan.value : null,
          "created_by": userId,
        });
        await db.enqueue('detil_jurnals', detilId.toString(), 'insert', detilPayload);
      }
    });
    return id;
  }

  @override
  Future<void> update(String id, {int? keuskupanId, DateTime? tanggal, String? deskripsi, String? noBukti, List<DetilJurnalsCompanion>? detils}) async {
    final userId = await _getUserId();
    final cleanDeskripsi = InputSanitizer.sanitizeText(deskripsi);
    final cleanNoBukti = InputSanitizer.sanitizeText(noBukti);
    // Update header
    final comp = JurnalsCompanion(
      keuskupanId: keuskupanId != null ? Value(keuskupanId) : const Value.absent(),
      tanggal: tanggal != null ? Value(tanggal) : const Value.absent(),
      deskripsi: deskripsi != null ? Value(cleanDeskripsi) : const Value.absent(),
      noBukti: noBukti != null ? Value(cleanNoBukti) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
      updatedBy: Value(userId),
      isSynced: const Value(false),
    );
    await (db.update(db.jurnals)..where((t) => t.id.equals(id))).write(comp);
    await db.enqueue('jurnals', id, 'update', jsonEncode({"id": id, "updated_by": userId}));

    // Update detils if provided
    if (detils != null) {
      // Soft delete existing detils
      await (db.update(db.detilJurnals)..where((t) => t.jurnalId.equals(id))).write(DetilJurnalsCompanion(
        deletedAt: Value(DateTime.now()),
        deletedBy: Value(userId),
        isSynced: const Value(false),
      ));
      // Insert new detils
      for (final d in detils) {
        final comp = d.copyWith(jurnalId: Value(id));
        final detilId = (await db.into(db.detilJurnals).insertReturning(comp)).id;
        final detilPayload = jsonEncode({
          "id": detilId,
          "jurnal_id": id,
          "akun_id": comp.akunId.value,
          "paroki_id": comp.parokiId.value,
          "debit": comp.debit.present ? comp.debit.value : 0,
          "kredit": comp.kredit.present ? comp.kredit.value : 0,
          "keterangan": comp.keterangan.present ? comp.keterangan.value : null,
          "created_by": userId,
        });
        await db.enqueue('detil_jurnals', detilId.toString(), 'insert', detilPayload);
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    final userId = await _getUserId();
    await (db.update(db.jurnals)..where((t) => t.id.equals(id))).write(JurnalsCompanion(
      deletedAt: Value(DateTime.now()),
      deletedBy: Value(userId),
      isSynced: const Value(false),
    ));
    await db.enqueue('jurnals', id, 'delete', jsonEncode({"id": id, "deleted_by": userId}));
    // soft delete detils juga
    await (db.update(db.detilJurnals)..where((t) => t.jurnalId.equals(id))).write(DetilJurnalsCompanion(
      deletedAt: Value(DateTime.now()),
      deletedBy: Value(userId),
    ));
  }

  @override
  Future<int> pendingCount() => db.queueCount();
}