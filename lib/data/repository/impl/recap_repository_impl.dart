import 'package:drift/drift.dart';
import '../../local/app_database.dart';
import '../../models/recap_models.dart';
import '../interfaces/recap_repository.dart';

class RecapRepositoryImpl implements RecapRepository {
  final AppDatabase db;
  RecapRepositoryImpl(this.db);

  // Satu baris format baru (akun_debit_id/akun_kredit_id/jumlah) dipecah jadi 2 leg;
  // baris format lama (akun_id/debit/kredit) tetap 1 leg.
  // shortcut: expand per query, bukan VIEW/backfill. Ganti ke backfill saat kolom lama di-drop.
  static const _legs = '''
    SELECT id, jurnal_id, paroki_id, keterangan, created_at, deleted_at,
           COALESCE(akun_debit_id, akun_id) AS akun_id,
           CASE WHEN akun_debit_id IS NOT NULL THEN COALESCE(jumlah, 0) ELSE COALESCE(debit, 0) END AS debit,
           CASE WHEN akun_debit_id IS NOT NULL THEN 0.0 ELSE COALESCE(kredit, 0) END AS kredit
    FROM detil_jurnals
    UNION ALL
    SELECT id, jurnal_id, paroki_id, keterangan, created_at, deleted_at,
           akun_kredit_id AS akun_id,
           0.0 AS debit,
           COALESCE(jumlah, 0) AS kredit
    FROM detil_jurnals
    WHERE akun_kredit_id IS NOT NULL
  ''';

  // Filter by paroki_id di detil_jurnal (satu jurnal bisa punya beberapa paroki)
  String _parokiFilter({int? parokiId}) =>
      (parokiId != null && parokiId > 0) ? ' AND dj.paroki_id = ? ' : ' ';

  List<Variable> _extraVars(int? parokiId) =>
      (parokiId != null && parokiId > 0) ? [Variable.withInt(parokiId)] : [];

  @override
  Future<RecapKeuskupanResult> getKeuskupanRecap(
    int keuskupanId,
    DateTime startDate,
    DateTime endDate, {
    int? parokiId,
  }) async {
    final rows = await db
        .customSelect(
          '''
      SELECT COALESCE(SUM(dj.debit), 0) AS total_debit,
             COALESCE(SUM(dj.kredit), 0) AS total_kredit
      FROM ($_legs) dj
      INNER JOIN jurnals j ON dj.jurnal_id = j.id
      WHERE j.keuskupan_id = ?
        AND j.tanggal >= ?
        AND j.tanggal < ?
        AND j.deleted_at IS NULL
        AND dj.deleted_at IS NULL
      ${_parokiFilter(parokiId: parokiId)}
      ''',
          variables: [
            Variable.withInt(keuskupanId),
            Variable.withString(startDate.toIso8601String().substring(0, 10)),
            Variable.withString(endDate.toIso8601String().substring(0, 10)),
            ..._extraVars(parokiId),
          ],
        )
        .get();

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
  Future<List<MonthlyRecap>> getMonthlyRecap(
    int keuskupanId,
    int year, {
    int? parokiId,
  }) async {
    final rows = await db
        .customSelect(
          '''
      SELECT 
        CAST(strftime('%m', j.tanggal) AS INTEGER) as bulan,
        COALESCE(SUM(dj.debit), 0) AS total_debit,
        COALESCE(SUM(dj.kredit), 0) AS total_kredit
      FROM ($_legs) dj
      INNER JOIN jurnals j ON dj.jurnal_id = j.id
      WHERE j.keuskupan_id = ?
        AND strftime('%Y', j.tanggal) = ?
        AND j.deleted_at IS NULL
        AND dj.deleted_at IS NULL
      ${_parokiFilter(parokiId: parokiId)}
      GROUP BY bulan
      ORDER BY bulan
      ''',
          variables: [
            Variable.withInt(keuskupanId),
            Variable.withString(year.toString()),
            ..._extraVars(parokiId),
          ],
        )
        .get();

    return rows
        .map(
          (r) => MonthlyRecap(
            bulan: r.read<int>('bulan'),
            totalDebit: r.read<double>('total_debit'),
            totalKredit: r.read<double>('total_kredit'),
          ),
        )
        .toList();
  }

  @override
  Future<List<WeeklyRecap>> getWeeklyRecap(
    int keuskupanId,
    int year,
    int month, {
    int? parokiId,
  }) async {
    final monthStr = month.toString().padLeft(2, '0');
    final rows = await db
        .customSelect(
          '''
      SELECT 
        CASE
          WHEN CAST(strftime('%d', j.tanggal) AS INTEGER) BETWEEN 1 AND 7 THEN 1
          WHEN CAST(strftime('%d', j.tanggal) AS INTEGER) BETWEEN 8 AND 14 THEN 2
          WHEN CAST(strftime('%d', j.tanggal) AS INTEGER) BETWEEN 15 AND 21 THEN 3
          WHEN CAST(strftime('%d', j.tanggal) AS INTEGER) BETWEEN 22 AND 28 THEN 4
          ELSE 5
        END as minggu,
        COALESCE(SUM(dj.debit), 0) AS total_debit,
        COALESCE(SUM(dj.kredit), 0) AS total_kredit
      FROM ($_legs) dj
      INNER JOIN jurnals j ON dj.jurnal_id = j.id
      WHERE j.keuskupan_id = ?
        AND strftime('%Y', j.tanggal) = ?
        AND strftime('%m', j.tanggal) = ?
        AND j.deleted_at IS NULL
        AND dj.deleted_at IS NULL
      ${_parokiFilter(parokiId: parokiId)}
      GROUP BY minggu
      ORDER BY minggu
      ''',
          variables: [
            Variable.withInt(keuskupanId),
            Variable.withString(year.toString()),
            Variable.withString(monthStr),
            ..._extraVars(parokiId),
          ],
        )
        .get();

    return rows
        .map(
          (r) => WeeklyRecap(
            minggu: r.read<int>('minggu'),
            totalDebit: r.read<double>('total_debit'),
            totalKredit: r.read<double>('total_kredit'),
          ),
        )
        .toList();
  }

  @override
  Future<BukuBesarResult> getBukuBesar(
    int keuskupanId,
    int akunId,
    DateTime startDate,
    DateTime endDate, {
    int? parokiId,
  }) async {
    // Ambil akun info
    final akunRows = await db
        .customSelect(
          'SELECT id, kode, nama FROM akuns WHERE id = ? AND deleted_at IS NULL',
          variables: [Variable.withInt(akunId)],
        )
        .get();
    if (akunRows.isEmpty) {
      return BukuBesarResult(
        akunId: akunId,
        akunKode: '',
        akunNama: '',
        saldoAwal: 0,
        mutasi: const [],
        saldoAkhir: 0,
      );
    }
    final kode = akunRows.first.read<String>('kode');
    final nama = akunRows.first.read<String>('nama');

    // Sisi normal berdasarkan kode awalan (1/5 = debit normal, 2/3/4 = kredit normal)
    final prefix = kode.isNotEmpty ? kode[0] : '1';
    final debitNormal = prefix == '1' || prefix == '5';

    final startStr = startDate.toIso8601String().substring(0, 10);
    final endStr = endDate.toIso8601String().substring(0, 10);

    final parokiFilter = _parokiFilter(parokiId: parokiId);
    final parokiVars = _extraVars(parokiId);

    // Saldo awal: akumulasi semua transaksi sebelum tanggal 1 bulan yang dipilih
    final awalRows = await db
        .customSelect(
          '''
      SELECT COALESCE(SUM(dj.debit), 0) AS total_debit,
             COALESCE(SUM(dj.kredit), 0) AS total_kredit
      FROM ($_legs) dj
      INNER JOIN jurnals j ON dj.jurnal_id = j.id
      WHERE j.keuskupan_id = ?
        AND dj.akun_id = ?
        AND j.tanggal < ?
        AND j.deleted_at IS NULL
        AND dj.deleted_at IS NULL
      $parokiFilter
      ''',
          variables: [
            Variable.withInt(keuskupanId),
            Variable.withInt(akunId),
            Variable.withString(startStr),
            ...parokiVars,
          ],
        )
        .get();
    final awalDebit = awalRows.isEmpty
        ? 0.0
        : awalRows.first.read<double>('total_debit');
    final awalKredit = awalRows.isEmpty
        ? 0.0
        : awalRows.first.read<double>('total_kredit');
    final saldoAwal = debitNormal
        ? (awalDebit - awalKredit)
        : (awalKredit - awalDebit);

    // Mutasi dalam periode (urut tanggal, created_at)
    final mutRows = await db
        .customSelect(
          '''
      SELECT j.tanggal AS tanggal,
             j.no_bukti AS no_bukti,
             j.deskripsi AS deskripsi,
             COALESCE(dj.debit, 0) AS debit,
             COALESCE(dj.kredit, 0) AS kredit,
             dj.keterangan AS keterangan
      FROM ($_legs) dj
      INNER JOIN jurnals j ON dj.jurnal_id = j.id
      WHERE j.keuskupan_id = ?
        AND dj.akun_id = ?
        AND j.tanggal >= ?
        AND j.tanggal < ?
        AND j.deleted_at IS NULL
        AND dj.deleted_at IS NULL
      $parokiFilter
      ORDER BY j.tanggal, dj.created_at, dj.id
      ''',
          variables: [
            Variable.withInt(keuskupanId),
            Variable.withInt(akunId),
            Variable.withString(startStr),
            Variable.withString(endStr),
            ...parokiVars,
          ],
        )
        .get();

    final mutasi = <BukuBesarMutasi>[];
    var saldo = saldoAwal;
    for (final r in mutRows) {
      final d = r.read<double>('debit');
      final k = r.read<double>('kredit');
      saldo = debitNormal ? saldo + d - k : saldo + k - d;
      final uraian =
          (r.readNullable<String>('deskripsi')) ??
          (r.readNullable<String>('keterangan'));
      mutasi.add(
        BukuBesarMutasi(
          tanggal: DateTime.parse(r.read<String>('tanggal')),
          noBukti: r.readNullable<String>('no_bukti'),
          uraian: uraian,
          debit: d,
          kredit: k,
          saldo: saldo,
        ),
      );
    }

    return BukuBesarResult(
      akunId: akunId,
      akunKode: kode,
      akunNama: nama,
      saldoAwal: saldoAwal,
      mutasi: mutasi,
      saldoAkhir: saldo,
    );
  }

  @override
  Future<List<NeracaSaldoBaris>> getNeracaSaldo(
    int keuskupanId,
    DateTime startDate,
    DateTime endDate, {
    int? parokiId,
  }) async {
    final startStr = startDate.toIso8601String().substring(0, 10);
    final endStr = endDate.toIso8601String().substring(0, 10);

    // Satu agregasi per akun x periode(awal/mutasi) x pembatasan.
    // Tanda sisi normal dihitung di Dart supaya SQL tetap satu bentuk.
    final rows = await db
        .customSelect(
          '''
      SELECT a.kode AS kode,
             a.nama AS nama,
             j.tanggal < ? AS is_awal,
             j.jenis_pembatasan AS pembatasan,
             COALESCE(SUM(dj.debit), 0)  AS total_debit,
             COALESCE(SUM(dj.kredit), 0) AS total_kredit
      FROM ($_legs) dj
      INNER JOIN jurnals j ON dj.jurnal_id = j.id
      INNER JOIN akuns   a ON dj.akun_id   = a.id
      WHERE j.keuskupan_id = ?
        AND j.tanggal < ?
        AND j.deleted_at IS NULL
        AND dj.deleted_at IS NULL
        AND a.deleted_at IS NULL
      ${_parokiFilter(parokiId: parokiId)}
      GROUP BY a.kode, a.nama, is_awal, pembatasan
      ORDER BY a.kode
      ''',
          variables: [
            Variable.withString(startStr),
            Variable.withInt(keuskupanId),
            Variable.withString(endStr),
            ..._extraVars(parokiId),
          ],
        )
        .get();

    final byKode = <String, NeracaSaldoBaris>{};
    for (final r in rows) {
      final kode = r.read<String>('kode');
      final prev =
          byKode[kode] ??
          NeracaSaldoBaris(
            kode: kode,
            nama: r.read<String>('nama'),
            debitNormal: kode.isNotEmpty && (kode[0] == '1' || kode[0] == '5'),
          );
      final signed = prev.debitNormal
          ? r.read<double>('total_debit') - r.read<double>('total_kredit')
          : r.read<double>('total_kredit') - r.read<double>('total_debit');
      final awal = r.read<int>('is_awal') == 1;
      final dengan = r.read<String>('pembatasan') == 'Dengan Pembatasan';
      byKode[kode] = NeracaSaldoBaris(
        kode: prev.kode,
        nama: prev.nama,
        debitNormal: prev.debitNormal,
        awalTanpa: prev.awalTanpa + (awal && !dengan ? signed : 0),
        awalDengan: prev.awalDengan + (awal && dengan ? signed : 0),
        mutTanpa: prev.mutTanpa + (!awal && !dengan ? signed : 0),
        mutDengan: prev.mutDengan + (!awal && dengan ? signed : 0),
      );
    }
    return byKode.values.toList()..sort((a, b) => a.kode.compareTo(b.kode));
  }

  @override
  Future<List<RecapParokiSummary>> getParokiRecapList(
    int keuskupanId,
    DateTime startDate,
    DateTime endDate, {
    int? parokiId,
  }) async {
    // MEMBER: hanya return paroki mereka, meski belum ada transaksi
    if (parokiId != null && parokiId > 0) {
      final pRows = await db
          .customSelect(
            'SELECT id, nama FROM parokis WHERE id = ? AND deleted_at IS NULL',
            variables: [Variable.withInt(parokiId)],
          )
          .get();
      final result = <RecapParokiSummary>[];
      for (final pr in pRows) {
        final subRows = await db
            .customSelect(
              '''
          SELECT COALESCE(SUM(dj.debit), 0) AS total_debit,
                 COALESCE(SUM(dj.kredit), 0) AS total_kredit
          FROM ($_legs) dj
          INNER JOIN jurnals j ON dj.jurnal_id = j.id
          WHERE dj.paroki_id = ?
            AND j.tanggal >= ?
            AND j.tanggal < ?
            AND j.deleted_at IS NULL
            AND dj.deleted_at IS NULL
          ''',
              variables: [
                Variable.withInt(parokiId),
                Variable.withString(
                  startDate.toIso8601String().substring(0, 10),
                ),
                Variable.withString(endDate.toIso8601String().substring(0, 10)),
              ],
            )
            .get();
        final debit = subRows.isEmpty
            ? 0.0
            : subRows.first.read<double>('total_debit');
        final kredit = subRows.isEmpty
            ? 0.0
            : subRows.first.read<double>('total_kredit');
        result.add(
          RecapParokiSummary(
            parokiId: pr.read<int>('id'),
            parokiNama: pr.read<String>('nama'),
            totalDebit: debit,
            totalKredit: kredit,
          ),
        );
      }
      return result;
    }

    final rows = await db
        .customSelect(
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
        FROM ($_legs) dj
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
            Variable.withString(startDate.toIso8601String().substring(0, 10)),
            Variable.withString(endDate.toIso8601String().substring(0, 10)),
            Variable.withInt(keuskupanId),
          ],
        )
        .get();

    return rows
        .map(
          (r) => RecapParokiSummary(
            parokiId: r.read<int>('paroki_id'),
            parokiNama: r.read<String>('paroki_nama'),
            totalDebit: r.read<double>('total_debit'),
            totalKredit: r.read<double>('total_kredit'),
          ),
        )
        .toList();
  }

  @override
  Future<List<RecapAkunDetail>> getParokiRecapDetail(
    int parokiId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final rows = await db
        .customSelect(
          '''
      SELECT a.id   AS akun_id,
             a.kode AS akun_kode,
             a.nama AS akun_nama,
             je.id   AS jenis_id,
             je.nama AS jenis_nama,
             COALESCE(SUM(dj.debit), 0)  AS total_debit,
             COALESCE(SUM(dj.kredit), 0) AS total_kredit
      FROM ($_legs) dj
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
            Variable.withInt(parokiId),
            Variable.withString(startDate.toIso8601String().substring(0, 10)),
            Variable.withString(endDate.toIso8601String().substring(0, 10)),
          ],
        )
        .get();

    return rows
        .map(
          (r) => RecapAkunDetail(
            akunId: r.read<int>('akun_id'),
            akunKode: r.read<String>('akun_kode'),
            akunNama: r.read<String>('akun_nama'),
            jenisId: r.read<int>('jenis_id'),
            jenisNama: r.read<String>('jenis_nama'),
            totalDebit: r.read<double>('total_debit'),
            totalKredit: r.read<double>('total_kredit'),
          ),
        )
        .toList();
  }
}
