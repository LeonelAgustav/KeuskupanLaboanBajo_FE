import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' hide Column;
import '../auth/token_storage.dart';
import '../network/connectivity_service.dart';
import '../network/http_client.dart';
import '../../data/local/app_database.dart';

// ponytail: push bulk, retryCount 3x max, last-write-wins di BE

typedef PushFn = Future<bool> Function(List<SyncQueue> pending, String accessToken);

class SyncService {
  final AppDatabase db;
  final TokenStorageI tokenStorage;
  final ConnectivityService connectivity;
  final PushFn pushToServer;
  final String baseUrl;
  final Duration debounce;
  StreamSubscription<bool>? _sub;
  Timer? _timer;
  bool _syncing = false;

  SyncService({
    required this.db,
    required this.tokenStorage,
    required this.connectivity,
    required this.pushToServer,
    required this.baseUrl,
    this.debounce = const Duration(seconds: 1),
  });

  // default push pakai http ke BE - BE expects {"items":[...]}
  static PushFn defaultPush(String baseUrl) {
    final client = getSecurityClient();
    return (pending, token) async {
      final url = Uri.parse('$baseUrl/api/v1/sync/push');
      final items = pending.map((e) {
        dynamic payload;
        try {
          payload = jsonDecode(e.payload);
        } catch (_) {
          payload = e.payload;
        }
        return {
          "target_table": e.targetTable,
          "row_id": e.rowId,
          "operation": e.operation,
          "payload": payload is Map ? payload : {"raw": e.payload},
        };
      }).toList();
      final body = jsonEncode({"items": items});
      debugPrint('SYNC PUSH URL: $url');
      debugPrint('SYNC PUSH BODY: $body');
      final res = await client.post(url,
          headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"}, body: body);
      debugPrint('SYNC PUSH STATUS: ${res.statusCode} BODY: ${res.body}');
      return res.statusCode >= 200 && res.statusCode < 300;
    };
  }

  void start() {
    _sub = connectivity.onOnline.listen((online) async {
      if (online) {
        await Future.delayed(debounce);
        await trySync();
      }
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) async {
      if (await connectivity.isOnline) await trySync();
    });
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _timer?.cancel();
  }

  Future<DateTime> _getLastPull() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString('last_pull');
    if (v == null) return DateTime(2020);
    return DateTime.tryParse(v) ?? DateTime(2020);
  }

  Future<void> _setLastPull(DateTime t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_pull', t.toIso8601String());
  }

  Future<bool> _pull(String baseUrl, String token) async {
    try {
      final since = await _getLastPull();
      final url = Uri.parse('$baseUrl/api/v1/sync/pull?since=${since.toIso8601String()}');
      debugPrint('SYNC PULL URL: $url');
      final res = await http.get(url, headers: {"Authorization": "Bearer $token"});
      debugPrint('SYNC PULL STATUS: ${res.statusCode}');
      debugPrint('SYNC PULL BODY LENGTH: ${res.body.length}');
      if (res.statusCode != 200) {
        debugPrint('SYNC PULL BODY: ${res.body}');
        return false;
      }
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      debugPrint('SYNC PULL KEYS: ${body.keys.toList()}');
      debugPrint('SYNC PULL JURNALS COUNT: ${(body['jurnals'] as List?)?.length ?? 0}');
      debugPrint('SYNC PULL PAROKIS COUNT: ${(body['parokis'] as List?)?.length ?? 0}');
      // master dulu biar FK jurnal tidak fail
      final kList = (body['keuskupans'] as List? ?? []);
      debugPrint('SYNC PULL: ${kList.length} keuskupans');
      for (final k in kList) {
        final m = k as Map<String, dynamic>;
        final uuid = (m['UUID'] ?? m['uuid'])?.toString();
        if (uuid == null) continue;
        // ponytail: upsert pakai uuid, bukan PK id (id lokal != id server -> dulu duplikat)
        final data = KeuskupansCompanion(
          nama: Value((m['Nama'] ?? m['nama'] ?? '') as String),
          alamat: Value((m['Alamat'] ?? m['alamat'] ?? '') as String),
        );
        final hit = await (db.update(db.keuskupans)..where((t) => t.uuid.equals(uuid))).write(data);
        if (hit == 0) {
          await db.into(db.keuskupans).insert(data.copyWith(
            uuid: Value(uuid),
            id: Value((m['ID'] ?? m['id']) as int),
          ));
        }
      }
      for (final p in (body['parokis'] as List? ?? [])) {
        final m = p as Map<String, dynamic>;
        final uuid = (m['UUID'] ?? m['uuid'])?.toString();
        if (uuid == null) continue;
        final nama = (m['Nama'] ?? m['nama'] ?? '') as String;
        final data = ParokisCompanion(
          nama: Value(nama),
          alamat: Value((m['Alamat'] ?? m['alamat'] ?? '') as String),
          keuskupanId: Value((m['KeuskupanID'] ?? m['keuskupan_id'] ?? 0) as int),
        );
        final hit = await (db.update(db.parokis)..where((t) => t.uuid.equals(uuid))).write(data);
        if (hit == 0) {
          await db.into(db.parokis).insert(data.copyWith(
            uuid: Value(uuid),
            id: Value((m['ID'] ?? m['id']) as int),
          ));
        }
      }
      for (final jn in (body['jenis'] as List? ?? [])) {
        final m = jn as Map<String, dynamic>;
        final uuid = (m['UUID'] ?? m['uuid'])?.toString();
        if (uuid == null) continue;
        final nama = (m['Nama'] ?? m['nama'] ?? '') as String;
        final data = JenisCompanion(
          nama: Value(nama),
        );
        final hit = await (db.update(db.jenis)..where((t) => t.uuid.equals(uuid))).write(data);
        if (hit == 0) {
          await db.into(db.jenis).insert(data.copyWith(
            uuid: Value(uuid),
            id: Value((m['ID'] ?? m['id']) as int),
          ));
        }
      }
      for (final a in (body['akuns'] as List? ?? [])) {
        final m = a as Map<String, dynamic>;
        final uuid = (m['UUID'] ?? m['uuid'])?.toString();
        if (uuid == null) continue;
        final kode = (m['Kode'] ?? m['kode'] ?? '') as String;
        final data = AkunsCompanion(
          kode: Value(kode),
          nama: Value((m['Nama'] ?? m['nama'] ?? '') as String),
          jenisId: Value((m['JenisID'] ?? m['jenis_id'] ?? 0) as int),
        );
        final hit = await (db.update(db.akuns)..where((t) => t.uuid.equals(uuid))).write(data);
        if (hit == 0) {
          await db.into(db.akuns).insert(data.copyWith(
            uuid: Value(uuid),
            id: Value((m['ID'] ?? m['id']) as int),
          ));
        }
      }
      for (final r in (body['roles'] as List? ?? [])) {
        final m = r as Map<String, dynamic>;
        final id = (m['ID'] ?? m['id']) as int;
        final nama = (m['Nama'] ?? m['nama'] ?? '') as String;
        final data = RolesCompanion(
          nama: Value(nama),
        );
        final hit = await (db.update(db.roles)..where((t) => t.id.equals(id))).write(data);
        if (hit == 0) {
          await db.into(db.roles).insert(data.copyWith(
            id: Value(id),
          ));
        }
      }
      for (final u in (body['users'] as List? ?? [])) {
        final m = u as Map<String, dynamic>;
        final uuid = (m['UUID'] ?? m['uuid'])?.toString();
        if (uuid == null) continue;
        final roleId = (m['RoleID'] ?? m['role_id']);
        final parokiId = (m['ParokiID'] ?? m['paroki_id']);
        final data = UsersCompanion(
          nama: Value((m['Nama'] ?? m['nama'] ?? '') as String),
          email: Value((m['Email'] ?? m['email'] ?? '') as String),
          roleId: Value(roleId != null ? (roleId as int) : null),
          parokiId: Value(parokiId != null ? (parokiId as int) : null),
        );
        final hit = await (db.update(db.users)..where((t) => t.uuid.equals(uuid))).write(data);
        if (hit == 0) {
          await db.into(db.users).insert(data.copyWith(
            uuid: Value(uuid),
            id: Value((m['ID'] ?? m['id']).toString()),
          ));
        }
      }
      // ADMIN tidak boleh lihat SUPERADMIN bahkan di cache lokal lama
      try {
        if (token.isNotEmpty) {
          final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(token.split('.')[1])))) as Map<String, dynamic>;
          if ((payload['role'] as String?)?.toUpperCase() == 'ADMIN') {
            await db.customStatement("DELETE FROM users WHERE email = 'superadmin@keuskupan.test'");
          }
        }
      } catch (_) {}
      final jurnals = body['jurnals'] as List? ?? [];
      for (final j in jurnals) {
        final m = j as Map<String, dynamic>;
        final id = (m['ID'] ?? m['id'])?.toString();
        if (id == null) continue;
        final keuskupanId = (m['KeuskupanID'] ?? m['keuskupan_id'] ?? 0) as int;
        final tanggalStr = m['Tanggal'] as String? ?? m['tanggal'] as String?;
        DateTime tanggal = DateTime.now();
        if (tanggalStr != null) tanggal = DateTime.tryParse(tanggalStr) ?? DateTime.now();
        await db.customStatement(
            'INSERT OR REPLACE INTO jurnals (id, keuskupan_id, tanggal, deskripsi, no_bukti, jenis_pembatasan, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)',
            [id, keuskupanId, tanggal.toIso8601String().substring(0, 10), m['Deskripsi'] ?? m['deskripsi'], m['NoBukti'] ?? m['no_bukti'], m['JenisPembatasan'] ?? m['jenis_pembatasan'] ?? 'Tanpa Pembatasan', DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
        final detils = m['DetilJurnal'] as List? ?? m['detil_jurnal'] as List? ?? [];
        // ponytail: hapus detil lama untuk jurnal ini agar tidak duplikat saat pull
        await db.customStatement('DELETE FROM detil_jurnals WHERE jurnal_id = ?', [id]);
        for (final d in detils) {
          final dm = d as Map<String, dynamic>;
          final did = (dm['ID'] ?? dm['id']);
          if (did == null) continue;
          await db.customStatement(
              'INSERT OR REPLACE INTO detil_jurnals (id, jurnal_id, akun_id, paroki_id, debit, kredit, akun_debit_id, akun_kredit_id, jumlah, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)',
              [did, id, (dm['AkunID'] ?? dm['akun_id'] ?? 0) as int, (dm['ParokiID'] ?? dm['paroki_id'] ?? 0) as int, dm['Debit'] ?? 0, dm['Kredit'] ?? 0, dm['AkunDebitID'] ?? dm['akun_debit_id'], dm['AkunKreditID'] ?? dm['akun_kredit_id'], dm['Jumlah'] ?? dm['jumlah'], DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
        }
      }
      // hapus lokal yang sudah di-soft-delete di BE
      for (final d in (body['deleted'] as List? ?? [])) {
        final m = d as Map<String, dynamic>;
        final id = m['ID'] as String? ?? m['id'] as String?;
        if (id == null) continue;
        await db.customStatement('UPDATE jurnals SET deleted_at = ?, is_synced = 1 WHERE id = ?', [DateTime.now().millisecondsSinceEpoch, id]);
        await db.customStatement('UPDATE detil_jurnals SET deleted_at = ? WHERE jurnal_id = ?', [DateTime.now().millisecondsSinceEpoch, id]);
      }
      await _setLastPull(DateTime.now());
      debugPrint('SYNC PULL SUCCESS');
      return true;
    } catch (e, st) {
      debugPrint('SYNC PULL ERROR: $e');
      debugPrint('SYNC PULL STACK: $st');
      return false;
    }
  }

  Future<bool> trySync() async {
    if (_syncing) return false;
    if (!await connectivity.isOnline) return false;
    if (!await tokenStorage.hasValidAccessToken()) return false;
    final token = await tokenStorage.getAccessToken();
    if (token == null) return false;

    _syncing = true;
    try {
      // 1. push pending
      final pending = await db.getPendingSync();
      final toPush = pending.where((e) => e.retryCount < 3).toList();
      if (toPush.isNotEmpty) {
        // ponytail: jaringan/BE down = gagal manis (retry nanti), jangan biarkan exception keluar
        bool ok;
        try {
          ok = await pushToServer(toPush, token);
        } catch (_) {
          ok = false;
        }
        if (!ok) {
          for (final q in toPush) {
            await db.customStatement('UPDATE sync_queues SET retry_count = retry_count + 1 WHERE id=?', [q.id]);
          }
          return false;
        }
        for (final q in toPush) {
          await db.clearSync(q.id);
          try {
            await db.customStatement('UPDATE ${q.targetTable} SET is_synced=1 WHERE id=?', [q.rowId]);
          } catch (_) {}
        }
      }
      // 2. pull dari server (biar HP lain dapat data)
      final pullOk = await _pull(baseUrl, token);
      debugPrint('SYNC PULL RESULT: $pullOk');
      return true;
    } finally {
      _syncing = false;
    }
  }
}
