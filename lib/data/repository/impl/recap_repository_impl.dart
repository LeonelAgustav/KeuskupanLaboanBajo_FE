import 'package:drift/drift.dart';
import '../../local/app_database.dart';
import '../../models/recap_models.dart';
import '../interfaces/recap_repository.dart';

class RecapRepositoryImpl implements RecapRepository {
  final AppDatabase db;
  RecapRepositoryImpl(this.db);

  @override
  Future<RecapKeuskupanResult> getKeuskupanRecap(
    String keuskupanId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rows = await db.customSelect(
      '''
      SELECT COALESCE(SUM(dj.debit), 0) AS total_debit,
             COALESCE(SUM(dj.kredit), 0) AS total_kredit
      FROM detil_jurnals dj
      INNER JOIN jurnals j ON dj.jurnal_id = j.id
      WHERE j.keuskupan_id = ?
        AND j.tanggal >= ?
        AND j.tanggal < ?
        AND j.deleted_at IS NULL
        AND dj.deleted_at IS NULL
      ''',
      variables: [
        Variable.withString(keuskupanId),
        Variable.withDateTime(startDate),
        Variable.withDateTime(endDate),
      ],
    ).get();

    if (rows.isEmpty) {
      return const RecapKeuskupanResult(totalDebit: 0, totalKredit: 0);
    }
    final r = rows.first;
    return RecapKeuskupanResult(
      totalDebit: (r.read<double>('total_debit')),
      totalKredit: (r.read<double>('total_kredit')),
    );
  }

  @override
  Future<List<RecapParokiSummary>> getParokiRecapList(
    String keuskupanId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rows = await db.customSelect(
      '''
      SELECT p.id   AS paroki_id,
             p.nama AS paroki_nama,
             COALESCE(sub.total_debit, 0)  AS total_debit,
             COALESCE(sub.total_kredit, 0) AS total_kredit
      FROM parokis p
      LEFT JOIN (
        SELECT dj.paroki_id,
               SUM(dj.debit)  AS total_debit,
               SUM(dj.kredit) AS total_kredit
        FROM detil_jurnals dj
        INNER JOIN jurnals j ON dj.jurnal_id = j.id
        WHERE j.tanggal >= ?
          AND j.tanggal < ?
          AND j.deleted_at IS NULL
          AND dj.deleted_at IS NULL
        GROUP BY dj.paroki_id
      ) sub ON sub.paroki_id = p.id
      WHERE p.keuskupan_id = ?
        AND p.deleted_at IS NULL
      ORDER BY p.nama
      ''',
      variables: [
        Variable.withDateTime(startDate),
        Variable.withDateTime(endDate),
        Variable.withString(keuskupanId),
      ],
    ).get();

    return rows.map((r) => RecapParokiSummary(
      parokiId: r.read<String>('paroki_id'),
      parokiNama: r.read<String>('paroki_nama'),
      totalDebit: r.read<double>('total_debit'),
      totalKredit: r.read<double>('total_kredit'),
    )).toList();
  }

  @override
  Future<List<RecapAkunDetail>> getParokiRecapDetail(
    String parokiId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rows = await db.customSelect(
      '''
      SELECT a.id   AS akun_id,
             a.kode AS akun_kode,
             a.nama AS akun_nama,
             je.id   AS jenis_id,
             je.nama AS jenis_nama,
             COALESCE(SUM(dj.debit), 0)  AS total_debit,
             COALESCE(SUM(dj.kredit), 0) AS total_kredit
      FROM detil_jurnals dj
      INNER JOIN jurnals j  ON dj.jurnal_id = j.id
      INNER JOIN akuns   a  ON dj.akun_id   = a.id
      INNER JOIN jenis   je ON a.jenis_id   = je.id
      WHERE dj.paroki_id = ?
        AND j.tanggal >= ?
        AND j.tanggal < ?
        AND j.deleted_at IS NULL
        AND dj.deleted_at IS NULL
        AND a.deleted_at  IS NULL
      GROUP BY a.id, a.kode, a.nama, je.id, je.nama
      ORDER BY je.nama, a.kode
      ''',
      variables: [
        Variable.withString(parokiId),
        Variable.withDateTime(startDate),
        Variable.withDateTime(endDate),
      ],
    ).get();

    return rows.map((r) => RecapAkunDetail(
      akunId: r.read<String>('akun_id'),
      akunKode: r.read<String>('akun_kode'),
      akunNama: r.read<String>('akun_nama'),
      jenisId: r.read<String>('jenis_id'),
      jenisNama: r.read<String>('jenis_nama'),
      totalDebit: r.read<double>('total_debit'),
      totalKredit: r.read<double>('total_kredit'),
    )).toList();
  }
}
