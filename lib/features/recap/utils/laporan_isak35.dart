import '../../../data/models/recap_models.dart';

// Empat laporan ISAK 35 diturunkan dari satu list Neraca Saldo (lihat Struktur_Excel_ISAK35).
// Akun 3xx: kode awalan 302 = Dengan Pembatasan, sisanya Tanpa.
// Akun 4xx/5xx: klasifikasi dari jurnal.jenis_pembatasan.

String _label(NeracaSaldoBaris b) => '${b.kode}  ${b.nama}';
double _sum(Iterable<NeracaSaldoBaris> xs, double Function(NeracaSaldoBaris) f) =>
    xs.fold(0.0, (s, b) => s + f(b));

/// Surplus (defisit) = pendapatan 4xx - beban 5xx; angka sudah bertanda sisi normal.
double _surplus(List<NeracaSaldoBaris> d, double Function(NeracaSaldoBaris) f) =>
    _sum(d.where((b) => b.grup == '4'), f) - _sum(d.where((b) => b.grup == '5'), f);

LaporanTabel buildNeracaSaldo(List<NeracaSaldoBaris> d) {
  List<double?> nums(NeracaSaldoBaris b) {
    double? dk(double v, bool debitCol) => b.debitNormal == debitCol ? v : 0;
    return [
      dk(b.saldoAwal, true), dk(b.saldoAwal, false),
      dk(b.perubahan, true), dk(b.perubahan, false),
      dk(b.saldoAkhir, true), dk(b.saldoAkhir, false),
    ];
  }

  final rows = [for (final b in d) LaporanRow(_label(b), nums: nums(b))];
  final total = List<double>.filled(6, 0);
  for (final r in rows) {
    for (var i = 0; i < 6; i++) {
      total[i] += r.nums[i] ?? 0;
    }
  }
  return LaporanTabel(
    ['Akun', 'Awal Debit', 'Awal Kredit', 'Perubahan Debit', 'Perubahan Kredit', 'Akhir Debit', 'Akhir Kredit'],
    [...rows, LaporanRow('TOTAL', nums: total, isTotal: true)],
  );
}

LaporanTabel buildNeraca(List<NeracaSaldoBaris> d) {
  final rows = <LaporanRow>[];
  List<double> tri(double awal, double akhir) => [awal, akhir - awal, akhir];

  List<double> section(String title, Iterable<NeracaSaldoBaris> xs) {
    final list = xs.toList();
    rows.add(LaporanRow(title, isHeader: true));
    for (final b in list) {
      rows.add(LaporanRow(_label(b), nums: tri(b.saldoAwal, b.saldoAkhir)));
    }
    final t = tri(_sum(list, (b) => b.saldoAwal), _sum(list, (b) => b.saldoAkhir));
    rows.add(LaporanRow('Total $title', nums: t, isTotal: true));
    return t;
  }

  List<double> add(List<double> a, List<double> b) => [for (var i = 0; i < 3; i++) a[i] + b[i]];

  rows.add(const LaporanRow('ASET', isHeader: true));
  final lancar = section('Aset Lancar', d.where((b) => b.kode.startsWith('101')));
  final tetap = section(
    'Aset Tetap',
    d.where((b) => b.grup == '1' && !b.kode.startsWith('101')),
  );
  final aset = add(lancar, tetap);
  rows.add(LaporanRow('TOTAL ASET', nums: aset, isTotal: true));

  rows.add(const LaporanRow('PASIVA', isHeader: true));
  final pendek = section('Liabilitas Jangka Pendek', d.where((b) => b.kode.startsWith('201')));
  final panjang = section(
    'Liabilitas Jangka Panjang',
    d.where((b) => b.grup == '2' && !b.kode.startsWith('201')),
  );
  final liab = add(pendek, panjang);
  rows.add(LaporanRow('Total Liabilitas', nums: liab, isTotal: true));

  // Aset Neto termasuk surplus/defisit berjalan supaya Total Aset = Total Pasiva.
  final an = asetNetoSaldo(d);
  rows.add(const LaporanRow('Aset Neto', isHeader: true));
  final tanpa = tri(an.tanpaAwal, an.tanpaAkhir);
  final dengan = tri(an.denganAwal, an.denganAkhir);
  rows.add(LaporanRow('Aset Neto Tanpa Pembatasan', nums: tanpa));
  rows.add(LaporanRow('Aset Neto Dengan Pembatasan', nums: dengan));
  final totalAn = add(tanpa, dengan);
  rows.add(LaporanRow('Total Aset Neto', nums: totalAn, isTotal: true));
  rows.add(LaporanRow('TOTAL PASIVA', nums: add(liab, totalAn), isTotal: true));

  return LaporanTabel(['Uraian', 'Saldo Awal', 'Periode Berjalan', 'Saldo Akhir'], rows);
}

LaporanTabel buildLapAktivitas(List<NeracaSaldoBaris> d) {
  // Periode lalu tidak ditampilkan; tetap dipakai asetNetoSaldo().
  List<double> three(Iterable<NeracaSaldoBaris> xs) {
    final mt = _sum(xs, (b) => b.mutTanpa), md = _sum(xs, (b) => b.mutDengan);
    return [mt, md, mt + md];
  }

  final rows = <LaporanRow>[];
  List<double> section(String title, String grup) {
    final list = d.where((b) => b.grup == grup).toList();
    rows.add(LaporanRow(title, isHeader: true));
    for (final b in list) {
      rows.add(LaporanRow(_label(b), nums: three([b])));
    }
    final t = three(list);
    rows.add(LaporanRow('TOTAL $title', nums: t, isTotal: true));
    return t;
  }

  final p = section('PENDAPATAN', '4');
  final b = section('BEBAN', '5');
  rows.add(LaporanRow(
    'TOTAL PENGHASILAN KOMPREHENSIF',
    nums: [for (var i = 0; i < 3; i++) p[i] - b[i]],
    isTotal: true,
  ));
  return LaporanTabel(
    ['Uraian', 'Tanpa Pembatasan', 'Dengan Pembatasan', 'Jumlah'],
    rows,
  );
}

/// Komponen perubahan aset neto per klasifikasi (dipakai Neraca & laporan Aset Neto).
class AsetNetoSaldo {
  final double tanpaSaldoAwal, tanpaMutasi, tanpaSurplusLalu, tanpaSurplusBerjalan;
  final double denganSaldoAwal, denganMutasi, denganSurplusLalu, denganSurplusBerjalan;
  const AsetNetoSaldo({
    required this.tanpaSaldoAwal,
    required this.tanpaMutasi,
    required this.tanpaSurplusLalu,
    required this.tanpaSurplusBerjalan,
    required this.denganSaldoAwal,
    required this.denganMutasi,
    required this.denganSurplusLalu,
    required this.denganSurplusBerjalan,
  });
  double get tanpaAwal => tanpaSaldoAwal + tanpaSurplusLalu;
  double get denganAwal => denganSaldoAwal + denganSurplusLalu;
  double get tanpaAkhir => tanpaAwal + tanpaMutasi + tanpaSurplusBerjalan;
  double get denganAkhir => denganAwal + denganMutasi + denganSurplusBerjalan;
}

AsetNetoSaldo asetNetoSaldo(List<NeracaSaldoBaris> d) {
  final dengan3 = d.where((b) => b.grup == '3' && b.kode.startsWith('302'));
  final tanpa3 = d.where((b) => b.grup == '3' && !b.kode.startsWith('302'));
  return AsetNetoSaldo(
    tanpaSaldoAwal: _sum(tanpa3, (b) => b.saldoAwal),
    tanpaMutasi: _sum(tanpa3, (b) => b.perubahan),
    tanpaSurplusLalu: _surplus(d, (b) => b.awalTanpa),
    tanpaSurplusBerjalan: _surplus(d, (b) => b.mutTanpa),
    denganSaldoAwal: _sum(dengan3, (b) => b.saldoAwal),
    denganMutasi: _sum(dengan3, (b) => b.perubahan),
    denganSurplusLalu: _surplus(d, (b) => b.awalDengan),
    denganSurplusBerjalan: _surplus(d, (b) => b.mutDengan),
  );
}

LaporanTabel buildAsetNeto(List<NeracaSaldoBaris> d) {
  final a = asetNetoSaldo(d);
  List<LaporanRow> block(String title, double awal, double mut, double lalu, double jalan, double akhir) => [
    LaporanRow(title, isHeader: true),
    LaporanRow('Saldo Awal', nums: [awal]),
    LaporanRow('Surplus (Defisit) Periode Lalu', nums: [lalu]),
    if (mut != 0) LaporanRow('Mutasi Langsung Aset Neto', nums: [mut]),
    LaporanRow('Surplus (Defisit) Periode Berjalan', nums: [jalan]),
    LaporanRow('Saldo Akhir', nums: [akhir], isTotal: true),
  ];
  return LaporanTabel(['Uraian', 'Jumlah'], [
    ...block('ASET NETO TANPA PEMBATASAN', a.tanpaSaldoAwal, a.tanpaMutasi,
        a.tanpaSurplusLalu, a.tanpaSurplusBerjalan, a.tanpaAkhir),
    ...block('ASET NETO DENGAN PEMBATASAN', a.denganSaldoAwal, a.denganMutasi,
        a.denganSurplusLalu, a.denganSurplusBerjalan, a.denganAkhir),
  ]);
}
