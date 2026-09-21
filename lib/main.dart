import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'core/auth/jwt_helper.dart';
import 'core/auth/token_storage.dart';
import 'core/config/api_config.dart';
import 'core/network/connectivity_service.dart';
import 'core/sync/sync_service.dart';
import 'core/theme.dart';
import 'data/local/app_database.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/jurnal/screens/jurnal_list_screen.dart';
import 'features/recap/widgets/recap_widgets.dart';
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
      theme: appTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final TokenStorageI _tokens = TokenStorage();
  late Future<bool> _hasSession = _check();
  Future<bool> _check() async => await _tokens.hasValidAccessToken() || await _tokens.hasValidRefreshToken();
  void _refresh() => setState(() { _hasSession = _check(); });
  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(future: _hasSession, builder: (c, s) { if (!s.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator())); return s.data! ? HomeTabs(onLogout: _refresh) : LoginScreen(tokens: _tokens, baseUrl: resolveApiUrl(), onSuccess: _refresh); });
}

class HomeTabs extends StatefulWidget {
  final VoidCallback? onLogout;
  const HomeTabs({super.key, this.onLogout});
  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> with WidgetsBindingObserver {
  int _idx = 0;
  late final AppDatabase _db = AppDatabase();
  late final TokenStorageI _tokens = TokenStorage();
  late final ConnectivityService _conn = ConnectivityService();
  late final SyncService _sync = SyncService(
    db: _db,
    tokenStorage: _tokens,
    connectivity: _conn,
    baseUrl: resolveApiUrl(),
    pushToServer: SyncService.defaultPush(resolveApiUrl()),
  );
  String _syncLog = '';
  bool _initialSyncDone = false;
  String _role = 'MEMBER';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sync.start();
    _loadRole().then((_) => _doInitialSync());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _sync.trySync();
  }

  Future<void> _loadRole() async {
    try {
      final t = await _tokens.getAccessToken();
      String newRole = 'MEMBER';
      if (t != null) {
        final payload = JwtHelper.decodePayload(t);
        final r = (payload['role'] as String?)?.toUpperCase();
        if (r != null && r.isNotEmpty) newRole = r;
      }
      if (newRole != _role) {
        if (mounted) setState(() => _role = newRole);
        else _role = newRole;
      }
    } catch (_) {
      if (_role != 'MEMBER' && mounted) setState(() => _role = 'MEMBER');
    }
  }

  Future<void> _doInitialSync() async {
    if (await _conn.isOnline) {
      final ok = await _sync.trySync();
      if (mounted) setState(() { _initialSyncDone = true; _syncLog = ok ? 'Auto-pull OK' : 'Auto-pull gagal (offline mode)'; });
    } else {
      if (mounted) setState(() { _initialSyncDone = true; _syncLog = 'Offline mode - data lokal'; });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sync.stop();
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMember = _role == 'MEMBER';
    final pages = <Widget>[
      DashboardScreen(db: _db, sync: _sync, log: _syncLog, role: _role, onNavigate: (i) => setState(() => _idx = i)),
      JurnalListScreen(db: _db, tokenStorage: _tokens),
      RecapKeuskupanScreen(db: _db, tokenStorage: _tokens),
      if (!isMember) MasterScreen(db: _db, role: _role),
      _ProfilTab(role: _role, onLogout: widget.onLogout),
    ];
    if (_idx >= pages.length) _idx = pages.length - 1;
    final railDests = <NavigationRailDestination>[
      const NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Beranda')),
      const NavigationRailDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: Text('Jurnal')),
      const NavigationRailDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: Text('Rekap')),
      if (!isMember) const NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Kelola Data')),
      const NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profil')),
    ];
    final barDests = <NavigationDestination>[
      const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
      const NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: 'Jurnal'),
      const NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Rekap'),
      if (!isMember) const NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Kelola Data'),
      const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
    ];
    return Stack(children: [
      LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        if (isWide) {
          return Scaffold(body: Row(children: [NavigationRail(selectedIndex: _idx, onDestinationSelected: (i) => setState(() => _idx = i), labelType: NavigationRailLabelType.all, destinations: railDests), const VerticalDivider(width: 1), Expanded(child: pages[_idx])]));
        }
        return Scaffold(body: pages[_idx], bottomNavigationBar: NavigationBar(selectedIndex: _idx, onDestinationSelected: (i) => setState(() => _idx = i), destinations: barDests));
      }),
      if (!_initialSyncDone) Container(color: Colors.white, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 96, height: 96, decoration: const BoxDecoration(shape: BoxShape.circle, color: ungu), child: const Icon(Icons.church, color: Colors.white, size: 48)), const SizedBox(height: 24), const Text('Keuskupan Labuan Bajo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText)), const SizedBox(height: 16), const CircularProgressIndicator(), const SizedBox(height: 12), Text(_syncLog.isEmpty ? 'Memuat data...' : _syncLog, style: const TextStyle(color: Colors.grey, fontSize: 13))]))),
    ]);
  }
}

class _ProfilTab extends StatelessWidget {
  final String role;
  final VoidCallback? onLogout;
  const _ProfilTab({this.role = 'MEMBER', this.onLogout});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [const Icon(Icons.person, color: ungu), const SizedBox(width: 8), Text('Role saat ini: $role', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                      const SizedBox(height: 8),
                      Text(role == 'SUPERADMIN' ? 'SUPERADMIN: kelola Role + User + Master' : role == 'ADMIN' ? 'ADMIN: kelola User + Master (tanpa Role)' : 'MEMBER: hanya Jurnal/Rekap + Export', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ]))),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: FilledButton.icon(icon: const Icon(Icons.logout), label: const Text('Keluar'), style: FilledButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: () async { await TokenStorage().clear(); await Future.delayed(const Duration(milliseconds: 100)); if (onLogout != null) onLogout!(); else if (context.mounted) { Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthGate()), (_) => false); } })),

          ]),
        ),
      ),
    );
  }
}

class _SettingsTab extends StatefulWidget {
  final AppDatabase db;
  final SyncService sync;
  final TokenStorageI tokens;
  const _SettingsTab({required this.db, required this.sync, required this.tokens});
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
              const ListTile(leading: Icon(Icons.security), title: Text('Auth'), subtitle: Text('JWT access 1 tahun, cek offline')),
              const ListTile(leading: Icon(Icons.storage), title: Text('Database'), subtitle: Text('drift SQLite (native) / IndexedDB+WASM (web)')),
              const Divider(),
              ElevatedButton.icon(icon: const Icon(Icons.sync), label: const Text('Sync Now'), onPressed: () async {
                final ok = await widget.sync.trySync();
                final msg = ok ? 'Sync berhasil' : 'Sync gagal: cek koneksi internet';
                setState(() { _status = msg; });
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: ok ? Colors.green : Colors.red));
                _check();
              }),
            ],
          ),
        ),
      ),
    );
  }
}

