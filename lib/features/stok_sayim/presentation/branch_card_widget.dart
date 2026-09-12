import 'package:flutter/material.dart';

class BranchCardWidget extends StatelessWidget {
  final Map<String, dynamic> branch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BranchCardWidget({
    super.key,
    required this.branch,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.store, color: Colors.amber, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch['branch_name'] ?? '',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Şehir: ${branch['city'] ?? '-'}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Düzenle Butonu (Kalem)
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                onPressed: onEdit,
                tooltip: 'Düzenle',
              ),
              // Sil Butonu (Çöp Kutusu)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: onDelete,
                tooltip: 'Sil',
              ),
            ],
          ),
        ],
      ),
    );
  }
}