import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import 'firebase_service.dart';

final _logger = Logger('Middleware');

/// Authentication middleware
Middleware get authMiddleware {
  return (Handler innerHandler) {
    return (Request request) async {
      // Skip auth for public endpoints
      final publicEndpoints = ['/health', '/info', '/auth/validate-token'];
      if (publicEndpoints.any((endpoint) => request.url.path.startsWith(endpoint))) {
        return await innerHandler(request);
      }

      // Get authorization header
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.unauthorized(
          '{"error": "Missing or invalid authorization header"}',
          headers: {'Content-Type': 'application/json'},
        );
      }

      try {
        // Extract and verify token
        final token = authHeader.substring(7); // Remove 'Bearer '
        final decodedToken = await FirebaseService.verifyIdToken(token);
        
        // Add user info to request context
        final updatedRequest = request.change(context: {
          'user': {
            'uid': decodedToken.uid,
            'email': decodedToken.email,
            'emailVerified': decodedToken.emailVerified,
            'claims': decodedToken.claims,
          }
        });

        return await innerHandler(updatedRequest);
      } catch (error) {
        _logger.warning('Authentication failed: $error');
        return Response.unauthorized(
          '{"error": "Invalid authentication token"}',
          headers: {'Content-Type': 'application/json'},
        );
      }
    };
  };
}

/// Rate limiting middleware
Middleware get rateLimitMiddleware {
  final Map<String, List<DateTime>> _requestCounts = {};
  
  return (Handler innerHandler) {
    return (Request request) async {
      final clientIp = request.headers['x-forwarded-for'] ?? 
                      request.headers['x-real-ip'] ?? 
                      'unknown';
      
      final now = DateTime.now();
      final windowStart = now.subtract(const Duration(minutes: 1));
      
      // Clean old requests
      _requestCounts[clientIp]?.removeWhere((time) => time.isBefore(windowStart));
      
      // Initialize if not exists
      _requestCounts[clientIp] ??= [];
      
      // Check rate limit (60 requests per minute)
      if (_requestCounts[clientIp]!.length >= 60) {
        return Response(429,
          body: '{"error": "Rate limit exceeded. Try again later."}',
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      // Add current request
      _requestCounts[clientIp]!.add(now);
      
      return await innerHandler(request);
    };
  };
}

/// Logging middleware
Middleware get loggingMiddleware {
  return (Handler innerHandler) {
    return (Request request) async {
      final stopwatch = Stopwatch()..start();
      final timestamp = DateTime.now().toIso8601String();
      
      _logger.info('${request.method} ${request.requestedUri} - Started at $timestamp');
      
      try {
        final response = await innerHandler(request);
        stopwatch.stop();
        
        _logger.info(
          '${request.method} ${request.requestedUri} - '
          'Status: ${response.statusCode} - '
          'Duration: ${stopwatch.elapsedMilliseconds}ms'
        );
        
        return response;
      } catch (error, stackTrace) {
        stopwatch.stop();
        
        _logger.severe(
          '${request.method} ${request.requestedUri} - '
          'Error: $error - '
          'Duration: ${stopwatch.elapsedMilliseconds}ms',
          error,
          stackTrace
        );
        
        return Response.internalServerError(
          body: '{"error": "Internal server error"}',
          headers: {'Content-Type': 'application/json'},
        );
      }
    };
  };
}

/// Admin authorization middleware
Middleware get adminMiddleware {
  return (Handler innerHandler) {
    return (Request request) async {
      final user = request.context['user'] as Map<String, dynamic>?;
      
      if (user == null) {
        return Response.unauthorized(
          '{"error": "Authentication required"}',
          headers: {'Content-Type': 'application/json'},
        );
      }

      final claims = user['claims'] as Map<String, dynamic>? ?? {};
      final isAdmin = claims['isAdmin'] == true || claims['role'] == 'admin';
      
      if (!isAdmin) {
        return Response.forbidden(
          '{"error": "Admin access required"}',
          headers: {'Content-Type': 'application/json'},
        );
      }

      return await innerHandler(request);
    };
  };
}

/// CORS middleware
Middleware corsHeaders(Map<String, String> headers) {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: headers);
      }

      final response = await innerHandler(request);
      return response.change(headers: {...response.headers, ...headers});
    };
  };
}

/// Request validation middleware
Middleware get validationMiddleware {
  return (Handler innerHandler) {
    return (Request request) async {
      // Validate content type for POST/PUT requests
      if (['POST', 'PUT', 'PATCH'].contains(request.method)) {
        final contentType = request.headers['content-type'];
        if (contentType == null || !contentType.contains('application/json')) {
          return Response.badRequest(
            body: '{"error": "Content-Type must be application/json"}',
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Validate JSON body
        try {
          final body = await request.readAsString();
          if (body.isNotEmpty) {
            jsonDecode(body);
          }
        } catch (error) {
          return Response.badRequest(
            body: '{"error": "Invalid JSON in request body"}',
            headers: {'Content-Type': 'application/json'},
          );
        }
      }

      return await innerHandler(request);
    };
  };
}

/// Security headers middleware
Middleware get securityMiddleware {
  return (Handler innerHandler) {
    return (Request request) async {
      final response = await innerHandler(request);
      
      return response.change(headers: {
        ...response.headers,
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'DENY',
        'X-XSS-Protection': '1; mode=block',
        'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
        'Referrer-Policy': 'strict-origin-when-cross-origin',
      });
    };
  };
}

/// Helper functions for middleware
class MiddlewareHelpers {
  /// Extract user from request context
  static Map<String, dynamic>? getUser(Request request) {
    return request.context['user'] as Map<String, dynamic>?;
  }

  /// Check if user is admin
  static bool isAdmin(Request request) {
    final user = getUser(request);
    if (user == null) return false;
    
    final claims = user['claims'] as Map<String, dynamic>? ?? {};
    return claims['isAdmin'] == true || claims['role'] == 'admin';
  }

  /// Check if user has specific role
  static bool hasRole(Request request, String role) {
    final user = getUser(request);
    if (user == null) return false;
    
    final claims = user['claims'] as Map<String, dynamic>? ?? {};
    return claims['role'] == role;
  }

  /// Check if user has permission
  static bool hasPermission(Request request, String permission) {
    final user = getUser(request);
    if (user == null) return false;
    
    final claims = user['claims'] as Map<String, dynamic>? ?? {};
    final permissions = claims['permissions'] as List<dynamic>? ?? [];
    return permissions.contains(permission);
  }

  /// Get user ID from request
  static String? getUserId(Request request) {
    final user = getUser(request);
    return user?['uid'] as String?;
  }

  /// Get user email from request
  static String? getUserEmail(Request request) {
    final user = getUser(request);
    return user?['email'] as String?;
  }

  /// Parse JSON body from request
  static Future<Map<String, dynamic>?> parseJsonBody(Request request) async {
    try {
      final body = await request.readAsString();
      if (body.isEmpty) return null;
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (error) {
      throw FormatException('Invalid JSON in request body');
    }
  }

  /// Create success response
  static Response successResponse(Map<String, dynamic> data, {int statusCode = 200}) {
    return Response(statusCode,
      body: jsonEncode({
        'success': true,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Create error response
  static Response errorResponse(String message, {int statusCode = 400, Map<String, dynamic>? details}) {
    return Response(statusCode,
      body: jsonEncode({
        'success': false,
        'error': {
          'message': message,
          'details': details,
        },
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Validate required fields
  static void validateRequiredFields(Map<String, dynamic> data, List<String> requiredFields) {
    final missingFields = <String>[];
    
    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        missingFields.add(field);
      }
    }
    
    if (missingFields.isNotEmpty) {
      throw ArgumentError('Missing required fields: ${missingFields.join(', ')}');
    }
  }

  /// Sanitize string input
  static String sanitizeString(String input) {
    return input.trim()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'[<>]'), ''); // Remove < and > characters
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  /// Validate phone number format
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(phone);
  }
}
