import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafd_v01/app/madad_app.dart';
import 'package:rafd_v01/data/mock/mock_catalog.dart';
import 'package:rafd_v01/data/models/business_profile.dart';
import 'package:rafd_v01/data/models/cart_item.dart';
import 'package:rafd_v01/data/models/order.dart';
import 'package:rafd_v01/data/models/order_line_request.dart';
import 'package:rafd_v01/data/models/product.dart';
import 'package:rafd_v01/data/remote/madad_store.dart';
import 'package:rafd_v01/data/repositories/catalog_repository.dart';
import 'package:rafd_v01/data/repositories/commerce_repository.dart';
import 'package:rafd_v01/features/auth/session_cubit.dart';
import 'package:rafd_v01/features/favorites/favorites_cubit.dart';
import 'package:rafd_v01/features/orders/orders_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rafd_v01/core/storage/local_store.dart';

class FakeCommerce implements CommerceRepository {
  SignedAccount? account;
  var failSignIn = false;
  var awaitEmailConfirmation = false;
  var failCatalog = false;
  var failFavorites = false;
  List<OrderLineRequest>? lastLines;
  final List<String> serverFavorites = ['p1'];

  @override
  bool get usesRemoteAuth => true;

  @override
  Stream<SignedAccount?> watchAuth() => const Stream.empty();

  @override
  Future<SignedAccount?> restoreAccount() async => account;

  @override
  Future<SignedAccount> signIn({
    required String email,
    required String password,
  }) async {
    if (failSignIn) {
      throw MadadAuthException('البريد أو كلمة المرور غير صحيحة.');
    }
    account = _account(AccountRole.shop);
    return account!;
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
    if (awaitEmailConfirmation) {
      throw MadadAuthException(
        'أُنشئ الحساب. أكّد البريد الإلكتروني ثم سجّل الدخول.',
        emailConfirmation: true,
      );
    }
    account = _account(role);
    return account!;
  }

  @override
  Future<void> signOut() async {
    account = null;
  }

  @override
  Future<CatalogSnapshot> loadCatalog() async {
    if (failCatalog) throw MadadAuthException('انقطع الاتصال بالسوق.');
    return CatalogSnapshot(
      categories: MockCatalog.categories,
      suppliers: MockCatalog.suppliers,
      products: [MockCatalog.products.first],
    );
  }

  @override
  Future<List<String>> loadFavoriteIds() async {
    if (failFavorites) throw Exception('offline');
    return List<String>.of(serverFavorites);
  }

  @override
  Future<void> setFavorite({
    required String productId,
    required bool saved,
  }) async {
    if (failFavorites) throw Exception('offline');
    serverFavorites.remove(productId);
    if (saved) serverFavorites.add(productId);
  }

  @override
  Future<List<Order>> loadOrders() async => const [];

  @override
  Future<Order> createOrder({
    required List<OrderLineRequest> lines,
    required String address,
    required PaymentMethod paymentMethod,
    required String notes,
  }) async {
    lastLines = lines;
    return Order(
      id: 'MD-9001',
      createdAt: DateTime.utc(2026, 9, 26),
      status: OrderStatus.created,
      address: address,
      paymentMethod: paymentMethod,
      notes: notes,
      deliveryFee: 25,
      items: [
        for (final line in lines)
          OrderItem(
            productId: line.productId,
            name: 'من الخادم',
            supplierName: 'مورد',
            unitLabel: 'كرتون',
            unitPrice: 7,
            quantity: line.quantity,
          ),
      ],
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
  }) async {
    return Product(
      id: 'sp-1',
      name: name,
      description: description,
      wholesalePrice: wholesalePrice,
      unit: unit,
      minOrder: minOrder,
      stock: stock,
      supplierId: supplierId,
      categoryId: categoryId,
      isPopular: false,
    );
  }

  SignedAccount _account(AccountRole role) {
    return SignedAccount(
      profile: const BusinessProfile(
        businessName: 'بقالة النور',
        ownerName: 'خالد العمري',
        phone: '0512345678',
        city: 'الرياض',
        addresses: ['حي النسيم'],
      ),
      role: role,
      supplierId: role == AccountRole.supplier ? 's-user' : null,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('رسائل Supabase العربية', () {
    expect(
      arabicAuthMessage('Invalid login credentials'),
      'البريد أو كلمة المرور غير صحيحة.',
    );
    expect(
      arabicAuthMessage('User already registered'),
      'هذا البريد مسجّل من قبل.',
    );
    expect(arabicAuthMessage('الكمية غير صالحة.'), 'الكمية غير صالحة.');
  });

  test('حالات الدخول واستعادة الجلسة لا تعتمد على العلم المحلي', () async {
    SharedPreferences.setMockInitialValues({
      'madad.session': jsonEncode({
        'isLoggedIn': true,
        'onboardingDone': true,
        'role': 'supplier',
      }),
      'madad.onboarding_done': true,
    });
    final store = await LocalStore.open();
    final fake = FakeCommerce();
    final cubit = SessionCubit(store: store, commerce: fake);
    addTearDown(cubit.close);

    expect(cubit.state.isLoggedIn, isFalse);
    expect(await cubit.restore(), isFalse);

    fake.failSignIn = true;
    expect(
      await cubit.signInWithEmail(
        email: 'shop@example.com',
        password: 'secret',
      ),
      isFalse,
    );
    expect(cubit.state.status, AuthStatus.failure);

    fake.failSignIn = false;
    expect(
      await cubit.signInWithEmail(
        email: 'shop@example.com',
        password: 'secret',
      ),
      isTrue,
    );
    expect(cubit.state.status, AuthStatus.success);
    expect(cubit.state.isLoggedIn, isTrue);
    expect(cubit.state.role, AccountRole.shop);

    fake.account = fake._account(AccountRole.shop);
    expect(await cubit.restore(), isTrue);
    await cubit.logout();
    expect(cubit.state.isLoggedIn, isFalse);
    expect(store.readSession(), isNull);
  });

  test('تحميل الكتالوج يعرض البيانات أو الخطأ', () async {
    final catalog = CatalogRepository.pending();
    final fake = FakeCommerce();
    catalog.remoteLoader = fake.loadCatalog;
    await catalog.refresh();
    expect(catalog.loading, isFalse);
    expect(catalog.products(), hasLength(1));
    expect(catalog.loadError, isNull);

    fake.failCatalog = true;
    await catalog.refresh();
    expect(catalog.loadError, 'انقطع الاتصال بالسوق.');
    expect(catalog.products(), hasLength(1));
  });

  test('مزامنة المفضلة تستبدل النسخة المحلية ولا تكرر', () async {
    final fake = FakeCommerce();
    final cubit = FavoritesCubit(remote: fake);
    addTearDown(cubit.close);
    await cubit.toggle('p9');
    expect(fake.serverFavorites, ['p1', 'p9']);
    await cubit.toggle('p9');
    expect(fake.serverFavorites, ['p1']);

    fake.failFavorites = true;
    await expectLater(cubit.toggle('p1'), throwsA(isA<MadadAuthException>()));
    expect(cubit.contains('p1'), isFalse);

    fake.failFavorites = false;
    fake.serverFavorites
      ..clear()
      ..add('p1');
    await cubit.refresh();
    expect(cubit.ids, ['p1']);
  });

  test('إنشاء الطلب يرسل المعرف والكمية ويأخذ سعر الخادم', () async {
    final fake = FakeCommerce();
    final catalog = CatalogRepository();
    final cubit = OrdersCubit(catalog: catalog, remote: fake);
    addTearDown(cubit.close);
    final product = MockCatalog.products.first;
    final order = await cubit.placeOrder(
      items: [CartItem(product: product, quantity: 3)],
      address: 'الرياض',
      paymentMethod: PaymentMethod.cashOnDelivery,
      notes: '',
    );
    expect(fake.lastLines, hasLength(1));
    expect(fake.lastLines!.single.productId, product.id);
    expect(fake.lastLines!.single.quantity, 3);
    expect(order.id, 'MD-9001');
    expect(order.items.single.unitPrice, 7);
    expect(order.items.single.unitPrice, isNot(product.wholesalePrice));
  });

  testWidgets('وضع التجربة يظهر عند غياب الاتصال', (tester) async {
    await tester.pumpWidget(
      const MadadApp(
        splashDelay: Duration.zero,
        startupNote: 'وضع التجربة المحلي',
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('skip-onboarding')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('demo-mode-banner')), findsOneWidget);
    expect(find.byKey(const ValueKey('demo-login')), findsOneWidget);
    expect(find.byKey(const ValueKey('auth-email')), findsNothing);
  });

  testWidgets('الوضع المتصل يعرض البريد لا أزرار التجربة', (tester) async {
    await tester.pumpWidget(
      MadadApp(
        splashDelay: Duration.zero,
        demoMode: false,
        commerce: FakeCommerce(),
        catalog: CatalogRepository(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('skip-onboarding')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('auth-email')), findsOneWidget);
    expect(find.byKey(const ValueKey('demo-login')), findsNothing);
  });

  testWidgets('بعد التسجيل يظهر تنبيه التأكيد مرة واحدة ويعود للدخول', (
    tester,
  ) async {
    final fake = FakeCommerce()..awaitEmailConfirmation = true;
    await tester.pumpWidget(
      MadadApp(
        splashDelay: Duration.zero,
        demoMode: false,
        commerce: fake,
        catalog: CatalogRepository(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('skip-onboarding')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('auth-toggle-register')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('auth-email')),
      'shop@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-password')),
      'secret123',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'اسم المنشأة'),
      'بقالة',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'اسم المسؤول'),
      'خالد',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'جوال المنشأة'),
      '0512345678',
    );
    await tester.enterText(find.widgetWithText(TextField, 'العنوان'), 'النسيم');
    await tester.ensureVisible(find.byKey(const ValueKey('auth-submit')));
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text('أُنشئ الحساب. أكّد البريد الإلكتروني ثم سجّل الدخول.'),
      findsOneWidget,
    );
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('اسم المنشأة'), findsNothing);
    expect(find.byKey(const ValueKey('auth-error')), findsNothing);
  });
}
