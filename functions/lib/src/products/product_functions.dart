import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../core/firebase_service.dart';
import '../core/middleware.dart';

final _logger = Logger('ProductFunctions');

/// Product management functions
class ProductFunctions {
  
  /// Create a new product
  static Future<Response> createProduct(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final body = await MiddlewareHelpers.parseJsonBody(request);
      if (body == null) {
        return MiddlewareHelpers.errorResponse('Request body is required');
      }

      MiddlewareHelpers.validateRequiredFields(body, ['name', 'description', 'price', 'categoryId']);

      final productRef = FirebaseService.getDatabaseRef('products').push();
      final productData = {
        'id': productRef.key,
        ...body,
        'status': 'active',
        'analytics': {
          'views': 0,
          'purchases': 0,
          'cartAdditions': 0,
          'wishlistAdditions': 0,
          'rating': 0.0,
          'reviewCount': 0,
        },
        'createdBy': MiddlewareHelpers.getUserId(request),
      };

      await productRef.setWithTimestamp(productData);

      _logger.info('Product created: ${productRef.key}');

      return MiddlewareHelpers.successResponse({
        'message': 'Product created successfully',
        'productId': productRef.key,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error creating product: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to create product');
    }
  }

  /// Update an existing product
  static Future<Response> updateProduct(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final productId = request.params['productId'];
      if (productId == null) {
        return MiddlewareHelpers.errorResponse('Product ID is required');
      }

      final body = await MiddlewareHelpers.parseJsonBody(request);
      if (body == null) {
        return MiddlewareHelpers.errorResponse('Request body is required');
      }

      final productRef = FirebaseService.getDatabaseRef('products/$productId');
      final snapshot = await productRef.once();

      if (snapshot.snapshot.value == null) {
        return MiddlewareHelpers.errorResponse('Product not found', statusCode: 404);
      }

      final updates = {
        ...body,
        'updatedBy': MiddlewareHelpers.getUserId(request),
      };

      await productRef.updateWithTimestamp(updates);

      return MiddlewareHelpers.successResponse({
        'message': 'Product updated successfully',
      });
    } catch (error, stackTrace) {
      _logger.severe('Error updating product: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to update product');
    }
  }

  /// Delete a product
  static Future<Response> deleteProduct(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final productId = request.params['productId'];
      if (productId == null) {
        return MiddlewareHelpers.errorResponse('Product ID is required');
      }

      // Soft delete - mark as deleted
      await FirebaseService.getDatabaseRef('products/$productId').updateWithTimestamp({
        'status': 'deleted',
        'deletedAt': FirebaseService.serverTimestamp,
        'deletedBy': MiddlewareHelpers.getUserId(request),
      });

      return MiddlewareHelpers.successResponse({
        'message': 'Product deleted successfully',
      });
    } catch (error, stackTrace) {
      _logger.severe('Error deleting product: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to delete product');
    }
  }

  /// Get products with filtering
  static Future<Response> getProducts(Request request) async {
    try {
      final category = request.url.queryParameters['category'];
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final status = request.url.queryParameters['status'] ?? 'active';

      final productsSnapshot = await FirebaseService.getDatabaseRef('products').once();
      final productsData = productsSnapshot.snapshot.value as Map<dynamic, dynamic>? ?? {};

      final products = <Map<String, dynamic>>[];

      for (final entry in productsData.entries) {
        final productData = entry.value as Map<dynamic, dynamic>;
        
        // Apply filters
        if (productData['status'] != status) continue;
        if (category != null && productData['categoryId'] != category) continue;

        products.add({
          'id': entry.key,
          ...Map<String, dynamic>.from(productData),
        });

        if (products.length >= limit) break;
      }

      return MiddlewareHelpers.successResponse({
        'products': products,
        'total': products.length,
        'hasMore': products.length == limit,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error getting products: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to get products');
    }
  }

  /// Search products
  static Future<Response> searchProducts(Request request) async {
    try {
      final query = request.url.queryParameters['q'];
      if (query == null || query.length < 2) {
        return MiddlewareHelpers.errorResponse('Search query must be at least 2 characters');
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;
      final category = request.url.queryParameters['category'];

      final productsSnapshot = await FirebaseService.getDatabaseRef('products').once();
      final productsData = productsSnapshot.snapshot.value as Map<dynamic, dynamic>? ?? {};

      final products = <Map<String, dynamic>>[];
      final searchTerm = query.toLowerCase();

      for (final entry in productsData.entries) {
        final productData = entry.value as Map<dynamic, dynamic>;
        
        // Skip inactive products
        if (productData['status'] != 'active') continue;
        
        // Apply category filter
        if (category != null && productData['categoryId'] != category) continue;

        // Simple text search
        final name = (productData['name'] as String? ?? '').toLowerCase();
        final description = (productData['description'] as String? ?? '').toLowerCase();
        final tags = (productData['tags'] as List<dynamic>? ?? []).join(' ').toLowerCase();

        if (name.contains(searchTerm) || description.contains(searchTerm) || tags.contains(searchTerm)) {
          products.add({
            'id': entry.key,
            ...Map<String, dynamic>.from(productData),
          });
        }

        if (products.length >= limit) break;
      }

      return MiddlewareHelpers.successResponse({
        'products': products,
        'total': products.length,
        'query': searchTerm,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error searching products: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to search products');
    }
  }

  /// Get product by ID
  static Future<Response> getProductById(Request request) async {
    try {
      final productId = request.params['productId'];
      if (productId == null) {
        return MiddlewareHelpers.errorResponse('Product ID is required');
      }

      final productSnapshot = await FirebaseService.getDatabaseRef('products/$productId').once();
      final productData = productSnapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (productData == null) {
        return MiddlewareHelpers.errorResponse('Product not found', statusCode: 404);
      }

      // Increment view count
      await FirebaseService.getDatabaseRef('products/$productId/analytics/views').set(
        FirebaseService.increment(1)
      );

      return MiddlewareHelpers.successResponse({
        'product': {
          'id': productId,
          ...Map<String, dynamic>.from(productData),
        },
      });
    } catch (error, stackTrace) {
      _logger.severe('Error getting product: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to get product');
    }
  }

  /// Get product recommendations
  static Future<Response> getProductRecommendations(Request request) async {
    try {
      final productId = request.params['productId'];
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;

      if (productId == null) {
        return MiddlewareHelpers.errorResponse('Product ID is required');
      }

      // Get current product
      final productSnapshot = await FirebaseService.getDatabaseRef('products/$productId').once();
      final productData = productSnapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (productData == null) {
        return MiddlewareHelpers.errorResponse('Product not found', statusCode: 404);
      }

      // Get similar products from same category
      final categoryId = productData['categoryId'] as String?;
      final productsSnapshot = await FirebaseService.getDatabaseRef('products').once();
      final productsData = productsSnapshot.snapshot.value as Map<dynamic, dynamic>? ?? {};

      final recommendations = <Map<String, dynamic>>[];

      for (final entry in productsData.entries) {
        if (entry.key == productId) continue; // Skip current product
        
        final data = entry.value as Map<dynamic, dynamic>;
        if (data['status'] != 'active') continue;
        if (data['categoryId'] == categoryId) {
          recommendations.add({
            'id': entry.key,
            ...Map<String, dynamic>.from(data),
          });
        }

        if (recommendations.length >= limit) break;
      }

      return MiddlewareHelpers.successResponse({
        'products': recommendations,
        'total': recommendations.length,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error getting recommendations: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to get recommendations');
    }
  }
}
