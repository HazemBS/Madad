import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/constants/madad_brand.dart';
import '../core/storage/local_store.dart';
import '../core/theme/madad_theme.dart';
import '../data/remote/madad_store.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/commerce_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/session_cubit.dart';
import '../features/cart/cart_cubit.dart';
import '../features/favorites/favorites_cubit.dart';
import '../features/home/shell_cubit.dart';
import '../features/orders/orders_cubit.dart';
import 'app_router.dart';
import 'madad_scope.dart';

class MadadApp extends StatefulWidget {
  const MadadApp({
    super.key,
    this.catalog,
    this.store,
    this.commerce,
    this.demoMode = true,
    this.startupNote,
    this.splashDelay = const Duration(milliseconds: 1200),
  });

  final CatalogRepository? catalog;
  final LocalStore? store;
  final CommerceRepository? commerce;
  final bool demoMode;
  final String? startupNote;
  final Duration splashDelay;

  @override
  State<MadadApp> createState() => _MadadAppState();
}

class _MadadAppState extends State<MadadApp> {
  late final CatalogRepository _catalog;
  late final CommerceRepository _commerce;
  late final SessionCubit _session;
  late final CartCubit _cart;
  late final FavoritesCubit _favorites;
  late final OrdersCubit _orders;
  late final ShellCubit _shell;
  late final bool _ownsCatalog;

  @override
  void initState() {
    super.initState();
    _ownsCatalog = widget.catalog == null;
    _commerce =
        widget.commerce ??
        (widget.demoMode
            ? DemoCommerceRepository()
            : SupabaseCommerceRepository(MadadStore(Supabase.instance.client)));
    if (widget.catalog != null) {
      _catalog = widget.catalog!;
    } else if (widget.demoMode) {
      _catalog = CatalogRepository();
      _catalog.restoreAdded(widget.store?.readAddedProducts() ?? const []);
    } else {
      final cached = widget.store?.readCatalog();
      _catalog = cached == null
          ? CatalogRepository.pending()
          : CatalogRepository.fromSnapshot(cached);
    }
    if (!widget.demoMode) {
      _catalog.remoteLoader = _commerce.loadCatalog;
      final store = widget.store;
      if (store != null) _catalog.cacheWriter = store.saveCatalog;
    }
    _catalog.addListener(_onCatalogChanged);
    final remote = widget.demoMode ? null : _commerce;
    _session = SessionCubit(store: widget.store, commerce: remote);
    _cart = CartCubit(store: widget.store);
    _favorites = FavoritesCubit(store: widget.store, remote: remote);
    _orders = OrdersCubit(
      catalog: _catalog,
      store: widget.store,
      remote: remote,
    );
    _shell = ShellCubit();
  }

  void _onCatalogChanged() {
    final store = widget.store;
    if (store != null) {
      store.saveAddedProducts(_catalog.addedProducts());
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _catalog.removeListener(_onCatalogChanged);
    if (_ownsCatalog) _catalog.dispose();
    _session.close();
    _cart.close();
    _favorites.close();
    _orders.close();
    _shell.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MadadScope(
      catalog: _catalog,
      commerce: _commerce,
      session: _session,
      cart: _cart,
      favorites: _favorites,
      orders: _orders,
      shell: _shell,
      splashDelay: widget.splashDelay,
      demoMode: widget.demoMode,
      startupNote: widget.startupNote,
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
