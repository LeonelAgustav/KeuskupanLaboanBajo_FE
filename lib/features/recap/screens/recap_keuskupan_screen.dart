import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import '../../../core/auth/token_storage.dart';
import '../../../core/security/screenshot_guard.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/recap_models.dart';
import '../../../data/repository/impl/master_repository_impl.dart';
import '../../../data/repository/impl/recap_repository_impl.dart';
import '../widgets/recap_widgets.dart';
import '../utils/pdf_export.dart';
import 'recap_paroki_detail_screen.dart';

class RecapKeuskupanScreen extends StatefulWidget {
  final AppDatabase? db;
  final TokenStorageI? tokenStorage;
  const RecapKeuskupanScreen({super.key, this.db, this.tokenStorage});
  @override
  State<RecapKeuskupanScreen> createState() => _RecapKeuskupanScreenState();
}

class _RecapKeuskupanScreenState extends State<RecapKeuskupanScreen> {
  late final AppDatabase _db = widget.db ?? AppDatabase();
  late final RecapRepositoryImpl _recapRepo = RecapRepositoryImpl(_db);
  late final KeuskupanRepositoryImpl _keuskupanRepo = KeuskupanRepositoryImpl(_db);
  bool _ownsDb = false;

  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month);
  PeriodMode _mode = PeriodMode.month;
  Keuskupan? _selectedKeuskupan;
  List<Keuskupan> _keuskupanList = [];
  int? _memberParokiId; // untuk MEMBER: filter hanya 1 paroki
  String? _memberParokiNama;

  bool _loading = true;
  String? _error;
  RecapKeuskupanResult? _recapResult;
  List<RecapParokiSummary> _parokiList = [];
  List<MonthlyRecap> _monthlyData = [];
  List<WeeklyRecap> _weeklyData = [];

  @override
  void initState() {
    super.initState();
    ScreenshotGuard.setSecure(true);
    _ownsDb = widget.db == null;
    _boot();
  }

  Future<void> _boot() async {
    await _initMemberFilter();
    await _loadData();
  }

  Future<void> _initMemberFilter() async {
    final ts = widget.tokenStorage;
    if (ts == null) return;
    try {
      final pid = await ts.getCurrentParokiId();
      if (pid != null && pid > 0) _memberParokiId = pid;
      // Ambil nama paroki dari DB lokal
      if (_memberParokiId != null) {
        final rows = await _db.customSelect(
          'SELECT nama FROM parokis WHERE id = ? AND deleted_at IS NULL',
          variables: [Variable.withInt(_memberParokiId!)],
        ).get();
        if (rows.isNotEmpty) _memberParokiNama = rows.first.read<String>('nama');
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    ScreenshotGuard.setSecure(false);
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
      // Load keuskupan list if first time
      if (_keuskupanList.isEmpty) {
        _keuskupanList = await _keuskupanRepo.getAll();
        if (_keuskupanList.isNotEmpty && _selectedKeuskupan == null) {
          _selectedKeuskupan = _keuskupanList.first;
        }
      }

      if (_selectedKeuskupan == null) {
        setState(() { _loading = false; });
        return;
      }

      final recap = await _recapRepo.getKeuskupanRecap(
        _selectedKeuskupan!.id, _startDate, _endDate,
        parokiId: _memberParokiId,
      );
      final parokiList = await _recapRepo.getParokiRecapList(
        _selectedKeuskupan!.id, _startDate, _endDate,
        parokiId: _memberParokiId,
      );

      // Load monthly data for yearly mode, weekly for monthly mode
      List<MonthlyRecap> monthlyData = [];
      List<WeeklyRecap> weeklyData = [];
      if (_mode == PeriodMode.year) {
        monthlyData = await _recapRepo.getMonthlyRecap(
          _selectedKeuskupan!.id, _selectedDate.year,
          parokiId: _memberParokiId,
        );
      } else {
        weeklyData = await _recapRepo.getWeeklyRecap(
          _selectedKeuskupan!.id, _selectedDate.year, _selectedDate.month,
          parokiId: _memberParokiId,
        );
      }

      setState(() {
        _recapResult = recap;
        _parokiList = parokiList;
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

  void _goToParokiDetail(RecapParokiSummary paroki) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RecapParokiDetailScreen(
        parokiId: paroki.parokiId,
        parokiNama: paroki.parokiNama,
        selectedDate: _selectedDate,
        mode: _mode,
        db: _db,
      ),
    ));
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_memberParokiNama != null ? 'Rekap $_memberParokiNama' : 'Rekap Keuskupan'),
        actions: [
          if (_recapResult != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Export PDF',
              onPressed: () => exportLaporanPdf(
                judul: 'Laporan Keuangan Keuskupan',
                periode: _mode == PeriodMode.year
                    ? '${_selectedDate.year}'
                    : '${monthNamesId[_selectedDate.month - 1]} ${_selectedDate.year}',
                baris: [
                  for (final p in _parokiList) PdfBaris(p.parokiNama, debit: p.totalDebit, kredit: p.totalKredit),
                ],
                totalDebit: _recapResult!.totalDebit,
                totalKredit: _recapResult!.totalKredit,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
    if (_selectedKeuskupan == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.church, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada data Keuskupan',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan data lewat menu Master',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // ponytail: 1 codebase app+web -> web centered max 900
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            children: [
          // Keuskupan dropdown (if multiple)
          if (_keuskupanList.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonFormField<int>(
                initialValue: _selectedKeuskupan!.id,
                decoration: const InputDecoration(
                  labelText: 'Keuskupan',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: _keuskupanList.map((k) => DropdownMenuItem(
                  value: k.id,
                  child: Text(k.nama),
                )).toList(),
                onChanged: (val) {
                  _selectedKeuskupan = _keuskupanList.firstWhere((k) => k.id == val);
                  _loadData();
                },
              ),
            ),

          // Period picker
          MonthYearPicker(
            selectedDate: _selectedDate,
            onDateChanged: _changeDate,
            mode: _mode,
            onModeChanged: _toggleMode,
          ),

          // Summary cards
          if (_recapResult != null)
            SummaryRow(
              totalPendapatan: _recapResult!.totalKredit, // Pendapatan = Kredit
              totalPengeluaran: _recapResult!.totalDebit, // Pengeluaran = Debit
            ),

          const SizedBox(height: 16),

          // Weekly table for monthly mode (PRIORITAS ATAS)
          if (_mode == PeriodMode.month && _weeklyData.isNotEmpty) ...[
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
              totalPendapatan: _recapResult?.totalKredit ?? 0,
              totalPengeluaran: _recapResult?.totalDebit ?? 0,
            ),
            const SizedBox(height: 16),
          ],

          // Monthly table for yearly mode (PRIORITAS ATAS)
          if (_mode == PeriodMode.year && _monthlyData.isNotEmpty) ...[
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
              totalPendapatan: _recapResult?.totalKredit ?? 0,
              totalPengeluaran: _recapResult?.totalDebit ?? 0,
            ),
            const SizedBox(height: 16),
          ],

          // Rekap Per Paroki (HANYA untuk non-MEMBER)
          if (_memberParokiId == null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Rekap Per Paroki',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Paroki list
            if (_parokiList.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'Tidak ada paroki pada keuskupan ini',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              ..._parokiList.map((p) => ParokiRecapCard(
                summary: p,
                onTap: () => _goToParokiDetail(p),
              )),
          ],

          const SizedBox(height: 80), // padding for FAB
            ],
          ),
        ),
      ),
    );
  }
}
