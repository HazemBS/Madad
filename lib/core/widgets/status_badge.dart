import 'package:flutter/material.dart';

import '../../data/models/order.dart';
import '../theme/madad_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final filled =
        status == OrderStatus.completed || status == OrderStatus.outForDelivery;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? MadadColors.teal : MadadColors.sand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: filled ? MadadColors.white : MadadColors.navy,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: MadadColors.teal.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 14, color: MadadColors.teal),
          const SizedBox(width: 4),
          Text(
            'موثّق',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: MadadColors.teal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
