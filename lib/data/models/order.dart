enum OrderStatus {
  created,
  confirmed,
  preparing,
  outForDelivery,
  completed;

  String get label => switch (this) {
    OrderStatus.created => 'جديد',
    OrderStatus.confirmed => 'تم التأكيد',
    OrderStatus.preparing => 'قيد التجهيز',
    OrderStatus.outForDelivery => 'خرج للتوصيل',
    OrderStatus.completed => 'مكتمل',
  };

  bool get isCurrent => this != OrderStatus.completed;
}

enum PaymentMethod {
  cashOnDelivery,
  bankTransfer;

  String get label => switch (this) {
    PaymentMethod.cashOnDelivery => 'دفع عند الاستلام',
    PaymentMethod.bankTransfer => 'تحويل بنكي',
  };
}

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.supplierName,
    required this.unitLabel,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String name;
  final String supplierName;
  final String unitLabel;
  final double unitPrice;
  final int quantity;

  double get lineTotal => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'supplierName': supplierName,
    'unitLabel': unitLabel,
    'unitPrice': unitPrice,
    'quantity': quantity,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      name: json['name'] as String,
      supplierName: json['supplierName'] as String,
      unitLabel: json['unitLabel'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }
}

class Order {
  const Order({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.address,
    required this.paymentMethod,
    required this.notes,
    required this.items,
    required this.deliveryFee,
  });

  final String id;
  final DateTime createdAt;
  final OrderStatus status;
  final String address;
  final PaymentMethod paymentMethod;
  final String notes;
  final List<OrderItem> items;
  final double deliveryFee;

  double get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  double get total => subtotal + deliveryFee;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'address': address,
    'paymentMethod': paymentMethod.name,
    'notes': notes,
    'deliveryFee': deliveryFee,
    'items': [for (final item in items) item.toJson()],
  };

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: OrderStatus.values.byName(json['status'] as String),
      address: json['address'] as String,
      paymentMethod: PaymentMethod.values.byName(
        json['paymentMethod'] as String,
      ),
      notes: json['notes'] as String? ?? '',
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      items: [
        for (final item in json['items'] as List<dynamic>)
          OrderItem.fromJson(item as Map<String, dynamic>),
      ],
    );
  }
}
