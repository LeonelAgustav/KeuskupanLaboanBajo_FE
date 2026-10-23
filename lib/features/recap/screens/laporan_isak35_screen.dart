import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/recap_models.dart';
import '../../../data/repository/impl/recap_repository_impl.dart';
import '../utils/laporan_isak35.dart';
import '../utils/pdf_export.dart';
import '../widgets/recap_widgets.dart';

class LaporanISAK35Screen extends StatefulWidget {
  final int keuskupanId;
  final int? parokiId;
  final DateTime startDate;
  final DateTime endDate;
  final int initialTab;
  final AppDatabase? db;

  const LaporanISAK35Screen({
    super.key,
    required this.keuskupanId,
    this.parokiId,
    required this.startDate,
    required this.endDate,
    this.initialTab = 0,
    this.db,
  });

  @override
  State<LaporanISAK35Screen> createState() => _LaporanISAK35ScreenState();
}

class _LaporanISAK35ScreenState extends State<LaporanISAK35Screen>
    with SingleTickerProviderStateMixin {
  late final AppDatabase _db = widget.db ?? AppDatabase();
  late final RecapRepositoryImpl _repo = RecapRepositoryImpl(_db);
  late final bool _ownsDb = widget.db == null;
  late final DateTime _startDate = widget.startDate;
  late final DateTime _endDate = widget.endDate;

  late TabController _tabCtrl;
  List<NeracaSaldoBaris>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 3),
    );
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    if (_ownsDb) _db.close();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final d = await _repo.getNeracaSaldo(
        widget.keuskupanId, _startDate, _endDate,
        parokiId: widget.parokiId,
      );
      if (mounted) setState(() { _data = d; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan ISAK 35'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Neraca Saldo'),
            Tab(text: 'Neraca'),
            Tab(text: 'Lap. Aktivitas'),
            Tab(text: 'Aset Neto'),
          ],
        ),
        actions: [
          if (_data != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Export PDF',
              onPressed: () => _exportPdf(_tabCtrl.index),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _Table(buildNeracaSaldo(_data!)),
                    _Table(buildNeraca(_data!)),
                    _Table(buildLapAktivitas(_data!)),
                    _Table(buildAsetNeto(_data!)),
                  ],
                ),
    );
  }

  void _exportPdf(int idx) {
    final end = _endDate.subtract(const Duration(days: 1));
    final periode = '${_startDate.day}/${_startDate.month}/${_startDate.year} - '
        '${end.day}/${end.month}/${end.year}';
    final judul = ['Neraca Saldo', 'Neraca', 'Laporan Aktivitas', 'Aset Neto'][idx];
    final t = [buildNeracaSaldo, buildNeraca, buildLapAktivitas, buildAsetNeto][idx](_data!);
    exportLaporanTabelPdf(judul: judul, periode: periode, data: t);
  }
}

class _Table extends StatelessWidget {
  final LaporanTabel data;
  const _Table(this.data);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(ungu.withValues(alpha: 0.1)),
          columns: [for (final h in data.headers) DataColumn(label: Text(h))],
          rows: [
            for (final r in data.rows)
              DataRow(
                color: WidgetStateProperty.all(
                  r.isHeader || r.isTotal ? ungu.withValues(alpha: 0.05) : null,
                ),
                cells: [
                  DataCell(Text(
                    r.isHeader ? r.label.toUpperCase() : r.label,
                    style: r.isHeader || r.isTotal
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : null,
                  )),
                  for (var i = 0; i < data.headers.length - 1; i++)
                    DataCell(Text(
                      i >= r.nums.length || r.nums[i] == null || r.nums[i] == 0
                          ? '-'
                          : formatRupiah(r.nums[i]!),
                      style: r.isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null,
                    )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
