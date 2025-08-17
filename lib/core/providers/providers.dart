import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_functions/firebase_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../data/repositories/coupon_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/analytics_repository_impl.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/profile/domain/repositories/user_repository.dart';
import '../../features/products/domain/repositories/review_repository.dart';
import '../../features/cart/domain/repositories/coupon_repository.dart';
import '../../features/shared/domain/repositories/notification_repository.dart';
import '../../features/admin/domain/repositories/analytics_repository.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/products/presentation/controllers/product_list_controller.dart';
import '../../features/products/presentation/controllers/product_details_controller.dart';
import '../../features/products/presentation/controllers/search_controller.dart';
import '../../features/cart/presentation/controllers/cart_controller.dart';
import '../../features/orders/presentation/controllers/orders_controller.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/home/presentation/controllers/home_controller.dart';

import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
import '../services/image_service.dart';
import '../services/hive_service.dart';

// =============================================================================
// FIREBASE PROVIDERS
// =============================================================================

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instance;
});

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

// =============================================================================
// LOCAL STORAGE PROVIDERS
// =============================================================================

final hiveProvider = Provider<HiveInterface>((ref) {
  return Hive;
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

// =============================================================================
// SERVICE PROVIDERS
// =============================================================================

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(ref.read(connectivityProvider));
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    database: ref.read(firebaseDatabaseProvider),
    hive: ref.read(hiveProvider),
    connectivity: ref.read(connectivityServiceProvider),
  );
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    messaging: ref.read(firebaseMessagingProvider),
    database: ref.read(firebaseDatabaseProvider),
  );
});

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService(
    storage: ref.read(firebaseStorageProvider),
  );
});

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService(ref.read(hiveProvider));
});

// =============================================================================
// REPOSITORY PROVIDERS
// =============================================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    auth: ref.read(firebaseAuthProvider),
    database: ref.read(firebaseDatabaseProvider),
    hive: ref.read(hiveServiceProvider),
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    database: ref.read(firebaseDatabaseProvider),
    storage: ref.read(firebaseStorageProvider),
    hive: ref.read(hiveServiceProvider),
    connectivity: ref.read(connectivityServiceProvider),
  );
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    database: ref.read(firebaseDatabaseProvider),
    hive: ref.read(hiveServiceProvider),
    connectivity: ref.read(connectivityServiceProvider),
  );
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    database: ref.read(firebaseDatabaseProvider),
    functions: ref.read(firebaseFunctionsProvider),
    hive: ref.read(hiveServiceProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    database: ref.read(firebaseDatabaseProvider),
    storage: ref.read(firebaseStorageProvider),
    hive: ref.read(hiveServiceProvider),
  );
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(
    database: ref.read(firebaseDatabaseProvider),
    storage: ref.read(firebaseStorageProvider),
  );
});

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  return CouponRepositoryImpl(
    database: ref.read(firebaseDatabaseProvider),
    functions: ref.read(firebaseFunctionsProvider),
  );
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    database: ref.read(firebaseDatabaseProvider),
    messaging: ref.read(firebaseMessagingProvider),
  );
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl(
    database: ref.read(firebaseDatabaseProvider),
    analytics: ref.read(analyticsServiceProvider),
  );
});

// =============================================================================
// CONTROLLER PROVIDERS
// =============================================================================

final authStateProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    authRepository: ref.read(authRepositoryProvider),
    analyticsService: ref.read(analyticsServiceProvider),
  );
});

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(
    productRepository: ref.read(productRepositoryProvider),
    analyticsService: ref.read(analyticsServiceProvider),
  );
});

final productListControllerProvider = StateNotifierProvider.family<
    ProductListController, ProductListState, ProductListParams>((ref, params) {
  return ProductListController(
    repository: ref.read(productRepositoryProvider),
    params: params,
    analyticsService: ref.read(analyticsServiceProvider),
  );
});

final productDetailsControllerProvider = StateNotifierProvider.family<
    ProductDetailsController, ProductDetailsState, String>((ref, productId) {
  return ProductDetailsController(
    productId: productId,
    productRepository: ref.read(productRepositoryProvider),
    cartRepository: ref.read(cartRepositoryProvider),
    reviewRepository: ref.read(reviewRepositoryProvider),
    analyticsService: ref.read(analyticsServiceProvider),
  );
});

final searchControllerProvider = StateNotifierProvider<SearchController, SearchState>((ref) {
  return SearchController(
    productRepository: ref.read(productRepositoryProvider),
    analyticsService: ref.read(analyticsServiceProvider),
  );
});

final cartControllerProvider = StateNotifierProvider<CartController, CartState>((ref) {
  final authState = ref.watch(authStateProvider);
  return CartController(
    cartRepository: ref.read(cartRepositoryProvider),
    authState: authState,
    analyticsService: ref.read(analyticsServiceProvider),
  );
});

final ordersControllerProvider = StateNotifierProvider<OrdersController, OrdersState>((ref) {
  final authState = ref.watch(authStateProvider);
  return OrdersController(
    orderRepository: ref.read(orderRepositoryProvider),
    authState: authState,
    analyticsService: ref.read(analyticsServiceProvider),
  );
});

final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  final authState = ref.watch(authStateProvider);
  return ProfileController(
    userRepository: ref.read(userRepositoryProvider),
    authRepository: ref.read(authRepositoryProvider),
    authState: authState,
  );
});

// =============================================================================
// STREAM PROVIDERS
// =============================================================================

final authStreamProvider = StreamProvider<User?>((ref) {
  return ref.read(firebaseAuthProvider).authStateChanges();
});

final cartStreamProvider = StreamProvider<Cart?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    authenticated: (user) => ref.read(cartRepositoryProvider).getCartStream(user.uid),
    orElse: () => Stream.value(null),
  );
});

final notificationsStreamProvider = StreamProvider<List<AppNotification>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    authenticated: (user) => ref.read(notificationRepositoryProvider).getNotificationsStream(user.uid),
    orElse: () => Stream.value([]),
  );
});

// =============================================================================
// FUTURE PROVIDERS
// =============================================================================

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.read(productRepositoryProvider).getCategories();
});

final flashSalesProvider = FutureProvider<List<FlashSale>>((ref) {
  return ref.read(productRepositoryProvider).getActiveFlashSales();
});

final recommendationsProvider = FutureProvider.family<List<Product>, String>((ref, userId) {
  return ref.read(productRepositoryProvider).getRecommendations(userId);
});

// =============================================================================
// STATE PROVIDERS
// =============================================================================

final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

final searchQueryProvider = StateProvider<String>((ref) => '');

final selectedFiltersProvider = StateProvider<ProductFilters>((ref) => const ProductFilters());

final selectedSortProvider = StateProvider<ProductSortBy>((ref) => ProductSortBy.relevance);

final isOfflineProvider = StateProvider<bool>((ref) => false);

final cartItemCountProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartControllerProvider);
  return cartState.maybeWhen(
    loaded: (cart) => cart.items.length,
    orElse: () => 0,
  );
});

final wishlistItemCountProvider = Provider<int>((ref) {
  final profileState = ref.watch(profileControllerProvider);
  return profileState.maybeWhen(
    loaded: (profile) => profile.wishlist.length,
    orElse: () => 0,
  );
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsStreamProvider);
  return notifications.maybeWhen(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

// =============================================================================
// COMPUTED PROVIDERS
// =============================================================================

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    authenticated: (_) => true,
    orElse: () => false,
  );
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
});

final hasAdminAccessProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    authenticated: (user) => user.role?.hasAdminAccess ?? false,
    orElse: () => false,
  );
});

final cartTotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartControllerProvider);
  return cartState.maybeWhen(
    loaded: (cart) => cart.total,
    orElse: () => 0.0,
  );
});

final cartSubtotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartControllerProvider);
  return cartState.maybeWhen(
    loaded: (cart) => cart.subtotal,
    orElse: () => 0.0,
  );
});

// =============================================================================
// LIFECYCLE PROVIDERS
// =============================================================================

final appLifecycleProvider = StateProvider<AppLifecycleState>((ref) {
  return AppLifecycleState.resumed;
});

// Auto-dispose providers for memory management
final autoDisposeProductListProvider = StateNotifierProvider.autoDispose
    .family<ProductListController, ProductListState, ProductListParams>((ref, params) {
  return ProductListController(
    repository: ref.read(productRepositoryProvider),
    params: params,
    analyticsService: ref.read(analyticsServiceProvider),
  );
});

final autoDisposeProductDetailsProvider = StateNotifierProvider.autoDispose
    .family<ProductDetailsController, ProductDetailsState, String>((ref, productId) {
  return ProductDetailsController(
    productId: productId,
    productRepository: ref.read(productRepositoryProvider),
    cartRepository: ref.read(cartRepositoryProvider),
    reviewRepository: ref.read(reviewRepositoryProvider),
    analyticsService: ref.read(analyticsServiceProvider),
  );
});
