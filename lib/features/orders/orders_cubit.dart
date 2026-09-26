import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_store.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/order.dart';
import '../../data/models/order_line_request.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/commerce_repository.dart';
import '../cart/cart_cubit.dart';

class OrdersCubit extends Cubit<List<Order>> {
  OrdersCubit({
    required CatalogRepository catalog,
    LocalStore? store,
    CommerceRepository? remote,
  }) : _catalog = catalog,
       _store = store,
       _remote = remote != null && remote.usesRemoteAuth ? remote : null,
       super(const []) {
    final saved = store?.readOrders();
    if (_remote != null) {
      if (saved != null) {
        _orders.addAll(saved);
        _sequence = _highestSequence(saved);
      }
    } else if (saved == null) {
      _seed();
    } else {
      _orders.addAll(saved);
      _sequence = _highestSequence(saved);
    }
    emit(List.unmodifiable(List<Order>.of(_orders)));
  }

  final CatalogRepository _catalog;
  final LocalStore? _store;
  final CommerceRepository? _remote;
  final List<Order> _orders = [];
  int _sequence = 1048;

  List<Order> get orders => state;

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

  Future<void> refresh() async {
    final remote = _remote;
    if (remote == null) return;
    final orders = await remote.loadOrders();
    _orders
      ..clear()
      ..addAll(orders);
    _publish();
  }

  Future<Order> placeOrder({
    required List<CartItem> items,
    required String address,
    required PaymentMethod paymentMethod,
    required String notes,
  }) async {
    final remote = _remote;
    if (remote != null) {
      if (items.isEmpty) {
        throw ArgumentError('لا يمكن إنشاء طلب من سلة فارغة');
      }
      final order = await remote.createOrder(
        lines: [
          for (final item in items)
            OrderLineRequest(
              productId: item.product.id,
              quantity: item.quantity,
            ),
        ],
        address: address,
        paymentMethod: paymentMethod,
        notes: notes.trim(),
      );
      _orders.insert(0, order);
      _publish();
      return order;
    }
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
    _publish();
    return order;
  }

  double _deliveryFeeFor(List<CartItem> items) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    if (subtotal >= CartCubit.freeDeliveryFrom) return 0;
    return CartCubit.flatDeliveryFee;
  }

  String _nextId() {
    _sequence += 1;
    return 'MD-$_sequence';
  }

  int _highestSequence(List<Order> orders) {
    var highest = _sequence;
    for (final order in orders) {
      final number = int.tryParse(order.id.replaceFirst('MD-', ''));
      if (number != null && number > highest) highest = number;
    }
    return highest;
  }

  void _publish() {
    emit(List.unmodifiable(List<Order>.of(_orders)));
    _store?.saveOrders(_orders);
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
