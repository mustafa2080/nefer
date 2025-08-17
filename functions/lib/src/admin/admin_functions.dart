import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../core/firebase_service.dart';
import '../core/middleware.dart';

final _logger = Logger('AdminFunctions');

/// Admin functions for user and system management
class AdminFunctions {
  
  /// Set user role and permissions
  static Future<Response> setUserRole(Request request) async {
    try {
      // Check admin permissions
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final body = await MiddlewareHelpers.parseJsonBody(request);
      if (body == null) {
        return MiddlewareHelpers.errorResponse('Request body is required');
      }

      MiddlewareHelpers.validateRequiredFields(body, ['userId', 'role']);

      final userId = body['userId'] as String;
      final role = body['role'] as String;
      final permissions = body['permissions'] as List<dynamic>? ?? [];

      // Validate role
      const validRoles = ['customer', 'moderator', 'admin', 'super_admin'];
      if (!validRoles.contains(role)) {
        return MiddlewareHelpers.errorResponse('Invalid role. Must be one of: ${validRoles.join(', ')}');
      }

      // Set custom claims
      final customClaims = {
        'role': role,
        'isAdmin': role == 'admin' || role == 'super_admin',
        'permissions': permissions,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await FirebaseService.setCustomUserClaims(userId, customClaims);

      // Update user data in database
      final userRef = FirebaseService.getDatabaseRef('users/$userId');
      await userRef.updateWithTimestamp({
        'role': {
          'id': role,
          'name': role,
          'displayName': _getRoleDisplayName(role),
          'permissions': permissions,
          'isAdmin': role == 'admin' || role == 'super_admin',
        },
      });

      // Log admin action
      await _logAdminAction(
        MiddlewareHelpers.getUserId(request)!,
        'set_user_role',
        {'userId': userId, 'role': role, 'permissions': permissions},
      );

      _logger.info('User role updated: $userId -> $role');

      return MiddlewareHelpers.successResponse({
        'message': 'User role updated successfully',
        'userId': userId,
        'role': role,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error setting user role: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to set user role');
    }
  }

  /// Create admin user
  static Future<Response> createAdminUser(Request request) async {
    try {
      // Check super admin permissions
      final user = MiddlewareHelpers.getUser(request);
      final claims = user?['claims'] as Map<String, dynamic>? ?? {};
      if (claims['role'] != 'super_admin') {
        return MiddlewareHelpers.errorResponse('Super admin access required', statusCode: 403);
      }

      final body = await MiddlewareHelpers.parseJsonBody(request);
      if (body == null) {
        return MiddlewareHelpers.errorResponse('Request body is required');
      }

      MiddlewareHelpers.validateRequiredFields(body, ['email', 'password', 'displayName']);

      final email = MiddlewareHelpers.sanitizeString(body['email'] as String);
      final password = body['password'] as String;
      final displayName = MiddlewareHelpers.sanitizeString(body['displayName'] as String);
      final role = body['role'] as String? ?? 'admin';

      // Validate email
      if (!MiddlewareHelpers.isValidEmail(email)) {
        return MiddlewareHelpers.errorResponse('Invalid email format');
      }

      // Validate password
      if (password.length < 8) {
        return MiddlewareHelpers.errorResponse('Password must be at least 8 characters');
      }

      // Create user
      final userRecord = await FirebaseService.auth.createUser(CreateRequest(
        email: email,
        password: password,
        displayName: displayName,
        emailVerified: true,
      ));

      // Set admin role
      final customClaims = {
        'role': role,
        'isAdmin': true,
        'permissions': _getDefaultPermissions(role),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      await FirebaseService.setCustomUserClaims(userRecord.uid, customClaims);

      // Create user profile in database
      final userRef = FirebaseService.getDatabaseRef('users/${userRecord.uid}');
      await userRef.setWithTimestamp({
        'uid': userRecord.uid,
        'email': email,
        'displayName': displayName,
        'role': {
          'id': role,
          'name': role,
          'displayName': _getRoleDisplayName(role),
          'permissions': _getDefaultPermissions(role),
          'isAdmin': true,
        },
        'status': {
          'isActive': true,
          'isVerified': true,
          'isSuspended': false,
        },
        'metadata': {
          'createdBy': MiddlewareHelpers.getUserId(request),
          'loginCount': 0,
          'signInProvider': 'email',
        },
      });

      // Log admin action
      await _logAdminAction(
        MiddlewareHelpers.getUserId(request)!,
        'create_admin_user',
        {'userId': userRecord.uid, 'email': email, 'role': role},
      );

      _logger.info('Admin user created: ${userRecord.uid} ($email)');

      return MiddlewareHelpers.successResponse({
        'message': 'Admin user created successfully',
        'userId': userRecord.uid,
        'email': email,
        'role': role,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error creating admin user: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to create admin user');
    }
  }

  /// Suspend user account
  static Future<Response> suspendUser(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final userId = request.params['userId'];
      if (userId == null) {
        return MiddlewareHelpers.errorResponse('User ID is required');
      }

      final body = await MiddlewareHelpers.parseJsonBody(request);
      final reason = body?['reason'] as String? ?? 'No reason provided';

      // Disable user account
      await FirebaseService.auth.updateUser(userId, UpdateRequest(disabled: true));

      // Update user status in database
      final userRef = FirebaseService.getDatabaseRef('users/$userId');
      await userRef.updateWithTimestamp({
        'status/isSuspended': true,
        'status/isActive': false,
        'status/suspendedAt': FirebaseService.serverTimestamp,
        'status/suspendedBy': MiddlewareHelpers.getUserId(request),
        'status/suspensionReason': reason,
      });

      // Log admin action
      await _logAdminAction(
        MiddlewareHelpers.getUserId(request)!,
        'suspend_user',
        {'userId': userId, 'reason': reason},
      );

      _logger.info('User suspended: $userId');

      return MiddlewareHelpers.successResponse({
        'message': 'User suspended successfully',
        'userId': userId,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error suspending user: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to suspend user');
    }
  }

  /// Activate user account
  static Future<Response> activateUser(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final userId = request.params['userId'];
      if (userId == null) {
        return MiddlewareHelpers.errorResponse('User ID is required');
      }

      // Enable user account
      await FirebaseService.auth.updateUser(userId, UpdateRequest(disabled: false));

      // Update user status in database
      final userRef = FirebaseService.getDatabaseRef('users/$userId');
      await userRef.updateWithTimestamp({
        'status/isSuspended': false,
        'status/isActive': true,
        'status/activatedAt': FirebaseService.serverTimestamp,
        'status/activatedBy': MiddlewareHelpers.getUserId(request),
        'status/suspensionReason': null,
      });

      // Log admin action
      await _logAdminAction(
        MiddlewareHelpers.getUserId(request)!,
        'activate_user',
        {'userId': userId},
      );

      _logger.info('User activated: $userId');

      return MiddlewareHelpers.successResponse({
        'message': 'User activated successfully',
        'userId': userId,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error activating user: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to activate user');
    }
  }

  /// Delete user account
  static Future<Response> deleteUser(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final userId = request.params['userId'];
      if (userId == null) {
        return MiddlewareHelpers.errorResponse('User ID is required');
      }

      // Mark user as deleted in database (keep for audit trail)
      final userRef = FirebaseService.getDatabaseRef('users/$userId');
      await userRef.updateWithTimestamp({
        'status/isActive': false,
        'status/isDeleted': true,
        'status/deletedAt': FirebaseService.serverTimestamp,
        'status/deletedBy': MiddlewareHelpers.getUserId(request),
      });

      // Delete from Firebase Auth
      await FirebaseService.deleteUser(userId);

      // Log admin action
      await _logAdminAction(
        MiddlewareHelpers.getUserId(request)!,
        'delete_user',
        {'userId': userId},
      );

      _logger.info('User deleted: $userId');

      return MiddlewareHelpers.successResponse({
        'message': 'User deleted successfully',
        'userId': userId,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error deleting user: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to delete user');
    }
  }

  /// Get all users (admin only)
  static Future<Response> getAllUsers(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '50') ?? 50;
      final pageToken = request.url.queryParameters['pageToken'];

      final result = await FirebaseService.listUsers(maxResults: limit, pageToken: pageToken);
      
      final users = result.users.map((user) => {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'emailVerified': user.emailVerified,
        'disabled': user.disabled,
        'creationTime': user.metadata.creationTime?.toIso8601String(),
        'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
        'customClaims': user.customClaims,
      }).toList();

      return MiddlewareHelpers.successResponse({
        'users': users,
        'pageToken': result.pageToken,
        'total': users.length,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error getting all users: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to get users');
    }
  }

  /// Reset user password
  static Future<Response> resetUserPassword(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final userId = request.params['userId'];
      if (userId == null) {
        return MiddlewareHelpers.errorResponse('User ID is required');
      }

      final body = await MiddlewareHelpers.parseJsonBody(request);
      final newPassword = body?['newPassword'] as String?;

      if (newPassword == null || newPassword.length < 8) {
        return MiddlewareHelpers.errorResponse('New password must be at least 8 characters');
      }

      // Update password
      await FirebaseService.auth.updateUser(userId, UpdateRequest(password: newPassword));

      // Log admin action
      await _logAdminAction(
        MiddlewareHelpers.getUserId(request)!,
        'reset_user_password',
        {'userId': userId},
      );

      _logger.info('Password reset for user: $userId');

      return MiddlewareHelpers.successResponse({
        'message': 'Password reset successfully',
        'userId': userId,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error resetting password: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to reset password');
    }
  }

  /// Get admin dashboard statistics
  static Future<Response> getAdminStats(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      // Get user statistics
      final usersSnapshot = await FirebaseService.getDatabaseRef('users').once();
      final usersData = usersSnapshot.snapshot.value as Map<dynamic, dynamic>? ?? {};
      
      int totalUsers = 0;
      int activeUsers = 0;
      int verifiedUsers = 0;
      int suspendedUsers = 0;

      for (final userData in usersData.values) {
        if (userData is Map) {
          totalUsers++;
          final status = userData['status'] as Map<dynamic, dynamic>? ?? {};
          if (status['isActive'] == true) activeUsers++;
          if (status['isVerified'] == true) verifiedUsers++;
          if (status['isSuspended'] == true) suspendedUsers++;
        }
      }

      // Get product statistics
      final productsSnapshot = await FirebaseService.getDatabaseRef('products').once();
      final productsData = productsSnapshot.snapshot.value as Map<dynamic, dynamic>? ?? {};
      
      int totalProducts = 0;
      int activeProducts = 0;
      
      for (final productData in productsData.values) {
        if (productData is Map) {
          totalProducts++;
          if (productData['status'] == 'active') activeProducts++;
        }
      }

      // Get order statistics
      final ordersSnapshot = await FirebaseService.getDatabaseRef('orders').once();
      final ordersData = ordersSnapshot.snapshot.value as Map<dynamic, dynamic>? ?? {};
      
      int totalOrders = 0;
      int pendingOrders = 0;
      double totalRevenue = 0.0;
      
      for (final orderData in ordersData.values) {
        if (orderData is Map) {
          totalOrders++;
          if (orderData['status'] == 'pending') pendingOrders++;
          if (orderData['status'] == 'completed') {
            totalRevenue += (orderData['total'] as num?)?.toDouble() ?? 0.0;
          }
        }
      }

      final stats = {
        'users': {
          'total': totalUsers,
          'active': activeUsers,
          'verified': verifiedUsers,
          'suspended': suspendedUsers,
        },
        'products': {
          'total': totalProducts,
          'active': activeProducts,
          'inactive': totalProducts - activeProducts,
        },
        'orders': {
          'total': totalOrders,
          'pending': pendingOrders,
          'completed': totalOrders - pendingOrders,
        },
        'revenue': {
          'total': totalRevenue,
          'average': totalOrders > 0 ? totalRevenue / totalOrders : 0.0,
        },
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      return MiddlewareHelpers.successResponse(stats);
    } catch (error, stackTrace) {
      _logger.severe('Error getting admin stats: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to get admin statistics');
    }
  }

  // Helper methods
  static String _getRoleDisplayName(String role) {
    switch (role) {
      case 'customer':
        return 'Customer';
      case 'moderator':
        return 'Moderator';
      case 'admin':
        return 'Administrator';
      case 'super_admin':
        return 'Super Administrator';
      default:
        return role;
    }
  }

  static List<String> _getDefaultPermissions(String role) {
    switch (role) {
      case 'customer':
        return ['view_products', 'add_to_cart', 'place_order', 'write_review', 'manage_profile'];
      case 'moderator':
        return ['view_products', 'add_to_cart', 'place_order', 'write_review', 'manage_profile', 'manage_reviews'];
      case 'admin':
        return [
          'view_products', 'add_to_cart', 'place_order', 'write_review', 'manage_profile',
          'manage_products', 'manage_orders', 'manage_users', 'view_analytics', 'manage_categories'
        ];
      case 'super_admin':
        return [
          'view_products', 'add_to_cart', 'place_order', 'write_review', 'manage_profile',
          'manage_products', 'manage_orders', 'manage_users', 'view_analytics', 'manage_categories',
          'system_settings', 'manage_admins', 'backup_data', 'view_logs'
        ];
      default:
        return [];
    }
  }

  static Future<void> _logAdminAction(String adminId, String action, Map<String, dynamic> details) async {
    try {
      final logRef = FirebaseService.getDatabaseRef('admin_logs').push();
      await logRef.setWithTimestamp({
        'id': logRef.key,
        'adminId': adminId,
        'action': action,
        'details': details,
      });
    } catch (error) {
      _logger.warning('Failed to log admin action: $error');
    }
  }
}
