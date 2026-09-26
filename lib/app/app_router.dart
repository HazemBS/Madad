import 'package:flutter/material.dart';

import '../core/constants/app_routes.dart';
import '../core/theme/madad_colors.dart';
import '../features/auth/login_page.dart';
import '../features/cart/cart_page.dart';
import '../features/cart/checkout_page.dart';
import '../features/home/shell_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/onboarding/splash_page.dart';
import '../features/orders/order_details_page.dart';
import '../features/orders/order_success_page.dart';
import '../features/products/product_details_page.dart';
import '../features/products/products_page.dart';
import '../features/suppliers/supplier_page.dart';
import '../features/suppliers/suppliers_page.dart';

abstract final class AppRouter {
  static Route<void> onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      AppRoutes.onboarding => const OnboardingPage(),
      AppRoutes.login => const LoginPage(),
      AppRoutes.shell => const ShellPage(),
      AppRoutes.products => ProductsPage(
        query: settings.arguments is ProductsQuery
            ? settings.arguments! as ProductsQuery
            : const ProductsQuery(),
      ),
      AppRoutes.productDetails => ProductDetailsPage(
        productId: settings.arguments as String? ?? '',
      ),
      AppRoutes.suppliers => const SuppliersPage(),
      AppRoutes.supplier => SupplierPage(
        supplierId: settings.arguments as String? ?? '',
      ),
      AppRoutes.cart => const CartPage(),
      AppRoutes.checkout => const CheckoutPage(),
      AppRoutes.orderSuccess => OrderSuccessPage(
        orderId: settings.arguments as String? ?? '',
      ),
      AppRoutes.orderDetails => OrderDetailsPage(
        orderId: settings.arguments as String? ?? '',
      ),
      _ => const SplashPage(),
    };

    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }
}

class UnknownPage extends StatelessWidget {
  const UnknownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'الصفحة غير متاحة',
          style: TextStyle(color: MadadColors.navy),
        ),
      ),
    );
  }
}
