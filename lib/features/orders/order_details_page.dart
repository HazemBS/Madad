import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/madad_message_view.dart';
import '../../core/widgets/price_label.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/order.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final order = MadadScope.of(context).orders.byId(orderId);
    if (order == null) {
      return const Scaffold(
        body: MadadMessageView(
          icon: Icons.receipt_long_outlined,
          title: 'الطلب غير موجود',
          message: 'ربما أُغلق التطبيق قبل حفظ هذا الطلب.',
        ),
      );
    }
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('حالة الطلب')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Row(
            children: [
              Flexible(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    order.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.headlineSmall,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: StatusBadge(status: order.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(formatDate(order.createdAt), style: theme.bodySmall),
          const SizedBox(height: 16),
          Text('مراحل الطلب', style: theme.titleMedium),
          const SizedBox(height: 8),
          for (final status in OrderStatus.values)
            _Step(
              label: status.label,
              done: status.index <= order.status.index,
            ),
          const SizedBox(height: 16),
          Text('المنتجات', style: theme.titleMedium),
          const SizedBox(height: 8),
          for (final item in order.items)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MadadColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: theme.titleSmall),
                        Text(
                          '${item.supplierName} · ${item.quantity} ${item.unitLabel}',
                          style: theme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PriceLabel(item.lineTotal, style: theme.titleSmall),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text('التوصيل والدفع', style: theme.titleMedium),
          const SizedBox(height: 8),
          Text(order.address, style: theme.bodyMedium),
          Text(order.paymentMethod.label, style: theme.bodyMedium),
          if (order.notes.isNotEmpty)
            Text('ملاحظة: ${order.notes}', style: theme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: Text('الإجمالي')),
              PriceLabel(order.total),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.circle_outlined,
            color: done ? MadadColors.teal : MadadColors.muted,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
