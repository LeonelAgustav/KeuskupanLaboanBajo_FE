import 'package:flutter/material.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/recap_models.dart';
import '../../../data/repository/impl/recap_repository_impl.dart';
import '../widgets/recap_widgets.dart';

class RecapParokiDetailScreen extends StatefulWidget {
  final String parokiId;
  final String parokiNama;
  final DateTime selectedMonth;
  final AppDatabase? db;

  const RecapParokiDetailScreen({
    super.key,
    required this.parokiId,
    required this.parokiNama,
    required this.selectedMonth,
    this.db,
  });

  @override
  State<RecapParokiDetailScreen> createState() => _RecapParokiDetailScreenState();
}

class _RecapParokiDetailScreenState extends State<RecapParokiDetailScreen> {
  late final AppDatabase _db = widget.db ?? AppDatabase();
  late final RecapRepositoryImpl _recapRepo = RecapRepositoryImpl(_db);
  bool _ownsDb = false;

  late DateTime _selectedMonth = widget.selectedMonth;
  bool _loading = true;
  String? _error;
  double _totalDebit = 0;
  double _totalKredit = 0;
  List<RecapAkunDetail> _details = [];

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

  DateTime get _startDate => _selectedMonth;
  DateTime get _endDate => DateTime(_selectedMonth.year, _selectedMonth.month + 1);

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

      setState(() {
        _details = details;
        _totalDebit = debit;
        _totalKredit = kredit;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _changeMonth(int delta) {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rekap ${widget.parokiNama}'),
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
          // Month picker
          MonthYearPicker(
            selectedMonth: _selectedMonth,
            onChangeMonth: _changeMonth,
          ),

          // Summary cards
          SummaryRow(
            totalDebit: _totalDebit,
            totalKredit: _totalKredit,
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
              color: Colors.deepPurple.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    jenisNama.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                ),
                Text(
                  'D: ${formatRupiah(subDebit)}',
                  style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 8),
                Text(
                  'K: ${formatRupiah(subKredit)}',
                  style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                ),
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
