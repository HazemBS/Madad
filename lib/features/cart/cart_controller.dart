import 'package:flutter/foundation.dart';

import '../../data/models/cart_item.dart';
import '../../data/models/product.dart';

class CartController extends ChangeNotifier {
  static const double flatDeliveryFee = 25;
  static const double freeDeliveryFrom = 500;

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get count => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.lineTotal);

  double get deliveryFee {
    if (_items.isEmpty || subtotal >= freeDeliveryFrom) return 0;
    return flatDeliveryFee;
  }

  double get total => subtotal + deliveryFee;

  bool get isEmpty => _items.isEmpty;

  /// يرجع رسالة تنبيه إن ضُبطت الكمية، أو null عند الإضافة الطبيعية.
  String? add(Product product, int quantity) {
    if (!product.inStock) return 'المنتج غير متوفر حاليًا';

    var qty = quantity;
    String? notice;
    if (qty < product.minOrder) {
      qty = product.minOrder;
      notice = 'تم ضبط الكمية إلى الحد الأدنى (${product.minOrder})';
    }

    final index = _indexOf(product.id);
    final current = index == null ? 0 : _items[index].quantity;
    if (current + qty > product.stock) {
      final allowed = product.stock - current;
      if (allowed <= 0) return 'الكمية المتوفرة لا تكفي';
      qty = allowed;
      notice = 'تمت الإضافة حتى الكمية المتوفرة';
    }

    if (index == null) {
      _items.add(CartItem(product: product, quantity: qty));
    } else {
      _items[index] = _items[index].copyWith(quantity: current + qty);
    }
    notifyListeners();
    return notice;
  }

  void setQuantity(String productId, int quantity) {
    final index = _indexOf(productId);
    if (index == null) return;
    final product = _items[index].product;
    var next = quantity;
    if (next < product.minOrder) next = product.minOrder;
    if (next > product.stock) next = product.stock;
    _items[index] = _items[index].copyWith(quantity: next);
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int? _indexOf(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    return index == -1 ? null : index;
  }
}
