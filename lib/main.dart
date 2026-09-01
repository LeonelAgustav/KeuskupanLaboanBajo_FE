import 'package:drift/drift.dart' hide Column;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'core/auth/jwt_helper.dart';
import 'core/auth/token_storage.dart';
import 'core/network/connectivity_service.dart';
import 'core/sync/sync_service.dart';
import 'data/local/app_database.dart';
import 'features/jurnal/screens/jurnal_list_screen.dart';
import 'features/master/screens/master_screen.dart';
import 'features/recap/screens/recap_keuskupan_screen.dart';

// ponytail: 1 codebase untuk app + website, responsive nav
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keuskupan Labuan Bajo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      home: const HomeTabs(),
    );
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});
  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _idx = 0;
  late final AppDatabase _db = AppDatabase();
  late final TokenStorageI _tokens = TokenStorage();
  late final ConnectivityService _conn = ConnectivityService();
  // API_URL bisa di-override: flutter run --dart-define=API_URL=https://be.up.railway.app
  String get _apiUrl {
    const env = String.fromEnvironment('API_URL');
    if (env.isNotEmpty) return env;
    if (kIsWeb) return 'http://localhost:8080';
    return 'http://10.39.48.26:8080'; // HP fisik di WiFi binus.local
  }

  late final SyncService _sync = SyncService(
    db: _db,
    tokenStorage: _tokens,
    connectivity: _conn,
    baseUrl: _apiUrl,
    pushToServer: SyncService.defaultPush(_apiUrl),
  );
  String _syncLog = '';

  @override
  void initState() {
    super.initState();
    _sync.start();
    _seedFakeTokenIfEmpty().then((_) {
      // ponytail: langsung pull saat buka app jika online (biar data server masuk)
      Future.delayed(const Duration(seconds: 1), () async {
        if (await _conn.isOnline) {
          final ok = await _sync.trySync();
          if (ok && mounted) setState(() => _syncLog = 'Auto-pull OK');
        }
      });
    });
  }

  Future<void> _seedFakeTokenIfEmpty() async {
    if (!await _tokens.hasValidAccessToken()) {
      final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      // pakai signed biar BE accept (secret sama dengan BE default)
      final token = JwtHelper.generateSignedJwt(expUnixSeconds: exp);
      await _tokens.saveTokens(accessToken: token, refreshToken: token);
    }
  }

  @override
  void dispose() {
    _sync.stop();
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ponytail: 1 codebase, 4 tab sesuai plan, Responsive: web >600 pakai NavigationRail
    final pages = [
      _DashboardTab(db: _db, sync: _sync, log: _syncLog),
      JurnalListScreen(db: _db),
      RecapKeuskupanScreen(db: _db),
      MasterScreen(db: _db),
      _SettingsTab(db: _db, sync: _sync, tokens: _tokens, onLog: (s) => setState(() => _syncLog = s)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        if (isWide) {
          // Website layout: Rail di kiri, content centered max 900
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _idx,
                  onDestinationSelected: (i) => setState(() => _idx = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
                    NavigationRailDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: Text('Jurnal')),
                    NavigationRailDestination(icon: Icon(Icons.assessment_outlined), selectedIcon: Icon(Icons.assessment), label: Text('Rekap')),
                    NavigationRailDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category), label: Text('Master')),
                    NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pages[_idx]),
              ],
            ),
          );
        }
        // App layout: Bottom nav
        return Scaffold(
          body: pages[_idx],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _idx,
            onDestinationSelected: (i) => setState(() => _idx = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
              NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: 'Jurnal'),
              NavigationDestination(icon: Icon(Icons.assessment_outlined), selectedIcon: Icon(Icons.assessment), label: 'Rekap'),
              NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category), label: 'Master'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardTab extends StatefulWidget {
  final AppDatabase db;
  final SyncService sync;
  final String log;
  const _DashboardTab({required this.db, required this.sync, required this.log});
  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  int _refresh = 0;
  Future<void> _doSync() async {
    final hasAccess = await widget.sync.tokenStorage.hasValidAccessToken();
    final online = await widget.sync.connectivity.isOnline;
    final pending = await widget.db.queueCount();
    debugPrint('Dashboard sync: online=$online hasAccess=$hasAccess pending=$pending');
    final ok = await widget.sync.trySync();
    final msg = ok ? 'Sync OK' : 'Sync gagal: online=$online access=$hasAccess pending=$pending -> cek BE http://10.39.48.26:8080';
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: ok ? Colors.green : Colors.red));
    setState(() => _refresh++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Keuskupan Labuan Bajo', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text('Sistem pembukuan offline-first untuk wilayah internet susah. Data tersimpan di SQLite lokal, sync otomatis saat online.'),
                    if (widget.log.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(widget.log, style: const TextStyle(color: Colors.blue, fontSize: 12))),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder(
                key: ValueKey(_refresh),
                future: Future.wait([
                  widget.db.customSelect('SELECT COUNT(*) as c FROM jurnals WHERE deleted_at IS NULL').getSingle(),
                  widget.db.queueCount(),
                ]),
                builder: (c, snap) {
                  final rows = snap.data as List?;
                  final count = rows != null ? (rows[0] as QueryRow).data['c'] as int : 0;
                  final pending = rows != null ? rows[1] as int : 0;
                  return Card(
                    child: ListTile(
                      leading: Icon(pending == 0 ? Icons.cloud_done : Icons.cloud_upload, color: pending == 0 ? Colors.green : Colors.orange),
                      title: Text('$count Jurnal tersimpan (lokal)'),
                      subtitle: Text('Pending sync: $pending'),
                      trailing: IconButton(icon: const Icon(Icons.sync), onPressed: _doSync),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const _DashboardCharts(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCharts extends StatelessWidget {
  const _DashboardCharts();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        // total debit/kredit dari detil_jurnals (YYYY-MM-DD TEXT)
        Future(() async {
          final db = AppDatabase();
          final r = await db.customSelect('SELECT COALESCE(SUM(debit),0) as d, COALESCE(SUM(kredit),0) as k FROM detil_jurnals WHERE deleted_at IS NULL').getSingle();
          await db.close();
          return r;
        }),
      ]),
      builder: (c, snap) {
        if (!snap.hasData) return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
        // ponytail: pakai fl_chart BarChart sederhana, data dari detil_jurnals
        return Column(
          children: [
            _ChartCard(title: 'Ringkasan Keuangan', child: _BarChart()),
            const SizedBox(height: 12),
            _ChartCard(title: 'Tren Bulanan', child: _LineChart()),
          ],
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(height: 180, child: child),
        ]),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ponytail: fl_chart BarChart 2 bar: Debit vs Kredit, data real dari recap jika ada, fallback 0
    return FutureBuilder(
      future: AppDatabase().customSelect('SELECT COALESCE(SUM(debit),0) as d, COALESCE(SUM(kredit),0) as k FROM detil_jurnals WHERE deleted_at IS NULL').getSingle().then((r) => [r.data['d'] as num, r.data['k'] as num]),
      builder: (c, snap) {
        final d = snap.data != null ? (snap.data![0] as num).toDouble() : 0.0;
        final k = snap.data != null ? (snap.data![1] as num).toDouble() : 0.0;
        final maxY = (d > k ? d : k) * 1.2 + 1000;
        return _BarChartView(debit: d, kredit: k, maxY: maxY == 0 ? 10000.0 : maxY);
      },
    );
  }
}

class _BarChartView extends StatelessWidget {
  final double debit, kredit, maxY;
  const _BarChartView({required this.debit, required this.kredit, required this.maxY});
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: debit, color: Colors.blue, width: 32, borderRadius: BorderRadius.circular(4))]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: kredit, color: Colors.green, width: 32, borderRadius: BorderRadius.circular(4))]),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(v == 0 ? 'Debit' : 'Kredit', style: const TextStyle(fontSize: 11)))),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 60, getTitlesWidget: (v, _) => Text('${(v / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 9)))),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Grafik tren bulanan akan muncul setelah ada data\n(6 bulan terakhir)', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)));
  }
}

class _SettingsTab extends StatefulWidget {
  final AppDatabase db;
  final SyncService sync;
  final TokenStorageI tokens;
  final ValueChanged<String> onLog;
  const _SettingsTab({required this.db, required this.sync, required this.tokens, required this.onLog});
  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  String _status = '';
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final hasAccess = await widget.tokens.hasValidAccessToken();
    final pending = await widget.db.queueCount();
    final online = await widget.sync.connectivity.isOnline;
    setState(() => _status = 'online=$online pending=$pending accessValid=$hasAccess');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(leading: const Icon(Icons.sync), title: const Text('Sync'), subtitle: Text(_status.isEmpty ? 'Otomatis saat online, retry 3x' : _status)),
              const ListTile(leading: Icon(Icons.security), title: Text('Auth'), subtitle: Text('JWT access 15m, refresh 7d, cek offline')),
              const ListTile(leading: Icon(Icons.storage), title: Text('Database'), subtitle: Text('drift SQLite (native) / IndexedDB+WASM (web)')),
              const Divider(),
              ElevatedButton.icon(icon: const Icon(Icons.sync), label: const Text('Sync Now'), onPressed: () async {
                final ok = await widget.sync.trySync();
                final msg = ok ? 'Sync berhasil' : 'Sync gagal: cek BE http://10.39.48.26:8080 + token';
                widget.onLog(msg);
                setState(() => _status = msg);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: ok ? Colors.green : Colors.red));
                _check();
              }),
              const SizedBox(height: 8),
              OutlinedButton.icon(icon: const Icon(Icons.bug_report), label: const Text('Cek BE'), onPressed: () async {
                final ok = await widget.sync.connectivity.isOnline;
                widget.onLog('isOnline=$ok');
                _check();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
