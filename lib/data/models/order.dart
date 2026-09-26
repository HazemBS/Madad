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
}
