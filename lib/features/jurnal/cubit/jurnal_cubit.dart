import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repository/impl/jurnal_repository_impl.dart';
import '../../../data/repository/impl/master_repository_impl.dart';

sealed class JurnalState {}
class JurnalInitial extends JurnalState {}
class JurnalLoading extends JurnalState {}
class JurnalLoaded extends JurnalState {
  final List<Jurnal> jurnals;
  final Map<String, List<DetilJurnal>> detils;
  final int pending;
  JurnalLoaded(this.jurnals, this.detils, this.pending);
}
class JurnalError extends JurnalState {
  final String msg;
  JurnalError(this.msg);
}

class JurnalCubit extends Cubit<JurnalState> {
  final JurnalRepositoryImpl jurnalRepo;
  final KeuskupanRepositoryImpl keuskupanRepo;
  final AppDatabase db;
  JurnalCubit({required this.db, required this.jurnalRepo, required this.keuskupanRepo}) : super(JurnalInitial());

  Future<void> load() async {
    emit(JurnalLoading());
    try {
      final list = await jurnalRepo.getAll();
      final map = <String, List<DetilJurnal>>{};
      for (final j in list) {
        map[j.id] = await jurnalRepo.getDetils(j.id);
      }
      final pending = await jurnalRepo.pendingCount();
      emit(JurnalLoaded(list, map, pending));
    } catch (e) {
      emit(JurnalError(e.toString()));
    }
  }

  Future<String> createJurnal({required String keuskupanId, required DateTime tanggal, String? deskripsi, String? noBukti, List<DetilJurnalsCompanion> detils = const []}) async {
    final id = await jurnalRepo.create(keuskupanId: keuskupanId, tanggal: tanggal, deskripsi: deskripsi, noBukti: noBukti, detils: detils);
    await load();
    return id;
  }

  Future<List<Akun>> getAkuns() => AkunRepositoryImpl(db).getAll();
  Future<List<Paroki>> getParokis() => ParokiRepositoryImpl(db).getAll();
  Future<List<Jeni>> getJenis() => JenisRepositoryImpl(db).getAll();

  Future<void> deleteJurnal(String id) async {
    await jurnalRepo.delete(id);
    await load();
  }

  Future<List<Keuskupan>> getKeuskupans() => keuskupanRepo.getAll();
  Future<String> createKeuskupan(String nama, String alamat) => keuskupanRepo.create(nama: nama, alamat: alamat);
}
