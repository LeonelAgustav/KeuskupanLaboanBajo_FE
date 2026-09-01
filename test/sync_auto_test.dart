import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keuskupanlaboanbajo_fe/core/auth/jwt_helper.dart';
import 'package:keuskupanlaboanbajo_fe/core/auth/token_storage.dart';
import 'package:keuskupanlaboanbajo_fe/core/network/connectivity_service.dart';
import 'package:keuskupanlaboanbajo_fe/core/sync/sync_service.dart';
import 'package:keuskupanlaboanbajo_fe/data/local/app_database.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('TokenStorage + Connectivity auto-sync', () {
    test('offline: simpan token, cek valid tanpa internet', () async {
      final storage = InMemoryTokenStorage();
      final expAccess = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 900; // 15 menit
      final expRefresh = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 7 * 24 * 3600;
      await storage.saveTokens(
        accessToken: JwtHelper.generateFakeJwt(expUnixSeconds: expAccess),
        refreshToken: JwtHelper.generateFakeJwt(expUnixSeconds: expRefresh),
      );
      expect(await storage.hasValidAccessToken(), true);
      expect(await storage.hasValidRefreshToken(), true);

      // access expired, refresh masih valid -> offline tetap bisa baca lokal
      await storage.saveTokens(
        accessToken: JwtHelper.generateFakeJwt(expUnixSeconds: (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 10),
        refreshToken: JwtHelper.generateFakeJwt(expUnixSeconds: expRefresh),
      );
      expect(await storage.hasValidAccessToken(), false);
      expect(await storage.hasValidRefreshToken(), true);
    });

    test('auto-sync: offline enqueue, online flush', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final uuid = const Uuid();
      final kId = uuid.v4();
      await db.into(db.keuskupans).insert(KeuskupansCompanion.insert(id: kId, nama: 'K', alamat: 'A'));

      final storage = InMemoryTokenStorage();
      final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      await storage.saveTokens(accessToken: JwtHelper.generateFakeJwt(expUnixSeconds: exp), refreshToken: JwtHelper.generateFakeJwt(expUnixSeconds: exp + 1000));

      final fakeConn = FakeConnectivityService(false); // offline dulu

      var pushCalled = false;
      final sync = SyncService(
        db: db,
        tokenStorage: storage,
        connectivity: fakeConn,
        pushToServer: (pending, token) async {
          pushCalled = true;
          expect(token.isNotEmpty, true);
          expect(pending.length, 2);
          return true;
        },
      );

      // offline: 2 jurnal
      for (var i = 0; i < 2; i++) {
        await db.insertJurnalLocal(id: uuid.v4(), keuskupanId: kId, tanggal: DateTime.now());
      }
      expect(await db.queueCount(), 2);

      // offline trySync harus gagal (tidak push)
      expect(await sync.trySync(), false);
      expect(pushCalled, false);

      // online
      fakeConn.setOnline(true);
      expect(await sync.trySync(), true);
      expect(pushCalled, true);
      expect(await db.queueCount(), 0);

      await db.close();
    });

    test('auto-sync gagal 3x -> stop retry', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final uuid = const Uuid();
      final kId = uuid.v4();
      await db.into(db.keuskupans).insert(KeuskupansCompanion.insert(id: kId, nama: 'K', alamat: 'A'));
      await db.insertJurnalLocal(id: uuid.v4(), keuskupanId: kId, tanggal: DateTime.now());

      final storage = InMemoryTokenStorage();
      final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      await storage.saveTokens(accessToken: JwtHelper.generateFakeJwt(expUnixSeconds: exp), refreshToken: JwtHelper.generateFakeJwt(expUnixSeconds: exp));

      final fakeConn = FakeConnectivityService(true);
      final sync = SyncService(
        db: db,
        tokenStorage: storage,
        connectivity: fakeConn,
        pushToServer: (pending, token) async => false, // selalu gagal (BE down)
      );

      for (var i = 0; i < 3; i++) {
        await sync.trySync();
      }
      final pending = await db.getPendingSync();
      expect(pending.first.retryCount, 3);

      // ke-4 tidak dipush lagi (filter retry<3)
      final before = pending.first.retryCount;
      await sync.trySync();
      final after = (await db.getPendingSync()).first;
      expect(after.retryCount, before); // tidak naik lagi

      await db.close();
    });

    test('start() listen onOnline -> auto flush saat online', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final uuid = const Uuid();
      final kId = uuid.v4();
      await db.into(db.keuskupans).insert(KeuskupansCompanion.insert(id: kId, nama: 'K', alamat: 'A'));
      await db.insertJurnalLocal(id: uuid.v4(), keuskupanId: kId, tanggal: DateTime.now());

      final storage = InMemoryTokenStorage();
      final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      await storage.saveTokens(accessToken: JwtHelper.generateFakeJwt(expUnixSeconds: exp), refreshToken: JwtHelper.generateFakeJwt(expUnixSeconds: exp));

      final fakeConn = FakeConnectivityService(false);
      var pushed = false;
      final sync = SyncService(
        db: db,
        tokenStorage: storage,
        connectivity: fakeConn,
        pushToServer: (p, t) async {
          pushed = true;
          return true;
        },
        debounce: Duration.zero,
      );
      sync.start();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(pushed, false);

      fakeConn.setOnline(true);
      await Future.delayed(const Duration(milliseconds: 200));
      expect(pushed, true);
      expect(await db.queueCount(), 0);

      await sync.stop();
      await db.close();
    });
  });
}


