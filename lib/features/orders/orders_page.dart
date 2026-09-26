import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/widgets/madad_builder.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/madad_message_view.dart';
import '../../core/widgets/price_label.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/order.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = MadadScope.of(context).orders;
    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: MadadBuilder(
        cubits: [orders],
        builder: (context, _) {
          if (orders.orders.isEmpty) {
            return const MadadMessageView(
              icon: Icons.receipt_long_outlined,
              title: 'لا توجد طلبات',
              message: 'عند تأكيد طلب جملة سيظهر هنا مع حالته.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              if (orders.current.isNotEmpty) ...[
                const SectionHeader(title: 'الطلبات الحالية'),
                for (final order in orders.current) _OrderCard(order: order),
              ],
              if (orders.previous.isNotEmpty) ...[
                const SizedBox(height: 8),
                const SectionHeader(title: 'الطلبات السابقة'),
                for (final order in orders.previous) _OrderCard(order: order),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: MadadColors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(AppRoutes.orderDetails, arguments: order.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          style: theme.titleMedium,
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
                const SizedBox(height: 4),
                Text(
                  '${order.items.length} منتجات · ${order.paymentMethod.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: PriceLabel(order.total),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
