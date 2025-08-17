import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/providers/providers.dart';
import '../../../../generated/l10n.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary_card.dart';
import '../widgets/coupon_input_section.dart';
import '../widgets/empty_cart_widget.dart';
import '../controllers/cart_controller.dart';

/// Shopping Cart Screen with Pharaonic design
/// 
/// Features:
/// - Cart items with quantity controls
/// - Coupon code application
/// - Order summary with taxes and shipping
/// - Checkout button with animations
/// - Empty cart state with recommendations
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCart();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _loadCart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartControllerProvider.notifier).loadCart();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cartState = ref.watch(cartControllerProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(context, l10n),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildContent(context, l10n, cartState),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations? l10n) {
    return AppBar(
      title: Text(
        l10n?.cart ?? 'Shopping Cart',
        style: NeferTypography.sectionHeader,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        // Clear cart button
        Consumer(
          builder: (context, ref, child) {
            final cartItems = ref.watch(cartItemsProvider);
            if (cartItems.isEmpty) return const SizedBox.shrink();
            
            return IconButton(
              onPressed: () => _showClearCartDialog(context),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear Cart',
            );
          },
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations? l10n,
    CartState cartState,
  ) {
    return cartState.when(
      loading: () => _buildLoadingState(),
      error: (error, _) => _buildErrorState(error.toString()),
      data: (cart) => cart.items.isEmpty 
          ? _buildEmptyCart(context, l10n)
          : _buildCartContent(context, l10n, cart),
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
            'Loading cart...',
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
            'Failed to load cart',
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
            onPressed: () {
              ref.refresh(cartControllerProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, AppLocalizations? l10n) {
    return EmptyCartWidget(
      onContinueShopping: () => context.goNamed(RouteNames.home),
      onViewRecommendations: () => context.pushNamed(RouteNames.recommendations),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    AppLocalizations? l10n,
    Cart cart,
  ) {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CartItemCard(
                  item: item,
                  onQuantityChanged: (quantity) => _updateQuantity(item.id, quantity),
                  onRemove: () => _removeItem(item.id),
                  onProductTap: () => _navigateToProduct(item.productId),
                ),
              );
            },
          ),
        ),
        
        // Bottom Section with Summary and Checkout
        _buildBottomSection(context, l10n, cart),
      ],
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    AppLocalizations? l10n,
    Cart cart,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Coupon Input Section
          CouponInputSection(
            controller: _couponController,
            onApplyCoupon: _applyCoupon,
            appliedCoupon: cart.appliedCoupon,
            onRemoveCoupon: _removeCoupon,
          ),
          
          // Cart Summary
          CartSummaryCard(
            subtotal: cart.subtotal,
            discount: cart.discount,
            shipping: cart.shipping,
            tax: cart.tax,
            total: cart.total,
            appliedCoupon: cart.appliedCoupon,
          ),
          
          // Checkout Button
          _buildCheckoutButton(context, cart),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, Cart cart) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: cart.items.isNotEmpty ? () => _proceedToCheckout(cart) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: NeferColors.pharaohGold,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, size: 20),
            const SizedBox(width: 8),
            Text(
              'Proceed to Checkout',
              style: NeferTypography.buttonText.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${cart.total.toStringAsFixed(2)}',
              style: NeferTypography.buttonText.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Event Handlers
  void _updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      _removeItem(itemId);
    } else {
      ref.read(cartControllerProvider.notifier).updateQuantity(itemId, quantity);
    }
  }

  void _removeItem(String itemId) {
    ref.read(cartControllerProvider.notifier).removeFromCart(itemId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removed from cart'),
        backgroundColor: NeferColors.warning,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // Implement undo functionality
          },
        ),
      ),
    );
  }

  void _navigateToProduct(String productId) {
    context.pushNamed(RouteNames.productDetails, 
      pathParameters: {'id': productId});
  }

  void _applyCoupon() {
    final couponCode = _couponController.text.trim();
    if (couponCode.isNotEmpty) {
      ref.read(cartControllerProvider.notifier).applyCoupon(couponCode);
    }
  }

  void _removeCoupon() {
    ref.read(cartControllerProvider.notifier).removeCoupon();
    _couponController.clear();
  }

  void _proceedToCheckout(Cart cart) {
    // Navigate to checkout screen
    context.pushNamed(RouteNames.checkout);
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(cartControllerProvider.notifier).clearCart();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart cleared'),
                  backgroundColor: NeferColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NeferColors.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

/// Cart data model
class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double shipping;
  final double tax;
  final double total;
  final Coupon? appliedCoupon;
  final DateTime updatedAt;

  const Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.tax,
    required this.total,
    this.appliedCoupon,
    required this.updatedAt,
  });

  Cart copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? subtotal,
    double? discount,
    double? shipping,
    double? tax,
    double? total,
    Coupon? appliedCoupon,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shipping: shipping ?? this.shipping,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Cart item model
class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String? sizeId;
  final String? sizeName;
  final String? colorId;
  final String? colorName;
  final String? colorHex;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.sizeId,
    this.sizeName,
    this.colorId,
    this.colorName,
    this.colorHex,
    required this.addedAt,
  });

  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? sizeId,
    String? sizeName,
    String? colorId,
    String? colorName,
    String? colorHex,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      sizeId: sizeId ?? this.sizeId,
      sizeName: sizeName ?? this.sizeName,
      colorId: colorId ?? this.colorId,
      colorName: colorName ?? this.colorName,
      colorHex: colorHex ?? this.colorHex,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

/// Coupon model
class Coupon {
  final String id;
  final String code;
  final String name;
  final CouponType type;
  final double value;
  final double? minimumAmount;
  final double? maximumDiscount;
  final DateTime validFrom;
  final DateTime validTo;
  final bool isActive;

  const Coupon({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.value,
    this.minimumAmount,
    this.maximumDiscount,
    required this.validFrom,
    required this.validTo,
    required this.isActive,
  });

  bool get isValid {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(validFrom) && 
           now.isBefore(validTo);
  }

  double calculateDiscount(double subtotal) {
    if (!isValid || (minimumAmount != null && subtotal < minimumAmount!)) {
      return 0.0;
    }

    double discount = 0.0;
    
    switch (type) {
      case CouponType.percentage:
        discount = subtotal * (value / 100);
        break;
      case CouponType.fixed:
        discount = value;
        break;
    }

    if (maximumDiscount != null && discount > maximumDiscount!) {
      discount = maximumDiscount!;
    }

    return discount;
  }
}

enum CouponType { percentage, fixed }
