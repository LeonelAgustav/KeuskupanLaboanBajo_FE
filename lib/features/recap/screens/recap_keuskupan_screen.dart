import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/recap_models.dart';
import '../../../data/repository/impl/master_repository_impl.dart';
import '../../../data/repository/impl/jurnal_repository_impl.dart';
import '../../../data/repository/impl/recap_repository_impl.dart';
import '../widgets/recap_widgets.dart';
import 'recap_paroki_detail_screen.dart';

class RecapKeuskupanScreen extends StatefulWidget {
  final AppDatabase? db;
  const RecapKeuskupanScreen({super.key, this.db});
  @override
  State<RecapKeuskupanScreen> createState() => _RecapKeuskupanScreenState();
}

class _RecapKeuskupanScreenState extends State<RecapKeuskupanScreen> {
  late final AppDatabase _db = widget.db ?? AppDatabase();
  late final RecapRepositoryImpl _recapRepo = RecapRepositoryImpl(_db);
  late final KeuskupanRepositoryImpl _keuskupanRepo = KeuskupanRepositoryImpl(_db);
  bool _ownsDb = false;

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  Keuskupan? _selectedKeuskupan;
  List<Keuskupan> _keuskupanList = [];

  bool _loading = true;
  String? _error;
  RecapKeuskupanResult? _recapResult;
  List<RecapParokiSummary> _parokiList = [];

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
      );
      final parokiList = await _recapRepo.getParokiRecapList(
        _selectedKeuskupan!.id, _startDate, _endDate,
      );

      setState(() {
        _recapResult = recap;
        _parokiList = parokiList;
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

  void _goToParokiDetail(RecapParokiSummary paroki) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RecapParokiDetailScreen(
        parokiId: paroki.parokiId,
        parokiNama: paroki.parokiNama,
        selectedMonth: _selectedMonth,
        db: _db,
      ),
    ));
  }

  // ── Seed sample data untuk testing ──────────────────────────────────────
  Future<void> _seedSampleData() async {
    final uuid = const Uuid();
    final keuskupanRepo = KeuskupanRepositoryImpl(_db);
    final parokiRepo = ParokiRepositoryImpl(_db);
    final jenisRepo = JenisRepositoryImpl(_db);
    final akunRepo = AkunRepositoryImpl(_db);
    final jurnalRepo = JurnalRepositoryImpl(_db);

    // Keuskupan
    final kId = await keuskupanRepo.create(
      nama: 'Keuskupan Labuan Bajo', alamat: 'Labuan Bajo, NTT',
    );

    // Parokis
    final p1 = await parokiRepo.create(nama: 'Paroki St. Yosep', alamat: 'Labuan Bajo', keuskupanId: kId);
    final p2 = await parokiRepo.create(nama: 'Paroki Maria Bunda', alamat: 'Ruteng', keuskupanId: kId);
    final p3 = await parokiRepo.create(nama: 'Paroki Kristus Raja', alamat: 'Borong', keuskupanId: kId);

    // Jenis akun
    final jPendapatan = await jenisRepo.create(nama: 'Pendapatan');
    final jBeban = await jenisRepo.create(nama: 'Beban');

    // Akuns
    final aKolekte = await akunRepo.create(kode: '4100', nama: 'Kolekte', jenisId: jPendapatan);
    final aSumbangan = await akunRepo.create(kode: '4200', nama: 'Sumbangan', jenisId: jPendapatan);
    final aGaji = await akunRepo.create(kode: '5100', nama: 'Gaji Pegawai', jenisId: jBeban);
    final aListrik = await akunRepo.create(kode: '5200', nama: 'Listrik & Air', jenisId: jBeban);

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);

    // Jurnal 1 — Paroki St. Yosep: kolekte masuk
    await jurnalRepo.create(
      keuskupanId: kId,
      tanggal: DateTime(thisMonth.year, thisMonth.month, 5),
      deskripsi: 'Penerimaan Kolekte Minggu I',
      noBukti: 'BKM-001',
      detils: [
        DetilJurnalsCompanion(
          id: Value(uuid.v4()), jurnalId: const Value(''), akunId: Value(aKolekte),
          parokiId: Value(p1), kredit: const Value(5000000),
        ),
      ],
    );

    // Jurnal 2 — Paroki St. Yosep: sumbangan masuk
    await jurnalRepo.create(
      keuskupanId: kId,
      tanggal: DateTime(thisMonth.year, thisMonth.month, 10),
      deskripsi: 'Sumbangan Donatur',
      noBukti: 'BKM-002',
      detils: [
        DetilJurnalsCompanion(
          id: Value(uuid.v4()), jurnalId: const Value(''), akunId: Value(aSumbangan),
          parokiId: Value(p1), kredit: const Value(3000000),
        ),
      ],
    );

    // Jurnal 3 — Paroki St. Yosep: bayar gaji
    await jurnalRepo.create(
      keuskupanId: kId,
      tanggal: DateTime(thisMonth.year, thisMonth.month, 15),
      deskripsi: 'Pembayaran Gaji',
      noBukti: 'BKK-001',
      detils: [
        DetilJurnalsCompanion(
          id: Value(uuid.v4()), jurnalId: const Value(''), akunId: Value(aGaji),
          parokiId: Value(p1), debit: const Value(4000000),
        ),
      ],
    );

    // Jurnal 4 — Paroki Maria Bunda: kolekte
    await jurnalRepo.create(
      keuskupanId: kId,
      tanggal: DateTime(thisMonth.year, thisMonth.month, 7),
      deskripsi: 'Kolekte Minggu I',
      noBukti: 'BKM-003',
      detils: [
        DetilJurnalsCompanion(
          id: Value(uuid.v4()), jurnalId: const Value(''), akunId: Value(aKolekte),
          parokiId: Value(p2), kredit: const Value(7000000),
        ),
      ],
    );

    // Jurnal 5 — Paroki Maria Bunda: listrik
    await jurnalRepo.create(
      keuskupanId: kId,
      tanggal: DateTime(thisMonth.year, thisMonth.month, 20),
      deskripsi: 'Bayar Listrik & Air',
      noBukti: 'BKK-002',
      detils: [
        DetilJurnalsCompanion(
          id: Value(uuid.v4()), jurnalId: const Value(''), akunId: Value(aListrik),
          parokiId: Value(p2), debit: const Value(2500000),
        ),
      ],
    );

    // Jurnal 6 — Paroki Kristus Raja: kolekte + sumbangan
    await jurnalRepo.create(
      keuskupanId: kId,
      tanggal: DateTime(thisMonth.year, thisMonth.month, 12),
      deskripsi: 'Kolekte & Sumbangan',
      noBukti: 'BKM-004',
      detils: [
        DetilJurnalsCompanion(
          id: Value(uuid.v4()), jurnalId: const Value(''), akunId: Value(aKolekte),
          parokiId: Value(p3), kredit: const Value(4000000),
        ),
        DetilJurnalsCompanion(
          id: Value(uuid.v4()), jurnalId: const Value(''), akunId: Value(aSumbangan),
          parokiId: Value(p3), kredit: const Value(2000000),
        ),
      ],
    );

    // Jurnal 7 — Paroki Kristus Raja: gaji
    await jurnalRepo.create(
      keuskupanId: kId,
      tanggal: DateTime(thisMonth.year, thisMonth.month, 25),
      deskripsi: 'Gaji Pegawai',
      noBukti: 'BKK-003',
      detils: [
        DetilJurnalsCompanion(
          id: Value(uuid.v4()), jurnalId: const Value(''), akunId: Value(aGaji),
          parokiId: Value(p3), debit: const Value(3500000),
        ),
      ],
    );

    // Reload
    _keuskupanList = [];
    _selectedKeuskupan = null;
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample data berhasil di-seed!')),
      );
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Keuskupan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: (_selectedKeuskupan == null && !_loading)
          ? FloatingActionButton.extended(
              onPressed: _seedSampleData,
              icon: const Icon(Icons.add),
              label: const Text('Seed Sample'),
            )
          : null,
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
              'Tap tombol "Seed Sample" untuk menambahkan data contoh',
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
              child: DropdownButtonFormField<String>(
                value: _selectedKeuskupan!.id,
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

          // Month picker
          MonthYearPicker(
            selectedMonth: _selectedMonth,
            onChangeMonth: _changeMonth,
          ),

          // Summary cards
          if (_recapResult != null)
            SummaryRow(
              totalDebit: _recapResult!.totalDebit,
              totalKredit: _recapResult!.totalKredit,
            ),

          const SizedBox(height: 16),

          // Section header
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

          const SizedBox(height: 80), // padding for FAB
            ],
          ),
        ),
      ),
    );
  }
}
