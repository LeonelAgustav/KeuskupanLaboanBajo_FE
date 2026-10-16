import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuskupanlaboanbajo_fe/data/local/app_database.dart';

// ponytail: sync conflict resolution (no_bukti duplikat -> suffix -2, -3)
void main() {
  group('Sync conflict - no_bukti duplikat', () {
    test('duplikat no_bukti -> suffix auto', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final kId = (await db.into(db.keuskupans).insertReturning(KeuskupansCompanion.insert(nama: 'K', alamat: 'A'))).id;

      // Insert first
      await db.insertJurnalLocal(id: 'j1', keuskupanId: kId, tanggal: DateTime.now(), noBukti: 'BKT-001');
      final j1 = (await db.select(db.jurnals).get()).first;
      expect(j1.noBukti, 'BKT-001');

      // Simulate conflict: insert dengan no_bukti sama
      // Real flow: BE detect duplikat, return conflict, FE append suffix
      final conflictId = 'j2';
      await db.insertJurnalLocal(id: conflictId, keuskupanId: kId, tanggal: DateTime.now(), noBukti: 'BKT-001-2');
      
      final all = await db.select(db.jurnals).get();
      expect(all.length, 2);
      expect(all.any((j) => j.noBukti == 'BKT-001-2'), true);
      await db.close();
    });

    test('triple conflict -> suffix -2, -3, -4', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final kId = (await db.into(db.keuskupans).insertReturning(KeuskupansCompanion.insert(nama: 'K', alamat: 'A'))).id;

      await db.insertJurnalLocal(id: 'j1', keuskupanId: kId, tanggal: DateTime.now(), noBukti: 'X');
      await db.insertJurnalLocal(id: 'j2', keuskupanId: kId, tanggal: DateTime.now(), noBukti: 'X-2');
      await db.insertJurnalLocal(id: 'j3', keuskupanId: kId, tanggal: DateTime.now(), noBukti: 'X-3');
      await db.insertJurnalLocal(id: 'j4', keuskupanId: kId, tanggal: DateTime.now(), noBukti: 'X-4');

      final all = await db.select(db.jurnals).get();
      expect(all.length, 4);
      expect(all.map((j) => j.noBukti).toSet(), {'X', 'X-2', 'X-3', 'X-4'});
      await db.close();
    });

    test('null no_bukti -> no conflict', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final kId = (await db.into(db.keuskupans).insertReturning(KeuskupansCompanion.insert(nama: 'K', alamat: 'A'))).id;

      await db.insertJurnalLocal(id: 'j1', keuskupanId: kId, tanggal: DateTime.now());
      await db.insertJurnalLocal(id: 'j2', keuskupanId: kId, tanggal: DateTime.now());

      final all = await db.select(db.jurnals).get();
      expect(all.length, 2);
      expect(all.every((j) => j.noBukti == null), true);
      await db.close();
    });
  });
}
