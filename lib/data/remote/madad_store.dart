import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/business_profile.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/order_line_request.dart';
import '../models/product.dart';
import '../models/supplier.dart';
import '../repositories/catalog_repository.dart';

String arabicAuthMessage(String raw) {
  if (RegExp(r'[\u0600-\u06FF]').hasMatch(raw)) return raw;
  final text = raw.toLowerCase();
  if (text.contains('invalid login') || text.contains('invalid credentials')) {
    return 'البريد أو كلمة المرور غير صحيحة.';
  }
  if (text.contains('already registered') ||
      text.contains('already been registered')) {
    return 'هذا البريد مسجّل من قبل.';
  }
  if (text.contains('email not confirmed')) {
    return 'أكّد البريد الإلكتروني ثم سجّل الدخول.';
  }
  if (text.contains('password')) {
    return 'كلمة المرور غير مقبولة. استخدم 8 أحرف على الأقل.';
  }
  if (text.contains('row-level') ||
      text.contains('permission') ||
      text.contains('42501')) {
    return 'ليست لديك صلاحية لهذه العملية.';
  }
  return 'تعذر إكمال العملية. تحقق من البيانات ثم أعد المحاولة.';
}

class MadadAuthException implements Exception {
  MadadAuthException(this.message, {this.emailConfirmation = false});

  final String message;
  final bool emailConfirmation;

  @override
  String toString() => message;
}

class RemoteAccount {
  const RemoteAccount({
    required this.profile,
    required this.role,
    required this.supplierId,
  });

  final BusinessProfile profile;
  final String role;
  final String? supplierId;
}

class MadadStore {
  MadadStore(this.client);

  final SupabaseClient client;

  bool get hasSession => client.auth.currentSession != null;

  Future<CatalogSnapshot> loadCatalogSnapshot() async {
    final catalog = await loadCatalog();
    return catalog.snapshot();
  }

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

  Future<void> signOut() => client.auth.signOut();

  Future<BusinessProfile> loadProfile() async {
    final account = await loadAccount();
    if (account == null) {
      throw MadadAuthException('لا توجد جلسة دخول.');
    }
    return account.profile;
  }

  Future<RemoteAccount?> loadAccount() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;
    Object? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final row = await client
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();
        return RemoteAccount(
          profile: BusinessProfile(
            businessName: row['business_name'] as String,
            ownerName: row['owner_name'] as String,
            phone: row['phone'] as String,
            city: row['city'] as String,
            addresses: [row['address'] as String],
          ),
          role: row['role'] as String? ?? 'customer',
          supplierId: row['supplier_id'] as String?,
        );
      } catch (error) {
        lastError = error;
        await Future<void>.delayed(const Duration(milliseconds: 350));
      }
    }
    throw MadadAuthException(arabicAuthMessage('$lastError'));
  }

  Future<RemoteAccount> signIn({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      await client.auth.signInWithPassword(email: email, password: password);
      final account = await loadAccount();
      if (account == null) {
        throw MadadAuthException('تعذر قراءة ملف المنشأة بعد الدخول.');
      }
      return account;
    });
  }

  Future<RemoteAccount> register({
    required String email,
    required String password,
    required String role,
    required String businessName,
    required String ownerName,
    required String phone,
    required String city,
    required String address,
  }) {
    return _guard(() async {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': role == 'supplier' ? 'supplier' : 'customer',
          'business_name': businessName,
          'owner_name': ownerName,
          'phone': phone,
          'city': city,
          'address': address,
        },
      );
      if (response.session == null) {
        throw MadadAuthException(
          'أُنشئ الحساب. أكّد البريد الإلكتروني ثم سجّل الدخول.',
          emailConfirmation: true,
        );
      }
      final account = await loadAccount();
      if (account == null) {
        throw MadadAuthException('تعذر قراءة ملف المنشأة بعد التسجيل.');
      }
      return account;
    });
  }

  Future<Product> createProduct({
    required String supplierId,
    required String name,
    required String description,
    required double wholesalePrice,
    required ProductUnit unit,
    required int minOrder,
    required int stock,
    required String categoryId,
  }) {
    return _guard(() async {
      final account = await loadAccount();
      if (account == null || account.role != 'supplier') {
        throw MadadAuthException('إضافة المنتجات متاحة لحساب المورد فقط.');
      }
      if (account.supplierId == null || account.supplierId != supplierId) {
        throw MadadAuthException('لا يمكنك إضافة منتج إلا لمنشأتك.');
      }
      final id = 'sp-${DateTime.now().microsecondsSinceEpoch}';
      await client.from('products').insert({
        'id': id,
        'name': name.trim(),
        'description': description.trim(),
        'wholesale_price': wholesalePrice,
        'unit': unit.name,
        'min_order': minOrder,
        'stock': stock,
        'supplier_id': supplierId,
        'category_id': categoryId,
        'is_popular': false,
      });
      await client.from('supplier_categories').upsert({
        'supplier_id': supplierId,
        'category_id': categoryId,
      });
      return Product(
        id: id,
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
    });
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
        .order('created_at', ascending: false);
    return [for (final row in rows) _orderFromRow(row)];
  }

  Future<Order> createSecureOrder({
    required List<OrderLineRequest> lines,
    required String address,
    required PaymentMethod paymentMethod,
    required String notes,
  }) {
    return _guard(() async {
      if (client.auth.currentUser == null) {
        throw MadadAuthException('سجّل الدخول قبل تأكيد الطلب.');
      }
      final raw = await client.rpc(
        'create_secure_order',
        params: {
          'p_items': [
            for (final line in lines)
              {'product_id': line.productId, 'quantity': line.quantity},
          ],
          'p_address': address,
          'p_payment_method': paymentMethod.name,
          'p_notes': notes,
        },
      );
      if (raw is! Map) {
        throw MadadAuthException('تعذر قراءة الطلب بعد إنشائه.');
      }
      return _orderFromRow(Map<String, dynamic>.from(raw));
    });
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on MadadAuthException {
      rethrow;
    } on AuthException catch (error) {
      throw MadadAuthException(arabicAuthMessage(error.message));
    } on PostgrestException catch (error) {
      throw MadadAuthException(arabicAuthMessage(error.message));
    }
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
