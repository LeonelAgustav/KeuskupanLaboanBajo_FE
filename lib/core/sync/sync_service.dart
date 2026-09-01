import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/token_storage.dart';
import '../network/connectivity_service.dart';
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
  bool _syncing = false;

  SyncService({
    required this.db,
    required this.tokenStorage,
    required this.connectivity,
    required this.pushToServer,
    this.baseUrl = 'keuskupanlaboanbajobe-production.up.railway.app:8080',
    this.debounce = const Duration(seconds: 1),
  });

  // default push pakai http ke BE - BE expects {"items":[...]}
  static PushFn defaultPush(String baseUrl) {
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
      final res = await http.post(url,
          headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"}, body: body);
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
  }

  Future<void> stop() async => await _sub?.cancel();

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
      final res = await http.get(url, headers: {"Authorization": "Bearer $token"});
      if (res.statusCode != 200) return false;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      // master dulu biar FK jurnal tidak fail
      for (final k in (body['keuskupans'] as List? ?? [])) {
        final m = k as Map<String, dynamic>;
        final id = m['ID'] as String? ?? m['id'] as String?;
        if (id == null) continue;
        await db.customStatement(
            'INSERT OR REPLACE INTO keuskupans (id, nama, alamat, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, ?, 1)',
            [id, m['Nama'] ?? m['nama'] ?? '', m['Alamat'] ?? m['alamat'] ?? '', DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
      }
      for (final p in (body['parokis'] as List? ?? [])) {
        final m = p as Map<String, dynamic>;
        final id = m['ID'] as String? ?? m['id'] as String?;
        if (id == null) continue;
        await db.customStatement(
            'INSERT OR REPLACE INTO parokis (id, nama, alamat, keuskupan_id, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, ?, ?, 1)',
            [id, m['Nama'] ?? m['nama'] ?? '', m['Alamat'] ?? m['alamat'] ?? '', m['KeuskupanID'] ?? m['keuskupan_id'] ?? '', DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
      }
      for (final jn in (body['jenis'] as List? ?? [])) {
        final m = jn as Map<String, dynamic>;
        final id = m['ID'] as String? ?? m['id'] as String?;
        if (id == null) continue;
        await db.customStatement('INSERT OR REPLACE INTO jenis (id, nama, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, 1)',
            [id, m['Nama'] ?? m['nama'] ?? '', DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
      }
      for (final a in (body['akuns'] as List? ?? [])) {
        final m = a as Map<String, dynamic>;
        final id = m['ID'] as String? ?? m['id'] as String?;
        if (id == null) continue;
        await db.customStatement(
            'INSERT OR REPLACE INTO akuns (id, kode, nama, jenis_id, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, ?, ?, 1)',
            [id, m['Kode'] ?? m['kode'] ?? '', m['Nama'] ?? m['nama'] ?? '', m['JenisID'] ?? m['jenis_id'] ?? '', DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
      }
      final jurnals = body['jurnals'] as List? ?? [];
      for (final j in jurnals) {
        final m = j as Map<String, dynamic>;
        final id = m['ID'] as String? ?? m['id'] as String?;
        if (id == null) continue;
        final keuskupanId = m['KeuskupanID'] as String? ?? m['keuskupan_id'] as String? ?? '';
        final tanggalStr = m['Tanggal'] as String? ?? m['tanggal'] as String?;
        DateTime tanggal = DateTime.now();
        if (tanggalStr != null) tanggal = DateTime.tryParse(tanggalStr) ?? DateTime.now();
        await db.customStatement(
            'INSERT OR REPLACE INTO jurnals (id, keuskupan_id, tanggal, deskripsi, no_bukti, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, ?, ?, ?, 1)',
            [id, keuskupanId, tanggal.toIso8601String().substring(0, 10), m['Deskripsi'] ?? m['deskripsi'], m['NoBukti'] ?? m['no_bukti'], DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
        final detils = m['DetilJurnal'] as List? ?? m['detil_jurnal'] as List? ?? [];
        for (final d in detils) {
          final dm = d as Map<String, dynamic>;
          final did = dm['ID'] as String? ?? dm['id'] as String?;
          if (did == null) continue;
          await db.customStatement(
              'INSERT OR REPLACE INTO detil_jurnals (id, jurnal_id, akun_id, paroki_id, debit, kredit, created_at, updated_at, is_synced) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)',
              [did, id, dm['AkunID'] ?? dm['akun_id'] ?? '', dm['ParokiID'] ?? dm['paroki_id'] ?? '', dm['Debit'] ?? 0, dm['Kredit'] ?? 0, DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch]);
        }
      }
      await _setLastPull(DateTime.now());
      return true;
    } catch (_) {
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
        final ok = await pushToServer(toPush, token);
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
      await _pull(baseUrl, token);
      return true;
    } finally {
      _syncing = false;
    }
  }
}
