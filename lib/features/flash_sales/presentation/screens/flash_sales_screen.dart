import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/providers/providers.dart';
import '../../../../generated/l10n.dart';
import '../widgets/flash_sale_banner.dart';
import '../widgets/flash_sale_product_card.dart';
import '../widgets/countdown_timer_widget.dart';
import '../widgets/flash_sale_progress_bar.dart';
import '../controllers/flash_sales_controller.dart';

/// Flash Sales Screen with countdown timers and limited-time offers
/// 
/// Features:
/// - Real-time countdown timers
/// - Limited quantity indicators
/// - Flash sale banners with Egyptian design
/// - Product cards with discount percentages
/// - Auto-refresh when sales end/start
/// - Push notifications for flash sales
class FlashSalesScreen extends ConsumerStatefulWidget {
  const FlashSalesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FlashSalesScreen> createState() => _FlashSalesScreenState();
}

class _FlashSalesScreenState extends ConsumerState<FlashSalesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadFlashSales();
    _startAutoRefresh();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _loadFlashSales() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(flashSalesControllerProvider.notifier).loadFlashSales();
    });
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        ref.read(flashSalesControllerProvider.notifier).refreshFlashSales();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final flashSalesState = ref.watch(flashSalesControllerProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(context, l10n),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildContent(context, l10n, flashSalesState),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations? l10n) {
    return AppBar(
      title: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Icon(
                  Icons.flash_on,
                  color: NeferColors.pharaohGold,
                  size: 24,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            l10n?.flashSales ?? 'Flash Sales',
            style: NeferTypography.sectionHeader,
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          onPressed: () => _showNotificationSettings(context),
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Notification Settings',
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations? l10n,
    FlashSalesState flashSalesState,
  ) {
    return flashSalesState.when(
      loading: () => _buildLoadingState(),
      error: (error, _) => _buildErrorState(error.toString()),
      data: (flashSales) => _buildFlashSalesContent(context, l10n, flashSales),
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
            'Loading flash sales...',
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
            'Failed to load flash sales',
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
              ref.refresh(flashSalesControllerProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSalesContent(
    BuildContext context,
    AppLocalizations? l10n,
    List<FlashSale> flashSales,
  ) {
    if (flashSales.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(flashSalesControllerProvider);
      },
      color: NeferColors.pharaohGold,
      child: CustomScrollView(
        slivers: [
          // Active Flash Sales
          if (flashSales.any((sale) => sale.isActive)) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildSectionHeader(
                  title: 'Active Flash Sales',
                  titleAr: 'العروض النشطة',
                  icon: Icons.flash_on,
                ),
              ),
            ),
            
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final activeSales = flashSales.where((sale) => sale.isActive).toList();
                  if (index >= activeSales.length) return null;
                  
                  final sale = activeSales[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildFlashSaleCard(context, sale),
                  );
                },
                childCount: flashSales.where((sale) => sale.isActive).length,
              ),
            ),
          ],
          
          // Upcoming Flash Sales
          if (flashSales.any((sale) => sale.isUpcoming)) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildSectionHeader(
                  title: 'Upcoming Flash Sales',
                  titleAr: 'العروض القادمة',
                  icon: Icons.schedule,
                ),
              ),
            ),
            
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final upcomingSales = flashSales.where((sale) => sale.isUpcoming).toList();
                  if (index >= upcomingSales.length) return null;
                  
                  final sale = upcomingSales[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildFlashSaleCard(context, sale),
                  );
                },
                childCount: flashSales.where((sale) => sale.isUpcoming).length,
              ),
            ),
          ],
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations? l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flash_off,
            size: 80,
            color: NeferColors.hieroglyphGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Flash Sales Available',
            style: NeferTypography.sectionHeader.copyWith(
              color: NeferColors.hieroglyphGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for amazing deals!',
            style: NeferTypography.bodyMedium.copyWith(
              color: NeferColors.hieroglyphGray.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pushNamed(RouteNames.products),
            child: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String titleAr,
    required IconData icon,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return Row(
      children: [
        Icon(
          icon,
          color: NeferColors.pharaohGold,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          isRTL ? titleAr : title,
          style: NeferTypography.sectionHeader.copyWith(
            color: NeferColors.hieroglyphGray,
          ),
        ),
      ],
    );
  }

  Widget _buildFlashSaleCard(BuildContext context, FlashSale sale) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              NeferColors.pharaohGold.withOpacity(0.1),
              NeferColors.turquoise.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flash Sale Banner
            FlashSaleBanner(
              sale: sale,
              onTap: () => _viewFlashSaleDetails(sale),
            ),
            
            // Countdown Timer
            if (sale.isActive || sale.isUpcoming)
              Padding(
                padding: const EdgeInsets.all(16),
                child: CountdownTimerWidget(
                  endTime: sale.isActive ? sale.endTime : sale.startTime,
                  label: sale.isActive ? 'Ends in:' : 'Starts in:',
                  onTimerEnd: () => _handleTimerEnd(sale),
                ),
              ),
            
            // Products Grid
            if (sale.products.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Featured Products',
                      style: NeferTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: sale.products.length.clamp(0, 5),
                        itemBuilder: (context, index) {
                          final product = sale.products[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: SizedBox(
                              width: 150,
                              child: FlashSaleProductCard(
                                product: product,
                                flashSale: sale,
                                onTap: () => _viewProduct(product),
                                onAddToCart: () => _addToCart(product),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            
            // View All Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _viewAllFlashSaleProducts(sale),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: NeferColors.pharaohGold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View All ${sale.products.length} Products',
                    style: TextStyle(color: NeferColors.pharaohGold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Event Handlers
  void _viewFlashSaleDetails(FlashSale sale) {
    context.pushNamed(RouteNames.flashSaleDetails, 
      pathParameters: {'saleId': sale.id});
  }

  void _viewProduct(Product product) {
    context.pushNamed(RouteNames.productDetails, 
      pathParameters: {'id': product.id});
  }

  void _addToCart(Product product) {
    ref.read(cartControllerProvider.notifier).addToCart(product.id, 1);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        backgroundColor: NeferColors.success,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => context.pushNamed(RouteNames.cart),
        ),
      ),
    );
  }

  void _viewAllFlashSaleProducts(FlashSale sale) {
    context.pushNamed(RouteNames.flashSaleProducts, 
      pathParameters: {'saleId': sale.id});
  }

  void _handleTimerEnd(FlashSale sale) {
    // Refresh flash sales when timer ends
    ref.refresh(flashSalesControllerProvider);
    
    if (sale.isActive) {
      // Show sale ended notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Flash sale "${sale.name}" has ended!'),
          backgroundColor: NeferColors.warning,
        ),
      );
    } else if (sale.isUpcoming) {
      // Show sale started notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Flash sale "${sale.name}" has started!'),
          backgroundColor: NeferColors.success,
        ),
      );
    }
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.notifications, color: NeferColors.pharaohGold),
              title: const Text('Flash Sale Notifications'),
              subtitle: const Text('Get notified when flash sales start'),
              trailing: Consumer(
                builder: (context, ref, child) {
                  final notificationsEnabled = ref.watch(flashSaleNotificationsProvider);
                  return Switch(
                    value: notificationsEnabled,
                    onChanged: (value) {
                      ref.read(flashSaleNotificationsProvider.notifier).state = value;
                    },
                    activeColor: NeferColors.pharaohGold,
                  );
                },
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.schedule, color: NeferColors.pharaohGold),
              title: const Text('Reminder Notifications'),
              subtitle: const Text('Get reminded 15 minutes before sales end'),
              trailing: Consumer(
                builder: (context, ref, child) {
                  final remindersEnabled = ref.watch(flashSaleRemindersProvider);
                  return Switch(
                    value: remindersEnabled,
                    onChanged: (value) {
                      ref.read(flashSaleRemindersProvider.notifier).state = value;
                    },
                    activeColor: NeferColors.pharaohGold,
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Flash Sale model
class FlashSale {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final DateTime startTime;
  final DateTime endTime;
  final List<Product> products;
  final String bannerImageUrl;
  final double discountPercentage;
  final bool isActive;
  final bool isUpcoming;
  final bool hasEnded;

  const FlashSale({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.startTime,
    required this.endTime,
    required this.products,
    required this.bannerImageUrl,
    required this.discountPercentage,
    required this.isActive,
    required this.isUpcoming,
    required this.hasEnded,
  });

  Duration get timeRemaining {
    final now = DateTime.now();
    if (isActive) {
      return endTime.difference(now);
    } else if (isUpcoming) {
      return startTime.difference(now);
    }
    return Duration.zero;
  }
}

// Providers for notification settings
final flashSaleNotificationsProvider = StateProvider<bool>((ref) => true);
final flashSaleRemindersProvider = StateProvider<bool>((ref) => true);
