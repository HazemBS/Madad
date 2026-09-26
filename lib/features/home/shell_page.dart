import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/widgets/madad_bottom_nav.dart';
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
    return ListenableBuilder(
      listenable: Listenable.merge([scope.shell, scope.session]),
      builder: (context, _) {
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
