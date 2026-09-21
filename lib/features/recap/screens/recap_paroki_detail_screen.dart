import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/recap_models.dart';
import '../../../data/repository/impl/recap_repository_impl.dart';
import '../widgets/recap_widgets.dart';
import '../utils/pdf_export.dart';

class RecapParokiDetailScreen extends StatefulWidget {
  final int parokiId;
  final String parokiNama;
  final DateTime selectedDate;
  final PeriodMode mode;
  final AppDatabase? db;

  const RecapParokiDetailScreen({
    super.key,
    required this.parokiId,
    required this.parokiNama,
    required this.selectedDate,
    required this.mode,
    this.db,
  });

  @override
  State<RecapParokiDetailScreen> createState() => _RecapParokiDetailScreenState();
}

class _RecapParokiDetailScreenState extends State<RecapParokiDetailScreen> {
  late final AppDatabase _db = widget.db ?? AppDatabase();
  late final RecapRepositoryImpl _recapRepo = RecapRepositoryImpl(_db);
  bool _ownsDb = false;

  late DateTime _selectedDate = widget.selectedDate;
  late PeriodMode _mode = widget.mode;
  bool _loading = true;
  String? _error;
  double _totalDebit = 0;
  double _totalKredit = 0;
  List<RecapAkunDetail> _details = [];
  List<MonthlyRecap> _monthlyData = [];
  List<WeeklyRecap> _weeklyData = [];

  // Group details by jenis
  Map<String, List<RecapAkunDetail>> get _groupedDetails {
    final map = <String, List<RecapAkunDetail>>{};
    for (final d in _details) {
      map.putIfAbsent(d.jenisNama, () => []).add(d);
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    _ownsDb = widget.db == null;
    _loadData();
  }

  @override
  void dispose() {
    if (_ownsDb) _db.close();
    super.dispose();
  }

  DateTime get _startDate {
    if (_mode == PeriodMode.year) {
      return DateTime(_selectedDate.year, 1, 1);
    }
    return DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  DateTime get _endDate {
    if (_mode == PeriodMode.year) {
      return DateTime(_selectedDate.year + 1, 1, 1);
    }
    return DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final details = await _recapRepo.getParokiRecapDetail(
        widget.parokiId, _startDate, _endDate,
      );

      double debit = 0;
      double kredit = 0;
      for (final d in details) {
        debit += d.totalDebit;
        kredit += d.totalKredit;
      }

      List<MonthlyRecap> monthlyData = [];
      List<WeeklyRecap> weeklyData = [];
      if (_mode == PeriodMode.year) {
        monthlyData = await _recapRepo.getMonthlyRecap(widget.parokiId, _selectedDate.year);
      } else {
        weeklyData = await _recapRepo.getWeeklyRecap(widget.parokiId, _selectedDate.year, _selectedDate.month);
      }

      setState(() {
        _details = details;
        _totalDebit = debit;
        _totalKredit = kredit;
        _monthlyData = monthlyData;
        _weeklyData = weeklyData;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _changeDate(DateTime newDate) {
    _selectedDate = newDate;
    _loadData();
  }

  void _toggleMode(PeriodMode mode) {
    _mode = mode;
    _loadData();
  }

  void _exportDetailPdf() {
    final baris = <PdfBaris>[];
    _groupedDetails.forEach((jenis, items) {
      baris.add(PdfBaris(jenis, isHeader: true));
      for (final d in items) {
        baris.add(PdfBaris('${d.akunKode} - ${d.akunNama}', debit: d.totalDebit, kredit: d.totalKredit));
      }
    });
    final periode = _mode == PeriodMode.year
        ? '${_selectedDate.year}'
        : '${monthNamesId[_selectedDate.month - 1]} ${_selectedDate.year}';
    exportLaporanPdf(
      judul: 'Laporan Keuangan Paroki ${widget.parokiNama}',
      periode: periode,
      baris: baris,
      totalDebit: _totalDebit,
      totalKredit: _totalKredit,
    );
  }

  void _exportMonthlyPdf() {
    final baris = <PdfBaris>[
      for (final m in _monthlyData)
        PdfBaris(m.namaBulan, debit: m.totalDebit, kredit: m.totalKredit),
    ];
    exportLaporanPdf(
      judul: 'Rekap Bulanan Paroki ${widget.parokiNama}',
      periode: '${_selectedDate.year}',
      baris: baris,
      totalDebit: _totalDebit,
      totalKredit: _totalKredit,
    );
  }

  void _exportWeeklyPdf() {
    final baris = <PdfBaris>[
      for (final w in _weeklyData)
        PdfBaris('${w.namaMinggu} (tgl ${w.rentang})', debit: w.totalDebit, kredit: w.totalKredit),
    ];
    exportLaporanPdf(
      judul: 'Rekap Mingguan Paroki ${widget.parokiNama}',
      periode: '${monthNamesId[_selectedDate.month - 1]} ${_selectedDate.year}',
      baris: baris,
      totalDebit: _totalDebit,
      totalKredit: _totalKredit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rekap ${widget.parokiNama}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF - Detail Akun',
            onPressed: (_loading || _details.isEmpty)
                ? null
                : () => _exportDetailPdf(),
          ),
          if (_mode == PeriodMode.year && _monthlyData.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.calendar_month),
              tooltip: 'Export PDF - Rekap Bulanan',
              onPressed: () => _exportMonthlyPdf(),
            ),
          if (_mode == PeriodMode.month && _weeklyData.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.calendar_view_week),
              tooltip: 'Export PDF - Rekap Mingguan',
              onPressed: () => _exportWeeklyPdf(),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

return RefreshIndicator(
      onRefresh: _loadData,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            children: [
              // Period picker
              MonthYearPicker(
                selectedDate: _selectedDate,
                onDateChanged: _changeDate,
                mode: _mode,
                onModeChanged: _toggleMode,
              ),

              // Summary cards
          SummaryRow(
            totalPendapatan: _totalKredit, // Pendapatan = Kredit
            totalPengeluaran: _totalDebit, // Pengeluaran = Debit
          ),

          const SizedBox(height: 20),

          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Rincian Per Akun',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 8),

          if (_details.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Tidak ada transaksi pada periode ini',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else
            ..._groupedDetails.entries.map((entry) => _buildJenisGroup(entry.key, entry.value)),

          // Monthly table for yearly mode
          if (_mode == PeriodMode.year && _monthlyData.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Rekap Bulanan (${_selectedDate.year})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 8),
            MonthlyRecapTable(
              monthlyData: _monthlyData,
              totalPendapatan: _totalKredit,
              totalPengeluaran: _totalDebit,
            ),
          ],
          // Weekly table for monthly mode
          if (_mode == PeriodMode.month && _weeklyData.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Rekap Mingguan (${monthNamesId[_selectedDate.month - 1]} ${_selectedDate.year})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 8),
            WeeklyRecapTable(
              weeklyData: _weeklyData,
              totalPendapatan: _totalKredit,
              totalPengeluaran: _totalDebit,
            ),
          ],

          const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJenisGroup(String jenisNama, List<RecapAkunDetail> items) {
    // Calculate subtotals for this jenis
    double subDebit = 0;
    double subKredit = 0;
    for (final d in items) {
      subDebit += d.totalDebit;
      subKredit += d.totalKredit;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: ungu.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    jenisNama.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: ungu,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(
                  'Pendapatan: ${formatRupiah(subKredit)}',
                  style: const TextStyle(fontSize: 11, color: hijauPendapatan),
                ))),
                const SizedBox(width: 8),
                Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(
                  'Pengeluaran: ${formatRupiah(subDebit)}',
                  style: const TextStyle(fontSize: 11, color: merahPengeluaran),
                ))),
              ],
            ),
          ),
          const Divider(height: 1),
          // Items
          ...items.map((d) => AkunDetailTile(detail: d)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
