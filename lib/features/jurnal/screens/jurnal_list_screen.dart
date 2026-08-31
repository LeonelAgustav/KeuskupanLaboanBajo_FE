import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repository/impl/jurnal_repository_impl.dart';
import '../../../data/repository/impl/master_repository_impl.dart';
import '../cubit/jurnal_cubit.dart';
import 'jurnal_form_screen.dart';
import 'jurnal_detail_screen.dart';
import '../../sync/widgets/sync_indicator.dart';

class JurnalListScreen extends StatelessWidget {
  final AppDatabase db;
  const JurnalListScreen({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JurnalCubit(
        db: db,
        jurnalRepo: JurnalRepositoryImpl(db),
        keuskupanRepo: KeuskupanRepositoryImpl(db),
      )..load(),
      child: const _JurnalView(),
    );
  }
}

class _JurnalView extends StatelessWidget {
  const _JurnalView();
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<JurnalCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jurnal - Offline First'),
        actions: [
          BlocBuilder<JurnalCubit, JurnalState>(
            builder: (c, s) {
              final pending = s is JurnalLoaded ? s.pending : 0;
              return SyncIndicator(pending: pending, onTap: () => cubit.load());
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => cubit.load()),
        ],
      ),
      body: BlocBuilder<JurnalCubit, JurnalState>(
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
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: s.jurnals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (c, i) {
                final j = s.jurnals[i];
                final detils = s.detils[j.id] ?? [];
                return Card(
                  child: ListTile(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JurnalDetailScreen(jurnalId: j.id, db: context.read<JurnalCubit>().db))),
                    title: Text(j.deskripsi ?? 'Tanpa deskripsi', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Tgl: ${j.tanggal.toString().substring(0, 10)} • ${j.noBukti ?? '-'}'),
                      Text('isSynced: ${j.isSynced ? "✓" : "pending"}', style: TextStyle(color: j.isSynced ? Colors.green : Colors.orange, fontSize: 12)),
                      if (detils.isNotEmpty) Text('${detils.length} detil • Tap untuk lihat', style: const TextStyle(fontSize: 11, color: Colors.deepPurple)),
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
