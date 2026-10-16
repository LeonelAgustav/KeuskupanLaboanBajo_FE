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
    final msg = ok ? '✓ Sinkronisasi berhasil' : 'Gagal sync: online=$online access=$hasAccess pending=$pending';
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: ok ? successGreen : dangerRed));
    setState(() => _refresh++);
  }

  Future<List> _loadKpi(String start, String next) async {
    final pid = await widget.sync.tokenStorage.getCurrentParokiId();
    final pf = (pid != null && pid > 0) ? ' AND EXISTS (SELECT 1 FROM detil_jurnals dd WHERE dd.jurnal_id = jurnals.id AND dd.paroki_id = ? AND dd.deleted_at IS NULL) ' : ' ';
    final pv = (pid != null && pid > 0) ? [Variable.withInt(pid)] : <Variable>[];
    final c = await widget.db.customSelect("SELECT COUNT(*) as c FROM jurnals WHERE deleted_at IS NULL AND tanggal >= ? AND tanggal < ?$pf", variables: [Variable.withString(start), Variable.withString(next), ...pv]).getSingle();
    final s = await widget.db.customSelect("SELECT COALESCE(SUM(dj.debit),0) as d, COALESCE(SUM(dj.kredit),0) as k FROM detil_jurnals dj INNER JOIN jurnals j ON dj.jurnal_id = j.id WHERE j.deleted_at IS NULL AND dj.deleted_at IS NULL AND j.tanggal >= ? AND j.tanggal < ?${(pid != null && pid > 0) ? ' AND dj.paroki_id = ?' : ''}", variables: [Variable.withString(start), Variable.withString(next), ...pv]).getSingle();
    return [c, s];
  }

  String _formatRupiah(double v) {
    final s = v.abs().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $s';
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
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
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), children: [
              // ── Header greeting ──
              Row(children: [
                Expanded(child: Text('${_greeting()}, ${widget.role} 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textDark))),
              ]),
              const SizedBox(height: 4),
              Text('${weekdayNamesId[now.weekday - 1]}, ${now.day} ${monthNamesId[now.month - 1]} ${now.year}', style: const TextStyle(color: abuHangat, fontSize: 13)),
              const SizedBox(height: 20),

              // ── Balance Card (anchor visual) ──
              FutureBuilder(
                key: ValueKey('kpi$_refresh'),
                future: _loadKpi(start, next),
                builder: (c, snap) {
                  final rows = snap.data;
                  final count = rows != null ? (rows[0] as QueryRow).data['c'] as int : 0;
                  final d = rows != null ? ((rows[1] as QueryRow).data['d'] as num).toDouble() : 0.0;
                  final k = rows != null ? ((rows[1] as QueryRow).data['k'] as num).toDouble() : 0.0;
                  final saldo = k - d;
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ungu, ungu.withValues(alpha: 0.85)]),
                      boxShadow: [BoxShadow(color: ungu.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Total Saldo', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text(_formatRupiah(saldo), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      const SizedBox(height: 12),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(999)), child: Text('$count jurnal ${monthNamesId[now.month - 1]}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _BalanceMini(label: 'Pemasukan', value: _formatRupiah(k), icon: Icons.arrow_upward, color: successGreen)),
                        const SizedBox(width: 12),
                        Expanded(child: _BalanceMini(label: 'Pengeluaran', value: _formatRupiah(d), icon: Icons.arrow_downward, color: merahPengeluaran)),
                      ]),
                    ]),
                  );
                },
              ),
              const SizedBox(height: 16),

              // ── Quick Actions ──
              Row(children: [
                Expanded(child: _QuickAction(icon: Icons.add_circle, label: 'Buat Jurnal', color: ungu, onTap: () => widget.onNavigate?.call(1))),
                const SizedBox(width: 12),
                Expanded(child: _QuickAction(icon: Icons.assessment, label: 'Lihat Rekap', color: infoBlue, onTap: () => widget.onNavigate?.call(2))),
              ]),
              const SizedBox(height: 20),

              // ── Sync Status Card ──
              FutureBuilder(
                key: ValueKey('sync$_refresh'),
                future: Future.wait([widget.db.customSelect('SELECT COUNT(*) as c FROM jurnals WHERE deleted_at IS NULL').getSingle(), widget.db.queueCount(), widget.db.conflictCount()]),
                builder: (c, snap) {
                  final rows = snap.data as List?;
                  final count = rows != null ? (rows[0] as QueryRow).data['c'] as int : 0;
                  final pending = rows != null ? rows[1] as int : 0;
                  final conflicts = rows != null ? rows[2] as int : 0;
                  final isSynced = pending == 0 && conflicts == 0;
                  final icon = conflicts > 0 ? Icons.cloud_off : isSynced ? Icons.cloud_done : Icons.cloud_upload;
                  final color = conflicts > 0 ? dangerRed : isSynced ? successGreen : warningOrange;
                  final statusText = conflicts > 0 ? 'Konflik: $conflicts data' : isSynced ? 'Semua data tersinkronisasi' : '$pending data pending sync';
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Icon(icon, color: color, size: 28),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('$count Jurnal tersimpan', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textDark)),
                          const SizedBox(height: 2),
                          Text(statusText, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
                        ])),
                        IconButton(icon: const Icon(Icons.sync, color: ungu), onPressed: _doSync),
                      ]),
                    ),
                  );
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _BalanceMini extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _BalanceMini({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
      ])),
    ]);
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textDark)),
          ]),
        ),
      ),
    );
  }
}
