import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/widgets/madad_message_view.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final order = MadadScope.of(context).orders.byId(orderId);
    final theme = Theme.of(context).textTheme;
    if (order == null) {
      return const Scaffold(
        body: MadadMessageView(
          icon: Icons.receipt_long_outlined,
          title: 'الطلب غير موجود',
          message: 'تعذر عرض تأكيد هذا الطلب.',
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: MadadColors.teal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: MadadColors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تم تأكيد طلبك',
                style: theme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'رقم الطلب',
                style: theme.bodyMedium?.copyWith(color: MadadColors.muted),
              ),
              const SizedBox(height: 4),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(order.id, style: theme.headlineMedium),
              ),
              const SizedBox(height: 8),
              Text(
                'طلبك الآن بحالة «جديد». يمكنك متابعة تنقله بين الحالات من صفحة طلباتي.',
                textAlign: TextAlign.center,
                style: theme.bodyLarge,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('track-order'),
                  onPressed: () {
                    final scope = MadadScope.of(context);
                    scope.shell.goTo(2);
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(AppRoutes.shell, (_) => false);
                  },
                  child: const Text('تتبع الطلب'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const ValueKey('back-home'),
                  onPressed: () {
                    final scope = MadadScope.of(context);
                    scope.shell.goTo(0);
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(AppRoutes.shell, (_) => false);
                  },
                  child: const Text('العودة للرئيسية'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
