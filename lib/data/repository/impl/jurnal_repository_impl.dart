import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../local/app_database.dart';
import '../interfaces/jurnal_repository.dart';

class JurnalRepositoryImpl implements JurnalRepository {
  final AppDatabase db;
  final _uuid = const Uuid();
  JurnalRepositoryImpl(this.db);

  @override
  Future<List<Jurnal>> getAll() => (db.select(db.jurnals)..where((t) => t.deletedAt.isNull())..orderBy([(t) => OrderingTerm.desc(t.tanggal)])).get();

  @override
  Future<Jurnal?> getById(String id) => (db.select(db.jurnals)..where((t) => t.id.equals(id))).getSingleOrNull();

  @override
  Future<List<DetilJurnal>> getDetils(String jurnalId) =>
      (db.select(db.detilJurnals)..where((t) => t.jurnalId.equals(jurnalId) & t.deletedAt.isNull())).get();

  @override
  Future<String> create({
    required String keuskupanId,
    required DateTime tanggal,
    String? deskripsi,
    String? noBukti,
    List<DetilJurnalsCompanion> detils = const [],
  }) async {
    final id = _uuid.v4();
    await db.transaction(() async {
      await db.into(db.jurnals).insert(JurnalsCompanion.insert(
        id: id,
        keuskupanId: keuskupanId,
        tanggal: tanggal,
        deskripsi: Value(deskripsi),
        noBukti: Value(noBukti),
      ));
      await db.enqueue('jurnals', id, 'insert', jsonEncode({"id": id, "keuskupan_id": keuskupanId, "tanggal": tanggal.toIso8601String(), "deskripsi": deskripsi, "no_bukti": noBukti}));
      for (final d in detils) {
        final rawId = d.id.present ? d.id.value : '';
        final detilId = (rawId.isEmpty || rawId == 'tmp') ? _uuid.v4() : rawId;
        final comp = d.copyWith(id: Value(detilId), jurnalId: Value(id));
        await db.into(db.detilJurnals).insert(comp);
        final detilPayload = jsonEncode({
          "id": detilId,
          "jurnal_id": id,
          "akun_id": comp.akunId.value,
          "paroki_id": comp.parokiId.value,
          "debit": comp.debit.present ? comp.debit.value : 0,
          "kredit": comp.kredit.present ? comp.kredit.value : 0,
          "keterangan": comp.keterangan.present ? comp.keterangan.value : null,
        });
        await db.enqueue('detil_jurnals', detilId, 'insert', detilPayload);
      }
    });
    return id;
  }

  @override
  Future<void> update(String id, {String? keuskupanId, DateTime? tanggal, String? deskripsi, String? noBukti}) async {
    final comp = JurnalsCompanion(
      keuskupanId: keuskupanId != null ? Value(keuskupanId) : const Value.absent(),
      tanggal: tanggal != null ? Value(tanggal) : const Value.absent(),
      deskripsi: deskripsi != null ? Value(deskripsi) : const Value.absent(),
      noBukti: noBukti != null ? Value(noBukti) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    );
    await (db.update(db.jurnals)..where((t) => t.id.equals(id))).write(comp);
    await db.enqueue('jurnals', id, 'update', '{"id":"$id"}');
  }

  @override
  Future<void> delete(String id) async {
    await (db.update(db.jurnals)..where((t) => t.id.equals(id))).write(JurnalsCompanion(
      deletedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    ));
    await db.enqueue('jurnals', id, 'delete', '{"id":"$id"}');
    // soft delete detils juga
    await (db.update(db.detilJurnals)..where((t) => t.jurnalId.equals(id))).write(DetilJurnalsCompanion(
      deletedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<int> pendingCount() => db.queueCount();
}
