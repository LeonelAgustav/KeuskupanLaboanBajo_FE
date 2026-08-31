import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  final Duration debounce;
  StreamSubscription<bool>? _sub;
  bool _syncing = false;

  SyncService({
    required this.db,
    required this.tokenStorage,
    required this.connectivity,
    required this.pushToServer,
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

  Future<bool> trySync() async {
    if (_syncing) return false;
    if (!await connectivity.isOnline) return false;
    if (!await tokenStorage.hasValidAccessToken()) {
      // coba refresh logic: kalau access habis tapi refresh valid, di real app hit /refresh dulu
      // di test kita anggap gagal sync kalau access invalid
      return false;
    }
    final token = await tokenStorage.getAccessToken();
    if (token == null) return false;

    final pending = await db.getPendingSync();
    if (pending.isEmpty) return true;

    // filter yang retry <3
    final toPush = pending.where((e) => e.retryCount < 3).toList();
    if (toPush.isEmpty) return false;

    _syncing = true;
    try {
      final ok = await pushToServer(toPush, token);
      if (ok) {
        for (final q in toPush) {
          await db.clearSync(q.id);
          // flag is_synced di tabel asal (pakai customStatement biar tidak perlu tau tabel)
          // untuk jurnals/detil_jurnals dll, BE sudah handle, lokal cukup hapus queue
          // tapi untuk UX, set is_synced=1 kalau kolom ada
          try {
            await db.customStatement('UPDATE ${q.targetTable} SET is_synced=1 WHERE id=?', [q.rowId]);
          } catch (_) {}
        }
        return true;
      } else {
        for (final q in toPush) {
          await db.customStatement('UPDATE sync_queues SET retry_count = retry_count + 1 WHERE id=?', [q.id]);
        }
        return false;
      }
    } finally {
      _syncing = false;
    }
  }
}
