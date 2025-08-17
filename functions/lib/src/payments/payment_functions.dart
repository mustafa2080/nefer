import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';
import '../core/firebase_service.dart';
import '../core/middleware.dart';

final _logger = Logger('PaymentFunctions');

/// Payment processing functions
class PaymentFunctions {
  
  /// Create payment intent
  static Future<Response> createPaymentIntent(Request request) async {
    try {
      final user = MiddlewareHelpers.getUser(request);
      if (user == null) {
        return MiddlewareHelpers.errorResponse('Authentication required', statusCode: 401);
      }

      final body = await MiddlewareHelpers.parseJsonBody(request);
      if (body == null) {
        return MiddlewareHelpers.errorResponse('Request body is required');
      }

      MiddlewareHelpers.validateRequiredFields(body, ['amount', 'orderId']);

      final amount = body['amount'] as num;
      final currency = body['currency'] as String? ?? 'usd';
      final orderId = body['orderId'] as String;

      // In a real implementation, you would integrate with Stripe here
      final paymentIntentId = 'pi_${DateTime.now().millisecondsSinceEpoch}';
      final clientSecret = '${paymentIntentId}_secret_${DateTime.now().millisecondsSinceEpoch}';

      final paymentIntent = {
        'id': paymentIntentId,
        'amount': amount,
        'currency': currency,
        'status': 'requires_payment_method',
        'clientSecret': clientSecret,
        'orderId': orderId,
        'userId': user['uid'],
      };

      // Store payment intent in database
      await FirebaseService.getDatabaseRef('payment_intents/$paymentIntentId').setWithTimestamp(paymentIntent);

      return MiddlewareHelpers.successResponse({
        'paymentIntent': paymentIntent,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error creating payment intent: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to create payment intent');
    }
  }

  /// Confirm payment
  static Future<Response> confirmPayment(Request request) async {
    try {
      final user = MiddlewareHelpers.getUser(request);
      if (user == null) {
        return MiddlewareHelpers.errorResponse('Authentication required', statusCode: 401);
      }

      final body = await MiddlewareHelpers.parseJsonBody(request);
      if (body == null) {
        return MiddlewareHelpers.errorResponse('Request body is required');
      }

      final paymentIntentId = body['paymentIntentId'] as String?;
      if (paymentIntentId == null) {
        return MiddlewareHelpers.errorResponse('Payment intent ID is required');
      }

      // In a real implementation, you would confirm with Stripe here
      await FirebaseService.getDatabaseRef('payment_intents/$paymentIntentId').updateWithTimestamp({
        'status': 'succeeded',
        'confirmedAt': FirebaseService.serverTimestamp,
      });

      return MiddlewareHelpers.successResponse({
        'message': 'Payment confirmed successfully',
      });
    } catch (error, stackTrace) {
      _logger.severe('Error confirming payment: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to confirm payment');
    }
  }

  /// Refund payment
  static Future<Response> refundPayment(Request request) async {
    try {
      if (!MiddlewareHelpers.isAdmin(request)) {
        return MiddlewareHelpers.errorResponse('Admin access required', statusCode: 403);
      }

      final body = await MiddlewareHelpers.parseJsonBody(request);
      if (body == null) {
        return MiddlewareHelpers.errorResponse('Request body is required');
      }

      MiddlewareHelpers.validateRequiredFields(body, ['paymentIntentId', 'amount']);

      final paymentIntentId = body['paymentIntentId'] as String;
      final amount = body['amount'] as num;

      // In a real implementation, you would process refund with Stripe here
      final refundId = 're_${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseService.getDatabaseRef('refunds/$refundId').setWithTimestamp({
        'id': refundId,
        'paymentIntentId': paymentIntentId,
        'amount': amount,
        'status': 'succeeded',
        'processedBy': MiddlewareHelpers.getUserId(request),
      });

      return MiddlewareHelpers.successResponse({
        'message': 'Refund processed successfully',
        'refundId': refundId,
      });
    } catch (error, stackTrace) {
      _logger.severe('Error processing refund: $error', error, stackTrace);
      return MiddlewareHelpers.errorResponse('Failed to process refund');
    }
  }

  /// Handle Stripe webhook
  static Future<Response> handleStripeWebhook(Request request) async {
    try {
      final body = await request.readAsString();
      final event = jsonDecode(body) as Map<String, dynamic>;

      // In a real implementation, you would verify the webhook signature
      
      switch (event['type']) {
        case 'payment_intent.succeeded':
          await _handlePaymentSuccess(event['data']['object']);
          break;
        case 'payment_intent.payment_failed':
          await _handlePaymentFailed(event['data']['object']);
          break;
        default:
          _logger.info('Unhandled event type: ${event['type']}');
      }

      return Response.ok('OK');
    } catch (error, stackTrace) {
      _logger.severe('Error handling webhook: $error', error, stackTrace);
      return Response.internalServerError(body: 'Error');
    }
  }

  // Helper methods
  static Future<void> _handlePaymentSuccess(Map<String, dynamic> paymentIntent) async {
    try {
      final paymentIntentId = paymentIntent['id'] as String;
      _logger.info('Payment succeeded: $paymentIntentId');
      
      // Update payment status in database
      await FirebaseService.getDatabaseRef('payment_intents/$paymentIntentId').updateWithTimestamp({
        'status': 'succeeded',
        'processedAt': FirebaseService.serverTimestamp,
      });
      
      // You could also update the related order status here
    } catch (error) {
      _logger.severe('Error handling payment success: $error');
    }
  }

  static Future<void> _handlePaymentFailed(Map<String, dynamic> paymentIntent) async {
    try {
      final paymentIntentId = paymentIntent['id'] as String;
      _logger.info('Payment failed: $paymentIntentId');
      
      // Update payment status in database
      await FirebaseService.getDatabaseRef('payment_intents/$paymentIntentId').updateWithTimestamp({
        'status': 'failed',
        'failedAt': FirebaseService.serverTimestamp,
        'failureReason': paymentIntent['last_payment_error']?['message'],
      });
    } catch (error) {
      _logger.severe('Error handling payment failure: $error');
    }
  }
}
