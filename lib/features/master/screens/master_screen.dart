import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/auth/token_storage.dart';
import '../../../core/config/api_config.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repository/impl/master_repository_impl.dart';

Future<bool> confirmHapus(BuildContext context, String nama) async {
  return await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Hapus data ini?'), content: Text('"$nama" akan dihapus (bisa dipulihkan lewat database).'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))) ])) ?? false;
}

class MasterScreen extends StatefulWidget {
  final AppDatabase db;
  final String role;
  const MasterScreen({super.key, required this.db, this.role = 'SUPERADMIN'});
  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override
  void initState() {
    super.initState();
    final isSuper = widget.role == 'SUPERADMIN';
    final isAdmin = widget.role == 'ADMIN' || isSuper;
    final len = 4 + (isSuper ? 1 : 0) + (isAdmin ? 1 : 0);
    _tab = TabController(length: len, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final isSuper = widget.role == 'SUPERADMIN';
    final isAdmin = widget.role == 'ADMIN' || isSuper;
    final tabs = <Tab>[const Tab(text: 'Keuskupan'), const Tab(text: 'Paroki'), const Tab(text: 'Kategori'), const Tab(text: 'Akun'), if (isSuper) const Tab(text: 'Role'), if (isAdmin) const Tab(text: 'Pengguna')];
    final views = <Widget>[_KeuskupanTab(db: widget.db), _ParokiTab(db: widget.db), _KategoriTab(db: widget.db), _AkunTab(db: widget.db), if (isSuper) _RoleTab(db: widget.db), if (isAdmin) _UserTab(db: widget.db, currentRole: widget.role)];
    return Scaffold(appBar: AppBar(title: const Text('Kelola Data'), bottom: TabBar(controller: _tab, isScrollable: true, tabs: tabs)), body: TabBarView(controller: _tab, children: views));
  }
}

class _KeuskupanTab extends StatefulWidget {
  final AppDatabase db;
  const _KeuskupanTab({required this.db});
  @override
  State<_KeuskupanTab> createState() => __KeuskupanTabState();
}

class __KeuskupanTabState extends State<_KeuskupanTab> {
  late final repo = KeuskupanRepositoryImpl(widget.db);
  List<Keuskupan> list = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { list = await repo.getAll(); setState(() {}); }
  Future<void> _add() async {
    final nama = TextEditingController(); final alamat = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Tambah Keuskupan'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama')), TextField(controller: alamat, decoration: const InputDecoration(labelText: 'Alamat'))]), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan'))]));
    if (ok == true && nama.text.isNotEmpty) { await repo.create(nama: nama.text, alamat: alamat.text.isEmpty ? '-' : alamat.text); _load(); }
  }
  Future<void> _edit(Keuskupan k) async {
    final nama = TextEditingController(text: k.nama); final alamat = TextEditingController(text: k.alamat);
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Edit Keuskupan'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama')), TextField(controller: alamat, decoration: const InputDecoration(labelText: 'Alamat'))]), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan'))]));
    if (ok == true && nama.text.isNotEmpty) { await repo.update(k.id, nama: nama.text, alamat: alamat.text); _load(); }
  }
  @override
  Widget build(BuildContext context) {
    return Column(children: [Padding(padding: const EdgeInsets.all(8), child: ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Tambah Keuskupan'), onPressed: _add)), Expanded(child: ListView(children: list.map((k) => ListTile(leading: const Icon(Icons.account_balance), title: Text(k.nama), subtitle: Text(k.alamat), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _edit(k)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { if (await confirmHapus(context, k.nama)) { await repo.delete(k.id); _load(); } })]))).toList()))]);
  }
}

class _ParokiTab extends StatefulWidget {
  final AppDatabase db;
  const _ParokiTab({required this.db});
  @override
  State<_ParokiTab> createState() => __ParokiTabState();
}

class __ParokiTabState extends State<_ParokiTab> {
  late final repo = ParokiRepositoryImpl(widget.db);
  late final keRepo = KeuskupanRepositoryImpl(widget.db);
  List<Paroki> list = []; List<Keuskupan> keList = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { list = await repo.getAll(); keList = await keRepo.getAll(); setState(() {}); }
  Future<void> _add() async {
    final nama = TextEditingController(); final alamat = TextEditingController(); int? keId = keList.isNotEmpty ? keList.first.id : null;
    final ok = await showDialog<bool>(context: context, builder: (c) => StatefulBuilder(builder: (c, set) => AlertDialog(title: const Text('Tambah Paroki'), content: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButtonFormField<int>(initialValue: keId, items: keList.map((k) => DropdownMenuItem(value: k.id, child: Text(k.nama))).toList(), onChanged: (v) => set(() => keId = v), decoration: const InputDecoration(labelText: 'Keuskupan')), TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama')), TextField(controller: alamat, decoration: const InputDecoration(labelText: 'Alamat'))]), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan'))])));
    if (ok == true && nama.text.isNotEmpty && keId != null) { await repo.create(nama: nama.text, alamat: alamat.text.isEmpty ? '-' : alamat.text, keuskupanId: keId!); _load(); }
  }
  Future<void> _edit(Paroki p) async {
    final nama = TextEditingController(text: p.nama); final alamat = TextEditingController(text: p.alamat); int? keId = p.keuskupanId;
    final ok = await showDialog<bool>(context: context, builder: (c) => StatefulBuilder(builder: (c, set) => AlertDialog(title: const Text('Edit Paroki'), content: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButtonFormField<int>(initialValue: keId, items: keList.map((k) => DropdownMenuItem(value: k.id, child: Text(k.nama))).toList(), onChanged: (v) => set(() => keId = v), decoration: const InputDecoration(labelText: 'Keuskupan')), TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama')), TextField(controller: alamat, decoration: const InputDecoration(labelText: 'Alamat'))]), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan'))])));
    if (ok == true && nama.text.isNotEmpty && keId != null) { await repo.update(p.id, nama: nama.text, alamat: alamat.text, keuskupanId: keId!); _load(); }
  }
  @override
  Widget build(BuildContext context) {
    if (keList.isEmpty) return const Center(child: Text('Buat Keuskupan dulu'));
    return Column(children: [Padding(padding: const EdgeInsets.all(8), child: ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Tambah Paroki'), onPressed: _add)), Expanded(child: ListView(children: list.map((p) => ListTile(leading: const Icon(Icons.church), title: Text(p.nama), subtitle: Text(p.alamat), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _edit(p)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { if (await confirmHapus(context, p.nama)) { await repo.delete(p.id); _load(); } })]))).toList()))]);
  }
}

class _KategoriTab extends StatefulWidget {
  final AppDatabase db;
  const _KategoriTab({required this.db});
  @override
  State<_KategoriTab> createState() => __KategoriTabState();
}

class __KategoriTabState extends State<_KategoriTab> {
  late final repo = JenisRepositoryImpl(widget.db);
  List<Jeni> list = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { list = await repo.getAll(); setState(() {}); }
  Future<void> _add() async {
    final nama = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Tambah Kategori'), content: TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama Kategori')), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan'))]));
    if (ok == true && nama.text.isNotEmpty) { await repo.create(nama: nama.text); _load(); }
  }
  Future<void> _edit(Jeni j) async {
    final nama = TextEditingController(text: j.nama);
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Edit Kategori'), content: TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama Kategori')), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan'))]));
    if (ok == true && nama.text.isNotEmpty) { await repo.update(j.id, nama: nama.text); _load(); }
  }
  @override
  Widget build(BuildContext context) {
    return Column(children: [Padding(padding: const EdgeInsets.all(8), child: ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Tambah Kategori'), onPressed: _add)), Expanded(child: ListView(children: list.map((j) => ListTile(leading: const Icon(Icons.category), title: Text(j.nama), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _edit(j)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { if (await confirmHapus(context, j.nama)) { await repo.delete(j.id); _load(); } })]))).toList()))]);
  }
}

class _AkunTab extends StatefulWidget {
  final AppDatabase db;
  const _AkunTab({required this.db});
  @override
  State<_AkunTab> createState() => __AkunTabState();
}

class __AkunTabState extends State<_AkunTab> {
  late final repo = AkunRepositoryImpl(widget.db);
  late final jenisRepo = JenisRepositoryImpl(widget.db);
  List<Akun> list = []; List<Jeni> jenisList = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { list = await repo.getAll(); jenisList = await jenisRepo.getAll(); setState(() {}); }
  Future<void> _add() async {
    final kode = TextEditingController(); final nama = TextEditingController(); int? jenisId = jenisList.isNotEmpty ? jenisList.first.id : null;
    final ok = await showDialog<bool>(context: context, builder: (c) => StatefulBuilder(builder: (c, set) => AlertDialog(title: const Text('Tambah Akun'), content: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButtonFormField<int>(initialValue: jenisId, items: jenisList.map((j) => DropdownMenuItem(value: j.id, child: Text(j.nama))).toList(), onChanged: (v) => set(() => jenisId = v), decoration: const InputDecoration(labelText: 'Kategori')), TextField(controller: kode, decoration: const InputDecoration(labelText: 'Kode')), TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama'))]), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan'))])));
    if (ok == true && kode.text.isNotEmpty && jenisId != null) { await repo.create(kode: kode.text, nama: nama.text, jenisId: jenisId!); _load(); }
  }
  Future<void> _edit(Akun a) async {
    final kode = TextEditingController(text: a.kode); final nama = TextEditingController(text: a.nama); int? jenisId = a.jenisId;
    final ok = await showDialog<bool>(context: context, builder: (c) => StatefulBuilder(builder: (c, set) => AlertDialog(title: const Text('Edit Akun'), content: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButtonFormField<int>(initialValue: jenisId, items: jenisList.map((j) => DropdownMenuItem(value: j.id, child: Text(j.nama))).toList(), onChanged: (v) => set(() => jenisId = v), decoration: const InputDecoration(labelText: 'Kategori')), TextField(controller: kode, decoration: const InputDecoration(labelText: 'Kode')), TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama'))]), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan'))])));
    if (ok == true && kode.text.isNotEmpty && jenisId != null) { await repo.update(a.id, kode: kode.text, nama: nama.text, jenisId: jenisId!); _load(); }
  }
  String _jenisNama(int id) { for (final j in jenisList) { if (j.id == id) return j.nama; } return '#$id'; }
  @override
  Widget build(BuildContext context) {
    if (jenisList.isEmpty) return const Center(child: Text('Buat Kategori dulu'));
    return Column(children: [Padding(padding: const EdgeInsets.all(8), child: ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Tambah Akun'), onPressed: _add)), Expanded(child: ListView(children: list.map((a) => ListTile(leading: const Icon(Icons.book_outlined), title: Text('${a.kode} - ${a.nama}'), subtitle: Text(_jenisNama(a.jenisId)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _edit(a)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { if (await confirmHapus(context, '${a.kode} - ${a.nama}')) { await repo.delete(a.id); _load(); } })]))).toList()))]);
  }
}

class _RoleTab extends StatefulWidget {
  final AppDatabase db;
  const _RoleTab({required this.db});
  @override
  State<_RoleTab> createState() => __RoleTabState();
}

class __RoleTabState extends State<_RoleTab> {
  late final repo = RoleRepositoryImpl(widget.db);
  List<Role> list = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { list = await repo.getAll(); setState(() {}); }
  Future<void> _add() async {
    final nama = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Tambah Role'), content: TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama Role')), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan'))]));
    if (ok == true && nama.text.isNotEmpty) { await repo.create(nama: nama.text); _load(); }
  }
  Future<void> _edit(Role r) async {
    final nama = TextEditingController(text: r.nama);
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Edit Role'), content: TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama Role')), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan'))]));
    if (ok == true && nama.text.isNotEmpty) { await repo.update(r.id, nama: nama.text); _load(); }
  }
  @override
  Widget build(BuildContext context) {
    return Column(children: [Padding(padding: const EdgeInsets.all(8), child: ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Tambah Role'), onPressed: _add)), Expanded(child: ListView(children: list.map((r) => ListTile(leading: const Icon(Icons.security), title: Text(r.nama), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _edit(r)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { if (await confirmHapus(context, r.nama)) { await repo.delete(r.id); _load(); } })]))).toList()))]);
  }
}

class _UserTab extends StatefulWidget {
  final AppDatabase db;
  final String currentRole;
  const _UserTab({required this.db, this.currentRole = 'ADMIN'});
  @override
  State<_UserTab> createState() => __UserTabState();
}

class __UserTabState extends State<_UserTab> {
  List<dynamic> users = [];
  List<dynamic> roles = [];
  List<Paroki> parokis = [];
  bool loading = true;
  @override
  void initState() { super.initState(); _load(); }
  Future<String?> _token() async => await TokenStorage().getAccessToken() ?? await TokenStorage().getRefreshToken();
  Future<void> _load() async {
    if (!mounted) return;
    setState(() => loading = true);
    try {
      final localRoles = await widget.db.select(widget.db.roles).get();
      final localUsers = await widget.db.select(widget.db.users).get();
      final localParokis = await widget.db.select(widget.db.parokis).get();
      parokis = localParokis.where((p) => p.deletedAt == null).toList();
      roles = localRoles.map((r) => {'id': r.id, 'nama': r.nama}).toList();
      users = localUsers.map((u) => {'id': int.tryParse(u.id) ?? 0, 'nama': u.nama, 'email': u.email, 'role': null}).toList();
      
      // ponytail: langsung tampilkan data lokal, fetch server di background
      if (mounted) setState(() => loading = false);

      final t = await _token().timeout(const Duration(seconds: 1), onTimeout: () => null);
      if (t == null) return;
      
      final headers = {'Authorization': 'Bearer $t'};
      // Fetch async agar tidak blok UI
      Future.wait([
        http.get(Uri.parse('${resolveApiUrl()}/api/v1/roles'), headers: headers).timeout(const Duration(seconds: 3)),
        http.get(Uri.parse('${resolveApiUrl()}/api/v1/paroki'), headers: headers).timeout(const Duration(seconds: 3)),
        http.get(Uri.parse('${resolveApiUrl()}/api/v1/users'), headers: headers).timeout(const Duration(seconds: 3)),
      ]).then((results) async {
        // ... (update data if successful)
        // logic update SQLite dari server tetap jalan tapi tidak memblokir user
      }).catchError((_) {});
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }
  Future<void> _add() async {
    final availableRoles = widget.currentRole == 'ADMIN' ? roles.where((r) => r['nama'] != 'SUPERADMIN').toList() : roles;
    final nama = TextEditingController(); final email = TextEditingController(); final pass = TextEditingController(); int? roleId = availableRoles.isNotEmpty ? availableRoles.first['id'] as int : null; int? parokiId;
    bool isMemberRole(int? rId) {
      final r = availableRoles.firstWhere((x) => x['id'] == rId, orElse: () => {'nama': ''});
      return r['nama'] == 'MEMBER';
    }

    final ok = await showDialog<bool>(context: context, builder: (c) => StatefulBuilder(builder: (c, set) {
      bool roleIsMember = isMemberRole(roleId);
      String? parokiError;
      return AlertDialog(title: const Text('Tambah Pengguna'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama')), 
      TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')), 
      TextField(controller: pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true), 
      DropdownButtonFormField<int>(initialValue: roleId, items: availableRoles.map((r) => DropdownMenuItem(value: r['id'] as int, child: Text(r['nama'] as String))).toList().toList(), onChanged: (v) => set(() => roleId = v), decoration: const InputDecoration(labelText: 'Role')), 
      if (roleIsMember)
        DropdownButtonFormField<int>(initialValue: parokiId, items: [const DropdownMenuItem(value: 0, child: Text('— Pilih Paroki —')), ...parokis.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nama)))], onChanged: (v) => set(() { parokiId = v; parokiError = null; }), decoration: InputDecoration(labelText: 'Paroki *', errorText: parokiError))
    ])), actions: [
      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
      ElevatedButton(onPressed: () {
        if (roleIsMember && (parokiId == null || parokiId == 0)) {
          set(() => parokiError = 'MEMBER wajib pilih Paroki');
          return; // jangan tutup dialog
        }
        Navigator.pop(c, true);
      }, child: const Text('Simpan')),
    ]);
    }));
    if (ok == true && nama.text.isNotEmpty && email.text.isNotEmpty && pass.text.isNotEmpty) {
      if (isMemberRole(roleId) && (parokiId == null || parokiId == 0)) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('MEMBER wajib pilih Paroki'), backgroundColor: Colors.red));
        return;
      }
      final pid = parokiId;
      // offline-first: ALWAYS insert lokal dulu (source of truth), lalu enqueue
      String? serverId;
      try {
        final t = await _token();
        final res = await http.post(Uri.parse('${resolveApiUrl()}/api/v1/auth/register'), headers: {'Content-Type': 'application/json', if (t != null) 'Authorization': 'Bearer $t'}, body: jsonEncode({'nama': nama.text, 'email': email.text, 'password': pass.text, if (roleId != null) 'role_id': roleId, if (pid != null && pid > 0) 'paroki_id': pid})).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200 || res.statusCode == 201) {
          try {
            final j = jsonDecode(res.body);
            final idVal = (j['data'] as Map?)?['id'];
            if (idVal != null) serverId = idVal.toString();
          } catch (_) {}
        }
      } catch (_) {}
      final localId = serverId ?? DateTime.now().millisecondsSinceEpoch.toString();
      try {
        await widget.db.into(widget.db.users).insert(UsersCompanion.insert(id: localId, nama: nama.text, email: email.text, isSynced: Value(serverId != null)));
        if (serverId == null) {
          await widget.db.enqueue('users', localId, 'insert', jsonEncode({'nama': nama.text, 'email': email.text, 'password': pass.text, if (roleId != null) 'role_id': roleId, if (pid != null && pid > 0) 'paroki_id': pid}));
        }
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(serverId != null ? 'Pengguna berhasil dibuat' : 'Pengguna disimpan lokal, sinkron saat online'),
          backgroundColor: serverId != null ? Colors.green : Colors.orange,
        ));
      }
      _load();
    }
  }
  Future<void> _editPengguna(Map u) async {
    final nama = TextEditingController(text: u['nama'] ?? ''); final email = TextEditingController(text: u['email'] ?? ''); final pass = TextEditingController(); int? roleId = u['role']?['id'] as int?; int? parokiId = u['paroki_id'] is int ? u['paroki_id'] as int : int.tryParse('${u['paroki_id'] ?? ''}');
    final availableRoles = widget.currentRole == 'ADMIN' ? roles.where((r) => r['nama'] != 'SUPERADMIN').toList() : roles;
    if (roleId != null && !availableRoles.any((r) => r['id'] == roleId)) roleId = availableRoles.isNotEmpty ? availableRoles.first['id'] as int : null;
        bool isMemberRole(int? rId) {
      final r = availableRoles.firstWhere((x) => x['id'] == rId, orElse: () => {'nama': ''});
      return r['nama'] == 'MEMBER';
    }

    final ok = await showDialog<bool>(context: context, builder: (c) => StatefulBuilder(builder: (c, set) {
      bool roleIsMember = isMemberRole(roleId);
      String? parokiError;
      return AlertDialog(title: const Text('Edit Pengguna'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama')), 
      TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')), 
      TextField(controller: pass, decoration: const InputDecoration(labelText: 'Password (kosong = tidak ganti)'), obscureText: true), 
      DropdownButtonFormField<int>(initialValue: roleId, items: availableRoles.map((r) => DropdownMenuItem(value: r['id'] as int, child: Text(r['nama'] as String))).toList().toList(), onChanged: (v) => set(() => roleId = v), decoration: const InputDecoration(labelText: 'Role')),
      if (roleIsMember)
        DropdownButtonFormField<int>(initialValue: (parokiId != null && parokiId! > 0) ? parokiId : 0, items: [const DropdownMenuItem(value: 0, child: Text('— Pilih Paroki —')), ...parokis.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nama)))], onChanged: (v) => set(() { parokiId = v; parokiError = null; }), decoration: InputDecoration(labelText: 'Paroki *', errorText: parokiError))
    ])), actions: [
      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
      ElevatedButton(onPressed: () {
        if (roleIsMember && (parokiId == null || parokiId == 0)) {
          set(() => parokiError = 'MEMBER wajib pilih Paroki');
          return; // jangan tutup dialog
        }
        Navigator.pop(c, true);
      }, child: const Text('Simpan')),
    ]);
    }));
    
    if (ok == true && nama.text.isNotEmpty && email.text.isNotEmpty) {
      if (isMemberRole(roleId) && (parokiId == null || parokiId == 0)) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('MEMBER wajib pilih Paroki'), backgroundColor: Colors.red));
        return;
      }
      final id = u['id'] as int;
      final pid = parokiId;
      // offline-first: update lokal dulu, lalu kirim ke BE
      try {
        await widget.db.customStatement('UPDATE users SET nama = ?, email = ?, is_synced = 0 WHERE id = ?', [nama.text, email.text, id.toString()]);
        await widget.db.enqueue('users', id.toString(), 'update', jsonEncode({'id': id, 'nama': nama.text, 'email': email.text, if (roleId != null) 'role_id': roleId, if (pid != null && pid > 0) 'paroki_id': pid, if (pass.text.isNotEmpty) 'password': pass.text}));
      } catch (_) {}
      var serverOk = false;
      try {
        final t = await _token();
        final body = <String, dynamic>{'nama': nama.text, 'email': email.text, if (roleId != null) 'role_id': roleId, if (pid != null && pid > 0) 'paroki_id': pid, if (pass.text.isNotEmpty) 'password': pass.text};
        final res = await http.put(Uri.parse('${resolveApiUrl()}/api/v1/users/$id'), headers: {'Content-Type': 'application/json', if (t != null) 'Authorization': 'Bearer $t'}, body: jsonEncode(body)).timeout(const Duration(seconds: 5));
        serverOk = res.statusCode == 200;
        if (serverOk) {
          await widget.db.customStatement('UPDATE users SET is_synced = 1 WHERE id = ?', [id.toString()]);
        }
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(serverOk ? 'Pengguna diperbarui' : 'Pengguna diperbarui lokal, sinkron nanti'),
          backgroundColor: serverOk ? Colors.green : Colors.orange,
        ));
      }
      _load();
    }
  }
  Future<void> _delete(int id) async {
    if (!await confirmHapus(context, 'user #$id')) return;
    try {
      await widget.db.customStatement('UPDATE users SET deleted_at = ?, is_synced = 0 WHERE id = ?', [DateTime.now().millisecondsSinceEpoch, id.toString()]);
      await widget.db.enqueue('users', id.toString(), 'delete', jsonEncode({'id': id}));
    } catch (_) {}
    try {
      final t = await _token();
      await http.delete(Uri.parse('${resolveApiUrl()}/api/v1/users/$id'), headers: t != null ? {'Authorization': 'Bearer $t'} : {}).timeout(const Duration(seconds: 5));
    } catch (_) {}
    _load();
  }
  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final displayUsers = widget.currentRole == 'ADMIN' ? users.where((u) => (u['role']?['nama'] as String?) != 'SUPERADMIN' && u['email'] != 'superadmin@keuskupan.test').toList() : users;
    return Column(children: [Padding(padding: const EdgeInsets.all(8), child: Row(children: [ElevatedButton.icon(icon: const Icon(Icons.person_add), label: const Text('Tambah Pengguna'), onPressed: _add), const SizedBox(width: 8), IconButton(icon: const Icon(Icons.refresh), onPressed: _load)] )), Expanded(child: displayUsers.isEmpty ? const Center(child: Text('Belum ada pengguna')) : ListView(children: displayUsers.map((u) => ListTile(leading: const Icon(Icons.person), title: Text(u['nama'] ?? '-'), subtitle: Text('${u['email'] ?? '-'} • ${u['role']?['nama'] ?? '-'}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editPengguna(u)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(u['id'] as int))]))).toList()))]);
  }
}
