import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../core/firebase_service.dart';
import '../core/middleware.dart';

final _logger = Logger('AnalyticsFunctions');

/// Analytics functions
class AnalyticsFunctions {
  
  /// Track user event
  static Future<Response> trackUserEvent(Request request) async {
    try {
      final body = await MiddlewareHelpers.parseJsonBody(request);
      if (body == null) {
        return MiddlewareHelpers.errorResponse('Request body is required');
      }

      MiddlewareHelpers.validateRequiredFields(body, ['eventName']);

      final eventName = body['eventName'] as String;
      final eventData = body['eventData'] as Map<String, dynamic>? ?? {};
      final user = MiddlewareHelpers.getUser(request);
      final userId = user?['uid'] ?? 'anonymous';

      final eventRef = FirebaseService.getDatabaseRef('analytics/events').push();
      await eventRef.setWithTimestamp({
        'id': eventRef.key,
        'userId': userId,
        'eventName': eventName,
        'eventData': eventData,
      });

      return MiddlewareHelpers.successResponse({
        'message': 'Event tracked successfully',
      });
    } catch (error, stackTrace) {
      _logger.severe('Error tracking event: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to track event');
    }
  }

  /// Generate sales report
  static Future<Response> generateSalesReport(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final startDate = int.tryParse(request.url.queryParameters['startDate'] ?? '0') ?? 0;
      final endDate = int.tryParse(request.url.queryParameters['endDate'] ?? '${DateTime.now().millisecondsSinceEpoch}') ?? DateTime.now().millisecondsSinceEpoch;

      final ordersSnapshot = await FirebaseService.getDatabaseRef('orders').once();
      final ordersData = ordersSnapshot.snapshot.value as Map<dynamic, dynamic>? ?? {};

      double totalSales = 0.0;
      int totalOrders = 0;
      final Map<String, double> salesByDay = {};

      for (final orderData in ordersData.values) {
        if (orderData is Map) {
          final createdAt = orderData['createdAt'] as int? ?? 0;
          final status = orderData['status'] as String?;
          final total = (orderData['total'] as num?)?.toDouble() ?? 0.0;

          if (createdAt >= startDate && createdAt <= endDate && status == 'completed') {
            totalSales += total;
            totalOrders++;

            final date = DateTime.fromMillisecondsSinceEpoch(createdAt).toIso8601String().split('T')[0];
            salesByDay[date] = (salesByDay[date] ?? 0.0) + total;
          }
        }
      }

      final report = {
        'totalSales': totalSales,
        'totalOrders': totalOrders,
        'averageOrderValue': totalOrders > 0 ? totalSales / totalOrders : 0.0,
        'salesByDay': salesByDay,
        'period': {
          'startDate': startDate,
          'endDate': endDate,
        },
      };

      return MiddlewareHelpers.successResponse(report);
    } catch (error, stackTrace) {
      _logger.severe('Error generating sales report: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to generate sales report');
    }
  }

  /// Generate user report
  static Future<Response> generateUserReport(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final usersSnapshot = await FirebaseService.getDatabaseRef('users').once();
      final usersData = usersSnapshot.snapshot.value as Map<dynamic, dynamic>? ?? {};

      int totalUsers = 0;
      int activeUsers = 0;
      int verifiedUsers = 0;
      int suspendedUsers = 0;
      final Map<String, int> usersByRole = {};

      for (final userData in usersData.values) {
        if (userData is Map) {
          totalUsers++;
          
          final status = userData['status'] as Map<dynamic, dynamic>? ?? {};
          if (status['isActive'] == true) activeUsers++;
          if (status['isVerified'] == true) verifiedUsers++;
          if (status['isSuspended'] == true) suspendedUsers++;

          final role = userData['role'] as Map<dynamic, dynamic>? ?? {};
          final roleId = role['id'] as String? ?? 'customer';
          usersByRole[roleId] = (usersByRole[roleId] ?? 0) + 1;
        }
      }

      final report = {
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'verifiedUsers': verifiedUsers,
        'suspendedUsers': suspendedUsers,
        'inactiveUsers': totalUsers - activeUsers,
        'usersByRole': usersByRole,
      };

      return MiddlewareHelpers.successResponse(report);
    } catch (error, stackTrace) {
      _logger.severe('Error generating user report: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to generate user report');
    }
  }

  /// Generate product report
  static Future<Response> generateProductReport(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final productsSnapshot = await FirebaseService.getDatabaseRef('products').once();
      final productsData = productsSnapshot.snapshot.value as Map<dynamic, dynamic>? ?? {};

      int totalProducts = 0;
      int activeProducts = 0;
      final List<Map<String, dynamic>> topProducts = [];
      final Map<String, int> productsByCategory = {};

      for (final entry in productsData.entries) {
        final productData = entry.value as Map<dynamic, dynamic>;
        totalProducts++;

        final status = productData['status'] as String?;
        if (status == 'active') activeProducts++;

        final categoryId = productData['categoryId'] as String? ?? 'uncategorized';
        productsByCategory[categoryId] = (productsByCategory[categoryId] ?? 0) + 1;

        final analytics = productData['analytics'] as Map<dynamic, dynamic>? ?? {};
        final purchases = (analytics['purchases'] as num?)?.toInt() ?? 0;
        final price = (productData['price'] as num?)?.toDouble() ?? 0.0;

        if (purchases > 0) {
          topProducts.add({
            'id': entry.key,
            'name': productData['name'] ?? 'Unknown',
            'purchases': purchases,
            'revenue': purchases * price,
          });
        }
      }

      // Sort top products by purchases
      topProducts.sort((a, b) => (b['purchases'] as int).compareTo(a['purchases'] as int));

      final report = {
        'totalProducts': totalProducts,
        'activeProducts': activeProducts,
        'inactiveProducts': totalProducts - activeProducts,
        'topProducts': topProducts.take(10).toList(),
        'productsByCategory': productsByCategory,
      };

      return MiddlewareHelpers.successResponse(report);
    } catch (error, stackTrace) {
      _logger.severe('Error generating product report: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to generate product report');
    }
  }
}
