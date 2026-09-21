import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuskupanlaboanbajo_fe/data/local/app_database.dart';
import 'package:uuid/uuid.dart';

void main() {
  test('sqlite local-first: insert jurnal offline + queue', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final uuid = const Uuid();

final keuskupanId = (await db.into(db.keuskupans).insertReturning(KeuskupansCompanion.insert(
      nama: 'Keuskupan Labuan Bajo',
      alamat: 'Jl Test',
    ))).id;

    final jurnalId = uuid.v4();
    await db.insertJurnalLocal(
      id: jurnalId,
      keuskupanId: keuskupanId,
      tanggal: DateTime.now(),
      deskripsi: 'Jurnal test offline',
      noBukti: 'BUKTI-${jurnalId.substring(0, 8)}',
    );

    final jurnals = await db.getAllJurnal();
    expect(jurnals.length, 1);
    expect(jurnals.first.id, jurnalId);
    expect(jurnals.first.isSynced, false);

    final pending = await db.getPendingSync();
    expect(pending.length, 1);
    expect(pending.first.targetTable, 'jurnals');
    expect(pending.first.rowId, jurnalId);

    await db.customStatement('UPDATE jurnals SET is_synced=1 WHERE id=?', [jurnalId]);
    await db.clearSync(pending.first.id);

    final afterSync = await db.queueCount();
    expect(afterSync, 0);

    final synced = await db.customSelect('SELECT is_synced FROM jurnals WHERE id=?', variables: [Variable.withString(jurnalId)]).getSingle();
    expect(synced.data['is_synced'], 1);

    await db.close();
  });

  test('sqlite: paroki + akun + detil jurnal', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final uuid = const Uuid();

final keuskupanId = (await db.into(db.keuskupans).insertReturning(KeuskupansCompanion.insert(nama: 'K1', alamat: 'A1'))).id;

    final jenisId = (await db.into(db.jenis).insertReturning(JenisCompanion.insert(nama: 'ASET'))).id;

    final akunId = (await db.into(db.akuns).insertReturning(AkunsCompanion.insert(kode: '101', nama: 'Kas', jenisId: jenisId))).id;

    final parokiId = (await db.into(db.parokis).insertReturning(ParokisCompanion.insert(nama: 'Paroki St Maria', alamat: 'Labuan', keuskupanId: keuskupanId))).id;

    final jurnalId = uuid.v4();
    await db.insertJurnalLocal(id: jurnalId, keuskupanId: keuskupanId, tanggal: DateTime.now(), deskripsi: 'test detil');

    await db.into(db.detilJurnals).insert(DetilJurnalsCompanion.insert(
      jurnalId: jurnalId,
      akunId: akunId,
      parokiId: parokiId,
      debit: const Value(100000),
    ));

    final detils = await db.customSelect('SELECT * FROM detil_jurnals WHERE jurnal_id=?', variables: [Variable.withString(jurnalId)]).get();
    expect(detils.length, 1);
    expect(detils.first.data['debit'], 100000);

    await db.close();
  });
}


