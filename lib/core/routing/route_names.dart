/// Route names for the Nefer app
/// 
/// This class contains all the route names used throughout the application.
/// Using constants ensures type safety and prevents typos in route navigation.
class RouteNames {
  // Private constructor to prevent instantiation
  RouteNames._();

  // Auth Routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main Navigation Routes
  static const String home = '/';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';

  // Product Routes
  static const String productDetails = 'product-details';
  static const String categoryProducts = 'category-products';
  static const String search = '/search';

  // Cart & Checkout Routes
  static const String checkout = 'checkout';
  static const String payment = 'payment';

  // Order Routes
  static const String orderDetails = 'order-details';
  static const String orderTracking = 'order-tracking';

  // Profile Routes
  static const String settings = 'settings';
  static const String wishlist = 'wishlist';
  static const String addresses = 'addresses';

  // Admin Routes
  static const String admin = '/admin';
  static const String adminProducts = '/admin/products';
  static const String adminOrders = '/admin/orders';
  static const String adminUsers = '/admin/users';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminSettings = '/admin/settings';

  // Support Routes
  static const String chat = '/chat';
  static const String complaints = '/complaints';
  static const String contact = '/contact';

  // Flash Sales Routes
  static const String flashSales = '/flash-sales';
  static const String coupons = '/coupons';

  // Deep Link Patterns
  static const String productDeepLink = '/product/:productId';
  static const String categoryDeepLink = '/category/:categoryId';
  static const String orderDeepLink = '/order/:orderId';
  static const String flashSaleDeepLink = '/flash-sale/:saleId';
  static const String couponDeepLink = '/coupon/:couponCode';

  // Query Parameters
  static const String queryParam = 'q';
  static const String categoryParam = 'category';
  static const String sortParam = 'sort';
  static const String filterParam = 'filter';
  static const String pageParam = 'page';

  // Route Groups for easier management
  static const List<String> authRoutes = [
    splash,
    login,
    register,
    forgotPassword,
  ];

  static const List<String> mainNavigationRoutes = [
    home,
    categories,
    cart,
    orders,
    profile,
  ];

  static const List<String> adminRoutes = [
    admin,
    adminProducts,
    adminOrders,
    adminUsers,
    adminAnalytics,
    adminSettings,
  ];

  static const List<String> publicRoutes = [
    splash,
    login,
    register,
    forgotPassword,
    home,
    categories,
    productDetails,
    search,
  ];

  static const List<String> protectedRoutes = [
    cart,
    checkout,
    payment,
    orders,
    orderDetails,
    orderTracking,
    profile,
    settings,
    wishlist,
    addresses,
    chat,
    complaints,
  ];

  // Helper methods
  static bool isAuthRoute(String route) {
    return authRoutes.contains(route);
  }

  static bool isMainNavigationRoute(String route) {
    return mainNavigationRoutes.contains(route);
  }

  static bool isAdminRoute(String route) {
    return adminRoutes.any((adminRoute) => route.startsWith(adminRoute));
  }

  static bool isProtectedRoute(String route) {
    return protectedRoutes.any((protectedRoute) => route.contains(protectedRoute));
  }

  static bool isPublicRoute(String route) {
    return publicRoutes.any((publicRoute) => route.contains(publicRoute));
  }

  // Get tab index for bottom navigation
  static int getTabIndex(String route) {
    if (route.startsWith(home)) return 0;
    if (route.startsWith(categories)) return 1;
    if (route.startsWith(cart)) return 2;
    if (route.startsWith(orders)) return 3;
    if (route.startsWith(profile)) return 4;
    return 0; // Default to home
  }

  // Get route title for app bar
  static String getRouteTitle(String route) {
    switch (route) {
      case home:
        return 'Nefer';
      case categories:
        return 'Categories';
      case cart:
        return 'Shopping Cart';
      case orders:
        return 'My Orders';
      case profile:
        return 'Profile';
      case search:
        return 'Search';
      case checkout:
        return 'Checkout';
      case payment:
        return 'Payment';
      case settings:
        return 'Settings';
      case wishlist:
        return 'Wishlist';
      case addresses:
        return 'Addresses';
      case admin:
        return 'Admin Dashboard';
      case chat:
        return 'Support Chat';
      case complaints:
        return 'Complaints';
      case contact:
        return 'Contact Us';
      case flashSales:
        return 'Flash Sales';
      case coupons:
        return 'Coupons';
      default:
        return 'Nefer';
    }
  }

  // Get Arabic route title for RTL support
  static String getRouteTitleAr(String route) {
    switch (route) {
      case home:
        return 'نفِر';
      case categories:
        return 'الفئات';
      case cart:
        return 'سلة التسوق';
      case orders:
        return 'طلباتي';
      case profile:
        return 'الملف الشخصي';
      case search:
        return 'البحث';
      case checkout:
        return 'الدفع';
      case payment:
        return 'الدفع';
      case settings:
        return 'الإعدادات';
      case wishlist:
        return 'المفضلة';
      case addresses:
        return 'العناوين';
      case admin:
        return 'لوحة الإدارة';
      case chat:
        return 'دعم العملاء';
      case complaints:
        return 'الشكاوى';
      case contact:
        return 'اتصل بنا';
      case flashSales:
        return 'العروض السريعة';
      case coupons:
        return 'الكوبونات';
      default:
        return 'نفِر';
    }
  }
}
