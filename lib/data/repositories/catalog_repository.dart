import 'package:flutter/foundation.dart' hide Category;

import '../mock/mock_catalog.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/supplier.dart';
import '../remote/madad_store.dart';

class CatalogSnapshot {
  const CatalogSnapshot({
    required this.categories,
    required this.suppliers,
    required this.products,
  });

  final List<Category> categories;
  final List<Supplier> suppliers;
  final List<Product> products;
}

class CatalogRepository extends ChangeNotifier {
  CatalogRepository()
    : _categories = List<Category>.of(MockCatalog.categories),
      _suppliers = List<Supplier>.of(MockCatalog.suppliers),
      _products = List<Product>.of(MockCatalog.products);

  CatalogRepository.pending()
    : _categories = <Category>[],
      _suppliers = <Supplier>[],
      _products = <Product>[],
      loading = true;

  CatalogRepository.data({
    required List<Category> categories,
    required List<Supplier> suppliers,
    required List<Product> products,
  }) : _categories = List<Category>.of(categories),
       _suppliers = List<Supplier>.of(suppliers),
       _products = List<Product>.of(products);

  factory CatalogRepository.fromSnapshot(CatalogSnapshot snapshot) {
    return CatalogRepository.data(
      categories: snapshot.categories,
      suppliers: snapshot.suppliers,
      products: snapshot.products,
    );
  }

  final List<Category> _categories;
  final List<Supplier> _suppliers;
  final List<Product> _products;
  int _localSequence = 1;
  bool loading = false;
  String? loadError;
  Future<CatalogSnapshot> Function()? remoteLoader;
  Future<void> Function(CatalogSnapshot snapshot)? cacheWriter;

  List<Category> categories() => List.unmodifiable(_categories);

  List<Supplier> suppliers() => List.unmodifiable(_suppliers);

  List<Product> products() => List.unmodifiable(_products);

  Category? categoryById(String id) {
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  Supplier? supplierById(String id) {
    for (final supplier in _suppliers) {
      if (supplier.id == id) return supplier;
    }
    return null;
  }

  Product? productById(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  List<Product> byCategory(String categoryId) {
    return _products
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  List<Product> bySupplier(String supplierId) {
    return _products
        .where((product) => product.supplierId == supplierId)
        .toList();
  }

  List<Product> popular() {
    return _products.where((product) => product.isPopular).toList();
  }

  String categoryName(String id) => categoryById(id)?.name ?? '';

  String supplierName(String id) => supplierById(id)?.name ?? '';

  Product addProduct({
    required String supplierId,
    required String name,
    required String description,
    required double wholesalePrice,
    required ProductUnit unit,
    required int minOrder,
    required int stock,
    required String categoryId,
  }) {
    final product = Product(
      id: 'local-$_localSequence',
      name: name.trim(),
      description: description.trim(),
      wholesalePrice: wholesalePrice,
      unit: unit,
      minOrder: minOrder,
      stock: stock,
      supplierId: supplierId,
      categoryId: categoryId,
      isPopular: false,
    );
    _localSequence += 1;
    _products.insert(0, product);
    notifyListeners();
    return product;
  }

  void insertProduct(Product product) {
    _products.removeWhere((item) => item.id == product.id);
    _products.insert(0, product);
    notifyListeners();
  }

  List<Product> addedProducts() {
    return _products
        .where((product) => product.id.startsWith('local-'))
        .toList();
  }

  void restoreAdded(List<Product> products) {
    if (products.isEmpty) return;
    _products.insertAll(0, products);
    var highest = 0;
    for (final product in products) {
      final number = int.tryParse(product.id.replaceFirst('local-', ''));
      if (number != null && number > highest) highest = number;
    }
    if (highest >= _localSequence) _localSequence = highest + 1;
    notifyListeners();
  }

  CatalogSnapshot snapshot() {
    return CatalogSnapshot(
      categories: categories(),
      suppliers: suppliers(),
      products: products(),
    );
  }

  void apply(CatalogSnapshot snapshot) {
    _categories
      ..clear()
      ..addAll(snapshot.categories);
    _suppliers
      ..clear()
      ..addAll(snapshot.suppliers);
    _products
      ..clear()
      ..addAll(snapshot.products);
    loading = false;
    loadError = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    final loader = remoteLoader;
    if (loader == null) return;
    loading = true;
    loadError = null;
    notifyListeners();
    try {
      final snapshot = await loader();
      apply(snapshot);
      await cacheWriter?.call(snapshot);
    } on MadadAuthException catch (error) {
      loading = false;
      loadError = error.message;
      notifyListeners();
    } catch (_) {
      loading = false;
      loadError = 'تعذر تحميل السوق. أعد المحاولة.';
      notifyListeners();
    }
  }
}
