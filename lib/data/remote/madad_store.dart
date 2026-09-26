// ملف إنتاج معزول. نقطة تشغيل العرض في main.dart لا تستورده ولا تنفّذه.
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../models/business_profile.dart';
import '../models/cart_item.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/supplier.dart';
import '../repositories/catalog_repository.dart';

class MadadAuthException implements Exception {
  MadadAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MadadStore {
  MadadStore(this.client);

  final SupabaseClient client;

  bool get hasSession => client.auth.currentSession != null;

  Future<CatalogRepository> loadCatalog() async {
    final categoriesRows = await client.from('categories').select();
    final supplierRows = await client.from('suppliers').select();
    final linkRows = await client.from('supplier_categories').select();
    final productRows = await client.from('products').select();

    final links = <String, List<String>>{};
    for (final row in linkRows) {
      final supplierId = row['supplier_id'] as String;
      links.putIfAbsent(supplierId, () => []).add(row['category_id'] as String);
    }

    return CatalogRepository.data(
      categories: [
        for (final row in categoriesRows)
          Category(
            id: row['id'] as String,
            name: row['name'] as String,
            icon: CategoryIcon.values.byName(row['icon'] as String),
          ),
      ],
      suppliers: [
        for (final row in supplierRows)
          Supplier(
            id: row['id'] as String,
            name: row['name'] as String,
            city: row['city'] as String,
            categoryIds: links[row['id'] as String] ?? const [],
            rating: (row['rating'] as num).toDouble(),
            verified: row['verified'] as bool,
            about: row['about'] as String,
          ),
      ],
      products: [
        for (final row in productRows)
          Product(
            id: row['id'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            wholesalePrice: (row['wholesale_price'] as num).toDouble(),
            unit: ProductUnit.values.byName(row['unit'] as String),
            minOrder: row['min_order'] as int,
            stock: row['stock'] as int,
            supplierId: row['supplier_id'] as String,
            categoryId: row['category_id'] as String,
            isPopular: row['is_popular'] as bool,
          ),
      ],
    );
  }

  Future<void> signInDemo() async {
    await client.auth.signInWithPassword(
      email: SupabaseConfig.demoEmail,
      password: SupabaseConfig.demoPassword,
    );
  }

  Future<void> signOut() => client.auth.signOut();

  Future<BusinessProfile> loadProfile() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw MadadAuthException('لا توجد جلسة دخول.');
    }
    final row = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return BusinessProfile(
      businessName: row['business_name'] as String,
      ownerName: row['owner_name'] as String,
      phone: row['phone'] as String,
      city: row['city'] as String,
      addresses: [row['address'] as String],
    );
  }

  Future<List<String>> loadFavoriteIds() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return const [];
    final rows = await client
        .from('favorites')
        .select('product_id')
        .eq('user_id', userId);
    return [for (final row in rows) row['product_id'] as String];
  }

  Future<void> setFavorite({
    required String productId,
    required bool saved,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;
    if (saved) {
      await client.from('favorites').upsert({
        'user_id': userId,
        'product_id': productId,
      });
    } else {
      await client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
    }
  }

  Future<List<Order>> loadOrders() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return const [];
    final rows = await client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return [for (final row in rows) _orderFromRow(row)];
  }

  Future<Order> createOrder({
    required List<CartItem> items,
    required String address,
    required PaymentMethod paymentMethod,
    required String notes,
    required double deliveryFee,
    required String Function(String supplierId) supplierName,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw MadadAuthException('سجّل الدخول قبل تأكيد الطلب.');
    }
    final orderId = await client.rpc('next_order_id') as String;
    await client.from('orders').insert({
      'id': orderId,
      'user_id': userId,
      'status': OrderStatus.created.name,
      'address': address,
      'payment_method': paymentMethod.name,
      'notes': notes,
      'delivery_fee': deliveryFee,
    });
    await client.from('order_items').insert([
      for (final item in items)
        {
          'order_id': orderId,
          'product_id': item.product.id,
          'name': item.product.name,
          'supplier_name': supplierName(item.product.supplierId),
          'unit_label': item.product.unit.label,
          'unit_price': item.product.wholesalePrice,
          'quantity': item.quantity,
        },
    ]);
    final rows = await loadOrders();
    return rows.firstWhere((order) => order.id == orderId);
  }

  Order _orderFromRow(Map<String, dynamic> row) {
    final items = row['order_items'] as List<dynamic>? ?? const [];
    return Order(
      id: row['id'] as String,
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      status: OrderStatus.values.byName(row['status'] as String),
      address: row['address'] as String,
      paymentMethod: PaymentMethod.values.byName(
        row['payment_method'] as String,
      ),
      notes: row['notes'] as String? ?? '',
      deliveryFee: (row['delivery_fee'] as num).toDouble(),
      items: [
        for (final item in items)
          OrderItem(
            productId: item['product_id'] as String,
            name: item['name'] as String,
            supplierName: item['supplier_name'] as String,
            unitLabel: item['unit_label'] as String,
            unitPrice: (item['unit_price'] as num).toDouble(),
            quantity: item['quantity'] as int,
          ),
      ],
    );
  }
}
