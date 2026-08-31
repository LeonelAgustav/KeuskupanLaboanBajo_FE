import 'package:flutter/material.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repository/impl/jurnal_repository_impl.dart';
import '../../../data/repository/impl/master_repository_impl.dart';
import '../../recap/widgets/recap_widgets.dart';

class JurnalDetailScreen extends StatefulWidget {
  final String jurnalId;
  final AppDatabase db;
  const JurnalDetailScreen({super.key, required this.jurnalId, required this.db});
  @override
  State<JurnalDetailScreen> createState() => _JurnalDetailScreenState();
}

class _JurnalDetailScreenState extends State<JurnalDetailScreen> {
  Jurnal? _jurnal;
  Keuskupan? _keuskupan;
  List<DetilJurnal> _detils = [];
  Map<String, Akun> _akunMap = {};
  Map<String, Paroki> _parokiMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final jurnalRepo = JurnalRepositoryImpl(widget.db);
    final j = await jurnalRepo.getById(widget.jurnalId);
    if (j == null) {
      setState(() => _loading = false);
      return;
    }
    final detils = await jurnalRepo.getDetils(widget.jurnalId);
    final keuskupan = await KeuskupanRepositoryImpl(widget.db).getById(j.keuskupanId);
    // ponytail: bulk load akun & paroki sekali, biar tidak N+1 dan tidak hilang
    final allAkuns = await widget.db.select(widget.db.akuns).get();
    final allParokis = await widget.db.select(widget.db.parokis).get();
    final akunMap = {for (var a in allAkuns) a.id: a};
    final parokiMap = {for (var p in allParokis) p.id: p};
    setState(() {
      _jurnal = j;
      _keuskupan = keuskupan;
      _detils = detils;
      _akunMap = akunMap;
      _parokiMap = parokiMap;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detil Jurnal')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _jurnal == null
              ? const Center(child: Text('Jurnal tidak ditemukan'))
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Icon(_jurnal!.isSynced ? Icons.cloud_done : Icons.cloud_upload, color: _jurnal!.isSynced ? Colors.green : Colors.orange, size: 18),
                                const SizedBox(width: 6),
                                Text(_jurnal!.isSynced ? 'Sudah sync' : 'Pending sync', style: TextStyle(color: _jurnal!.isSynced ? Colors.green : Colors.orange, fontSize: 12)),
                                const Spacer(),
                                Text(_jurnal!.tanggal.toString().substring(0, 10), style: const TextStyle(color: Colors.grey)),
                              ]),
                              const SizedBox(height: 12),
                              _row('Keuskupan', _keuskupan?.nama ?? _jurnal!.keuskupanId.substring(0, 8)),
                              _row('Tanggal', _jurnal!.tanggal.toString().substring(0, 10)),
                              _row('Deskripsi', _jurnal!.deskripsi ?? '-'),
                              _row('No Bukti', _jurnal!.noBukti ?? '-'),
                              _row('ID', _jurnal!.id.substring(0, 8)),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Detil Jurnal (${_detils.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (_detils.isEmpty)
                          const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Tidak ada detil', style: TextStyle(color: Colors.grey)))))
                        else
                          ..._detils.map((d) {
                            final akun = _akunMap[d.akunId];
                            final paroki = _parokiMap[d.parokiId];
                            final akunText = akun != null ? '${akun.kode} - ${akun.nama}' : 'Akun tidak ditemukan';
                            final parokiText = paroki != null ? paroki.nama : 'Paroki tidak ditemukan';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    Expanded(child: Text(akunText, style: TextStyle(fontWeight: FontWeight.w600, color: akun == null ? Colors.red : Colors.black))),
                                    if (d.debit != null && d.debit! > 0) Text('Debit ${formatRupiah(d.debit!)}', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                                    if (d.kredit != null && d.kredit! > 0) Text('Kredit ${formatRupiah(d.kredit!)}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                                  ]),
                                  const SizedBox(height: 4),
                                  Text('Paroki: $parokiText', style: TextStyle(fontSize: 12, color: paroki == null ? Colors.red : Colors.grey)),
                                  if (d.keterangan != null) Text('Ket: ${d.keterangan}', style: const TextStyle(fontSize: 12)),
                                ]),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ]),
      );
}
