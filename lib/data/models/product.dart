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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'wholesalePrice': wholesalePrice,
    'unit': unit.name,
    'minOrder': minOrder,
    'stock': stock,
    'supplierId': supplierId,
    'categoryId': categoryId,
    'isPopular': isPopular,
  };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      wholesalePrice: (json['wholesalePrice'] as num).toDouble(),
      unit: ProductUnit.values.byName(json['unit'] as String),
      minOrder: json['minOrder'] as int,
      stock: json['stock'] as int,
      supplierId: json['supplierId'] as String,
      categoryId: json['categoryId'] as String,
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }
}
