import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/providers/providers.dart';
import '../../../../generated/l10n.dart';
import '../widgets/order_status_timeline.dart';
import '../widgets/order_details_card.dart';
import '../widgets/delivery_map_widget.dart';
import '../widgets/contact_delivery_section.dart';
import '../controllers/order_tracking_controller.dart';

/// Order Tracking Screen with real-time shipment progress
/// 
/// Features:
/// - Real-time order status updates
/// - Interactive timeline with Pharaonic design
/// - Delivery map with live tracking
/// - Estimated delivery time
/// - Contact delivery person
/// - Order details and items
class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  ConsumerState<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadOrderTracking();
    _startRealTimeUpdates();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _loadOrderTracking() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderTrackingControllerProvider(widget.orderId).notifier)
          .loadOrderTracking();
    });
  }

  void _startRealTimeUpdates() {
    // Start real-time updates every 30 seconds
    ref.read(orderTrackingControllerProvider(widget.orderId).notifier)
        .startRealTimeUpdates();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    // Stop real-time updates
    ref.read(orderTrackingControllerProvider(widget.orderId).notifier)
        .stopRealTimeUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trackingState = ref.watch(orderTrackingControllerProvider(widget.orderId));
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(context, l10n),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildContent(context, l10n, trackingState),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations? l10n) {
    return AppBar(
      title: Text(
        'Order Tracking',
        style: NeferTypography.sectionHeader,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          onPressed: () => _refreshTracking(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
        IconButton(
          onPressed: () => _shareOrderTracking(),
          icon: const Icon(Icons.share),
          tooltip: 'Share',
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations? l10n,
    OrderTrackingState trackingState,
  ) {
    return trackingState.when(
      loading: () => _buildLoadingState(),
      error: (error, _) => _buildErrorState(error.toString()),
      data: (tracking) => _buildTrackingContent(context, l10n, tracking),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(NeferColors.pharaohGold),
          ),
          SizedBox(height: 16),
          Text(
            'Loading order tracking...',
            style: TextStyle(
              color: NeferColors.hieroglyphGray,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: NeferColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load tracking',
            style: NeferTypography.sectionHeader.copyWith(
              color: NeferColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: NeferTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _refreshTracking(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingContent(
    BuildContext context,
    AppLocalizations? l10n,
    OrderTracking tracking,
  ) {
    return RefreshIndicator(
      onRefresh: () async => _refreshTracking(),
      color: NeferColors.pharaohGold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header with Status
            _buildOrderHeader(tracking),
            
            const SizedBox(height: 24),
            
            // Delivery Map (if order is shipped)
            if (tracking.isShipped) ...[
              _buildDeliveryMap(tracking),
              const SizedBox(height: 24),
            ],
            
            // Order Status Timeline
            _buildStatusTimeline(tracking),
            
            const SizedBox(height: 24),
            
            // Estimated Delivery
            _buildEstimatedDelivery(tracking),
            
            const SizedBox(height: 24),
            
            // Contact Delivery Section (if order is shipped)
            if (tracking.isShipped) ...[
              ContactDeliverySection(
                deliveryPerson: tracking.deliveryPerson,
                onCallDelivery: () => _callDeliveryPerson(tracking.deliveryPerson),
                onMessageDelivery: () => _messageDeliveryPerson(tracking.deliveryPerson),
              ),
              const SizedBox(height: 24),
            ],
            
            // Order Details
            OrderDetailsCard(
              order: tracking.order,
              onViewInvoice: () => _viewInvoice(tracking.order),
              onReorderItems: () => _reorderItems(tracking.order),
            ),
            
            const SizedBox(height: 24),
            
            // Tracking History
            _buildTrackingHistory(tracking),
            
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(OrderTracking tracking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getStatusGradient(tracking.currentStatus),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(tracking.currentStatus).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: tracking.isInTransit ? _pulseAnimation.value : 1.0,
                    child: Icon(
                      _getStatusIcon(tracking.currentStatus),
                      color: Colors.white,
                      size: 32,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${tracking.order.orderNumber}',
                      style: NeferTypography.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _getStatusDisplayName(tracking.currentStatus),
                      style: NeferTypography.sectionHeader.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (tracking.estimatedDelivery != null) ...[
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Estimated delivery: ${_formatDeliveryDate(tracking.estimatedDelivery!)}',
                  style: NeferTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
          
          if (tracking.trackingNumber != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Tracking: ${tracking.trackingNumber}',
                  style: NeferTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryMap(OrderTracking tracking) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: NeferColors.lightShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DeliveryMapWidget(
          deliveryLocation: tracking.currentLocation,
          destinationLocation: tracking.deliveryAddress,
          deliveryPerson: tracking.deliveryPerson,
          onMapTap: () => _openFullScreenMap(tracking),
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(OrderTracking tracking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: NeferColors.lightShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Progress',
            style: NeferTypography.sectionHeader.copyWith(
              color: NeferColors.hieroglyphGray,
            ),
          ),
          const SizedBox(height: 16),
          
          OrderStatusTimeline(
            currentStatus: tracking.currentStatus,
            statusHistory: tracking.statusHistory,
            onStatusTap: (status) => _showStatusDetails(status),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedDelivery(OrderTracking tracking) {
    if (tracking.estimatedDelivery == null) return const SizedBox.shrink();
    
    final now = DateTime.now();
    final delivery = tracking.estimatedDelivery!;
    final isToday = delivery.day == now.day && 
                   delivery.month == now.month && 
                   delivery.year == now.year;
    final isTomorrow = delivery.difference(now).inDays == 1;
    
    String deliveryText;
    if (isToday) {
      deliveryText = 'Today by ${_formatTime(delivery)}';
    } else if (isTomorrow) {
      deliveryText = 'Tomorrow by ${_formatTime(delivery)}';
    } else {
      deliveryText = _formatDeliveryDate(delivery);
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NeferColors.pharaohGold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: NeferColors.pharaohGold.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NeferColors.pharaohGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time,
              color: NeferColors.pharaohGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Delivery',
                  style: NeferTypography.bodyMedium.copyWith(
                    color: NeferColors.hieroglyphGray.withOpacity(0.7),
                  ),
                ),
                Text(
                  deliveryText,
                  style: NeferTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: NeferColors.hieroglyphGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingHistory(OrderTracking tracking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: NeferColors.lightShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking History',
            style: NeferTypography.sectionHeader.copyWith(
              color: NeferColors.hieroglyphGray,
            ),
          ),
          const SizedBox(height: 16),
          
          ...tracking.trackingEvents.map((event) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: NeferColors.pharaohGold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.description,
                        style: NeferTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_formatDate(event.timestamp)} at ${_formatTime(event.timestamp)}',
                        style: NeferTypography.bodySmall.copyWith(
                          color: NeferColors.hieroglyphGray.withOpacity(0.7),
                        ),
                      ),
                      if (event.location != null)
                        Text(
                          event.location!,
                          style: NeferTypography.bodySmall.copyWith(
                            color: NeferColors.hieroglyphGray.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // Helper Methods
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return NeferColors.warning;
      case OrderStatus.confirmed:
        return NeferColors.info;
      case OrderStatus.processing:
        return NeferColors.pharaohGold;
      case OrderStatus.shipped:
        return NeferColors.lapisBlue;
      case OrderStatus.outForDelivery:
        return NeferColors.turquoise;
      case OrderStatus.delivered:
        return NeferColors.success;
      case OrderStatus.cancelled:
        return NeferColors.error;
      case OrderStatus.refunded:
        return NeferColors.hieroglyphGray;
    }
  }

  Gradient _getStatusGradient(OrderStatus status) {
    final color = _getStatusColor(status);
    return LinearGradient(
      colors: [color, color.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.processing:
        return Icons.settings;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.refunded:
        return Icons.money_off;
    }
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Pending';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  String _formatDeliveryDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Event Handlers
  void _refreshTracking() {
    ref.refresh(orderTrackingControllerProvider(widget.orderId));
  }

  void _shareOrderTracking() {
    // Implement sharing functionality
  }

  void _openFullScreenMap(OrderTracking tracking) {
    // Navigate to full screen map
    context.pushNamed(RouteNames.deliveryMap, 
      pathParameters: {'orderId': widget.orderId});
  }

  void _showStatusDetails(OrderStatusHistory status) {
    // Show detailed status information
  }

  void _callDeliveryPerson(DeliveryPerson? deliveryPerson) {
    // Implement call functionality
  }

  void _messageDeliveryPerson(DeliveryPerson? deliveryPerson) {
    // Implement messaging functionality
  }

  void _viewInvoice(Order order) {
    context.pushNamed(RouteNames.invoice, 
      pathParameters: {'orderId': order.id});
  }

  void _reorderItems(Order order) {
    // Add all order items to cart
    context.pushNamed(RouteNames.cart);
  }
}

// Enums and Models
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  refunded,
}
