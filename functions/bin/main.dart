import 'dart:io';
import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_cors/shelf_cors.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:logging/logging.dart';

import '../lib/src/admin/admin_functions.dart';
import '../lib/src/auth/auth_functions.dart';
import '../lib/src/products/product_functions.dart';
import '../lib/src/orders/order_functions.dart';
import '../lib/src/payments/payment_functions.dart';
import '../lib/src/notifications/notification_functions.dart';
import '../lib/src/analytics/analytics_functions.dart';
import '../lib/src/core/firebase_service.dart';
import '../lib/src/core/middleware.dart';

final _logger = Logger('NeferFunctions');

@CloudFunction()
Future<Response> function(Request request) async {
  return await _handleRequest(request);
}

Future<Response> _handleRequest(Request request) async {
  // Initialize Firebase
  await FirebaseService.initialize();
  
  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Create router
  final router = Router();

  // Add CORS middleware
  final corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  };

  final handler = Pipeline()
      .addMiddleware(corsHeaders(corsHeaders))
      .addMiddleware(authMiddleware)
      .addMiddleware(rateLimitMiddleware)
      .addMiddleware(loggingMiddleware)
      .addHandler(router);

  // Health check endpoint
  router.get('/health', (Request request) {
    return Response.ok('{"status": "healthy", "timestamp": "${DateTime.now().toIso8601String()}"}',
        headers: {'Content-Type': 'application/json'});
  });

  // API info endpoint
  router.get('/info', (Request request) {
    final info = {
      'name': 'Nefer E-commerce API',
      'version': '1.0.0',
      'description': 'Firebase Cloud Functions for Nefer marketplace written in Dart',
      'endpoints': {
        'admin': '/admin/*',
        'auth': '/auth/*',
        'products': '/products/*',
        'orders': '/orders/*',
        'payments': '/payments/*',
        'notifications': '/notifications/*',
        'analytics': '/analytics/*',
      },
      'documentation': 'https://docs.nefer-ecommerce.com/api',
      'support': 'support@nefer-ecommerce.com',
    };
    
    return Response.ok(jsonEncode(info),
        headers: {'Content-Type': 'application/json'});
  });

  // =============================================================================
  // ADMIN ROUTES
  // =============================================================================
  
  // User management
  router.post('/admin/users/role', AdminFunctions.setUserRole);
  router.post('/admin/users/create', AdminFunctions.createAdminUser);
  router.post('/admin/users/<userId>/suspend', AdminFunctions.suspendUser);
  router.post('/admin/users/<userId>/activate', AdminFunctions.activateUser);
  router.delete('/admin/users/<userId>', AdminFunctions.deleteUser);
  router.get('/admin/users', AdminFunctions.getAllUsers);
  router.post('/admin/users/<userId>/reset-password', AdminFunctions.resetUserPassword);
  router.get('/admin/stats', AdminFunctions.getAdminStats);

  // =============================================================================
  // AUTH ROUTES
  // =============================================================================
  
  router.post('/auth/validate-token', AuthFunctions.validateAuthToken);
  router.post('/auth/refresh-token', AuthFunctions.refreshUserToken);
  router.post('/auth/verify-email', AuthFunctions.verifyEmail);

  // =============================================================================
  // PRODUCT ROUTES
  // =============================================================================
  
  router.post('/products', ProductFunctions.createProduct);
  router.put('/products/<productId>', ProductFunctions.updateProduct);
  router.delete('/products/<productId>', ProductFunctions.deleteProduct);
  router.get('/products', ProductFunctions.getProducts);
  router.get('/products/search', ProductFunctions.searchProducts);
  router.get('/products/<productId>', ProductFunctions.getProductById);
  router.get('/products/<productId>/recommendations', ProductFunctions.getProductRecommendations);

  // =============================================================================
  // ORDER ROUTES
  // =============================================================================
  
  router.post('/orders', OrderFunctions.createOrder);
  router.put('/orders/<orderId>/status', OrderFunctions.updateOrderStatus);
  router.post('/orders/<orderId>/cancel', OrderFunctions.cancelOrder);
  router.get('/orders/<orderId>', OrderFunctions.getOrderDetails);
  router.get('/users/<userId>/orders', OrderFunctions.getUserOrders);

  // =============================================================================
  // PAYMENT ROUTES
  // =============================================================================
  
  router.post('/payments/intent', PaymentFunctions.createPaymentIntent);
  router.post('/payments/confirm', PaymentFunctions.confirmPayment);
  router.post('/payments/refund', PaymentFunctions.refundPayment);
  router.post('/payments/webhook', PaymentFunctions.handleStripeWebhook);

  // =============================================================================
  // NOTIFICATION ROUTES
  // =============================================================================
  
  router.post('/notifications/send', NotificationFunctions.sendNotification);
  router.post('/notifications/bulk', NotificationFunctions.sendBulkNotification);
  router.post('/notifications/schedule', NotificationFunctions.scheduleNotification);
  router.get('/users/<userId>/notifications', NotificationFunctions.getUserNotifications);
  router.put('/notifications/<notificationId>/read', NotificationFunctions.markAsRead);

  // =============================================================================
  // ANALYTICS ROUTES
  // =============================================================================
  
  router.post('/analytics/track', AnalyticsFunctions.trackUserEvent);
  router.get('/analytics/sales', AnalyticsFunctions.generateSalesReport);
  router.get('/analytics/users', AnalyticsFunctions.generateUserReport);
  router.get('/analytics/products', AnalyticsFunctions.generateProductReport);

  // Handle 404
  router.all('/<ignored|.*>', (Request request) {
    return Response.notFound('{"error": "Endpoint not found"}',
        headers: {'Content-Type': 'application/json'});
  });

  try {
    return await handler(request);
  } catch (error, stackTrace) {
    _logger.severe('Unhandled error: $error', error, stackTrace);
    return Response.internalServerError(
      body: '{"error": "Internal server error"}',
      headers: {'Content-Type': 'application/json'},
    );
  }
}

// Helper function to encode JSON
String jsonEncode(Map<String, dynamic> data) {
  return data.toString().replaceAll('{', '{"').replaceAll(': ', '": "').replaceAll(', ', '", "').replaceAll('}', '"}');
}
