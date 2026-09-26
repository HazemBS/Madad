import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/widgets/madad_builder.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/madad_messenger.dart';
import '../../core/widgets/madad_message_view.dart';
import '../../core/widgets/price_label.dart';
import '../../core/widgets/product_photo.dart';
import '../../core/widgets/quantity_stepper.dart';
import 'cart_cubit.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = MadadScope.of(context).cart;
    return MadadBuilder(
      cubits: [cart],
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('سلة المشتريات')),
          body: cart.isEmpty
              ? MadadMessageView(
                  icon: Icons.shopping_bag_outlined,
                  title: 'سلتك فارغة',
                  message: 'أضف منتجات الجملة ثم ارجع لإتمام الطلب.',
                  actionLabel: 'تصفح المنتجات',
                  onAction: () {
                    Navigator.of(context).pushNamed(AppRoutes.products);
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    final theme = Theme.of(context).textTheme;
                    return Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      decoration: BoxDecoration(
                        color: MadadColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MadadColors.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ProductPhoto(
                                  productId: item.product.id,
                                  size: 56,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    item.product.name,
                                    style: theme.titleSmall,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'حذف',
                                onPressed: () {
                                  cart.remove(item.product.id);
                                  showMadadMessage(
                                    context,
                                    'حُذف المنتج من السلة',
                                  );
                                },
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          Text(
                            '${formatPrice(item.product.wholesalePrice)} / ${item.product.unit.label}',
                            style: theme.bodySmall,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              QuantityStepper(
                                value: item.quantity,
                                min: item.product.minOrder,
                                max: item.product.stock,
                                onChanged: (value) =>
                                    cart.setQuantity(item.product.id, value),
                              ),
                              const Spacer(),
                              PriceLabel(item.lineTotal),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
          bottomNavigationBar: cart.isEmpty ? null : _Summary(cart: cart),
        );
      },
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.cart});

  final CartCubit cart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 12 + bottom),
      decoration: BoxDecoration(
        color: MadadColors.white,
        border: Border(top: BorderSide(color: MadadColors.line)),
        boxShadow: [
          BoxShadow(
            color: MadadColors.navy.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row(context, 'المجموع', cart.subtotal, theme),
          const SizedBox(height: 8),
          _row(context, 'التوصيل', cart.deliveryFee, theme),
          const SizedBox(height: 8),
          Divider(height: 1, color: MadadColors.line),
          const SizedBox(height: 8),
          _row(context, 'الإجمالي', cart.total, theme, emphasize: true),
          const SizedBox(height: 6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'التوصيل مجاني عند بلوغ 500 ر.س.',
              style: theme.bodySmall,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey('checkout-button'),
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.checkout),
              child: const Text('إتمام الطلب'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    double amount,
    TextTheme theme, {
    bool emphasize = false,
  }) {
    final style = emphasize ? theme.titleMedium : theme.bodyMedium;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        const SizedBox(width: 12),
        PriceLabel(
          amount,
          style: style,
          color: emphasize ? MadadColors.teal : MadadColors.navy,
        ),
      ],
    );
  }
}
