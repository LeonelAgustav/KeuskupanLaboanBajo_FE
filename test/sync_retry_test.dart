import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuskupanlaboanbajo_fe/data/local/app_database.dart';
import 'package:uuid/uuid.dart';

// ponytail: test antrian sync + retry tanpa butuh internet beneran
void main() {
  group('Sync queue retry - offline tolerant', () {
    test('enqueue 3 op offline -> pending 3', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final uuid = const Uuid();
      final kId = uuid.v4();
      await db.into(db.keuskupans).insert(KeuskupansCompanion.insert(id: kId, nama: 'K', alamat: 'A'));

      for (var i = 0; i < 3; i++) {
        final jId = uuid.v4();
        await db.insertJurnalLocal(id: jId, keuskupanId: kId, tanggal: DateTime.now(), deskripsi: 'op $i');
      }
      expect(await db.queueCount(), 3);
      final pending = await db.getPendingSync();
      expect(pending.length, 3);
      // FIFO: id kecil = lebih dulu (createdAt bisa sama detik)
      expect(pending.first.id <= pending.last.id, true);
      await db.close();
    });

    test('retryCount naik tiap gagal sync', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final uuid = const Uuid();
      final kId = uuid.v4();
      await db.into(db.keuskupans).insert(KeuskupansCompanion.insert(id: kId, nama: 'K', alamat: 'A'));
      final jId = uuid.v4();
      await db.insertJurnalLocal(id: jId, keuskupanId: kId, tanggal: DateTime.now());

      final q = (await db.getPendingSync()).first;
      expect(q.retryCount, 0);

      // simulasi gagal sync 3x (internet putus)
      await db.customStatement('UPDATE sync_queues SET retry_count = retry_count + 1 WHERE id = ?', [q.id]);
      await db.customStatement('UPDATE sync_queues SET retry_count = retry_count + 1 WHERE id = ?', [q.id]);
      await db.customStatement('UPDATE sync_queues SET retry_count = retry_count + 1 WHERE id = ?', [q.id]);

      final after = (await db.getPendingSync()).first;
      expect(after.retryCount, 3);

      // ponytail: kalau retry >3, bisa skip atau tampilkan warning, jangan infinite loop
      await db.close();
    });

    test('sync sukses -> queue hilang, is_synced jadi 1', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final uuid = const Uuid();
      final kId = uuid.v4();
      await db.into(db.keuskupans).insert(KeuskupansCompanion.insert(id: kId, nama: 'K', alamat: 'A'));
      final jId = uuid.v4();
      await db.insertJurnalLocal(id: jId, keuskupanId: kId, tanggal: DateTime.now());

      final before = await db.queueCount();
      expect(before, 1);

      // simulasi push ke BE sukses
      final pending = (await db.getPendingSync()).first;
      await db.customStatement('UPDATE jurnals SET is_synced = 1 WHERE id = ?', [jId]);
      await db.clearSync(pending.id);

      expect(await db.queueCount(), 0);
      final row = await db.customSelect('SELECT is_synced FROM jurnals WHERE id = ?', variables: [Variable.withString(jId)]).getSingle();
      expect(row.data['is_synced'], 1);
      await db.close();
    });

    test('offline tulis banyak, online flush semua', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final uuid = const Uuid();
      final kId = uuid.v4();
      await db.into(db.keuskupans).insert(KeuskupansCompanion.insert(id: kId, nama: 'K', alamat: 'A'));

      // offline: 5 jurnal
      for (var i = 0; i < 5; i++) {
        await db.insertJurnalLocal(id: uuid.v4(), keuskupanId: kId, tanggal: DateTime.now().add(Duration(days: i)));
      }
      expect(await db.queueCount(), 5);

      // online: flush semua (simulate BE push bulk)
      final pending = await db.getPendingSync();
      for (final q in pending) {
        await db.clearSync(q.id);
        await db.customStatement('UPDATE jurnals SET is_synced = 1 WHERE id = ?', [q.rowId]);
      }
      expect(await db.queueCount(), 0);
      final synced = await db.customSelect('SELECT COUNT(*) as c FROM jurnals WHERE is_synced = 1').getSingle();
      expect(synced.data['c'], 5);
      await db.close();
    });
  });
}


