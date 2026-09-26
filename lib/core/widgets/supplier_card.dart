import 'package:flutter/material.dart';

import '../../data/models/supplier.dart';
import '../theme/madad_colors.dart';
import 'status_badge.dart';

class SupplierCard extends StatelessWidget {
  const SupplierCard({
    super.key,
    required this.supplier,
    required this.categoryLabel,
    required this.onTap,
    this.width,
  });

  final Supplier supplier;
  final String categoryLabel;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return SizedBox(
      width: width,
      child: Material(
        color: MadadColors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MadadColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: MadadColors.sand,
                      foregroundColor: MadadColors.navy,
                      child: Text(supplier.initial, style: theme.titleMedium),
                    ),
                    const Spacer(),
                    if (supplier.verified) const VerifiedBadge(),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  supplier.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${supplier.city} · $categoryLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: MadadColors.teal),
                    const SizedBox(width: 4),
                    Text(
                      supplier.rating.toStringAsFixed(1),
                      style: theme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
