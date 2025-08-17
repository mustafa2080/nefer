import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/products/presentation/screens/product_details_screen.dart';
import '../../features/products/presentation/screens/categories_screen.dart';
import '../../features/products/presentation/screens/search_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/presentation/screens/checkout_screen.dart';
import '../../features/cart/presentation/screens/payment_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';
import '../../features/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/wishlist_screen.dart';
import '../../features/profile/presentation/screens/addresses_screen.dart';
import '../../features/shared/presentation/screens/main_navigation_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'route_names.dart';

class AppRouter {
  static final List<RouteBase> routes = [
    // Splash Route
    GoRoute(
      path: RouteNames.splash,
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Auth Routes
    GoRoute(
      path: RouteNames.login,
      name: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.register,
      name: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      name: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Main Navigation Shell
    ShellRoute(
      builder: (context, state, child) => MainNavigationScreen(child: child),
      routes: [
        // Home Route
        GoRoute(
          path: RouteNames.home,
          name: RouteNames.home,
          builder: (context, state) => const HomeScreen(),
        ),

        // Categories Route
        GoRoute(
          path: RouteNames.categories,
          name: RouteNames.categories,
          builder: (context, state) => const CategoriesScreen(),
          routes: [
            GoRoute(
              path: 'products/:categoryId',
              name: RouteNames.categoryProducts,
              builder: (context, state) => ProductListScreen(
                categoryId: state.pathParameters['categoryId']!,
              ),
            ),
          ],
        ),

        // Cart Route
        GoRoute(
          path: RouteNames.cart,
          name: RouteNames.cart,
          builder: (context, state) => const CartScreen(),
          routes: [
            GoRoute(
              path: 'checkout',
              name: RouteNames.checkout,
              builder: (context, state) => const CheckoutScreen(),
              routes: [
                GoRoute(
                  path: 'payment',
                  name: RouteNames.payment,
                  builder: (context, state) => PaymentScreen(
                    orderId: state.uri.queryParameters['orderId']!,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Orders Route
        GoRoute(
          path: RouteNames.orders,
          name: RouteNames.orders,
          builder: (context, state) => const OrdersScreen(),
          routes: [
            GoRoute(
              path: ':orderId',
              name: RouteNames.orderDetails,
              builder: (context, state) => OrderDetailsScreen(
                orderId: state.pathParameters['orderId']!,
              ),
              routes: [
                GoRoute(
                  path: 'tracking',
                  name: RouteNames.orderTracking,
                  builder: (context, state) => OrderTrackingScreen(
                    orderId: state.pathParameters['orderId']!,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Profile Route
        GoRoute(
          path: RouteNames.profile,
          name: RouteNames.profile,
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'settings',
              name: RouteNames.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: 'wishlist',
              name: RouteNames.wishlist,
              builder: (context, state) => const WishlistScreen(),
            ),
            GoRoute(
              path: 'addresses',
              name: RouteNames.addresses,
              builder: (context, state) => const AddressesScreen(),
            ),
          ],
        ),
      ],
    ),

    // Product Routes (outside shell for full-screen experience)
    GoRoute(
      path: '/product/:productId',
      name: RouteNames.productDetails,
      builder: (context, state) => ProductDetailsScreen(
        productId: state.pathParameters['productId']!,
      ),
    ),

    // Search Route
    GoRoute(
      path: RouteNames.search,
      name: RouteNames.search,
      builder: (context, state) => SearchScreen(
        query: state.uri.queryParameters['q'],
      ),
    ),

    // Admin Routes
    GoRoute(
      path: RouteNames.admin,
      name: RouteNames.admin,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ];

  // Deep Link Handlers
  static String generateProductLink(String productId) {
    return '/product/$productId';
  }

  static String generateCategoryLink(String categoryId) {
    return '/categories/products/$categoryId';
  }

  static String generateOrderLink(String orderId) {
    return '/orders/$orderId';
  }

  static String generateSearchLink(String query) {
    return '/search?q=${Uri.encodeComponent(query)}';
  }

  // Navigation Helpers
  static void navigateToProduct(BuildContext context, String productId) {
    context.pushNamed(RouteNames.productDetails, pathParameters: {
      'productId': productId,
    });
  }

  static void navigateToCategory(BuildContext context, String categoryId) {
    context.pushNamed(RouteNames.categoryProducts, pathParameters: {
      'categoryId': categoryId,
    });
  }

  static void navigateToOrder(BuildContext context, String orderId) {
    context.pushNamed(RouteNames.orderDetails, pathParameters: {
      'orderId': orderId,
    });
  }

  static void navigateToSearch(BuildContext context, {String? query}) {
    context.pushNamed(
      RouteNames.search,
      queryParameters: query != null ? {'q': query} : null,
    );
  }

  static void navigateToCheckout(BuildContext context) {
    context.pushNamed(RouteNames.checkout);
  }

  static void navigateToPayment(BuildContext context, String orderId) {
    context.pushNamed(
      RouteNames.payment,
      queryParameters: {'orderId': orderId},
    );
  }

  // Auth Navigation
  static void navigateToLogin(BuildContext context) {
    context.goNamed(RouteNames.login);
  }

  static void navigateToRegister(BuildContext context) {
    context.pushNamed(RouteNames.register);
  }

  static void navigateToHome(BuildContext context) {
    context.goNamed(RouteNames.home);
  }

  // Bottom Navigation
  static void navigateToTab(BuildContext context, int tabIndex) {
    switch (tabIndex) {
      case 0:
        context.goNamed(RouteNames.home);
        break;
      case 1:
        context.goNamed(RouteNames.categories);
        break;
      case 2:
        context.goNamed(RouteNames.cart);
        break;
      case 3:
        context.goNamed(RouteNames.orders);
        break;
      case 4:
        context.goNamed(RouteNames.profile);
        break;
    }
  }
}
