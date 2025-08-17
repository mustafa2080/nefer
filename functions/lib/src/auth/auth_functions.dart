import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../core/firebase_service.dart';
import '../core/middleware.dart';

final _logger = Logger('AuthFunctions');

/// Authentication functions
class AuthFunctions {
  
  /// Validate authentication token
  static Future<Response> validateAuthToken(Request request) async {
    try {
      final body = await MiddlewareHelpers.parseJsonBody(request);
      if (body == null) {
        return MiddlewareHelpers.errorResponse('Request body is required');
      }

      final token = body['token'] as String?;
      if (token == null) {
        return MiddlewareHelpers.errorResponse('Token is required');
      }

      // Verify the token
      final decodedToken = await FirebaseService.verifyIdToken(token);
      
      // Get user data from database
      final userSnapshot = await FirebaseService.getDatabaseRef('users/${decodedToken.uid}').once();
      final userData = userSnapshot.snapshot.value as Map<dynamic, dynamic>?;

      return MiddlewareHelpers.successResponse({
        'valid': true,
        'user': {
          'uid': decodedToken.uid,
          'email': decodedToken.email,
          'emailVerified': decodedToken.emailVerified,
          'claims': decodedToken.claims,
          'profile': userData,
        },
      });
    } catch (error, stackTrace) {
      _logger.warning('Token validation failed: $error');
      return MiddlewareHelpers.errorResponse('Invalid authentication token', statusCode: 401);
    }
  }

  /// Refresh user token with updated claims
  static Future<Response> refreshUserToken(Request request) async {
    try {
      final user = MiddlewareHelpers.getUser(request);
      if (user == null) {
        return MiddlewareHelpers.errorResponse('Authentication required', statusCode: 401);
      }

      final uid = user['uid'] as String;
      
      // Get latest user data
      final userSnapshot = await FirebaseService.getDatabaseRef('users/$uid').once();
      final userData = userSnapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (userData == null) {
        return MiddlewareHelpers.errorResponse('User data not found', statusCode: 404);
      }

      // Update custom claims
      final role = userData['role'] as Map<dynamic, dynamic>? ?? {};
      final customClaims = {
        'role': role['id'] ?? 'customer',
        'isAdmin': role['isAdmin'] == true,
        'permissions': role['permissions'] ?? [],
        'emailVerified': userData['status']?['isVerified'] == true,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };

      await FirebaseService.setCustomUserClaims(uid, customClaims);

      // Update last login
      await FirebaseService.getDatabaseRef('users/$uid/metadata').updateWithTimestamp({
        'lastLoginAt': FirebaseService.serverTimestamp,
        'loginCount': FirebaseService.increment(1),
      });

      return MiddlewareHelpers.successResponse({
        'message': 'Token refreshed successfully',
        'claims': customClaims,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error refreshing token: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to refresh token');
    }
  }

  /// Verify email
  static Future<Response> verifyEmail(Request request) async {
    try {
      final user = MiddlewareHelpers.getUser(request);
      if (user == null) {
        return MiddlewareHelpers.errorResponse('Authentication required', statusCode: 401);
      }

      final uid = user['uid'] as String;
      
      // Update user verification status
      await FirebaseService.getDatabaseRef('users/$uid/status').updateWithTimestamp({
        'isVerified': true,
        'verifiedAt': FirebaseService.serverTimestamp,
      });

      // Update custom claims
      final userSnapshot = await FirebaseService.getDatabaseRef('users/$uid').once();
      final userData = userSnapshot.snapshot.value as Map<dynamic, dynamic>?;
      final role = userData?['role'] as Map<dynamic, dynamic>? ?? {};
      
      final customClaims = {
        'role': role['id'] ?? 'customer',
        'isAdmin': role['isAdmin'] == true,
        'permissions': role['permissions'] ?? [],
        'emailVerified': true,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };

      await FirebaseService.setCustomUserClaims(uid, customClaims);

      _logger.info('Email verified for user: $uid');

      return MiddlewareHelpers.successResponse({
        'message': 'Email verified successfully',
      });
    } catch (error, stackTrace) {
      _logger.severe('Error verifying email: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to verify email');
    }
  }
}
