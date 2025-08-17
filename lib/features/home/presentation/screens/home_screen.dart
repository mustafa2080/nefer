import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/providers/providers.dart';
import '../../../../generated/l10n.dart';
import '../widgets/pharaoh_home_app_bar.dart';
import '../widgets/hero_banner_carousel.dart';
import '../widgets/categories_grid.dart';
import '../widgets/featured_products_section.dart';
import '../widgets/flash_sales_section.dart';
import '../widgets/recommendations_section.dart';
import '../controllers/home_controller.dart';

/// Home Screen - Main landing page with Pharaonic design
/// 
/// Features:
/// - Animated app bar with search functionality
/// - Hero banner carousel with promotions
/// - Categories grid with Egyptian-themed icons
/// - Featured products section
/// - Flash sales with countdown timers
/// - Personalized recommendations
/// - Smooth scrolling and animations
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _showAppBarBackground = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadHomeData();
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();
  }

  void _loadHomeData() {
    // Load home data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeControllerProvider.notifier).loadHomeData();
    });
  }

  void _onScroll() {
    final showBackground = _scrollController.offset > 100;
    if (showBackground != _showAppBarBackground) {
      setState(() {
        _showAppBarBackground = showBackground;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final homeState = ref.watch(homeControllerProvider);
    final currentUser = ref.watch(currentUserProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Pharaoh-themed app bar
                PharaohHomeAppBar(
                  showBackground: _showAppBarBackground,
                  userName: currentUser?.fullName ?? 'Welcome',
                  onSearchTap: () => context.pushNamed(RouteNames.search),
                  onNotificationTap: () => _showNotifications(context),
                  onCartTap: () => context.pushNamed(RouteNames.cart),
                ),
                
                // Main content
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHomeContent(context, l10n, homeState),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    AppLocalizations? l10n,
    HomeState homeState,
  ) {
    return homeState.when(
      loading: () => _buildLoadingState(),
      error: (error, _) => _buildErrorState(error.toString()),
      data: (data) => _buildLoadedState(context, l10n, data),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(NeferColors.pharaohGold),
            ),
            SizedBox(height: 16),
            Text(
              'Loading marketplace...',
              style: TextStyle(
                color: NeferColors.hieroglyphGray,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Center(
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
              'Failed to load marketplace',
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
                ref.refresh(homeControllerProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    AppLocalizations? l10n,
    HomeData data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Banner Carousel
        HeroBannerCarousel(
          banners: data.banners,
          onBannerTap: (banner) => _handleBannerTap(context, banner),
        ),
        
        const SizedBox(height: 24),
        
        // Categories Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                title: l10n?.categories ?? 'Categories',
                titleAr: 'الفئات',
                onViewAll: () => context.pushNamed(RouteNames.categories),
              ),
              const SizedBox(height: 16),
              CategoriesGrid(
                categories: data.categories,
                onCategoryTap: (category) => _handleCategoryTap(context, category),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Flash Sales Section
        if (data.flashSales.isNotEmpty) ...[
          FlashSalesSection(
            flashSales: data.flashSales,
            onProductTap: (product) => _handleProductTap(context, product),
            onViewAll: () => context.pushNamed(RouteNames.flashSales),
          ),
          const SizedBox(height: 32),
        ],
        
        // Featured Products Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                title: 'Featured Products',
                titleAr: 'المنتجات المميزة',
                onViewAll: () => context.pushNamed(RouteNames.products, 
                  queryParameters: {'featured': 'true'}),
              ),
              const SizedBox(height: 16),
              FeaturedProductsSection(
                products: data.featuredProducts,
                onProductTap: (product) => _handleProductTap(context, product),
                onAddToCart: (product) => _handleAddToCart(context, product),
                onAddToWishlist: (product) => _handleAddToWishlist(context, product),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Recommendations Section
        if (data.recommendations.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  title: 'Recommended for You',
                  titleAr: 'موصى لك',
                  showViewAll: false,
                ),
                const SizedBox(height: 16),
                RecommendationsSection(
                  products: data.recommendations,
                  onProductTap: (product) => _handleProductTap(context, product),
                  onAddToCart: (product) => _handleAddToCart(context, product),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
        
        // New Arrivals Section
        if (data.newArrivals.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  title: 'New Arrivals',
                  titleAr: 'وصل حديثاً',
                  onViewAll: () => context.pushNamed(RouteNames.products, 
                    queryParameters: {'new': 'true'}),
                ),
                const SizedBox(height: 16),
                FeaturedProductsSection(
                  products: data.newArrivals,
                  onProductTap: (product) => _handleProductTap(context, product),
                  onAddToCart: (product) => _handleAddToCart(context, product),
                  onAddToWishlist: (product) => _handleAddToWishlist(context, product),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
        
        // Bottom spacing for navigation bar
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String titleAr,
    VoidCallback? onViewAll,
    bool showViewAll = true,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRTL ? titleAr : title,
              style: NeferTypography.sectionHeader.copyWith(
                color: NeferColors.hieroglyphGray,
              ),
            ),
            Container(
              width: 40,
              height: 3,
              decoration: const BoxDecoration(
                gradient: NeferColors.pharaohGradient,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
          ],
        ),
        if (showViewAll && onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text(
              isRTL ? 'عرض الكل' : 'View All',
              style: NeferTypography.bodyMedium.copyWith(
                color: NeferColors.pharaohGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // Event Handlers
  void _handleBannerTap(BuildContext context, Banner banner) {
    if (banner.actionType == 'product') {
      context.pushNamed(RouteNames.productDetails, 
        pathParameters: {'id': banner.actionValue});
    } else if (banner.actionType == 'category') {
      context.pushNamed(RouteNames.categoryProducts, 
        pathParameters: {'categoryId': banner.actionValue});
    } else if (banner.actionType == 'url') {
      // Handle external URL
    }
  }

  void _handleCategoryTap(BuildContext context, Category category) {
    context.pushNamed(RouteNames.categoryProducts, 
      pathParameters: {'categoryId': category.id});
  }

  void _handleProductTap(BuildContext context, Product product) {
    context.pushNamed(RouteNames.productDetails, 
      pathParameters: {'id': product.id});
  }

  void _handleAddToCart(BuildContext context, Product product) {
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

  void _handleAddToWishlist(BuildContext context, Product product) {
    ref.read(wishlistControllerProvider.notifier).toggleWishlist(product.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to wishlist'),
        backgroundColor: NeferColors.info,
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child: Text('Notifications'),
        ),
      ),
    );
  }
}
