import '../models/account_role.dart';
import '../models/business_profile.dart';
import '../models/order.dart';
import '../models/order_line_request.dart';
import '../models/product.dart';
import '../remote/madad_store.dart';
import 'catalog_repository.dart';

class SignedAccount {
  const SignedAccount({
    required this.profile,
    required this.role,
    required this.supplierId,
  });

  final BusinessProfile profile;
  final AccountRole role;
  final String? supplierId;
}

/// الحد بين Cubit ومصدر البيانات. الوضع المتصل يمر عبر Supabase.
abstract class CommerceRepository {
  bool get usesRemoteAuth;

  Stream<SignedAccount?> watchAuth();

  Future<SignedAccount?> restoreAccount();

  Future<SignedAccount> signIn({
    required String email,
    required String password,
  });

  Future<SignedAccount> register({
    required String email,
    required String password,
    required AccountRole role,
    required String businessName,
    required String ownerName,
    required String phone,
    required String city,
    required String address,
  });

  Future<void> signOut();

  Future<CatalogSnapshot> loadCatalog();

  Future<List<String>> loadFavoriteIds();

  Future<void> setFavorite({required String productId, required bool saved});

  Future<List<Order>> loadOrders();

  Future<Order> createOrder({
    required List<OrderLineRequest> lines,
    required String address,
    required PaymentMethod paymentMethod,
    required String notes,
  });

  Future<Product> createProduct({
    required String supplierId,
    required String name,
    required String description,
    required double wholesalePrice,
    required ProductUnit unit,
    required int minOrder,
    required int stock,
    required String categoryId,
  });
}

class DemoCommerceRepository implements CommerceRepository {
  @override
  bool get usesRemoteAuth => false;

  @override
  Stream<SignedAccount?> watchAuth() => const Stream.empty();

  @override
  Future<SignedAccount?> restoreAccount() async => null;

  @override
  Future<SignedAccount> signIn({
    required String email,
    required String password,
  }) {
    throw MadadAuthException('وضع التجربة يستخدم أزرار الدخول المحلي.');
  }

  @override
  Future<SignedAccount> register({
    required String email,
    required String password,
    required AccountRole role,
    required String businessName,
    required String ownerName,
    required String phone,
    required String city,
    required String address,
  }) {
    throw MadadAuthException('إنشاء الحساب غير متاح في وضع التجربة.');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<CatalogSnapshot> loadCatalog() async {
    throw MadadAuthException('الكتالوج المحلي لا يُحمّل من الخادم.');
  }

  @override
  Future<List<String>> loadFavoriteIds() async => const [];

  @override
  Future<void> setFavorite({
    required String productId,
    required bool saved,
  }) async {}

  @override
  Future<List<Order>> loadOrders() async => const [];

  @override
  Future<Order> createOrder({
    required List<OrderLineRequest> lines,
    required String address,
    required PaymentMethod paymentMethod,
    required String notes,
  }) {
    throw MadadAuthException('تأكيد الطلب في وضع التجربة يبقى على الجهاز.');
  }

  @override
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
    throw MadadAuthException('إضافة المنتج في وضع التجربة تبقى على الجهاز.');
  }
}

class SupabaseCommerceRepository implements CommerceRepository {
  SupabaseCommerceRepository(this._store);

  final MadadStore _store;

  @override
  bool get usesRemoteAuth => true;

  @override
  Stream<SignedAccount?> watchAuth() {
    return _store.client.auth.onAuthStateChange.asyncMap((_) async {
      if (!_store.hasSession) return null;
      try {
        return await restoreAccount();
      } on MadadAuthException {
        return null;
      }
    });
  }

  @override
  Future<SignedAccount?> restoreAccount() async {
    final account = await _store.loadAccount();
    return account == null ? null : _signed(account);
  }

  @override
  Future<SignedAccount> signIn({
    required String email,
    required String password,
  }) async {
    return _signed(await _store.signIn(email: email, password: password));
  }

  @override
  Future<SignedAccount> register({
    required String email,
    required String password,
    required AccountRole role,
    required String businessName,
    required String ownerName,
    required String phone,
    required String city,
    required String address,
  }) async {
    return _signed(
      await _store.register(
        email: email,
        password: password,
        role: role == AccountRole.supplier ? 'supplier' : 'customer',
        businessName: businessName,
        ownerName: ownerName,
        phone: phone,
        city: city,
        address: address,
      ),
    );
  }

  SignedAccount _signed(RemoteAccount account) {
    return SignedAccount(
      profile: account.profile,
      role: accountRoleFromDatabase(account.role),
      supplierId: account.supplierId,
    );
  }

  @override
  Future<void> signOut() => _store.signOut();

  @override
  Future<CatalogSnapshot> loadCatalog() => _store.loadCatalogSnapshot();

  @override
  Future<List<String>> loadFavoriteIds() => _store.loadFavoriteIds();

  @override
  Future<void> setFavorite({required String productId, required bool saved}) {
    return _store.setFavorite(productId: productId, saved: saved);
  }

  @override
  Future<List<Order>> loadOrders() => _store.loadOrders();

  @override
  Future<Order> createOrder({
    required List<OrderLineRequest> lines,
    required String address,
    required PaymentMethod paymentMethod,
    required String notes,
  }) {
    return _store.createSecureOrder(
      lines: lines,
      address: address,
      paymentMethod: paymentMethod,
      notes: notes,
    );
  }

  @override
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
    return _store.createProduct(
      supplierId: supplierId,
      name: name,
      description: description,
      wholesalePrice: wholesalePrice,
      unit: unit,
      minOrder: minOrder,
      stock: stock,
      categoryId: categoryId,
    );
  }
}
