enum ProductUnit {
  carton,
  box,
  piece,
  kilo;

  String get label => switch (this) {
    ProductUnit.carton => 'كرتون',
    ProductUnit.box => 'صندوق',
    ProductUnit.piece => 'حبة',
    ProductUnit.kilo => 'كيلو',
  };
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.wholesalePrice,
    required this.unit,
    required this.minOrder,
    required this.stock,
    required this.supplierId,
    required this.categoryId,
    required this.isPopular,
  });

  final String id;
  final String name;
  final String description;
  final double wholesalePrice;
  final ProductUnit unit;
  final int minOrder;
  final int stock;
  final String supplierId;
  final String categoryId;
  final bool isPopular;

  bool get inStock => stock > 0;
}
