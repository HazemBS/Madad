import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/widgets/madad_builder.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/widgets/madad_message_view.dart';
import '../../core/utils/madad_messenger.dart';
import '../../core/widgets/price_label.dart';
import '../../data/models/order.dart';
import '../../data/remote/madad_store.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _notes = TextEditingController();
  PaymentMethod _payment = PaymentMethod.cashOnDelivery;
  var _submitting = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_submitting) return;
    final scope = MadadScope.of(context);
    final profile = scope.session.profile;
    if (scope.cart.isEmpty || profile == null || profile.addresses.isEmpty) {
      return;
    }
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    late final String orderId;
    try {
      final order = await scope.orders.placeOrder(
        items: scope.cart.items,
        address: profile.addresses.first,
        paymentMethod: _payment,
        notes: _notes.text,
      );
      orderId = order.id;
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showMadadMessage(
        context,
        error is MadadAuthException
            ? error.message
            : 'تعذر حفظ الطلب. تحقق من الاتصال ثم أعد المحاولة.',
      );
      return;
    }
    scope.cart.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.orderSuccess,
      (route) => route.settings.name == AppRoutes.shell,
      arguments: orderId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = MadadScope.of(context);
    final profile = scope.session.profile;
    if (profile == null) {
      return const Scaffold(
        body: MadadMessageView(
          icon: Icons.person_outline,
          title: 'يلزم تسجيل الدخول',
          message: 'عد إلى شاشة الدخول ثم أعد المحاولة.',
        ),
      );
    }

    final theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('تأكيد الطلب')),
      body: MadadBuilder(
        cubits: [scope.cart],
        builder: (context, _) {
          if (scope.cart.isEmpty) {
            return const MadadMessageView(
              icon: Icons.shopping_bag_outlined,
              title: 'السلة فارغة',
              message: 'أضف منتجات قبل تأكيد الطلب.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text('عنوان التوصيل', style: theme.titleMedium),
              const SizedBox(height: 8),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.businessName, style: theme.titleSmall),
                    const SizedBox(height: 4),
                    Text(profile.addresses.first, style: theme.bodyMedium),
                    Text(
                      '${profile.city} · ${profile.phone}',
                      style: theme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('طريقة الدفع', style: theme.titleMedium),
              const SizedBox(height: 8),
              _PaymentTile(
                label: PaymentMethod.cashOnDelivery.label,
                selected: _payment == PaymentMethod.cashOnDelivery,
                onTap: () =>
                    setState(() => _payment = PaymentMethod.cashOnDelivery),
              ),
              const SizedBox(height: 8),
              _PaymentTile(
                label: PaymentMethod.bankTransfer.label,
                selected: _payment == PaymentMethod.bankTransfer,
                onTap: () =>
                    setState(() => _payment = PaymentMethod.bankTransfer),
              ),
              if (_payment == PaymentMethod.bankTransfer) ...[
                const SizedBox(height: 8),
                Text(
                  'حساب تجريبي للعرض: مصرف الراجحي — SA00 MADAD 0000 0001',
                  style: theme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              Text('ملاحظات الطلب', style: theme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _notes,
                minLines: 3,
                maxLines: 4,
                maxLength: 240,
                buildCounter:
                    (
                      _, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => const SizedBox.shrink(),
                decoration: const InputDecoration(
                  hintText: 'مثال: التسليم بعد العصر، والاتصال قبل الوصول',
                ),
              ),
              const SizedBox(height: 16),
              _Card(
                child: Column(
                  children: [
                    _line(context, 'المجموع', scope.cart.subtotal),
                    const SizedBox(height: 6),
                    _line(context, 'التوصيل', scope.cart.deliveryFee),
                    const Divider(height: 20),
                    _line(context, 'الإجمالي', scope.cart.total, strong: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('confirm-order'),
                  onPressed: _submitting ? null : _confirm,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: MadadColors.white,
                          ),
                        )
                      : const Text('تأكيد الطلب'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _line(
    BuildContext context,
    String label,
    double amount, {
    bool strong = false,
  }) {
    final style = strong
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        PriceLabel(
          amount,
          style: style,
          color: strong ? MadadColors.teal : MadadColors.navy,
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MadadColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MadadColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? MadadColors.teal : MadadColors.line,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? MadadColors.teal : MadadColors.navy,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}
