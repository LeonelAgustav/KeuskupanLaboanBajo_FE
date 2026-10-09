import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme.dart';
import '../../../core/auth/token_storage.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repository/impl/jurnal_repository_impl.dart';
import '../../../data/repository/impl/master_repository_impl.dart';
import '../cubit/jurnal_cubit.dart';
import 'jurnal_form_screen.dart';
import 'jurnal_detail_screen.dart';
import '../../sync/widgets/sync_indicator.dart';

class JurnalListScreen extends StatelessWidget {
  final AppDatabase db;
  final TokenStorageI tokenStorage;
  const JurnalListScreen({super.key, required this.db, required this.tokenStorage});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JurnalCubit(
        db: db,
        jurnalRepo: JurnalRepositoryImpl(db, tokenStorage: tokenStorage),
        keuskupanRepo: KeuskupanRepositoryImpl(db),
        tokenStorage: tokenStorage,
      )..load(),
      child: _JurnalView(tokenStorage: tokenStorage),
    );
  }
}

class _JurnalView extends StatefulWidget {
  final TokenStorageI tokenStorage;
  const _JurnalView({required this.tokenStorage});
  @override
  State<_JurnalView> createState() => _JurnalViewState();
}

class _JurnalViewState extends State<_JurnalView> {
  static const _monthAbbr = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  int _filter = 0; // 0 semua, 1 pending, 2 synced
  String? _monthFilter; // 'YYYY-MM'
  String? _jenisFilter; // Pendapatan / Pengeluaran / Campuran

  String? _jenisOf(List<DetilJurnal> detils) {
    if (detils.isEmpty) return null;
    final allKredit = detils.every((d) => (d.kredit ?? 0) > 0 && (d.debit ?? 0) == 0);
    final allDebit = detils.every((d) => (d.debit ?? 0) > 0 && (d.kredit ?? 0) == 0);
    if (allKredit) return 'Pendapatan';
    if (allDebit) return 'Pengeluaran';
    return 'Campuran';
  }

  bool _matches(Jurnal j, List<DetilJurnal> detils) {
    if (_filter == 1 && j.isSynced) return false;
    if (_filter == 2 && !j.isSynced) return false;
    if (_monthFilter != null && j.tanggal.toIso8601String().substring(0, 7) != _monthFilter) return false;
    if (_jenisFilter != null && _jenisOf(detils) != _jenisFilter) return false;
    return true;
  }

  String _formatMonth(String ym) {
    final parts = ym.split('-');
    final m = int.tryParse(parts[1]) ?? 1;
    return '${_monthAbbr[m - 1]} ${parts[0]}';
  }

  String _formatDate(DateTime d) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatRupiah(double v) {
    final s = v.abs().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $s';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<JurnalCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jurnal'),
        actions: [
          BlocBuilder<JurnalCubit, JurnalState>(
            builder: (c, s) {
              final pending = s is JurnalLoaded ? s.pending : 0;
              final conflicts = s is JurnalLoaded ? s.conflicts : 0;
              if (conflicts > 0) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(c).showSnackBar(SnackBar(
                    content: Text('⚠️ Konflik duplikat: $conflicts data gagal sync'),
                    backgroundColor: dangerRed,
                    duration: const Duration(seconds: 5),
                  ));
                });
              }
              return SyncIndicator(pending: pending, conflicts: conflicts, onTap: () => cubit.load());
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => cubit.load()),
        ],
      ),
      body: Column(
        children: [
          // Filter status & jenis (Scrollable Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(children: [
              _FilterChip(label: 'Semua Status', selected: _filter == 0, onTap: () => setState(() => _filter = 0)),
              const SizedBox(width: 8),
              _FilterChip(label: 'Pending', selected: _filter == 1, onTap: () => setState(() => _filter = 1)),
              const SizedBox(width: 8),
              _FilterChip(label: 'Synced', selected: _filter == 2, onTap: () => setState(() => _filter = 2)),
              const SizedBox(width: 16),
              Container(width: 1, height: 20, color: Colors.grey[300]),
              const SizedBox(width: 16),
              _FilterChip(label: 'Semua Jenis', selected: _jenisFilter == null, onTap: () => setState(() => _jenisFilter = null)),
              const SizedBox(width: 8),
              _FilterChip(label: 'Pendapatan', selected: _jenisFilter == 'Pendapatan', onTap: () => setState(() => _jenisFilter = 'Pendapatan')),
              const SizedBox(width: 8),
              _FilterChip(label: 'Pengeluaran', selected: _jenisFilter == 'Pengeluaran', onTap: () => setState(() => _jenisFilter = 'Pengeluaran')),
              const SizedBox(width: 8),
              _FilterChip(label: 'Campuran', selected: _jenisFilter == 'Campuran', onTap: () => setState(() => _jenisFilter = 'Campuran')),
            ]),
          ),
          // Filter Periode / Bulan (Action Chip)
          BlocBuilder<JurnalCubit, JurnalState>(
            builder: (c, s) {
              if (s is! JurnalLoaded || s.jurnals.isEmpty) return const SizedBox.shrink();
              final months = <String>{for (final j in s.jurnals) j.tanggal.toIso8601String().substring(0, 7)}.toList()..sort((a, b) => b.compareTo(a));
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Text(
                      _monthFilter == null ? 'Periode: Semua Waktu' : 'Periode: ${_formatMonth(_monthFilter!)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    const Spacer(),
                    if (_monthFilter != null)
                      TextButton(
                        onPressed: () => setState(() => _monthFilter = null),
                        child: const Text('Reset', style: TextStyle(fontSize: 12, color: Colors.red)),
                      ),
                    PopupMenuButton<String?>(
                      icon: const Icon(Icons.calendar_month, color: ungu, size: 20),
                      tooltip: 'Pilih Bulan',
                      onSelected: (v) => setState(() => _monthFilter = v),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: null, child: Text('Semua Bulan')),
                        ...months.map((m) => PopupMenuItem(value: m, child: Text(_formatMonth(m)))),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<JurnalCubit, JurnalState>(
              builder: (c, s) {
                if (s is JurnalLoading) return const Center(child: CircularProgressIndicator());
                if (s is JurnalError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, size: 48, color: dangerRed),
                  const SizedBox(height: 8),
                  Text('Gagal memuat data', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textDark)),
                  Text(s.msg, style: const TextStyle(fontSize: 12, color: abuHangat)),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(icon: const Icon(Icons.refresh), label: const Text('Coba Lagi'), onPressed: () => cubit.load()),
                ]));
                if (s is JurnalLoaded) {
                  if (s.jurnals.isEmpty) {
                    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 80, height: 80, decoration: BoxDecoration(color: ungu.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.book_outlined, size: 40, color: ungu)),
                      const SizedBox(height: 20),
                      const Text('Belum ada jurnal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textDark)),
                      const SizedBox(height: 6),
                      const Text('Catat transaksi keuangan pertama Anda.\nData tersimpan offline dan otomatis sinkronisasi.', style: TextStyle(fontSize: 13, color: abuHangat), textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      FilledButton.icon(onPressed: () => _openForm(context), icon: const Icon(Icons.add), label: const Text('Buat Jurnal')),
                    ])));
                  }
                  final list = s.jurnals.where((j) => _matches(j, s.detils[j.id] ?? [])).toList();
                  if (list.isEmpty) {
                    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.search_off, size: 48, color: abuHangat),
                      const SizedBox(height: 8),
                      const Text('Tidak ada jurnal yang cocok', style: TextStyle(fontSize: 13, color: abuHangat)),
                    ]));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (c, i) {
                      final j = list[i];
                      final detils = s.detils[j.id] ?? [];
                      String? jenisLabel;
                      Color? jenisColor;
                      double totalNominal = 0;
                      if (detils.isNotEmpty) {
                        final allKredit = detils.every((d) => (d.kredit ?? 0) > 0 && (d.debit ?? 0) == 0);
                        final allDebit = detils.every((d) => (d.debit ?? 0) > 0 && (d.kredit ?? 0) == 0);
                        for (final d in detils) { totalNominal += (d.kredit ?? 0) + (d.debit ?? 0); }
                        if (allKredit) { jenisLabel = 'Pendapatan'; jenisColor = successGreen; }
                        else if (allDebit) { jenisLabel = 'Pengeluaran'; jenisColor = merahPengeluaran; }
                        else { jenisLabel = 'Campuran'; jenisColor = Colors.grey; }
                      }
                      return Card(
                        elevation: 0.5,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JurnalDetailScreen(jurnalId: j.id, db: context.read<JurnalCubit>().db, tokenStorage: widget.tokenStorage))),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              // Left: icon + date
                              Container(width: 44, height: 56, decoration: BoxDecoration(color: (jenisColor ?? ungu).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text('${j.tanggal.day}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: jenisColor ?? ungu)),
                                Text(_formatDate(j.tanggal).split(' ')[1], style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: jenisColor ?? ungu)),
                              ])),
                              const SizedBox(width: 12),
                              // Middle: info
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Expanded(child: Text(j.noBukti ?? '-', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textDark), overflow: TextOverflow.ellipsis)),
                                  if (jenisLabel != null) Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: (jenisColor!).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)), child: Text(jenisLabel, style: TextStyle(color: jenisColor, fontSize: 10, fontWeight: FontWeight.w700))),
                                ]),
                                const SizedBox(height: 3),
                                Text(j.deskripsi ?? 'Tanpa deskripsi', style: const TextStyle(fontSize: 12, color: abuHangat), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Row(children: [
                                  // Sync status badge
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: (j.isSynced ? successGreen : warningOrange).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(j.isSynced ? Icons.check_circle_outline : Icons.sync, size: 11, color: j.isSynced ? successGreen : warningOrange),
                                    const SizedBox(width: 3),
                                    Text(j.isSynced ? 'Tersinkron' : 'Pending', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: j.isSynced ? successGreen : warningOrange)),
                                  ])),
                                  const SizedBox(width: 8),
                                  Text('${detils.length} detil • ${totalNominal > 0 ? _formatRupiah(totalNominal) : '-'}', style: const TextStyle(fontSize: 11, color: textMuted2)),
                                ]),
                              ])),
                              // Right: chevron + delete
                              Column(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.chevron_right, size: 18, color: textMuted2),
                                const SizedBox(height: 4),
                                IconButton(icon: const Icon(Icons.delete_outline, color: dangerRed, size: 18), constraints: const BoxConstraints(minWidth: 28, minHeight: 28), padding: EdgeInsets.zero, onPressed: () => cubit.deleteJurnal(j.id)),
                              ]),
                            ]),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ungu,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Jurnal'),
      ),
    );
  }

  void _openForm(BuildContext context) async {
    final cubit = context.read<JurnalCubit>();
    final keuskupans = await cubit.getKeuskupans();
    if (!context.mounted) return;
    final res = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => JurnalFormScreen(keuskupans: keuskupans, cubit: cubit)));
    if (res == true) cubit.load();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ungu : surfaceWhite,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : textSecondary))),
      ),
    );
  }
}
