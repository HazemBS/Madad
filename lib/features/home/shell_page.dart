import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/widgets/madad_builder.dart';
import '../../core/widgets/madad_bottom_nav.dart';
import '../../core/widgets/madad_message_view.dart';
import '../categories/categories_page.dart';
import '../favorites/favorites_page.dart';
import '../orders/orders_page.dart';
import '../profile/profile_page.dart';
import '../suppliers/supplier_workspace.dart';
import 'home_page.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = MadadScope.of(context);
    return MadadBuilder(
      cubits: [scope.shell, scope.session],
      listenables: [scope.catalog],
      builder: (context, _) {
        final catalog = scope.catalog;
        if (!scope.demoMode && catalog.loading && catalog.products().isEmpty) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: MadadColors.teal),
            ),
          );
        }
        if (!scope.demoMode &&
            catalog.loadError != null &&
            catalog.products().isEmpty) {
          return Scaffold(
            body: MadadMessageView(
              icon: Icons.cloud_off_outlined,
              title: 'تعذر تحميل السوق',
              message: catalog.loadError!,
              actionLabel: 'إعادة المحاولة',
              onAction: catalog.refresh,
            ),
          );
        }
        if (!scope.demoMode &&
            !catalog.loading &&
            catalog.loadError == null &&
            catalog.products().isEmpty) {
          return Scaffold(
            body: MadadMessageView(
              icon: Icons.inventory_2_outlined,
              title: 'لا توجد منتجات',
              message: 'لم يُنشر شيء في السوق بعد.',
              actionLabel: 'تحديث',
              onAction: catalog.refresh,
            ),
          );
        }
        final supplier = scope.session.isSupplier;
        final pages = supplier
            ? const [
                SupplierHomePage(),
                SupplierProductsPage(),
                SupplierOrdersPage(),
                ProfilePage(),
              ]
            : const [
                HomePage(),
                CategoriesPage(),
                OrdersPage(),
                FavoritesPage(),
                ProfilePage(),
              ];
        final index = scope.shell.index.clamp(0, pages.length - 1);
        return Scaffold(
          body: IndexedStack(index: index, children: pages),
          bottomNavigationBar: MadadBottomNav(
            index: index,
            onChanged: scope.shell.goTo,
            items: supplier
                ? MadadBottomNav.supplierItems
                : MadadBottomNav.shopItems,
          ),
        );
      },
    );
  }
}
