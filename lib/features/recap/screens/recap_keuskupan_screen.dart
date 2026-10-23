import 'package:flutter/material.dart';

import '../../../core/auth/token_storage.dart';
import '../../../core/security/screenshot_guard.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/akun_picker.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repository/impl/master_repository_impl.dart';
import '../widgets/recap_widgets.dart';
import 'buku_besar_screen.dart';
import 'laporan_isak35_screen.dart';

class RecapKeuskupanScreen extends StatefulWidget {
  final AppDatabase? db;
  final TokenStorageI? tokenStorage;

  const RecapKeuskupanScreen({super.key, this.db, this.tokenStorage});

  @override
  State<RecapKeuskupanScreen> createState() => _RecapKeuskupanScreenState();
}

class _RecapKeuskupanScreenState extends State<RecapKeuskupanScreen> {
  late final AppDatabase _db = widget.db ?? AppDatabase();
  late final KeuskupanRepositoryImpl _keuskupanRepo = KeuskupanRepositoryImpl(
    _db,
  );
  late final AkunRepositoryImpl _akunRepo = AkunRepositoryImpl(_db);
  late final bool _ownsDb = widget.db == null;

  Keuskupan? _selectedKeuskupan;
  List<Keuskupan> _keuskupans = [];
  List<Akun> _akuns = [];
  int? _selectedAkunId;
  int? _memberParokiId;
  int? _memberKeuskupanId;
  String? _memberParokiNama;
  DateTime _startMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _endMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool _loading = true;
  String? _error;

  DateTime get _startDate => DateTime(_startMonth.year, _startMonth.month, 1);
  DateTime get _endDate => DateTime(_endMonth.year, _endMonth.month + 1, 1);

  @override
  void initState() {
    super.initState();
    ScreenshotGuard.setSecure(true);
    _boot();
  }

  Future<void> _boot() async {
    try {
      await _loadMemberScope();
      final results = await Future.wait([
        _keuskupanRepo.getAll(),
        _akunRepo.getAll(),
      ]);
      if (!mounted) return;

      _keuskupans = results[0] as List<Keuskupan>;
      _akuns = results[1] as List<Akun>;
      if (_keuskupans.isNotEmpty) {
        _selectedKeuskupan = _memberKeuskupanId == null
            ? _keuskupans.first
            : _keuskupans
                  .where((k) => k.id == _memberKeuskupanId)
                  .firstOrNull;
      }
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadMemberScope() async {
    final parokiId = await widget.tokenStorage?.getCurrentParokiId();
    if (parokiId == null || parokiId <= 0) return;

    final paroki = await (_db.select(
      _db.parokis,
    )..where((p) => p.id.equals(parokiId))).getSingleOrNull();
    if (paroki == null) return;

    _memberParokiId = paroki.id;
    _memberKeuskupanId = paroki.keuskupanId;
    _memberParokiNama = paroki.nama;
  }

  @override
  void dispose() {
    ScreenshotGuard.setSecure(false);
    if (_ownsDb) _db.close();
    super.dispose();
  }

  void _openBukuBesar() {
    if (_selectedKeuskupan == null || _selectedAkunId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih keuskupan dan akun terlebih dahulu')),
      );
      return;
    }
    if (_startDate.isAfter(_endMonth)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bulan awal tidak boleh setelah bulan akhir')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BukuBesarScreen(
          keuskupanId: _selectedKeuskupan!.id,
          parokiId: _memberParokiId,
          akunId: _selectedAkunId,
          startDate: _startDate,
          endDate: _endDate,
          db: _db,
        ),
      ),
    );
  }

  void _openLaporan(int tab) {
    if (_selectedKeuskupan == null) return;
    if (_startDate.isAfter(_endMonth)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bulan awal tidak boleh setelah bulan akhir')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LaporanISAK35Screen(
          keuskupanId: _selectedKeuskupan!.id,
          parokiId: _memberParokiId,
          startDate: _startDate,
          endDate: _endDate,
          initialTab: tab,
          db: _db,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _memberParokiNama == null ? 'Rekap' : 'Rekap $_memberParokiNama',
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Text('Error: $_error', textAlign: TextAlign.center));
    }
    if (_selectedKeuskupan == null) {
      return const Center(child: Text('Belum ada data keuskupan'));
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Filter Laporan',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _selectedKeuskupan!.id,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Keuskupan',
                border: const OutlineInputBorder(),
                helperText: _memberKeuskupanId == null
                    ? null
                    : 'Keuskupan terkunci untuk akun MEMBER',
              ),
              items: _keuskupans
                  .map(
                    (k) => DropdownMenuItem(
                      value: k.id,
                      child: Text(k.nama, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: _memberKeuskupanId != null
                  ? null
                  : (id) => setState(() {
                      _selectedKeuskupan = _keuskupans.firstWhere(
                        (k) => k.id == id,
                      );
                    }),
            ),
            const SizedBox(height: 16),
            AkunPickerButton(
              akuns: _akuns,
              selected: _selectedAkunId != null
                  ? _akuns.cast<Akun?>().firstWhere((a) => a?.id == _selectedAkunId, orElse: () => null)
                  : null,
              label: 'Akun *',
              onChanged: (a) => setState(() => _selectedAkunId = a.id),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _MonthField(
                    label: 'Bulan Awal',
                    value: _startMonth,
                    onChanged: (date) => setState(() => _startMonth = date),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MonthField(
                    label: 'Bulan Akhir',
                    value: _endMonth,
                    onChanged: (date) => setState(() => _endMonth = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ReportButton(
              icon: Icons.menu_book,
              label: 'Buku Besar',
              onPressed: _openBukuBesar,
              backgroundColor: successGreen,
            ),
            const SizedBox(height: 24),
            _ReportButton(
              icon: Icons.balance,
              label: 'Neraca Saldo',
              onPressed: () => _openLaporan(0),
            ),
            const SizedBox(height: 10),
            _ReportButton(
              icon: Icons.account_balance,
              label: 'Neraca',
              onPressed: () => _openLaporan(1),
            ),
            const SizedBox(height: 10),
            _ReportButton(
              icon: Icons.trending_up,
              label: 'Laporan Aktivitas',
              onPressed: () => _openLaporan(2),
            ),
            const SizedBox(height: 10),
            _ReportButton(
              icon: Icons.savings,
              label: 'Aset Neto',
              onPressed: () => _openLaporan(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const _MonthField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Bulan sebelumnya',
            onPressed: () => onChanged(DateTime(value.year, value.month - 1)),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              '${monthNamesId[value.month - 1]} ${value.year}',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            tooltip: 'Bulan berikutnya',
            onPressed: () => onChanged(DateTime(value.year, value.month + 1)),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _ReportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const _ReportButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      style: backgroundColor != null
          ? FilledButton.styleFrom(backgroundColor: backgroundColor)
          : null,
      icon: Icon(icon),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(label),
        ),
      ),
    );
  }
}
