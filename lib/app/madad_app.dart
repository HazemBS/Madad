import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/constants/madad_brand.dart';
import '../core/theme/madad_theme.dart';
import '../data/repositories/catalog_repository.dart';
import '../features/auth/session_controller.dart';
import '../features/cart/cart_controller.dart';
import '../features/favorites/favorites_controller.dart';
import '../features/home/shell_controller.dart';
import '../features/orders/orders_controller.dart';
import 'app_router.dart';
import 'madad_scope.dart';

class MadadApp extends StatefulWidget {
  const MadadApp({
    super.key,
    this.catalog,
    this.splashDelay = const Duration(milliseconds: 1200),
  });

  final CatalogRepository? catalog;
  final Duration splashDelay;

  @override
  State<MadadApp> createState() => _MadadAppState();
}

class _MadadAppState extends State<MadadApp> {
  late final CatalogRepository _catalog;
  late final SessionController _session;
  late final CartController _cart;
  late final FavoritesController _favorites;
  late final OrdersController _orders;
  late final ShellController _shell;
  late final bool _ownsCatalog;

  @override
  void initState() {
    super.initState();
    _ownsCatalog = widget.catalog == null;
    _catalog = widget.catalog ?? CatalogRepository();
    _catalog.addListener(_onCatalogChanged);
    _session = SessionController();
    _cart = CartController();
    _favorites = FavoritesController();
    _orders = OrdersController(catalog: _catalog);
    _shell = ShellController();
  }

  void _onCatalogChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _catalog.removeListener(_onCatalogChanged);
    if (_ownsCatalog) _catalog.dispose();
    _session.dispose();
    _cart.dispose();
    _favorites.dispose();
    _orders.dispose();
    _shell.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MadadScope(
      catalog: _catalog,
      session: _session,
      cart: _cart,
      favorites: _favorites,
      orders: _orders,
      shell: _shell,
      splashDelay: widget.splashDelay,
      child: MaterialApp(
        title: MadadBrand.arabicName,
        debugShowCheckedModeBanner: false,
        theme: MadadTheme.light,
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [Locale('ar', 'SA')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        initialRoute: '/',
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
