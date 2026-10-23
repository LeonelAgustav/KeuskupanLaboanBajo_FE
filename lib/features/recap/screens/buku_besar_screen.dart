import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/akun_picker.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/recap_models.dart';
import '../../../data/repository/impl/master_repository_impl.dart';
import '../../../data/repository/impl/recap_repository_impl.dart';
import '../utils/pdf_export.dart';
import '../widgets/recap_widgets.dart';

class BukuBesarScreen extends StatefulWidget {
  final int keuskupanId;
  final int? parokiId;
  final int? akunId;
  final DateTime startDate;
  final DateTime endDate;
  final AppDatabase? db;

  const BukuBesarScreen({
    super.key,
    required this.keuskupanId,
    this.parokiId,
    this.akunId,
    required this.startDate,
    required this.endDate,
    this.db,
  });

  @override
  State<BukuBesarScreen> createState() => _BukuBesarScreenState();
}

class _BukuBesarScreenState extends State<BukuBesarScreen> {
  late final AppDatabase _db = widget.db ?? AppDatabase();
  late final RecapRepositoryImpl _recapRepo = RecapRepositoryImpl(_db);
  late final AkunRepositoryImpl _akunRepo = AkunRepositoryImpl(_db);
  late final DateTime _startDate = widget.startDate;
  late final DateTime _endDate = widget.endDate;
  late final bool _ownsDb = widget.db == null;

  List<Akun> _akuns = [];
  int? _akunId;
  BukuBesarResult? _result;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    if (_ownsDb) _db.close();
    super.dispose();
  }

  Future<void> _boot() async {
    try {
      _akuns = await _akunRepo.getAll();
      _akuns.sort((a, b) => a.kode.compareTo(b.kode));
      if (widget.akunId != null && _akuns.any((a) => a.id == widget.akunId)) {
        _akunId = widget.akunId;
      } else if (_akuns.isNotEmpty) {
        _akunId = _akuns.first.id;
      }
      await _loadData();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadData() async {
    if (_akunId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _recapRepo.getBukuBesar(
        widget.keuskupanId,
        _akunId!,
        _startDate,
        _endDate,
        parokiId: widget.parokiId,
      );
      if (mounted) {
        setState(() {
          _result = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Besar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: _result == null || _loading
                ? null
                : () => exportBukuBesarPdf(
                    data: _result!,
                    startDate: _startDate,
                    endDate: _endDate,
                  ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: AkunPickerButton(
                akuns: _akuns,
                selected: _akunId != null
                    ? _akuns.cast<Akun?>().firstWhere((a) => a?.id == _akunId, orElse: () => null)
                    : null,
                label: 'Akun',
                enabled: !_loading,
                onChanged: (a) {
                  _akunId = a.id;
                  _loadData();
                },
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text('Error: $_error', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_akuns.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Belum ada akun')),
              )
            else if (_result != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Saldo Awal',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                formatRupiah(_result!.saldoAwal),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Saldo Akhir',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                formatRupiah(_result!.saldoAkhir),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildTable(_result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTable(BukuBesarResult data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(ungu.withValues(alpha: 0.1)),
          columns: const [
            DataColumn(label: Text('Tanggal')),
            DataColumn(label: Text('No Bukti')),
            DataColumn(label: Text('Uraian')),
            DataColumn(label: Text('Debit'), numeric: true),
            DataColumn(label: Text('Kredit'), numeric: true),
            DataColumn(label: Text('Saldo'), numeric: true),
          ],
          rows: [
            _summaryRow('Saldo Awal', data.saldoAwal),
            for (final m in data.mutasi)
              DataRow(
                cells: [
                  DataCell(
                    Text(
                      '${m.tanggal.day.toString().padLeft(2, '0')}/${m.tanggal.month.toString().padLeft(2, '0')}/${m.tanggal.year}',
                    ),
                  ),
                  DataCell(Text(m.noBukti ?? '-')),
                  DataCell(
                    SizedBox(
                      width: 220,
                      child: Text(
                        m.uraian ?? '-',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(m.debit == 0 ? '-' : formatRupiah(m.debit))),
                  DataCell(Text(m.kredit == 0 ? '-' : formatRupiah(m.kredit))),
                  DataCell(Text(formatRupiah(m.saldo))),
                ],
              ),
            _summaryRow('Saldo Akhir', data.saldoAkhir),
          ],
        ),
      ),
    );
  }

  DataRow _summaryRow(String label, double saldo) => DataRow(
    color: WidgetStateProperty.all(ungu.withValues(alpha: 0.05)),
    cells: [
      DataCell(
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      const DataCell(Text('')),
      const DataCell(Text('')),
      const DataCell(Text('')),
      const DataCell(Text('')),
      DataCell(
        Text(
          formatRupiah(saldo),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}
