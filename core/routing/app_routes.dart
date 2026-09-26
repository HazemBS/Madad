abstract final class AppRoutes {
  const AppRoutes._();

  // المسارات المشتركة
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelection = '/role-selection';

  // مسارات العميل
  static const String customerHome = '/customer/home';
  static const String productDetails = '/customer/product-details';
  static const String cart = '/customer/cart';
  static const String customerOrders = '/customer/orders';
  static const String customerOrderDetails = '/customer/order-details';

  // مسارات تاجر الجملة
  static const String wholesalerDashboard = '/wholesaler/dashboard';
  static const String wholesalerProducts = '/wholesaler/products';
  static const String addProduct = '/wholesaler/products/add';
  static const String editProduct = '/wholesaler/products/edit';
  static const String wholesalerOrders = '/wholesaler/orders';
  static const String wholesalerOrderDetails = '/wholesaler/order-details';
}
