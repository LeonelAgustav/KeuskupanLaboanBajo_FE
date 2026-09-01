import 'package:flutter/material.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repository/impl/master_repository_impl.dart';

class MasterScreen extends StatefulWidget {
  final AppDatabase db;
  const MasterScreen({super.key, required this.db});
  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master Data'), bottom: TabBar(controller: _tab, tabs: const [Tab(text: 'Keuskupan'), Tab(text: 'Paroki'), Tab(text: 'Jenis'), Tab(text: 'Akun')])),
      body: TabBarView(controller: _tab, children: [
        _KeuskupanTab(db: widget.db),
        _ParokiTab(db: widget.db),
        _JenisTab(db: widget.db),
        _AkunTab(db: widget.db),
      ]),
    );
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
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    list = await repo.getAll();
    setState(() {});
  }

  Future<void> _add() async {
    final nama = TextEditingController();
    final alamat = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Tambah Keuskupan'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama')), TextField(controller: alamat, decoration: const InputDecoration(labelText: 'Alamat'))]), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan'))]));
    if (ok == true && nama.text.isNotEmpty) {
      await repo.create(nama: nama.text, alamat: alamat.text.isEmpty ? '-' : alamat.text);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.all(8), child: ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Tambah Keuskupan'), onPressed: _add)),
      Expanded(child: ListView(children: list.map((k) => ListTile(title: Text(k.nama), subtitle: Text(k.alamat), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { await repo.delete(k.id); _load(); }))).toList())),
    ]);
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
  List<Paroki> list = [];
  List<Keuskupan> keList = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    list = await repo.getAll();
    keList = await keRepo.getAll();
    setState(() {});
  }

  Future<void> _add() async {
    final nama = TextEditingController();
    final alamat = TextEditingController();
    String? keId = keList.isNotEmpty ? keList.first.id : null;
    final ok = await showDialog<bool>(context: context, builder: (c) => StatefulBuilder(builder: (c, set) => AlertDialog(title: const Text('Tambah Paroki'), content: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButtonFormField<String>(value: keId, items: keList.map((k) => DropdownMenuItem(value: k.id, child: Text(k.nama))).toList(), onChanged: (v) => set(() => keId = v), decoration: const InputDecoration(labelText: 'Keuskupan')), TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama')), TextField(controller: alamat, decoration: const InputDecoration(labelText: 'Alamat'))]), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan'))])));
    if (ok == true && nama.text.isNotEmpty && keId != null) {
      await repo.create(nama: nama.text, alamat: alamat.text.isEmpty ? '-' : alamat.text, keuskupanId: keId!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (keList.isEmpty) return const Center(child: Text('Buat Keuskupan dulu'));
    return Column(children: [
      Padding(padding: const EdgeInsets.all(8), child: ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Tambah Paroki'), onPressed: _add)),
      Expanded(child: ListView(children: list.map((p) => ListTile(title: Text(p.nama), subtitle: Text(p.alamat), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { await repo.delete(p.id); _load(); }))).toList())),
    ]);
  }
}

class _JenisTab extends StatefulWidget {
  final AppDatabase db;
  const _JenisTab({required this.db});
  @override
  State<_JenisTab> createState() => __JenisTabState();
}

class __JenisTabState extends State<_JenisTab> {
  late final repo = JenisRepositoryImpl(widget.db);
  List<Jeni> list = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    list = await repo.getAll();
    setState(() {});
  }

  Future<void> _add() async {
    final nama = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Tambah Jenis'), content: TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama Jenis')), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan'))]));
    if (ok == true && nama.text.isNotEmpty) {
      await repo.create(nama: nama.text);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.all(8), child: ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Tambah Jenis'), onPressed: _add)),
      Expanded(child: ListView(children: list.map((j) => ListTile(title: Text(j.nama), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { await repo.delete(j.id); _load(); }))).toList())),
    ]);
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
  List<Akun> list = [];
  List<Jeni> jenisList = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    list = await repo.getAll();
    jenisList = await jenisRepo.getAll();
    setState(() {});
  }

  Future<void> _add() async {
    final kode = TextEditingController();
    final nama = TextEditingController();
    String? jenisId = jenisList.isNotEmpty ? jenisList.first.id : null;
    final ok = await showDialog<bool>(context: context, builder: (c) => StatefulBuilder(builder: (c, set) => AlertDialog(title: const Text('Tambah Akun'), content: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButtonFormField<String>(value: jenisId, items: jenisList.map((j) => DropdownMenuItem(value: j.id, child: Text(j.nama))).toList(), onChanged: (v) => set(() => jenisId = v), decoration: const InputDecoration(labelText: 'Jenis')), TextField(controller: kode, decoration: const InputDecoration(labelText: 'Kode')), TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama'))]), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Simpan'))])));
    if (ok == true && kode.text.isNotEmpty && jenisId != null) {
      await repo.create(kode: kode.text, nama: nama.text, jenisId: jenisId!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (jenisList.isEmpty) return const Center(child: Text('Buat Jenis dulu'));
    return Column(children: [
      Padding(padding: const EdgeInsets.all(8), child: ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Tambah Akun'), onPressed: _add)),
      Expanded(child: ListView(children: list.map((a) => ListTile(title: Text('${a.kode} - ${a.nama}'), subtitle: Text(a.jenisId), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { await repo.delete(a.id); _load(); }))).toList())),
    ]);
  }
}
