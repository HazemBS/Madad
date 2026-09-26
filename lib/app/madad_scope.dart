import 'package:flutter/material.dart';

import '../data/repositories/catalog_repository.dart';
import '../features/auth/session_controller.dart';
import '../features/cart/cart_controller.dart';
import '../features/favorites/favorites_controller.dart';
import '../features/home/shell_controller.dart';
import '../features/orders/orders_controller.dart';

class MadadScope extends InheritedWidget {
  const MadadScope({
    super.key,
    required this.catalog,
    required this.session,
    required this.cart,
    required this.favorites,
    required this.orders,
    required this.shell,
    required this.splashDelay,
    required super.child,
  });

  final CatalogRepository catalog;
  final SessionController session;
  final CartController cart;
  final FavoritesController favorites;
  final OrdersController orders;
  final ShellController shell;
  final Duration splashDelay;

  static MadadScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MadadScope>();
    assert(scope != null, 'MadadScope غير موجود في الشجرة');
    return scope!;
  }

  @override
  bool updateShouldNotify(MadadScope oldWidget) {
    return catalog != oldWidget.catalog ||
        session != oldWidget.session ||
        cart != oldWidget.cart ||
        favorites != oldWidget.favorites ||
        orders != oldWidget.orders ||
        shell != oldWidget.shell ||
        splashDelay != oldWidget.splashDelay;
  }
}
