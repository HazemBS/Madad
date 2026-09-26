import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/utils/madad_messenger.dart';
import '../../core/widgets/madad_message_view.dart';
import '../../core/widgets/product_tile.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/category.dart';
import '../../data/models/product.dart';

class SupplierPage extends StatelessWidget {
  const SupplierPage({super.key, required this.supplierId});

  final String supplierId;

  @override
  Widget build(BuildContext context) {
    final scope = MadadScope.of(context);
    final supplier = scope.catalog.supplierById(supplierId);
    if (supplier == null) {
      return const Scaffold(
        body: MadadMessageView(
          icon: Icons.storefront_outlined,
          title: 'المورد غير متاح',
          message: 'تعذر العثور على هذا المورد.',
        ),
      );
    }

    final products = scope.catalog.bySupplier(supplier.id);
    final categories = supplier.categoryIds
        .map(scope.catalog.categoryName)
        .where((name) => name.isNotEmpty)
        .join('، ');
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('صفحة المورد')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MadadColors.navy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: MadadColors.sand,
                      child: Text(supplier.initial, style: theme.titleLarge),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            supplier.name,
                            style: theme.titleLarge?.copyWith(
                              color: MadadColors.white,
                            ),
                          ),
                          Text(
                            supplier.city,
                            style: theme.bodyMedium?.copyWith(
                              color: MadadColors.sand,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (supplier.verified) const VerifiedBadge(),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star, color: MadadColors.teal, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      supplier.rating.toStringAsFixed(1),
                      style: theme.titleMedium?.copyWith(
                        color: MadadColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  supplier.about,
                  style: theme.bodyMedium?.copyWith(color: MadadColors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  categories,
                  style: theme.bodySmall?.copyWith(color: MadadColors.sand),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('منتجات المورد', style: theme.titleMedium),
          const SizedBox(height: 10),
          if (products.isEmpty)
            const MadadMessageView(
              icon: Icons.inventory_2_outlined,
              title: 'لا توجد منتجات',
              message: 'لم يضف هذا المورد منتجات بعد.',
            )
          else
            for (final product in products) ...[
              ProductTile(
                product: product,
                supplierName: supplier.name,
                icon:
                    scope.catalog.categoryById(product.categoryId)?.icon ??
                    CategoryIcon.food,
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.productDetails, arguments: product.id);
                },
                onAdd: () => _add(context, product),
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }

  void _add(BuildContext context, Product product) {
    final notice = MadadScope.of(context).cart.add(product, product.minOrder);
    showMadadMessage(context, notice ?? 'أُضيف المنتج إلى السلة');
  }
}
