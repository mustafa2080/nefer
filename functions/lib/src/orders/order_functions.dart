import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../core/firebase_service.dart';
import '../core/middleware.dart';

final _logger = Logger('OrderFunctions');

/// Order management functions
class OrderFunctions {
  
  /// Create order
  static Future<Response> createOrder(Request request) async {
    try {
      final user = MiddlewareHelpers.getUser(request);
      if (user == null) {
        return MiddlewareHelpers.errorResponse('Authentication required', statusCode: 401);
      }

      final body = await MiddlewareHelpers.parseJsonBody(request);
      if (body == null) {
        return MiddlewareHelpers.errorResponse('Request body is required');
      }

      MiddlewareHelpers.validateRequiredFields(body, ['items', 'shippingAddress', 'total']);

      final orderRef = FirebaseService.getDatabaseRef('orders').push();
      final orderData = {
        'id': orderRef.key,
        'userId': user['uid'],
        'status': 'pending',
        ...body,
      };

      await orderRef.setWithTimestamp(orderData);

      _logger.info('Order created: ${orderRef.key}');

      return MiddlewareHelpers.successResponse({
        'message': 'Order created successfully',
        'orderId': orderRef.key,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error creating order: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to create order');
    }
  }

  /// Update order status
  static Future<Response> updateOrderStatus(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final orderId = request.params['orderId'];
      if (orderId == null) {
        return MiddlewareHelpers.errorResponse('Order ID is required');
      }

      final body = await MiddlewareHelpers.parseJsonBody(request);
      if (body == null) {
        return MiddlewareHelpers.errorResponse('Request body is required');
      }

      final status = body['status'] as String?;
      if (status == null) {
        return MiddlewareHelpers.errorResponse('Status is required');
      }

      await FirebaseService.getDatabaseRef('orders/$orderId').updateWithTimestamp({
        'status': status,
        'updatedBy': MiddlewareHelpers.getUserId(request),
      });

      return MiddlewareHelpers.successResponse({
        'message': 'Order status updated successfully',
      });
    } catch (error, stackTrace) {
      _logger.severe('Error updating order status: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to update order status');
    }
  }

  /// Cancel order
  static Future<Response> cancelOrder(Request request) async {
    try {
      final user = MiddlewareHelpers.getUser(request);
      if (user == null) {
        return MiddlewareHelpers.errorResponse('Authentication required', statusCode: 401);
      }

      final orderId = request.params['orderId'];
      if (orderId == null) {
        return MiddlewareHelpers.errorResponse('Order ID is required');
      }

      final orderSnapshot = await FirebaseService.getDatabaseRef('orders/$orderId').once();
      final orderData = orderSnapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (orderData == null) {
        return MiddlewareHelpers.errorResponse('Order not found', statusCode: 404);
      }

      // Check if user owns the order or is admin
      if (orderData['userId'] != user['uid'] && !MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Access denied', statusCode: 403);
      }

      await FirebaseService.getDatabaseRef('orders/$orderId').updateWithTimestamp({
        'status': 'cancelled',
        'cancelledAt': FirebaseService.serverTimestamp,
        'cancelledBy': user['uid'],
      });

      return MiddlewareHelpers.successResponse({
        'message': 'Order cancelled successfully',
      });
    } catch (error, stackTrace) {
      _logger.severe('Error cancelling order: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to cancel order');
    }
  }

  /// Get order details
  static Future<Response> getOrderDetails(Request request) async {
    try {
      final user = MiddlewareHelpers.getUser(request);
      if (user == null) {
        return MiddlewareHelpers.errorResponse('Authentication required', statusCode: 401);
      }

      final orderId = request.params['orderId'];
      if (orderId == null) {
        return MiddlewareHelpers.errorResponse('Order ID is required');
      }

      final orderSnapshot = await FirebaseService.getDatabaseRef('orders/$orderId').once();
      final orderData = orderSnapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (orderData == null) {
        return MiddlewareHelpers.errorResponse('Order not found', statusCode: 404);
      }

      // Check if user owns the order or is admin
      if (orderData['userId'] != user['uid'] && !MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Access denied', statusCode: 403);
      }

      return MiddlewareHelpers.successResponse({
        'order': {
          'id': orderId,
          ...Map<String, dynamic>.from(orderData),
        },
      });
    } catch (error, stackTrace) {
      _logger.severe('Error getting order details: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to get order details');
    }
  }

  /// Get user orders
  static Future<Response> getUserOrders(Request request) async {
    try {
      final user = MiddlewareHelpers.getUser(request);
      if (user == null) {
        return MiddlewareHelpers.errorResponse('Authentication required', statusCode: 401);
      }

      final userId = request.params['userId'];
      if (userId == null) {
        return MiddlewareHelpers.errorResponse('User ID is required');
      }

      // Check if user is requesting their own orders or is admin
      if (userId != user['uid'] && !MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Access denied', statusCode: 403);
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '20') ?? 20;

      final ordersSnapshot = await FirebaseService.getDatabaseRef('orders').once();
      final ordersData = ordersSnapshot.snapshot.value as Map<dynamic, dynamic>? ?? {};

      final orders = <Map<String, dynamic>>[];

      for (final entry in ordersData.entries) {
        final orderData = entry.value as Map<dynamic, dynamic>;
        if (orderData['userId'] == userId) {
          orders.add({
            'id': entry.key,
            ...Map<String, dynamic>.from(orderData),
          });
        }

        if (orders.length >= limit) break;
      }

      // Sort by creation date (newest first)
      orders.sort((a, b) {
        final aTime = a['createdAt'] as int? ?? 0;
        final bTime = b['createdAt'] as int? ?? 0;
        return bTime.compareTo(aTime);
      });

      return MiddlewareHelpers.successResponse({
        'orders': orders,
        'total': orders.length,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error getting user orders: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to get user orders');
    }
  }
}
