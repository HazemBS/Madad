import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/widgets/madad_builder.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/madad_messenger.dart';
import '../../core/widgets/madad_message_view.dart';
import '../../core/widgets/product_tile.dart';
import '../../data/models/category.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = MadadScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: MadadBuilder(
        cubits: [scope.favorites],
        builder: (context, _) {
          final products = [
            for (final id in scope.favorites.ids)
              if (scope.catalog.productById(id) case final product?) product,
          ];
          if (products.isEmpty) {
            return MadadMessageView(
              icon: Icons.favorite_border,
              title: 'لا توجد مفضلة',
              message: 'احفظ المنتجات التي تشتريها باستمرار لتصل إليها بسرعة.',
              actionLabel: 'تصفح التصنيفات',
              onAction: () => scope.shell.goTo(1),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductTile(
                product: product,
                supplierName: scope.catalog.supplierName(product.supplierId),
                icon:
                    scope.catalog.categoryById(product.categoryId)?.icon ??
                    CategoryIcon.food,
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.productDetails, arguments: product.id);
                },
                onAdd: () {
                  final notice = scope.cart.add(product, product.minOrder);
                  showMadadMessage(context, notice ?? 'أُضيف المنتج إلى السلة');
                },
              );
            },
          );
        },
      ),
    );
  }
}
