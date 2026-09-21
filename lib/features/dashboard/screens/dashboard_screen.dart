import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/theme.dart';
import '../../../data/local/app_database.dart';
import '../../recap/widgets/recap_widgets.dart';

class DashboardScreen extends StatefulWidget {
  final AppDatabase db;
  final SyncService sync;
  final String log;
  final String role;
  final ValueChanged<int>? onNavigate;
  const DashboardScreen({super.key, required this.db, required this.sync, required this.log, this.role = 'MEMBER', this.onNavigate});
  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _refresh = 0;
  Future<void> _doSync() async {
    final hasAccess = await widget.sync.tokenStorage.hasValidAccessToken();
    final online = await widget.sync.connectivity.isOnline;
    final pending = await widget.db.queueCount();
    final ok = await widget.sync.trySync();
    final msg = ok ? 'Sync OK' : 'Sync gagal: online=$online access=$hasAccess pending=$pending';
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: ok ? Colors.green : Colors.red));
    setState(() => _refresh++);
  }

  // MEMBER: hitung hanya jurnal milik paroki mereka
  Future<List> _loadKpi(String start, String next) async {
    final pid = await widget.sync.tokenStorage.getCurrentParokiId();
    final pf = (pid != null && pid > 0) ? ' AND EXISTS (SELECT 1 FROM detil_jurnals dd WHERE dd.jurnal_id = jurnals.id AND dd.paroki_id = ? AND dd.deleted_at IS NULL) ' : ' ';
    final pv = (pid != null && pid > 0) ? [Variable.withInt(pid)] : <Variable>[];
    final c = await widget.db.customSelect("SELECT COUNT(*) as c FROM jurnals WHERE deleted_at IS NULL AND tanggal >= ? AND tanggal < ?$pf", variables: [Variable.withString(start), Variable.withString(next), ...pv]).getSingle();
    final s = await widget.db.customSelect("SELECT COALESCE(SUM(dj.debit),0) as d, COALESCE(SUM(dj.kredit),0) as k FROM detil_jurnals dj INNER JOIN jurnals j ON dj.jurnal_id = j.id WHERE j.deleted_at IS NULL AND dj.deleted_at IS NULL AND j.tanggal >= ? AND j.tanggal < ?${(pid != null && pid > 0) ? ' AND dj.paroki_id = ?' : ''}", variables: [Variable.withString(start), Variable.withString(next), ...pv]).getSingle();
    return [c, s];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month).toIso8601String().substring(0, 10);
    final next = DateTime(now.year, now.month + 1).toIso8601String().substring(0, 10);
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: RefreshIndicator(
            onRefresh: () async => _doSync(),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [ungu, emas])),
                  child: Row(children: [
                    const CircleAvatar(radius: 24, backgroundColor: Colors.white24, child: Icon(Icons.church, color: Colors.white, size: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Selamat datang, ${widget.role}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 4),
                      Text('${weekdayNamesId[now.weekday - 1]}, ${now.day} ${monthNamesId[now.month - 1]} ${now.year}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ])),
                  ])),
              const SizedBox(height: 12),
              FutureBuilder(
                  key: ValueKey('kpi$_refresh'),
                  future: _loadKpi(start, next),
                  builder: (c, snap) {
                    final rows = snap.data as List?;
                    final count = rows != null ? (rows[0] as QueryRow).data['c'] as int : 0;
                    final d = rows != null ? ((rows[1] as QueryRow).data['d'] as num).toDouble() : 0.0;
                    final k = rows != null ? ((rows[1] as QueryRow).data['k'] as num).toDouble() : 0.0;
                    return Column(children: [
                      Card(child: ListTile(leading: Icon(Icons.book, color: ungu), title: Text('$count jurnal bulan ${monthNamesId[now.month - 1]}', style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('Jumlah jurnal tercatat bulan ini'))),
                      const SizedBox(height: 4),
                      SummaryRow(totalPendapatan: k, totalPengeluaran: d),
                    ]);
                  }),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: FilledButton.icon(onPressed: () => widget.onNavigate?.call(1), icon: const Icon(Icons.add), label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Catat Pendapatan')))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(onPressed: () => widget.onNavigate?.call(2), icon: const Icon(Icons.assessment), label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Lihat Rekap')))),
              ]),
              const SizedBox(height: 12),
              FutureBuilder(
                  key: ValueKey('sync$_refresh'),
                  future: Future.wait([widget.db.customSelect('SELECT COUNT(*) as c FROM jurnals WHERE deleted_at IS NULL').getSingle(), widget.db.queueCount(), widget.db.conflictCount()]),
                  builder: (c, snap) {
                    final rows = snap.data as List?;
                    final count = rows != null ? (rows[0] as QueryRow).data['c'] as int : 0;
                    final pending = rows != null ? rows[1] as int : 0;
                    final conflicts = rows != null ? rows[2] as int : 0;
                    final icon = conflicts > 0 ? Icons.cloud_off : pending == 0 ? Icons.cloud_done : Icons.cloud_upload;
                    final color = conflicts > 0 ? Colors.red : pending == 0 ? Colors.green : orangeKhas;
                    return Card(child: ListTile(leading: Icon(icon, color: color, size: 32), title: Text('$count Jurnal tersimpan (lokal)'), subtitle: Text('$pending data pending sync${conflicts > 0 ? ' | ⚠️ Konflik: $conflicts' : ''}'), trailing: IconButton(icon: const Icon(Icons.sync), onPressed: _doSync)));
                  }),
            ]),
          ),
        ),
      ),
    );
  }
}
