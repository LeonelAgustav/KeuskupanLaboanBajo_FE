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
  String _query = '';
  int _filter = 0; // 0 semua, 1 pending, 2 synced

  bool _matches(Jurnal j) {
    if (_filter == 1 && j.isSynced) return false;
    if (_filter == 2 && !j.isSynced) return false;
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    final tgl = j.tanggal.toIso8601String().substring(0, 10);
    return (j.noBukti ?? '').toLowerCase().contains(q) ||
        (j.deskripsi ?? '').toLowerCase().contains(q) ||
        tgl.contains(q);
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
                    backgroundColor: Colors.red,
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
          // Search bar (UI_DESIGN.md §3.2.1)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Cari no bukti / deskripsi / tanggal',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _query = '')),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          // Filter status sync
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Semua')),
                ButtonSegment(value: 1, label: Text('Pending')),
                ButtonSegment(value: 2, label: Text('Synced')),
              ],
              selected: {_filter},
              onSelectionChanged: (s) => setState(() => _filter = s.first),
            ),
          ),
          Expanded(
            child: BlocBuilder<JurnalCubit, JurnalState>(
              builder: (c, s) {
                if (s is JurnalLoading) return const Center(child: CircularProgressIndicator());
                if (s is JurnalError) return Center(child: Text('Error: ${s.msg}', style: const TextStyle(color: Colors.red)));
                if (s is JurnalLoaded) {
                  if (s.jurnals.isEmpty) {
                    return Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.book, size: 64, color: Colors.grey),
                        const Text('Belum ada jurnal'),
                        const SizedBox(height: 8),
                        const Text('Tulis offline, sync otomatis saat online', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Buat Jurnal'), onPressed: () => _openForm(context)),
                      ]),
                    );
                  }
                  final list = s.jurnals.where(_matches).toList();
                  if (list.isEmpty) {
                    return const Center(child: Text('Tidak ada jurnal yang cocok', style: TextStyle(color: Colors.grey)));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (c, i) {
                      final j = list[i];
                      final detils = s.detils[j.id] ?? [];
                      // Tentukan jenis jurnal dari detil: semua kredit > 0 = Pendapatan, semua debit > 0 = Pengeluaran
                      String? jenisLabel;
                      Color? jenisColor;
                      if (detils.isNotEmpty) {
                        final allKredit = detils.every((d) => (d.kredit ?? 0) > 0 && (d.debit ?? 0) == 0);
                        final allDebit = detils.every((d) => (d.debit ?? 0) > 0 && (d.kredit ?? 0) == 0);
                        if (allKredit) {
                          jenisLabel = 'Pendapatan';
                          jenisColor = hijauPendapatan;
                        } else if (allDebit) {
                          jenisLabel = 'Pengeluaran';
                          jenisColor = merahPengeluaran;
                        } else {
                          jenisLabel = 'Campuran';
                          jenisColor = Colors.grey;
                        }
                      }
                      return Card(
                        child: ListTile(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JurnalDetailScreen(jurnalId: j.id, db: context.read<JurnalCubit>().db, tokenStorage: widget.tokenStorage))),
                          title: Text('${j.tanggal.toIso8601String().substring(0, 10)} - ${j.noBukti ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(j.deskripsi ?? 'Tanpa deskripsi', style: const TextStyle(fontSize: 12)),
                            Text('isSynced: ${j.isSynced ? "✓" : "pending"}', style: TextStyle(color: j.isSynced ? Colors.green : orangeKhas, fontSize: 10)),
                            if (detils.isNotEmpty) Wrap(spacing: 6, children: [
                              if (jenisLabel != null) Chip(label: Text(jenisLabel, style: TextStyle(color: jenisColor, fontSize: 10, fontWeight: FontWeight.w600)), backgroundColor: jenisColor!.withValues(alpha: 0.12), side: BorderSide(color: jenisColor), visualDensity: VisualDensity.compact),
                              Text('${detils.length} detil • Tap untuk lihat', style: const TextStyle(fontSize: 11, color: ungu)),
                            ]),
                          ]),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => cubit.deleteJurnal(j.id)),
                          ]),
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