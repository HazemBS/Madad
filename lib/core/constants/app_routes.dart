abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const shell = '/shell';
  static const products = '/products';
  static const productDetails = '/product';
  static const suppliers = '/suppliers';
  static const supplier = '/supplier';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orderSuccess = '/order-success';
  static const orderDetails = '/order';
}

class ProductsQuery {
  const ProductsQuery({this.categoryId, this.supplierId, this.search});

  final String? categoryId;
  final String? supplierId;
  final String? search;
}
