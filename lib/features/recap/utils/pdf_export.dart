import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../widgets/recap_widgets.dart'; // formatRupiah

/// Satu baris tabel PDF. isHeader = baris kelompok (mis. "PENDAPATAN").
class PdfBaris {
  final String nama;
  final double debit;
  final double kredit;
  final bool isHeader;
  const PdfBaris(this.nama, {this.debit = 0, this.kredit = 0, this.isHeader = false});
}

/// Laporan resmi PDF (UI_DESIGN.md §7.1.3): judul, tabel D/K, saldo, tanda tangan.
/// Buka dialog cetak OS — dari situ bisa "Save as PDF".
Future<void> exportLaporanPdf({
  required String judul,
  required String periode,
  required List<PdfBaris> baris,
  required double totalDebit,
  required double totalKredit,
}) async {
  final doc = pw.Document();
  const ungu = PdfColor.fromInt(0xFF5B2E7C);
  final saldo = totalDebit - totalKredit;

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) => [
        pw.Center(child: pw.Text('KEUSKUPAN LABUAN BAJO', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))),
        pw.Center(child: pw.Text(judul, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
        pw.Center(child: pw.Text('Periode: $periode', style: const pw.TextStyle(fontSize: 10))),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headers: ['Uraian', 'Debit', 'Kredit'],
          data: [
            for (final b in baris) [
              b.isHeader ? b.nama.toUpperCase() : b.nama,
              b.isHeader || b.debit == 0 ? '-' : formatRupiah(b.debit),
              b.isHeader || b.kredit == 0 ? '-' : formatRupiah(b.kredit),
            ],
          ],
          headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
          headerDecoration: const pw.BoxDecoration(color: ungu),
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellAlignment: pw.Alignment.centerLeft,
          columnWidths: const {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(1.5), 2: pw.FlexColumnWidth(1.5)},
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
        ),
        pw.SizedBox(height: 12),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Total Debit : ${formatRupiah(totalDebit)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text('Total Kredit : ${formatRupiah(totalKredit)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text('Saldo : ${formatRupiah(saldo)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: ungu)),
            ],
          ),
        ),
        pw.SizedBox(height: 48),
        // Tanda tangan laporan resmi
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _ttd('Bendahara'),
            _ttd('Ketua'),
          ],
        ),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => doc.save());
}

pw.Widget _ttd(String jabatan) {
  return pw.Column(
    children: [
      pw.Text(jabatan, style: const pw.TextStyle(fontSize: 10)),
      pw.SizedBox(height: 48),
      pw.Text('(..................................)', style: const pw.TextStyle(fontSize: 10)),
    ],
  );
}
