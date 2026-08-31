import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../data/local/app_database.dart';
import '../../../core/auth/jwt_helper.dart';
import '../../../core/auth/token_storage.dart';

class DebugDbScreen extends StatefulWidget {
  const DebugDbScreen({super.key});
  @override
  State<DebugDbScreen> createState() => _DebugDbScreenState();
}

class _DebugDbScreenState extends State<DebugDbScreen> {
  final db = AppDatabase();
  final uuid = const Uuid();
  String _log = '';

  Future<Map<String, int>> _counts() async {
    try {
      await db.customSelect('SELECT 1').getSingle();
      final j = await db.customSelect('SELECT COUNT(*) as c FROM jurnals').getSingle();
      final k = await db.customSelect('SELECT COUNT(*) as c FROM keuskupans').getSingle();
      final p = await db.customSelect('SELECT COUNT(*) as c FROM parokis').getSingle();
      final a = await db.customSelect('SELECT COUNT(*) as c FROM akuns').getSingle();
      final q = await db.queueCount();
      return {
        'jurnals': j.data['c'] as int,
        'keuskupans': k.data['c'] as int,
        'parokis': p.data['c'] as int,
        'akuns': a.data['c'] as int,
        'queue': q,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _insertDummy() async {
    final kId = uuid.v4();
    await db.into(db.keuskupans).insert(KeuskupansCompanion.insert(id: kId, nama: 'K ${kId.substring(0, 4)}', alamat: 'Labuan'));
    final jId = uuid.v4();
    await db.insertJurnalLocal(id: jId, keuskupanId: kId, tanggal: DateTime.now(), deskripsi: 'dummy ${DateTime.now().toIso8601String()}', noBukti: 'DBG-${jId.substring(0, 8)}');
    setState(() => _log = 'insert dummy jurnals $jId (is_synced=0)');
  }

  Future<void> _clearAll() async {
    await db.customStatement('DELETE FROM detil_jurnals');
    await db.customStatement('DELETE FROM jurnals');
    await db.customStatement('DELETE FROM sync_queues');
    await db.customStatement('DELETE FROM parokis');
    await db.customStatement('DELETE FROM akuns');
    await db.customStatement('DELETE FROM jenis');
    await db.customStatement('DELETE FROM keuskupans');
    setState(() => _log = 'clear all local');
  }

  Future<void> _testJwt() async {
    final storage = InMemoryTokenStorage();
    final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
    await storage.saveTokens(
      accessToken: JwtHelper.generateFakeJwt(expUnixSeconds: exp),
      refreshToken: JwtHelper.generateFakeJwt(expUnixSeconds: exp + 86400),
    );
    final a = await storage.hasValidAccessToken();
    final r = await storage.hasValidRefreshToken();
    setState(() => _log = 'JWT valid: access=$a refresh=$r');
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug SQLite Lokal'), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() {})),
      ]),
      body: FutureBuilder<Map<String, int>>(
        future: _counts(),
        builder: (c, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text('Error DB: ${snap.error}', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    Text('${snap.stackTrace}', style: const TextStyle(fontSize: 10)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: () => setState(() {}), child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final m = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(_log, style: const TextStyle(color: Colors.blue)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: [
                Chip(label: Text('jurnals: ${m['jurnals']}')),
                Chip(label: Text('keuskupans: ${m['keuskupans']}')),
                Chip(label: Text('parokis: ${m['parokis']}')),
                Chip(label: Text('akuns: ${m['akuns']}')),
                Chip(label: Text('queue: ${m['queue']}', style: TextStyle(color: Colors.red))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                ElevatedButton(onPressed: _insertDummy, child: const Text('Insert Dummy')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _testJwt, child: const Text('Test JWT')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _clearAll, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Clear All')),
              ]),
              const Divider(height: 32),
              const Text('Jurnals (lokal):', style: TextStyle(fontWeight: FontWeight.bold)),
              FutureBuilder(
                future: db.getAllJurnal(),
                builder: (c, s) {
                  if (!s.hasData) return const Text('loading...');
                  if (s.data!.isEmpty) return const Text('kosong - insert dummy dulu');
                  return Column(
                    children: s.data!.map((j) => ListTile(
                          dense: true,
                          title: Text('${j.id.substring(0, 8)} ${j.deskripsi ?? '-'}'),
                          subtitle: Text('synced=${j.isSynced} bukti=${j.noBukti}'),
                          trailing: Text(j.tanggal.toString().substring(0, 10)),
                        )).toList(),
                  );
                },
              ),
              const Divider(),
              const Text('Sync Queue:', style: TextStyle(fontWeight: FontWeight.bold)),
              FutureBuilder(
                future: db.getPendingSync(),
                builder: (c, s) {
                  if (!s.hasData) return const Text('loading...');
                  if (s.data!.isEmpty) return const Text('queue kosong = sudah sync ke BE', style: TextStyle(color: Colors.green));
                  return Column(
                    children: s.data!.map((q) => ListTile(
                          dense: true,
                          title: Text('${q.targetTable} ${q.rowId.substring(0, 8)}'),
                          subtitle: Text('${q.operation} retry=${q.retryCount}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            onPressed: () async {
                              await db.clearSync(q.id);
                              setState(() {});
                            },
                          ),
                        )).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text('Lokasi: Android file SQLite, Web IndexedDB+WASM (sqlite3.wasm)', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          );
        },
      ),
    );
  }
}
