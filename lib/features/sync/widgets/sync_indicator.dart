import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class SyncIndicator extends StatelessWidget {
  final int pending;
  final int conflicts;
  final VoidCallback onTap;
  const SyncIndicator({super.key, required this.pending, required this.conflicts, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSynced = pending == 0 && conflicts == 0;
    final hasConflict = conflicts > 0;
    final color = hasConflict ? dangerRed : isSynced ? successGreen : warningOrange;
    final icon = hasConflict ? Icons.cloud_off : isSynced ? Icons.cloud_done : Icons.cloud_upload;
    final label = hasConflict ? 'Konflik' : isSynced ? 'Synced' : 'Pending';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text('$pending', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 10)),
          if (hasConflict) Container(margin: const EdgeInsets.only(left: 4), width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red)),
        ]),
      ),
    );
  }
}
