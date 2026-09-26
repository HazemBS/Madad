import 'package:flutter/foundation.dart';

import '../../data/models/cart_item.dart';
import '../../data/models/order.dart';
import '../cart/cart_controller.dart';
import '../../data/repositories/catalog_repository.dart';

class OrdersController extends ChangeNotifier {
  OrdersController({required CatalogRepository catalog}) : _catalog = catalog {
    _seed();
  }

  final CatalogRepository _catalog;
  final List<Order> _orders = [];
  int _sequence = 1048;

  List<Order> get orders => List.unmodifiable(_orders);

  List<Order> get current =>
      _orders.where((order) => order.status.isCurrent).toList();

  List<Order> get previous =>
      _orders.where((order) => !order.status.isCurrent).toList();

  Order? byId(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  Future<void> refresh() async {}

  Future<Order> placeOrder({
    required List<CartItem> items,
    required String address,
    required PaymentMethod paymentMethod,
    required String notes,
  }) async {
    if (items.isEmpty) {
      throw ArgumentError.value(
        items,
        'items',
        'لا يمكن إنشاء طلب من سلة فارغة',
      );
    }
    final deliveryFee = _deliveryFeeFor(items);
    final order = Order(
      id: _nextId(),
      createdAt: DateTime.now(),
      status: OrderStatus.created,
      address: address,
      paymentMethod: paymentMethod,
      notes: notes.trim(),
      deliveryFee: deliveryFee,
      items: [
        for (final item in items)
          OrderItem(
            productId: item.product.id,
            name: item.product.name,
            supplierName: _catalog.supplierName(item.product.supplierId),
            unitLabel: item.product.unit.label,
            unitPrice: item.product.wholesalePrice,
            quantity: item.quantity,
          ),
      ],
    );
    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  double _deliveryFeeFor(List<CartItem> items) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    if (subtotal >= CartController.freeDeliveryFrom) return 0;
    return CartController.flatDeliveryFee;
  }

  String _nextId() {
    _sequence += 1;
    return 'MD-$_sequence';
  }

  void _seed() {
    _orders.addAll([
      _sample(
        id: 'MD-1048',
        status: OrderStatus.outForDelivery,
        daysAgo: 1,
        payment: PaymentMethod.cashOnDelivery,
        lines: const [('p2', 2), ('p6', 2)],
      ),
      _sample(
        id: 'MD-1042',
        status: OrderStatus.completed,
        daysAgo: 6,
        payment: PaymentMethod.bankTransfer,
        lines: const [('p8', 2), ('p12', 4)],
      ),
    ]);
  }

  Order _sample({
    required String id,
    required OrderStatus status,
    required int daysAgo,
    required PaymentMethod payment,
    required List<(String, int)> lines,
  }) {
    final items = <OrderItem>[
      for (final line in lines)
        OrderItem(
          productId: line.$1,
          name: _catalog.productById(line.$1)?.name ?? '',
          supplierName: _catalog.supplierName(
            _catalog.productById(line.$1)?.supplierId ?? '',
          ),
          unitLabel: _catalog.productById(line.$1)?.unit.label ?? '',
          unitPrice: _catalog.productById(line.$1)?.wholesalePrice ?? 0,
          quantity: line.$2,
        ),
    ];
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    return Order(
      id: id,
      createdAt: DateTime.now().subtract(Duration(days: daysAgo)),
      status: status,
      address: 'حي النسيم، شارع الأمير بندر، الرياض',
      paymentMethod: payment,
      notes: '',
      items: items,
      deliveryFee: subtotal >= 500 ? 0 : 25,
    );
  }
}
