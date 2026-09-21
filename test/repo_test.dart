import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuskupanlaboanbajo_fe/data/local/app_database.dart';
import 'package:keuskupanlaboanbajo_fe/data/repository/impl/jurnal_repository_impl.dart';
import 'package:keuskupanlaboanbajo_fe/data/repository/impl/master_repository_impl.dart';
import 'package:keuskupanlaboanbajo_fe/core/auth/token_storage.dart';

void main() {
  group('Step 2 Repository - local first', () {
    test('jurnal repo create + get + soft delete', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final jurnalRepo = JurnalRepositoryImpl(db, tokenStorage: InMemoryTokenStorage());
      final keuskupanRepo = KeuskupanRepositoryImpl(db);
      final kId = await keuskupanRepo.create(nama: 'K1', alamat: 'A1');
      final jId = await jurnalRepo.create(keuskupanId: kId, tanggal: DateTime.now(), deskripsi: 'test');
      expect((await jurnalRepo.getAll()).length, 1);
      expect(await jurnalRepo.pendingCount(), 2); // keuskupan + jurnal
      await jurnalRepo.delete(jId);
      expect((await jurnalRepo.getAll()).length, 0); // soft delete filter
      final pending = await db.getPendingSync();
      expect(pending.any((e) => e.operation == 'delete'), true);
      await db.close();
    });

    test('paroki + akun + jenis flow', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final jenisRepo = JenisRepositoryImpl(db);
      final akunRepo = AkunRepositoryImpl(db);
      final keuskupanRepo = KeuskupanRepositoryImpl(db);
      final parokiRepo = ParokiRepositoryImpl(db);

      final keId = await keuskupanRepo.create(nama: 'Keuskupan', alamat: 'Jl');
      final jeId = await jenisRepo.create(nama: 'ASET');
      final akId = await akunRepo.create(kode: '101', nama: 'Kas', jenisId: jeId);
      final paId = await parokiRepo.create(nama: 'Paroki', alamat: 'Labuan', keuskupanId: keId);

      expect((await jenisRepo.getAll()).length, 1);
      expect((await akunRepo.getAll()).length, 1);
      expect((await parokiRepo.getAll()).length, 1);

      await akunRepo.update(akId, nama: 'Kas Besar');
      expect((await akunRepo.getById(akId))!.nama, 'Kas Besar');

      await parokiRepo.delete(paId);
      expect((await parokiRepo.getAll()).length, 0);

      await db.close();
    });

    test('jurnal with detils', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final keRepo = KeuskupanRepositoryImpl(db);
      final jeRepo = JenisRepositoryImpl(db);
      final akRepo = AkunRepositoryImpl(db);
      final paRepo = ParokiRepositoryImpl(db);
      final juRepo = JurnalRepositoryImpl(db, tokenStorage: InMemoryTokenStorage());

      final kId = await keRepo.create(nama: 'K', alamat: 'A');
      final jId2 = await jeRepo.create(nama: 'PENDAPATAN');
      final aId = await akRepo.create(kode: '401', nama: 'Sumbangan', jenisId: jId2);
      final pId = await paRepo.create(nama: 'Paroki', alamat: 'X', keuskupanId: kId);

      final jId = await juRepo.create(
        keuskupanId: kId,
        tanggal: DateTime.now(),
        detils: [
          DetilJurnalsCompanion.insert(jurnalId: 'tmp', akunId: aId, parokiId: pId, debit: const Value(50000)),
        ],
      );
      final detils = await juRepo.getDetils(jId);
      expect(detils.length, 1);
      expect(detils.first.debit, 50000);
      await db.close();
    });
  });
}
