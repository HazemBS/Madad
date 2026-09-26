import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/supplier_card.dart';

class SuppliersPage extends StatelessWidget {
  const SuppliersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = MadadScope.of(context).catalog;
    final suppliers = catalog.suppliers();
    return Scaffold(
      appBar: AppBar(title: const Text('الموردون')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: suppliers.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          final labels = supplier.categoryIds
              .map(catalog.categoryName)
              .where((name) => name.isNotEmpty)
              .join('، ');
          return SupplierCard(
            supplier: supplier,
            categoryLabel: labels,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.supplier, arguments: supplier.id);
            },
          );
        },
      ),
    );
  }
}
