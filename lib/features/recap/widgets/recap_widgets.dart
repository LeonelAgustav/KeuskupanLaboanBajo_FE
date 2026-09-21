import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/recap_models.dart';

// ─── Currency Formatter ─────────────────────────────────────────────────────

String formatRupiah(double amount) {
  final isNegative = amount < 0;
  final str = amount.abs().toStringAsFixed(0);
  final formatted = str.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return '${isNegative ? '- ' : ''}Rp $formatted';
}

// ─── Indonesian Month Names ─────────────────────────────────────────────────

const monthNamesId = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

const weekdayNamesId = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
];

// ─── MonthYearPicker ────────────────────────────────────────────────────────

enum PeriodMode { month, year }

class MonthYearPicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final PeriodMode mode;
  final ValueChanged<PeriodMode>? onModeChanged;

  const MonthYearPicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.mode = PeriodMode.month,
    this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isYearMode = mode == PeriodMode.year;
    final label = isYearMode
        ? '${selectedDate.year}'
        : '${monthNamesId[selectedDate.month - 1]} ${selectedDate.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onDateChanged(
              isYearMode
                  ? DateTime(selectedDate.year - 1, selectedDate.month, selectedDate.day)
                  : DateTime(selectedDate.year, selectedDate.month - 1, selectedDate.day),
            ),
          ),
          if (onModeChanged != null) ...[
            const SizedBox(width: 4),
            Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: SegmentedButton<PeriodMode>(
              segments: const [
                ButtonSegment(value: PeriodMode.month, label: Text('Bulanan')),
                ButtonSegment(value: PeriodMode.year, label: Text('Tahunan')),
              ],
              selected: {mode},
              onSelectionChanged: (s) => onModeChanged!(s.first),
            ))),
            const SizedBox(width: 4),
          ],
          Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis))),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onDateChanged(
              isYearMode
                  ? DateTime(selectedDate.year + 1, selectedDate.month, selectedDate.day)
                  : DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SummaryCard ────────────────────────────────────────────────────────────

class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatRupiah(amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SummaryRow (3 cards) ───────────────────────────────────────────────────

class SummaryRow extends StatelessWidget {
  final double totalPendapatan;
  final double totalPengeluaran;

  const SummaryRow({
    super.key,
    required this.totalPendapatan,
    required this.totalPengeluaran,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          SummaryCard(
            title: 'Total Pendapatan',
            amount: totalPendapatan,
            color: hijauPendapatan,
            icon: Icons.arrow_upward,
          ),
          const SizedBox(width: 4),
          SummaryCard(
            title: 'Total Pengeluaran',
            amount: totalPengeluaran,
            color: merahPengeluaran,
            icon: Icons.arrow_downward,
          ),
          const SizedBox(width: 4),
          SummaryCard(
            title: 'Saldo Kas',
            amount: totalPendapatan - totalPengeluaran,
            color: emasTeks,
            icon: Icons.account_balance_wallet,
          ),
        ],
      ),
    );
  }
}

// ─── ParokiRecapCard ────────────────────────────────────────────────────────

class ParokiRecapCard extends StatelessWidget {
  final RecapParokiSummary summary;
  final VoidCallback onTap;

  const ParokiRecapCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.church, color: ungu.withOpacity(0.6), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      summary.parokiNama,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _AmountLabel(
                      label: 'Pendapatan',
                      amount: summary.totalPendapatan,
                      color: hijauPendapatan,
                    ),
                  ),
                  Expanded(
                    child: _AmountLabel(
                      label: 'Pengeluaran',
                      amount: summary.totalPengeluaran,
                      color: merahPengeluaran,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountLabel extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _AmountLabel({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            formatRupiah(amount),
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color),
          ),
        ),
      ],
    );
  }
}

// ─── AkunDetailTile ─────────────────────────────────────────────────────────

class AkunDetailTile extends StatelessWidget {
  final RecapAkunDetail detail;

  const AkunDetailTile({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${detail.akunKode} - ${detail.akunNama}',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatRupiah(detail.totalPendapatan),
                  style: TextStyle(fontSize: 12, color: hijauPendapatan),
                ),
                Text(
                  formatRupiah(detail.totalPengeluaran),
                  style: TextStyle(fontSize: 12, color: merahPengeluaran),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Monthly recap per bulan untuk mode tahunan
class MonthlyRecapTable extends StatelessWidget {
  final List<MonthlyRecap> monthlyData;
  final double totalPendapatan;
  final double totalPengeluaran;
  const MonthlyRecapTable({super.key, required this.monthlyData, required this.totalPendapatan, required this.totalPengeluaran});
  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) return Card(child: Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('Tidak ada data tahun ini', style: TextStyle(color: Colors.grey[500])))));
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 360),
          child: Column(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: ungu.withOpacity(0.08), borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Row(children: const [SizedBox(width: 80, child: Text('Bulan', style: TextStyle(fontWeight: FontWeight.bold, fontSize:12))), SizedBox(width: 90, child: Text('Pendapatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize:12), textAlign: TextAlign.right)), SizedBox(width: 90, child: Text('Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize:12), textAlign: TextAlign.right)), SizedBox(width: 90, child: Text('Saldo', style: TextStyle(fontWeight: FontWeight.bold, fontSize:12), textAlign: TextAlign.right)) ])),
            ...monthlyData.map((m) => Container(padding: const EdgeInsets.symmetric(horizontal:12, vertical:8), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0)))), child: Row(children: [SizedBox(width: 80, child: Text(m.namaBulan, style: const TextStyle(fontSize:12, fontWeight: FontWeight.w500))), SizedBox(width: 90, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatRupiah(m.totalPendapatan), style: TextStyle(fontSize:12, color:hijauPendapatan), textAlign: TextAlign.right))), SizedBox(width: 90, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatRupiah(m.totalPengeluaran), style: TextStyle(fontSize:12, color:merahPengeluaran), textAlign: TextAlign.right))), SizedBox(width: 90, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatRupiah(m.saldo), style: TextStyle(fontSize:12, color: m.saldo>=0?hijauPendapatan:merahPengeluaran, fontWeight: FontWeight.w600), textAlign: TextAlign.right))) ]))),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: ungu.withOpacity(0.08), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12))), child: Row(children: [const SizedBox(width: 80, child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize:12))), SizedBox(width: 90, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatRupiah(totalPendapatan), style: TextStyle(fontWeight: FontWeight.bold, fontSize:12, color:hijauPendapatan), textAlign: TextAlign.right))), SizedBox(width: 90, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatRupiah(totalPengeluaran), style: TextStyle(fontWeight: FontWeight.bold, fontSize:12, color:merahPengeluaran), textAlign: TextAlign.right))), SizedBox(width: 90, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatRupiah(totalPendapatan-totalPengeluaran), style: TextStyle(fontWeight: FontWeight.bold, fontSize:12, color:emasTeks), textAlign: TextAlign.right))) ])),
          ]),
        ),
      ),
    );
  }
}

/// Weekly recap table for monthly mode (W1-5)
class WeeklyRecapTable extends StatelessWidget {
  final List<WeeklyRecap> weeklyData;
  final double totalPendapatan;
  final double totalPengeluaran;
  const WeeklyRecapTable({super.key, required this.weeklyData, required this.totalPendapatan, required this.totalPengeluaran});
  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) return Card(child: Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('Tidak ada data minggu ini', style: TextStyle(color: Colors.grey[500])))));
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 360),
          child: Column(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: ungu.withOpacity(0.08), borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Row(children: const [SizedBox(width: 80, child: Text('Minggu', style: TextStyle(fontWeight: FontWeight.bold, fontSize:12))), SizedBox(width: 90, child: Text('Pendapatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize:12), textAlign: TextAlign.right)), SizedBox(width: 90, child: Text('Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize:12), textAlign: TextAlign.right)), SizedBox(width: 90, child: Text('Saldo', style: TextStyle(fontWeight: FontWeight.bold, fontSize:12), textAlign: TextAlign.right)) ])),
            ...weeklyData.map((w) => Container(padding: const EdgeInsets.symmetric(horizontal:12, vertical:8), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0)))), child: Row(children: [SizedBox(width: 80, child: Text('${w.namaMinggu} (${w.rentang})', style: const TextStyle(fontSize:12, fontWeight: FontWeight.w500))), SizedBox(width: 90, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatRupiah(w.totalPendapatan), style: TextStyle(fontSize:12, color:hijauPendapatan), textAlign: TextAlign.right))), SizedBox(width: 90, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatRupiah(w.totalPengeluaran), style: TextStyle(fontSize:12, color:merahPengeluaran), textAlign: TextAlign.right))), SizedBox(width: 90, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatRupiah(w.saldo), style: TextStyle(fontSize:12, color: w.saldo>=0?hijauPendapatan:merahPengeluaran, fontWeight: FontWeight.w600), textAlign: TextAlign.right))) ]))),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: ungu.withOpacity(0.08), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12))), child: Row(children: [const SizedBox(width: 80, child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize:12))), SizedBox(width: 90, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatRupiah(totalPendapatan), style: TextStyle(fontWeight: FontWeight.bold, fontSize:12, color:hijauPendapatan), textAlign: TextAlign.right))), SizedBox(width: 90, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatRupiah(totalPengeluaran), style: TextStyle(fontWeight: FontWeight.bold, fontSize:12, color:merahPengeluaran), textAlign: TextAlign.right))), SizedBox(width: 90, child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatRupiah(totalPendapatan-totalPengeluaran), style: TextStyle(fontWeight: FontWeight.bold, fontSize:12, color:emasTeks), textAlign: TextAlign.right))) ])),
          ]),
        ),
      ),
    );
  }
}
