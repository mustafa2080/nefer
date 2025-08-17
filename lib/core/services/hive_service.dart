import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service for managing local storage with Hive
/// 
/// Provides type-safe local storage operations for the Nefer app's
/// offline-first architecture, including caching and data persistence.
class HiveService {
  final HiveInterface _hive;
  
  // Box names
  static const String productsBox = 'products';
  static const String categoriesBox = 'categories';
  static const String cartBox = 'cart';
  static const String userBox = 'user';
  static const String ordersBox = 'orders';
  static const String syncQueueBox = 'sync_queue';
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  static const String wishlistBox = 'wishlist';
  static const String searchHistoryBox = 'search_history';

  HiveService(this._hive);

  /// Initialize Hive and open all required boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register type adapters here when models are created
    // Hive.registerAdapter(ProductAdapter());
    // Hive.registerAdapter(CategoryAdapter());
    // etc.
    
    // Open all required boxes
    await Future.wait([
      Hive.openBox(productsBox),
      Hive.openBox(categoriesBox),
      Hive.openBox(cartBox),
      Hive.openBox(userBox),
      Hive.openBox(ordersBox),
      Hive.openBox(syncQueueBox),
      Hive.openBox(settingsBox),
      Hive.openBox(cacheBox),
      Hive.openBox(wishlistBox),
      Hive.openBox(searchHistoryBox),
    ]);
  }

  /// Get a box by name
  Box getBox(String boxName) {
    return _hive.box(boxName);
  }

  /// Get typed box
  Box<T> getTypedBox<T>(String boxName) {
    return _hive.box<T>(boxName);
  }

  // =============================================================================
  // PRODUCTS OPERATIONS
  // =============================================================================

  /// Save product to local storage
  Future<void> saveProduct(String productId, Map<String, dynamic> productData) async {
    final box = getBox(productsBox);
    await box.put(productId, productData);
  }

  /// Get product from local storage
  Map<String, dynamic>? getProduct(String productId) {
    final box = getBox(productsBox);
    final data = box.get(productId);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Save multiple products
  Future<void> saveProducts(Map<String, Map<String, dynamic>> products) async {
    final box = getBox(productsBox);
    await box.putAll(products);
  }

  /// Get all cached products
  Map<String, Map<String, dynamic>> getAllProducts() {
    final box = getBox(productsBox);
    final Map<String, Map<String, dynamic>> products = {};
    
    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        products[key.toString()] = Map<String, dynamic>.from(data);
      }
    }
    
    return products;
  }

  /// Clear products cache
  Future<void> clearProducts() async {
    final box = getBox(productsBox);
    await box.clear();
  }

  // =============================================================================
  // CATEGORIES OPERATIONS
  // =============================================================================

  /// Save categories to local storage
  Future<void> saveCategories(List<Map<String, dynamic>> categories) async {
    final box = getBox(categoriesBox);
    await box.put('categories', categories);
  }

  /// Get categories from local storage
  List<Map<String, dynamic>>? getCategories() {
    final box = getBox(categoriesBox);
    final data = box.get('categories');
    return data != null ? List<Map<String, dynamic>>.from(data) : null;
  }

  // =============================================================================
  // CART OPERATIONS
  // =============================================================================

  /// Save cart data
  Future<void> saveCart(String userId, Map<String, dynamic> cartData) async {
    final box = getBox(cartBox);
    await box.put(userId, cartData);
  }

  /// Get cart data
  Map<String, dynamic>? getCart(String userId) {
    final box = getBox(cartBox);
    final data = box.get(userId);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Save anonymous cart
  Future<void> saveAnonymousCart(Map<String, dynamic> cartData) async {
    final box = getBox(cartBox);
    await box.put('anonymous_cart', cartData);
  }

  /// Get anonymous cart
  Map<String, dynamic>? getAnonymousCart() {
    final box = getBox(cartBox);
    final data = box.get('anonymous_cart');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Clear cart data
  Future<void> clearCart(String userId) async {
    final box = getBox(cartBox);
    await box.delete(userId);
  }

  // =============================================================================
  // USER OPERATIONS
  // =============================================================================

  /// Save user data
  Future<void> saveUser(String userId, Map<String, dynamic> userData) async {
    final box = getBox(userBox);
    await box.put(userId, userData);
  }

  /// Get user data
  Map<String, dynamic>? getUser(String userId) {
    final box = getBox(userBox);
    final data = box.get(userId);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Clear user data
  Future<void> clearUser(String userId) async {
    final box = getBox(userBox);
    await box.delete(userId);
  }

  // =============================================================================
  // ORDERS OPERATIONS
  // =============================================================================

  /// Save order
  Future<void> saveOrder(String orderId, Map<String, dynamic> orderData) async {
    final box = getBox(ordersBox);
    await box.put(orderId, orderData);
  }

  /// Get order
  Map<String, dynamic>? getOrder(String orderId) {
    final box = getBox(ordersBox);
    final data = box.get(orderId);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Get all orders for user
  List<Map<String, dynamic>> getUserOrders(String userId) {
    final box = getBox(ordersBox);
    final List<Map<String, dynamic>> orders = [];
    
    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final orderData = Map<String, dynamic>.from(data);
        if (orderData['userId'] == userId) {
          orders.add(orderData);
        }
      }
    }
    
    return orders;
  }

  // =============================================================================
  // SYNC QUEUE OPERATIONS
  // =============================================================================

  /// Add item to sync queue
  Future<void> addToSyncQueue(Map<String, dynamic> syncItem) async {
    final box = getBox(syncQueueBox);
    final key = DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(key, syncItem);
  }

  /// Get all sync queue items
  List<Map<String, dynamic>> getSyncQueueItems() {
    final box = getBox(syncQueueBox);
    final List<Map<String, dynamic>> items = [];
    
    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final item = Map<String, dynamic>.from(data);
        item['_key'] = key; // Add key for deletion
        items.add(item);
      }
    }
    
    return items;
  }

  /// Remove item from sync queue
  Future<void> removeFromSyncQueue(String key) async {
    final box = getBox(syncQueueBox);
    await box.delete(key);
  }

  /// Clear sync queue
  Future<void> clearSyncQueue() async {
    final box = getBox(syncQueueBox);
    await box.clear();
  }

  // =============================================================================
  // SETTINGS OPERATIONS
  // =============================================================================

  /// Save setting
  Future<void> saveSetting(String key, dynamic value) async {
    final box = getBox(settingsBox);
    await box.put(key, value);
  }

  /// Get setting
  T? getSetting<T>(String key, [T? defaultValue]) {
    final box = getBox(settingsBox);
    return box.get(key, defaultValue: defaultValue) as T?;
  }

  /// Remove setting
  Future<void> removeSetting(String key) async {
    final box = getBox(settingsBox);
    await box.delete(key);
  }

  // =============================================================================
  // CACHE OPERATIONS
  // =============================================================================

  /// Save to cache with expiration
  Future<void> saveToCache(
    String key,
    dynamic data, {
    Duration? expiration,
  }) async {
    final box = getBox(cacheBox);
    final cacheItem = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiration': expiration?.inMilliseconds,
    };
    await box.put(key, cacheItem);
  }

  /// Get from cache
  T? getFromCache<T>(String key) {
    final box = getBox(cacheBox);
    final cacheItem = box.get(key);
    
    if (cacheItem == null) return null;
    
    final data = Map<String, dynamic>.from(cacheItem);
    final timestamp = data['timestamp'] as int;
    final expiration = data['expiration'] as int?;
    
    // Check if expired
    if (expiration != null) {
      final expirationTime = timestamp + expiration;
      if (DateTime.now().millisecondsSinceEpoch > expirationTime) {
        // Remove expired item
        box.delete(key);
        return null;
      }
    }
    
    return data['data'] as T?;
  }

  /// Clear expired cache items
  Future<void> clearExpiredCache() async {
    final box = getBox(cacheBox);
    final keysToDelete = <String>[];
    final now = DateTime.now().millisecondsSinceEpoch;
    
    for (final key in box.keys) {
      final cacheItem = box.get(key);
      if (cacheItem != null) {
        final data = Map<String, dynamic>.from(cacheItem);
        final timestamp = data['timestamp'] as int;
        final expiration = data['expiration'] as int?;
        
        if (expiration != null) {
          final expirationTime = timestamp + expiration;
          if (now > expirationTime) {
            keysToDelete.add(key.toString());
          }
        }
      }
    }
    
    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }

  // =============================================================================
  // WISHLIST OPERATIONS
  // =============================================================================

  /// Save wishlist
  Future<void> saveWishlist(String userId, List<String> productIds) async {
    final box = getBox(wishlistBox);
    await box.put(userId, productIds);
  }

  /// Get wishlist
  List<String> getWishlist(String userId) {
    final box = getBox(wishlistBox);
    final data = box.get(userId);
    return data != null ? List<String>.from(data) : [];
  }

  /// Add to wishlist
  Future<void> addToWishlist(String userId, String productId) async {
    final wishlist = getWishlist(userId);
    if (!wishlist.contains(productId)) {
      wishlist.add(productId);
      await saveWishlist(userId, wishlist);
    }
  }

  /// Remove from wishlist
  Future<void> removeFromWishlist(String userId, String productId) async {
    final wishlist = getWishlist(userId);
    wishlist.remove(productId);
    await saveWishlist(userId, wishlist);
  }

  // =============================================================================
  // SEARCH HISTORY OPERATIONS
  // =============================================================================

  /// Save search query
  Future<void> saveSearchQuery(String query) async {
    final box = getBox(searchHistoryBox);
    final history = getSearchHistory();
    
    // Remove if already exists
    history.remove(query);
    
    // Add to beginning
    history.insert(0, query);
    
    // Keep only last 20 searches
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }
    
    await box.put('search_history', history);
  }

  /// Get search history
  List<String> getSearchHistory() {
    final box = getBox(searchHistoryBox);
    final data = box.get('search_history');
    return data != null ? List<String>.from(data) : [];
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    final box = getBox(searchHistoryBox);
    await box.delete('search_history');
  }

  // =============================================================================
  // UTILITY OPERATIONS
  // =============================================================================

  /// Get storage info
  Map<String, dynamic> getStorageInfo() {
    final info = <String, dynamic>{};
    
    final boxNames = [
      productsBox,
      categoriesBox,
      cartBox,
      userBox,
      ordersBox,
      syncQueueBox,
      settingsBox,
      cacheBox,
      wishlistBox,
      searchHistoryBox,
    ];
    
    for (final boxName in boxNames) {
      try {
        final box = getBox(boxName);
        info[boxName] = {
          'length': box.length,
          'keys': box.keys.length,
        };
      } catch (e) {
        info[boxName] = {'error': e.toString()};
      }
    }
    
    return info;
  }

  /// Clear all data
  Future<void> clearAllData() async {
    final boxNames = [
      productsBox,
      categoriesBox,
      cartBox,
      userBox,
      ordersBox,
      syncQueueBox,
      settingsBox,
      cacheBox,
      wishlistBox,
      searchHistoryBox,
    ];
    
    for (final boxName in boxNames) {
      try {
        final box = getBox(boxName);
        await box.clear();
      } catch (e) {
        print('Error clearing box $boxName: $e');
      }
    }
  }

  /// Close all boxes
  Future<void> close() async {
    await _hive.close();
  }
}
