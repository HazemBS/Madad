import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/cart_item.dart';
import '../../data/models/category.dart';
import '../../data/models/order.dart';
import '../../data/models/product.dart';
import '../../data/models/supplier.dart';
import '../../data/repositories/catalog_repository.dart';

/// تخزين محلي للتعريف والسلة وآخر بيانات ناجحة. ليس دليلًا على جلسة Supabase.
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingKey = 'madad.onboarding_done';
  static const _sessionKey = 'madad.session';
  static const _cartKey = 'madad.cart';
  static const _favoritesKey = 'madad.favorites';
  static const _productsKey = 'madad.added_products';
  static const _ordersKey = 'madad.orders';
  static const _catalogKey = 'madad.catalog_cache';

  static Future<LocalStore> open() async {
    return LocalStore(await SharedPreferences.getInstance());
  }

  bool get onboardingDone => _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingDone() => _prefs.setBool(_onboardingKey, true);

  Map<String, dynamic>? readSession() => _readMap(_sessionKey);

  Future<void> saveSession(Map<String, dynamic> json) {
    return _prefs.setString(_sessionKey, jsonEncode(json));
  }

  Future<void> clearSession() => _prefs.remove(_sessionKey);

  List<CartItem> readCart() {
    final list = _readList(_cartKey);
    if (list == null) return const [];
    return [
      for (final item in list)
        if (item is Map) CartItem.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  Future<void> saveCart(List<CartItem> items) {
    return _prefs.setString(
      _cartKey,
      jsonEncode([for (final item in items) item.toJson()]),
    );
  }

  List<String> readFavorites() {
    return _prefs.getStringList(_favoritesKey) ?? const [];
  }

  Future<void> saveFavorites(List<String> ids) {
    return _prefs.setStringList(_favoritesKey, ids);
  }

  List<Product> readAddedProducts() {
    final list = _readList(_productsKey);
    if (list == null) return const [];
    return [
      for (final item in list)
        if (item is Map) Product.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  Future<void> saveAddedProducts(List<Product> products) {
    return _prefs.setString(
      _productsKey,
      jsonEncode([for (final product in products) product.toJson()]),
    );
  }

  List<Order>? readOrders() {
    final list = _readList(_ordersKey);
    if (list == null) return null;
    return [
      for (final item in list)
        if (item is Map) Order.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  CatalogSnapshot? readCatalog() {
    final json = _readMap(_catalogKey);
    if (json == null) return null;
    try {
      return CatalogSnapshot(
        categories: [
          for (final item in json['categories'] as List<dynamic>)
            if (item is Map) Category.fromJson(Map<String, dynamic>.from(item)),
        ],
        suppliers: [
          for (final item in json['suppliers'] as List<dynamic>)
            if (item is Map) Supplier.fromJson(Map<String, dynamic>.from(item)),
        ],
        products: [
          for (final item in json['products'] as List<dynamic>)
            if (item is Map) Product.fromJson(Map<String, dynamic>.from(item)),
        ],
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCatalog(CatalogSnapshot snapshot) {
    return _prefs.setString(
      _catalogKey,
      jsonEncode({
        'categories': [
          for (final category in snapshot.categories) category.toJson(),
        ],
        'suppliers': [
          for (final supplier in snapshot.suppliers) supplier.toJson(),
        ],
        'products': [for (final product in snapshot.products) product.toJson()],
      }),
    );
  }

  Future<void> saveOrders(List<Order> orders) {
    return _prefs.setString(
      _ordersKey,
      jsonEncode([for (final order in orders) order.toJson()]),
    );
  }

  Map<String, dynamic>? _readMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } on FormatException {
      return null;
    }
    return null;
  }

  List<dynamic>? _readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List<dynamic>) return decoded;
    } on FormatException {
      return null;
    }
    return null;
  }
}
