import 'package:flutter/material.dart';

class SyncIndicator extends StatelessWidget {
  final int pending;
  final int conflicts;
  final VoidCallback onTap;
  const SyncIndicator({super.key, required this.pending, required this.conflicts, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSynced = pending == 0;
    final hasConflict = conflicts > 0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          Icon(isSynced ? Icons.cloud_done : hasConflict ? Icons.cloud_off : Icons.cloud_upload, color: isSynced ? Colors.green : hasConflict ? Colors.red : Colors.orange, size: 20),
          const SizedBox(width: 4),
          Text('$pending', style: TextStyle(color: isSynced ? Colors.green : hasConflict ? Colors.red : Colors.orange, fontWeight: FontWeight.bold)),
          if (!isSynced) const Padding(padding: EdgeInsets.only(left: 4), child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))),
          if (hasConflict) Padding(padding: const EdgeInsets.only(left: 4), child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red))),
        ]),
      ),
    );
  }
}
