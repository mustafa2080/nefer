import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../core/firebase_service.dart';
import '../core/middleware.dart';

final _logger = Logger('NotificationFunctions');

/// Notification functions
class NotificationFunctions {
  
  /// Send notification
  static Future<Response> sendNotification(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final body = await MiddlewareHelpers.parseJsonBody(request);
      if (body == null) {
        return MiddlewareHelpers.errorResponse('Request body is required');
      }

      MiddlewareHelpers.validateRequiredFields(body, ['userId', 'title', 'body']);

      final userId = body['userId'] as String;
      final title = body['title'] as String;
      final messageBody = body['body'] as String;
      final data = body['data'] as Map<String, dynamic>? ?? {};

      // Get user's FCM token
      final userSnapshot = await FirebaseService.getDatabaseRef('users/$userId/fcmToken').once();
      final fcmToken = userSnapshot.snapshot.value as String?;

      if (fcmToken != null) {
        // Send push notification
        final message = Message(
          token: fcmToken,
          notification: Notification(
            title: title,
            body: messageBody,
          ),
          data: data.map((key, value) => MapEntry(key, value.toString())),
        );

        await FirebaseService.sendNotification(message);
      }

      // Store notification in database
      final notificationRef = FirebaseService.getDatabaseRef('notifications').push();
      await notificationRef.setWithTimestamp({
        'id': notificationRef.key,
        'userId': userId,
        'title': title,
        'body': messageBody,
        'data': data,
        'isRead': false,
      });

      return MiddlewareHelpers.successResponse({
        'message': 'Notification sent successfully',
      });
    } catch (error, stackTrace) {
      _logger.severe('Error sending notification: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to send notification');
    }
  }

  /// Send bulk notification
  static Future<Response> sendBulkNotification(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final body = await MiddlewareHelpers.parseJsonBody(request);
      if (body == null) {
        return MiddlewareHelpers.errorResponse('Request body is required');
      }

      MiddlewareHelpers.validateRequiredFields(body, ['userIds', 'title', 'body']);

      final userIds = List<String>.from(body['userIds'] as List);
      final title = body['title'] as String;
      final messageBody = body['body'] as String;
      final data = body['data'] as Map<String, dynamic>? ?? {};

      int sentCount = 0;

      for (final userId in userIds) {
        try {
          await _sendNotificationToUser(userId, title, messageBody, data);
          sentCount++;
        } catch (error) {
          _logger.warning('Failed to send notification to user $userId: $error');
        }
      }

      return MiddlewareHelpers.successResponse({
        'message': 'Bulk notification sent',
        'sent': sentCount,
        'total': userIds.length,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error sending bulk notification: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to send bulk notification');
    }
  }

  /// Schedule notification
  static Future<Response> scheduleNotification(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final body = await MiddlewareHelpers.parseJsonBody(request);
      if (body == null) {
        return MiddlewareHelpers.errorResponse('Request body is required');
      }

      MiddlewareHelpers.validateRequiredFields(body, ['userId', 'title', 'body', 'scheduledTime']);

      final userId = body['userId'] as String;
      final title = body['title'] as String;
      final messageBody = body['body'] as String;
      final scheduledTime = body['scheduledTime'] as int;
      final data = body['data'] as Map<String, dynamic>? ?? {};

      // Store scheduled notification
      final scheduledRef = FirebaseService.getDatabaseRef('scheduled_notifications').push();
      await scheduledRef.setWithTimestamp({
        'id': scheduledRef.key,
        'userId': userId,
        'title': title,
        'body': messageBody,
        'data': data,
        'scheduledTime': scheduledTime,
        'status': 'pending',
        'createdBy': MiddlewareHelpers.getUserId(request),
      });

      return MiddlewareHelpers.successResponse({
        'message': 'Notification scheduled successfully',
        'scheduledId': scheduledRef.key,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error scheduling notification: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to schedule notification');
    }
  }

  /// Get user notifications
  static Future<Response> getUserNotifications(Request request) async {
    try {
      final user = MiddlewareHelpers.getUser(request);
      if (user == null) {
        return MiddlewareHelpers.errorResponse('Authentication required', statusCode: 401);
      }

      final userId = request.params['userId'];
      if (userId == null) {
        return MiddlewareHelpers.errorResponse('User ID is required');
      }

      // Check if user is requesting their own notifications or is admin
      if (userId != user['uid'] && !MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Access denied', statusCode: 403);
      }

      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '50') ?? 50;

      final notificationsSnapshot = await FirebaseService.getDatabaseRef('notifications').once();
      final notificationsData = notificationsSnapshot.snapshot.value as Map<dynamic, dynamic>? ?? {};

      final notifications = <Map<String, dynamic>>[];

      for (final entry in notificationsData.entries) {
        final notificationData = entry.value as Map<dynamic, dynamic>;
        if (notificationData['userId'] == userId) {
          notifications.add({
            'id': entry.key,
            ...Map<String, dynamic>.from(notificationData),
          });
        }

        if (notifications.length >= limit) break;
      }

      // Sort by creation date (newest first)
      notifications.sort((a, b) {
        final aTime = a['createdAt'] as int? ?? 0;
        final bTime = b['createdAt'] as int? ?? 0;
        return bTime.compareTo(aTime);
      });

      return MiddlewareHelpers.successResponse({
        'notifications': notifications,
        'total': notifications.length,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error getting user notifications: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to get notifications');
    }
  }

  /// Mark notification as read
  static Future<Response> markAsRead(Request request) async {
    try {
      final user = MiddlewareHelpers.getUser(request);
      if (user == null) {
        return MiddlewareHelpers.errorResponse('Authentication required', statusCode: 401);
      }

      final notificationId = request.params['notificationId'];
      if (notificationId == null) {
        return MiddlewareHelpers.errorResponse('Notification ID is required');
      }

      final notificationSnapshot = await FirebaseService.getDatabaseRef('notifications/$notificationId').once();
      final notificationData = notificationSnapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (notificationData == null) {
        return MiddlewareHelpers.errorResponse('Notification not found', statusCode: 404);
      }

      // Check if user owns the notification
      if (notificationData['userId'] != user['uid']) {
        return MiddlewareHelpers.errorResponse('Access denied', statusCode: 403);
      }

      await FirebaseService.getDatabaseRef('notifications/$notificationId').updateWithTimestamp({
        'isRead': true,
        'readAt': FirebaseService.serverTimestamp,
      });

      return MiddlewareHelpers.successResponse({
        'message': 'Notification marked as read',
      });
    } catch (error, stackTrace) {
      _logger.severe('Error marking notification as read: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to mark notification as read');
    }
  }

  // Helper method
  static Future<void> _sendNotificationToUser(
    String userId,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    try {
      // Get user's FCM token
      final userSnapshot = await FirebaseService.getDatabaseRef('users/$userId/fcmToken').once();
      final fcmToken = userSnapshot.snapshot.value as String?;

      if (fcmToken != null) {
        // Send push notification
        final message = Message(
          token: fcmToken,
          notification: Notification(
            title: title,
            body: body,
          ),
          data: data.map((key, value) => MapEntry(key, value.toString())),
        );

        await FirebaseService.sendNotification(message);
      }

      // Store notification in database
      final notificationRef = FirebaseService.getDatabaseRef('notifications').push();
      await notificationRef.setWithTimestamp({
        'id': notificationRef.key,
        'userId': userId,
        'title': title,
        'body': body,
        'data': data,
        'isRead': false,
      });
    } catch (error) {
      _logger.warning('Failed to send notification to user $userId: $error');
      rethrow;
    }
  }
}
