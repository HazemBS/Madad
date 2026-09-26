import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/widgets/category_glyph.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = MadadScope.of(context).catalog;
    final categories = catalog.categories();
    return Scaffold(
      appBar: AppBar(title: const Text('التصنيفات')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.74,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          final count = catalog.byCategory(category.id).length;
          return Material(
            color: MadadColors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.products,
                  arguments: ProductsQuery(categoryId: category.id),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                child: Column(
                  children: [
                    const Spacer(),
                    CategoryGlyph(
                      icon: category.icon,
                      size: 84,
                      iconScale: 0.58,
                    ),
                    const Spacer(),
                    Text(
                      category.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count منتجات',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
