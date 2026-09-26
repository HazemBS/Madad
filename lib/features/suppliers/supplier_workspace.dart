import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import 'add_product_page.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/madad_messenger.dart';
import '../../core/widgets/madad_message_view.dart';
import '../../core/widgets/price_label.dart';
import '../../core/widgets/product_tile.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/category.dart';
import '../../data/models/order.dart';
import '../../data/models/product.dart';
import '../../data/repositories/catalog_repository.dart';

class SupplierHomePage extends StatelessWidget {
  const SupplierHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = MadadScope.of(context);
    final supplierId = scope.session.supplierId;
    final supplier = supplierId == null
        ? null
        : scope.catalog.supplierById(supplierId);
    if (supplier == null) {
      return const Scaffold(
        body: MadadMessageView(
          icon: Icons.storefront_outlined,
          title: 'حساب المورد غير متاح',
          message: 'أعد الدخول من زر دخول كمورد.',
        ),
      );
    }
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: scope.catalog,
          builder: (context, _) {
            final products = scope.catalog.bySupplier(supplier.id);
            final orders = _ordersFor(scope, supplier.id);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Text(
                  'مرحبًا ${scope.session.profile?.ownerName ?? ''}',
                  style: theme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${supplier.name} · ${supplier.city}',
                  style: theme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'المنتجات',
                        value: '${products.length}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'طلبات واردة',
                        value: '${orders.length}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(supplier.about, style: theme.bodyLarge),
                const SizedBox(height: 16),
                const SectionHeader(title: 'منتجاتك'),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => openAddProduct(context),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة منتج جديد'),
                ),
                const SizedBox(height: 12),
                if (products.isEmpty)
                  const MadadMessageView(
                    icon: Icons.inventory_2_outlined,
                    title: 'لا توجد منتجات',
                    message: 'لم يُضف لهذا المورد منتجات في بيانات العرض.',
                  )
                else
                  for (final product in products) ...[
                    _SupplierProductTile(product: product),
                    const SizedBox(height: 10),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class SupplierProductsPage extends StatelessWidget {
  const SupplierProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = MadadScope.of(context);
    final supplierId = scope.session.supplierId;
    return Scaffold(
      appBar: AppBar(title: const Text('منتجاتي')),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add-product'),
        onPressed: () => openAddProduct(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة منتج جديد'),
      ),
      body: ListenableBuilder(
        listenable: scope.catalog,
        builder: (context, _) {
          final products = supplierId == null
              ? const <Product>[]
              : scope.catalog.bySupplier(supplierId);
          if (products.isEmpty) {
            return const MadadMessageView(
              icon: Icons.inventory_2_outlined,
              title: 'لا توجد منتجات',
              message: 'منتجات المورد التجريبية تظهر هنا.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _SupplierProductTile(product: products[index]);
            },
          );
        },
      ),
    );
  }
}

class SupplierOrdersPage extends StatelessWidget {
  const SupplierOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = MadadScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('الطلبات الواردة')),
      body: ListenableBuilder(
        listenable: scope.orders,
        builder: (context, _) {
          final supplierId = scope.session.supplierId;
          final orders = supplierId == null
              ? const <Order>[]
              : _ordersFor(scope, supplierId);
          if (orders.isEmpty || supplierId == null) {
            return const MadadMessageView(
              icon: Icons.receipt_long_outlined,
              title: 'لا توجد طلبات واردة',
              message: 'عندما يطلب متجر من منتجاتك يظهر الطلب هنا.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              for (final order in orders)
                _IncomingOrderCard(order: order, supplierId: supplierId),
            ],
          );
        },
      ),
    );
  }
}

class _SupplierProductTile extends StatelessWidget {
  const _SupplierProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final scope = MadadScope.of(context);
    final icon =
        scope.catalog.categoryById(product.categoryId)?.icon ??
        CategoryIcon.food;
    return ProductTile(
      product: product,
      supplierName: 'مخزون ${product.stock}',
      icon: icon,
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.productDetails, arguments: product.id);
      },
      addIcon: Icons.info_outline,
      addTooltip: 'ملاحظة عن المنتج',
      onAdd: () {
        showMadadMessage(context, 'هذا المنتج ظاهر للمتاجر في سوق الجملة.');
      },
    );
  }
}

class _IncomingOrderCard extends StatelessWidget {
  const _IncomingOrderCard({required this.order, required this.supplierId});

  final Order order;
  final String supplierId;

  @override
  Widget build(BuildContext context) {
    final scope = MadadScope.of(context);
    final theme = Theme.of(context).textTheme;
    final lines = [
      for (final item in order.items)
        if (scope.catalog.productById(item.productId)?.supplierId == supplierId)
          item,
    ];
    final share = lines.fold<double>(0, (sum, item) => sum + item.lineTotal);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: MadadColors.white,
        borderRadius: BorderRadius.circular(16),
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
                      child: Text(order.id, style: theme.titleMedium),
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
              Text('المتجر: بقالة النور', style: theme.bodyMedium),
              Text(formatDate(order.createdAt), style: theme.bodySmall),
              const SizedBox(height: 8),
              for (final item in lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${item.name} · ${item.quantity} ${item.unitLabel}',
                    style: theme.bodyMedium,
                  ),
                ),
              const SizedBox(height: 4),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: PriceLabel(share),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MadadColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MadadColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.headlineSmall),
          const SizedBox(height: 2),
          Text(label, style: theme.bodySmall),
        ],
      ),
    );
  }
}

List<Order> _ordersFor(MadadScope scope, String supplierId) {
  return [
    for (final order in scope.orders.orders)
      if (_containsSupplier(scope.catalog, order, supplierId)) order,
  ];
}

bool _containsSupplier(
  CatalogRepository catalog,
  Order order,
  String supplierId,
) {
  for (final item in order.items) {
    if (catalog.productById(item.productId)?.supplierId == supplierId) {
      return true;
    }
  }
  return false;
}
