import 'package:flutter/material.dart';

import '../data/repositories/catalog_repository.dart';
import '../data/repositories/commerce_repository.dart';
import '../features/auth/session_cubit.dart';
import '../features/cart/cart_cubit.dart';
import '../features/favorites/favorites_cubit.dart';
import '../features/home/shell_cubit.dart';
import '../features/orders/orders_cubit.dart';

class MadadScope extends InheritedWidget {
  const MadadScope({
    super.key,
    required this.catalog,
    required this.commerce,
    required this.session,
    required this.cart,
    required this.favorites,
    required this.orders,
    required this.shell,
    required this.splashDelay,
    required this.demoMode,
    this.startupNote,
    required super.child,
  });

  final CatalogRepository catalog;
  final CommerceRepository commerce;
  final SessionCubit session;
  final CartCubit cart;
  final FavoritesCubit favorites;
  final OrdersCubit orders;
  final ShellCubit shell;
  final Duration splashDelay;
  final bool demoMode;
  final String? startupNote;

  static MadadScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MadadScope>();
    assert(scope != null, 'MadadScope غير موجود في الشجرة');
    return scope!;
  }

  @override
  bool updateShouldNotify(MadadScope oldWidget) {
    return catalog != oldWidget.catalog ||
        commerce != oldWidget.commerce ||
        session != oldWidget.session ||
        cart != oldWidget.cart ||
        favorites != oldWidget.favorites ||
        orders != oldWidget.orders ||
        shell != oldWidget.shell ||
        splashDelay != oldWidget.splashDelay ||
        demoMode != oldWidget.demoMode ||
        startupNote != oldWidget.startupNote;
  }
}
