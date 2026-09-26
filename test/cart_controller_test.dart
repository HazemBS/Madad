import 'package:flutter_test/flutter_test.dart';
import 'package:rafd_v01/data/mock/mock_catalog.dart';
import 'package:rafd_v01/data/models/order.dart';
import 'package:rafd_v01/data/repositories/catalog_repository.dart';
import 'package:rafd_v01/features/cart/cart_cubit.dart';
import 'package:rafd_v01/features/orders/orders_cubit.dart';

void main() {
  final catalog = CatalogRepository();
  final rice = MockCatalog.products.firstWhere((product) => product.id == 'p1');

  test('إضافة منتج تحترم الحد الأدنى وتحسب التوصيل', () {
    final cart = CartCubit();
    cart.add(rice, 1);
    expect(cart.items.single.quantity, rice.minOrder);
    expect(cart.subtotal, rice.wholesalePrice * rice.minOrder);
    expect(cart.deliveryFee, CartCubit.flatDeliveryFee);
    expect(cart.total, cart.subtotal + cart.deliveryFee);
  });

  test('التوصيل يصبح مجانيًا عند بلوغ الحد', () {
    final cart = CartCubit();
    cart.add(rice, 6);
    expect(cart.subtotal, greaterThanOrEqualTo(CartCubit.freeDeliveryFrom));
    expect(cart.deliveryFee, 0);
  });

  test('إنشاء الطلب يفرغ رقمًا جديدًا ويحفظ العناصر', () async {
    final cart = CartCubit();
    cart.add(rice, rice.minOrder);
    final orders = OrdersCubit(catalog: catalog);
    final before = orders.orders.length;
    final order = await orders.placeOrder(
      items: cart.items,
      address: 'الرياض',
      paymentMethod: PaymentMethod.cashOnDelivery,
      notes: 'تجريبي',
    );
    expect(order.id, 'MD-1049');
    expect(order.status, OrderStatus.created);
    expect(order.deliveryFee, cart.deliveryFee);
    expect(orders.orders.length, before + 1);
    expect(order.items.single.name, rice.name);
    cart.clear();
    expect(cart.isEmpty, isTrue);
  });

  test('إضافة المنتج نفسه تجمع الكمية ولا تتجاوز المخزون', () {
    final cart = CartCubit();
    cart.add(rice, rice.minOrder);
    cart.add(rice, rice.minOrder);
    expect(cart.items, hasLength(1));
    expect(cart.items.single.quantity, rice.minOrder * 2);

    cart.add(rice, 1000);
    expect(cart.items.single.quantity, rice.stock);
  });

  test('حذف المنتج يلغي رسوم التوصيل', () {
    final cart = CartCubit();
    cart.add(rice, rice.minOrder);
    cart.remove(rice.id);
    expect(cart.isEmpty, isTrue);
    expect(cart.subtotal, 0);
    expect(cart.deliveryFee, 0);
    expect(cart.total, 0);
  });

  test('حد التوصيل المجاني لا يُمنح قبل 500', () {
    final cart = CartCubit();
    cart.add(rice, 5);
    expect(cart.subtotal, lessThan(CartCubit.freeDeliveryFrom));
    expect(cart.deliveryFee, CartCubit.flatDeliveryFee);
  });

  test('طلب فارغ يُرفض ورسوم التوصيل تُحسب من العناصر', () async {
    final orders = OrdersCubit(catalog: catalog);
    await expectLater(
      orders.placeOrder(
        items: const [],
        address: 'الرياض',
        paymentMethod: PaymentMethod.cashOnDelivery,
        notes: '',
      ),
      throwsArgumentError,
    );

    final cart = CartCubit();
    cart.add(rice, 6);
    final order = await orders.placeOrder(
      items: cart.items,
      address: 'الرياض',
      paymentMethod: PaymentMethod.cashOnDelivery,
      notes: '',
    );
    expect(order.deliveryFee, 0);
    expect(order.total, cart.subtotal);
  });
}
