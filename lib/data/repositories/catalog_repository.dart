import 'package:flutter/foundation.dart' hide Category;

import '../mock/mock_catalog.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/supplier.dart';

class CatalogRepository extends ChangeNotifier {
  CatalogRepository()
    : _categories = List<Category>.of(MockCatalog.categories),
      _suppliers = List<Supplier>.of(MockCatalog.suppliers),
      _products = List<Product>.of(MockCatalog.products);

  CatalogRepository.data({
    required List<Category> categories,
    required List<Supplier> suppliers,
    required List<Product> products,
  }) : _categories = List<Category>.of(categories),
       _suppliers = List<Supplier>.of(suppliers),
       _products = List<Product>.of(products);

  final List<Category> _categories;
  final List<Supplier> _suppliers;
  final List<Product> _products;
  int _localSequence = 1;

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
}
