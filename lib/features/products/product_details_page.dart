import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/utils/madad_messenger.dart';
import '../../core/widgets/product_photo.dart';
import '../../core/widgets/madad_message_view.dart';
import '../../core/widgets/price_label.dart';
import '../../core/widgets/quantity_stepper.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/category.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int? _quantity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _quantity ??=
        MadadScope.of(
          context,
        ).catalog.productById(widget.productId)?.minOrder ??
        1;
  }

  @override
  Widget build(BuildContext context) {
    final scope = MadadScope.of(context);
    final product = scope.catalog.productById(widget.productId);
    if (product == null) {
      return const Scaffold(
        body: MadadMessageView(
          icon: Icons.error_outline,
          title: 'المنتج غير متاح',
          message: 'تعذر العثور على هذا المنتج في البيانات التجريبية.',
        ),
      );
    }

    final supplier = scope.catalog.supplierById(product.supplierId);
    final icon =
        scope.catalog.categoryById(product.categoryId)?.icon ??
        CategoryIcon.food;
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        actions: [
          IconButton(
            key: const ValueKey('details-open-cart'),
            tooltip: 'السلة',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          ProductPhoto(
            productId: product.id,
            expandWidth: true,
            height: (MediaQuery.sizeOf(context).width - 32).clamp(220, 360),
            radius: 24,
            fit: BoxFit.contain,
            fallbackIcon: icon,
          ),
          const SizedBox(height: 16),
          Text(product.name, style: theme.headlineSmall),
          const SizedBox(height: 8),
          PriceLabel(product.wholesalePrice, style: theme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip('الوحدة: ${product.unit.label}'),
              _InfoChip('الحد الأدنى: ${product.minOrder}'),
              _InfoChip('المتوفر: ${product.stock}'),
            ],
          ),
          const SizedBox(height: 16),
          Text(product.description, style: theme.bodyLarge),
          const SizedBox(height: 16),
          if (supplier != null)
            Material(
              color: MadadColors.white,
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: MadadColors.line),
                ),
                leading: CircleAvatar(
                  backgroundColor: MadadColors.sand,
                  child: Text(supplier.initial),
                ),
                title: Text(supplier.name),
                subtitle: Text(
                  '${supplier.city} · ${supplier.rating.toStringAsFixed(1)}',
                ),
                trailing: supplier.verified
                    ? const VerifiedBadge()
                    : const Icon(Icons.chevron_left),
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.supplier, arguments: supplier.id);
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: Material(
        color: MadadColors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: ListenableBuilder(
              listenable: scope.favorites,
              builder: (context, _) {
                final saved = scope.favorites.contains(product.id);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text('الكمية', style: theme.titleSmall),
                        const SizedBox(width: 8),
                        QuantityStepper(
                          value: _quantity ?? product.minOrder,
                          min: product.minOrder,
                          max: product.stock,
                          compact: true,
                          onChanged: (value) =>
                              setState(() => _quantity = value),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: saved
                              ? 'محفوظ في المفضلة'
                              : 'إضافة إلى المفضلة',
                          onPressed: () async {
                            final added = await scope.favorites.toggle(
                              product.id,
                            );
                            if (!context.mounted) return;
                            showMadadMessage(
                              context,
                              added
                                  ? 'حُفظ المنتج في المفضلة'
                                  : 'أُزيل المنتج من المفضلة',
                            );
                          },
                          icon: Icon(
                            saved ? Icons.favorite : Icons.favorite_border,
                            color: MadadColors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('add-to-cart'),
                        onPressed: product.inStock
                            ? () {
                                final notice = scope.cart.add(
                                  product,
                                  _quantity ?? product.minOrder,
                                );
                                showMadadMessage(
                                  context,
                                  notice ?? 'أُضيف المنتج إلى السلة',
                                );
                              }
                            : null,
                        icon: const Icon(Icons.add_shopping_cart_outlined),
                        label: const Text('إضافة إلى السلة'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: MadadColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: MadadColors.navy,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
