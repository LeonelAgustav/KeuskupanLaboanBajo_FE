import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import '../../../data/local/app_database.dart';
import '../cubit/jurnal_cubit.dart';

class JurnalFormScreen extends StatefulWidget {
  final List<Keuskupan> keuskupans;
  final JurnalCubit cubit;
  const JurnalFormScreen({super.key, required this.keuskupans, required this.cubit});
  @override
  State<JurnalFormScreen> createState() => _JurnalFormScreenState();
}

class _DetilForm {
  String? akunId;
  String? parokiId;
  final debitCtrl = TextEditingController();
  final kreditCtrl = TextEditingController();
  final ketCtrl = TextEditingController();
}

class _JurnalFormScreenState extends State<JurnalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _keuskupanId;
  DateTime _tanggal = DateTime.now();
  final _deskripsiCtrl = TextEditingController();
  final _noBuktiCtrl = TextEditingController();
  bool _saving = false;
  List<Akun> _akuns = [];
  List<Paroki> _parokis = [];
  bool _loadingMaster = true;
  final List<_DetilForm> _detils = [_DetilForm()];

  @override
  void initState() {
    super.initState();
    _loadMaster();
  }

  Future<void> _loadMaster() async {
    final akuns = await widget.cubit.getAkuns();
    final parokis = await widget.cubit.getParokis();
    setState(() {
      _akuns = akuns;
      _parokis = parokis;
      _loadingMaster = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Jurnal Offline')),
      body: _loadingMaster
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (widget.keuskupans.isEmpty)
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(children: [
                          const Text('Belum ada Keuskupan. Buat dulu:'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              await widget.cubit.createKeuskupan('Keuskupan Labuan Bajo', 'Jl Test');
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keuskupan dibuat (lokal)')));
                              setState(() {});
                            },
                            child: const Text('Buat Keuskupan Dummy'),
                          ),
                        ]),
                      ),
                    ),
                  DropdownButtonFormField<String>(
                    value: _keuskupanId,
                    decoration: const InputDecoration(labelText: 'Keuskupan *', border: OutlineInputBorder()),
                    items: widget.keuskupans.map((k) => DropdownMenuItem(value: k.id, child: Text('${k.nama} (${k.id.substring(0, 4)})'))).toList(),
                    onChanged: (v) => setState(() => _keuskupanId = v),
                    validator: (v) => v == null ? 'Wajib pilih' : null,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text('Tanggal: ${_tanggal.toString().substring(0, 10)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: _tanggal, firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (d != null) setState(() => _tanggal = d);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: _deskripsiCtrl, decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()), maxLines: 2),
                  const SizedBox(height: 12),
                  TextFormField(controller: _noBuktiCtrl, decoration: const InputDecoration(labelText: 'No Bukti (unik)', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Detil Jurnal *', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.add_circle, color: Colors.deepPurple), onPressed: () => setState(() => _detils.add(_DetilForm()))),
                    ],
                  ),
                  const Text('Minimal 1 detil, isi Debit atau Kredit', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 8),
                  ..._detils.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final d = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(children: [
                              Text('Detil ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              const Spacer(),
                              if (_detils.length > 1) IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => setState(() => _detils.removeAt(idx))),
                            ]),
                            DropdownButtonFormField<String>(
                              value: d.akunId,
                              decoration: const InputDecoration(labelText: 'Akun *', border: OutlineInputBorder(), isDense: true),
                              items: _akuns.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.kode} - ${a.nama}'))).toList(),
                              onChanged: (v) => d.akunId = v,
                              validator: (v) => v == null ? 'Wajib' : null,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: d.parokiId,
                              decoration: const InputDecoration(labelText: 'Paroki *', border: OutlineInputBorder(), isDense: true),
                              items: _parokis.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nama))).toList(),
                              onChanged: (v) => d.parokiId = v,
                              validator: (v) => v == null ? 'Wajib' : null,
                            ),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(child: TextFormField(controller: d.debitCtrl, decoration: const InputDecoration(labelText: 'Debit', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                              const SizedBox(width: 8),
                              Expanded(child: TextFormField(controller: d.kreditCtrl, decoration: const InputDecoration(labelText: 'Kredit', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                            ]),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  if (_akuns.isEmpty || _parokis.isEmpty)
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(children: [
                          const Text('Belum ada Akun/Paroki. Seed dulu:', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: () async {
                              // seed via debug
                              await widget.cubit.createKeuskupan('Keuskupan Dummy', 'Jl');
                              setState(() {});
                              await _loadMaster();
                            },
                            child: const Text('Seed Master'),
                          ),
                        ]),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text('Data disimpan ke SQLite lokal (is_synced=0) dan masuk antrian sync. Saat online otomatis push ke BE.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                    label: Text(_saving ? 'Menyimpan...' : 'Simpan Offline'),
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    // validasi detil minimal 1
    if (_detils.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimal 1 detil')));
      return;
    }
    for (final d in _detils) {
      if (d.akunId == null || d.parokiId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi Akun & Paroki di semua detil')));
        return;
      }
      if ((d.debitCtrl.text.isEmpty || double.tryParse(d.debitCtrl.text) == 0) && (d.kreditCtrl.text.isEmpty || double.tryParse(d.kreditCtrl.text) == 0)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi Debit atau Kredit di semua detil')));
        return;
      }
    }
    setState(() => _saving = true);
    try {
      final detilsComp = _detils
          .map((d) => DetilJurnalsCompanion.insert(
                id: '', // repo generate uuid
                jurnalId: '',
                akunId: d.akunId!,
                parokiId: d.parokiId!,
                debit: d.debitCtrl.text.isEmpty ? const Value(0) : Value(double.tryParse(d.debitCtrl.text) ?? 0),
                kredit: d.kreditCtrl.text.isEmpty ? const Value(0) : Value(double.tryParse(d.kreditCtrl.text) ?? 0),
                keterangan: const Value.absent(),
              ))
          .toList();
      await widget.cubit.createJurnal(
        keuskupanId: _keuskupanId!,
        tanggal: _tanggal,
        deskripsi: _deskripsiCtrl.text.isEmpty ? null : _deskripsiCtrl.text,
        noBukti: _noBuktiCtrl.text.isEmpty ? null : _noBuktiCtrl.text,
        detils: detilsComp,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jurnal disimpan lokal ✓ (pending sync)'), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _deskripsiCtrl.dispose();
    _noBuktiCtrl.dispose();
    for (final d in _detils) {
      d.debitCtrl.dispose();
      d.kreditCtrl.dispose();
      d.ketCtrl.dispose();
    }
    super.dispose();
  }
}
