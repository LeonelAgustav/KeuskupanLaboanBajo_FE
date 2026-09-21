import 'package:flutter_test/flutter_test.dart';

// ponytail: balance check logic jurnal (debit = kredit)
void main() {
  group('Jurnal balance validation', () {
    test('debit = kredit -> balanced', () {
      final detils = [
        (debit: 100000.0, kredit: 0.0),
        (debit: 0.0, kredit: 100000.0),
      ];
      final totalDebit = detils.fold(0.0, (sum, d) => sum + d.debit);
      final totalKredit = detils.fold(0.0, (sum, d) => sum + d.kredit);
      expect(totalDebit, totalKredit);
    });

    test('debit != kredit -> not balanced', () {
      final detils = [
        (debit: 100000.0, kredit: 0.0),
        (debit: 0.0, kredit: 50000.0),
      ];
      final totalDebit = detils.fold(0.0, (sum, d) => sum + d.debit);
      final totalKredit = detils.fold(0.0, (sum, d) => sum + d.kredit);
      expect(totalDebit != totalKredit, true);
      expect((totalDebit - totalKredit).abs(), 50000.0);
    });

    test('multiple detils balanced', () {
      final detils = [
        (debit: 500000.0, kredit: 0.0),
        (debit: 0.0, kredit: 300000.0),
        (debit: 0.0, kredit: 200000.0),
      ];
      final totalDebit = detils.fold(0.0, (sum, d) => sum + d.debit);
      final totalKredit = detils.fold(0.0, (sum, d) => sum + d.kredit);
      expect(totalDebit, totalKredit);
      expect(totalDebit, 500000.0);
    });

    test('empty detils -> balanced (0 = 0)', () {
      final detils = <({double debit, double kredit})>[];
      final totalDebit = detils.fold(0.0, (sum, d) => sum + d.debit);
      final totalKredit = detils.fold(0.0, (sum, d) => sum + d.kredit);
      expect(totalDebit, 0.0);
      expect(totalKredit, 0.0);
    });
  });
}
