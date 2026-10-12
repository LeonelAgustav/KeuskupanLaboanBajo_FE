import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
        final id = (m['ID'] ?? m['id']);
        if (id == null) continue;
        await db.customStatement(
            'INSERT OR REPLACE INTO keuskupans (id, nama, alamat, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, ?, 1)',
            [id, m['Nama'] ?? m['nama'] ?? '', m['Alamat'] ?? m['alamat'] ?? '', DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
      }
      for (final p in (body['parokis'] as List? ?? [])) {
        final m = p as Map<String, dynamic>;
        final id = (m['ID'] ?? m['id']);
        if (id == null) continue;
        final nama = m['Nama'] ?? m['nama'] ?? '';
        // ponytail: dedupe by nama, server ID wins
        await db.customStatement('DELETE FROM parokis WHERE nama = ? AND id != ?', [nama, id]);
        await db.customStatement(
            'INSERT OR REPLACE INTO parokis (id, nama, alamat, keuskupan_id, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, ?, ?, 1)',
            [id, nama, m['Alamat'] ?? m['alamat'] ?? '', m['KeuskupanID'] ?? m['keuskupan_id'] ?? 0, DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
      }
      for (final jn in (body['jenis'] as List? ?? [])) {
        final m = jn as Map<String, dynamic>;
        final id = (m['ID'] ?? m['id']);
        if (id == null) continue;
        final nama = m['Nama'] ?? m['nama'] ?? '';
        await db.customStatement('DELETE FROM jenis WHERE nama = ? AND id != ?', [nama, id]);
        await db.customStatement('INSERT OR REPLACE INTO jenis (id, nama, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, 1)',
            [id, nama, DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
      }
      for (final a in (body['akuns'] as List? ?? [])) {
        final m = a as Map<String, dynamic>;
        final id = (m['ID'] ?? m['id']);
        if (id == null) continue;
        final kode = m['Kode'] ?? m['kode'] ?? '';
        // ponytail: dedupe by kode (unique business key), server ID wins
        await db.customStatement('DELETE FROM akuns WHERE kode = ? AND id != ?', [kode, id]);
        await db.customStatement(
            'INSERT OR REPLACE INTO akuns (id, kode, nama, jenis_id, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, ?, ?, 1)',
            [id, kode, m['Nama'] ?? m['nama'] ?? '', m['JenisID'] ?? m['jenis_id'] ?? 0, DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
      }
      for (final r in (body['roles'] as List? ?? [])) {
        final m = r as Map<String, dynamic>;
        final id = (m['ID'] ?? m['id']);
        if (id == null) continue;
        final nama = m['Nama'] ?? m['nama'] ?? '';
        await db.customStatement('DELETE FROM roles WHERE nama = ? AND id != ?', [nama, id]);
        await db.customStatement(
            'INSERT OR REPLACE INTO roles (id, nama, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, 1)',
            [id, nama, DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
      }
      for (final u in (body['users'] as List? ?? [])) {
        final m = u as Map<String, dynamic>;
        final id = (m['ID'] ?? m['id']);
        if (id == null) continue;
        final roleId = m['RoleID'] ?? m['role_id'];
        final parokiId = m['ParokiID'] ?? m['paroki_id'];
        await db.customStatement(
            'INSERT OR REPLACE INTO users (id, nama, email, role_id, paroki_id, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, ?, ?, ?, 1)',
            [id.toString(), m['Nama'] ?? m['nama'] ?? '', m['Email'] ?? m['email'] ?? '', roleId, parokiId, DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
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
        final id = m['ID'] as String? ?? m['id'] as String?;
        if (id == null) continue;
        final keuskupanId = m['KeuskupanID'] ?? m['keuskupan_id'] ?? 0;
        final tanggalStr = m['Tanggal'] as String? ?? m['tanggal'] as String?;
        DateTime tanggal = DateTime.now();
        if (tanggalStr != null) tanggal = DateTime.tryParse(tanggalStr) ?? DateTime.now();
        await db.customStatement(
            'INSERT OR REPLACE INTO jurnals (id, keuskupan_id, tanggal, deskripsi, no_bukti, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, ?, ?, ?, 1)',
            [id, keuskupanId, tanggal.toIso8601String().substring(0, 10), m['Deskripsi'] ?? m['deskripsi'], m['NoBukti'] ?? m['no_bukti'], DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
        final detils = m['DetilJurnal'] as List? ?? m['detil_jurnal'] as List? ?? [];
        // ponytail: hapus detil lama untuk jurnal ini agar tidak duplikat saat pull
        await db.customStatement('DELETE FROM detil_jurnals WHERE jurnal_id = ?', [id]);
        for (final d in detils) {
          final dm = d as Map<String, dynamic>;
          final did = (dm['ID'] ?? dm['id']);
          if (did == null) continue;
          await db.customStatement(
              'INSERT OR REPLACE INTO detil_jurnals (id, jurnal_id, akun_id, paroki_id, debit, kredit, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)',
              [did, id, dm['AkunID'] ?? dm['akun_id'] ?? 0, dm['ParokiID'] ?? dm['paroki_id'] ?? 0, dm['Debit'] ?? 0, dm['Kredit'] ?? 0, DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
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
