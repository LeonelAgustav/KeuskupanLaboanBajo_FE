import 'package:flutter/material.dart';
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

// ─── MonthYearPicker ────────────────────────────────────────────────────────

class MonthYearPicker extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<int> onChangeMonth;

  const MonthYearPicker({
    super.key,
    required this.selectedMonth,
    required this.onChangeMonth,
  });

  @override
  Widget build(BuildContext context) {
    final label = '${monthNamesId[selectedMonth.month - 1]} ${selectedMonth.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onChangeMonth(-1),
          ),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onChangeMonth(1),
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
  final double totalDebit;
  final double totalKredit;

  const SummaryRow({
    super.key,
    required this.totalDebit,
    required this.totalKredit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          SummaryCard(
            title: 'Total Debit',
            amount: totalDebit,
            color: Colors.blue.shade700,
            icon: Icons.arrow_upward,
          ),
          const SizedBox(width: 4),
          SummaryCard(
            title: 'Total Kredit',
            amount: totalKredit,
            color: Colors.green.shade700,
            icon: Icons.arrow_downward,
          ),
          const SizedBox(width: 4),
          SummaryCard(
            title: 'Saldo',
            amount: totalDebit - totalKredit,
            color: Colors.orange.shade700,
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
                  Icon(Icons.church, color: Colors.deepPurple.shade300, size: 20),
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
                      label: 'Debit',
                      amount: summary.totalDebit,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Expanded(
                    child: _AmountLabel(
                      label: 'Kredit',
                      amount: summary.totalKredit,
                      color: Colors.green.shade700,
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
        Text(
          formatRupiah(amount),
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color),
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
                  formatRupiah(detail.totalDebit),
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
                Text(
                  formatRupiah(detail.totalKredit),
                  style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
