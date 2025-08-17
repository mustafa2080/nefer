import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/providers/providers.dart';
import '../../../../generated/l10n.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_info_section.dart';
import '../widgets/product_variants_selector.dart';
import '../widgets/product_reviews_section.dart';
import '../widgets/product_recommendations.dart';
import '../widgets/product_action_buttons.dart';
import '../controllers/product_details_controller.dart';

/// Product Details Screen with comprehensive product information
/// 
/// Features:
/// - Image gallery with zoom and swipe
/// - Product information and variants
/// - Size and color selection
/// - Reviews and ratings
/// - Add to cart and wishlist
/// - Related products
/// - Return policy information
class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailsScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _showAppBarBackground = false;
  String? _selectedSizeId;
  String? _selectedColorId;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadProductDetails();
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

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

  void _loadProductDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productDetailsControllerProvider(widget.productId).notifier)
          .loadProductDetails();
    });
  }

  void _onScroll() {
    final showBackground = _scrollController.offset > 200;
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
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final productState = ref.watch(productDetailsControllerProvider(widget.productId));
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildContent(context, l10n, productState),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations? l10n,
    ProductDetailsState productState,
  ) {
    return productState.when(
      loading: () => _buildLoadingState(),
      error: (error, _) => _buildErrorState(error.toString()),
      data: (product) => _buildProductDetails(context, l10n, product),
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
            'Loading product details...',
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
            'Failed to load product',
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
              ref.refresh(productDetailsControllerProvider(widget.productId));
            },
            child: const Text('Retry'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(
    BuildContext context,
    AppLocalizations? l10n,
    Product product,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App Bar
        _buildSliverAppBar(context, product),
        
        // Product Content
        SliverList(
          delegate: SliverChildListDelegate([
            // Product Image Gallery
            ProductImageGallery(
              images: product.media.images,
              onImageTap: (index) => _showImageViewer(context, product.media.images, index),
            ),
            
            const SizedBox(height: 16),
            
            // Product Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProductInfoSection(
                product: product,
                onShareTap: () => _shareProduct(product),
                onWishlistTap: () => _toggleWishlist(product),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Product Variants (Size, Color)
            if (product.hasVariants) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ProductVariantsSelector(
                  product: product,
                  selectedSizeId: _selectedSizeId,
                  selectedColorId: _selectedColorId,
                  onSizeSelected: (sizeId) {
                    setState(() {
                      _selectedSizeId = sizeId;
                    });
                  },
                  onColorSelected: (colorId) {
                    setState(() {
                      _selectedColorId = colorId;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Quantity Selector and Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProductActionButtons(
                product: product,
                quantity: _quantity,
                selectedSizeId: _selectedSizeId,
                selectedColorId: _selectedColorId,
                onQuantityChanged: (quantity) {
                  setState(() {
                    _quantity = quantity;
                  });
                },
                onAddToCart: () => _addToCart(product),
                onBuyNow: () => _buyNow(product),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Product Description and Details
            _buildProductDescription(product),
            
            const SizedBox(height: 32),
            
            // Return Policy
            _buildReturnPolicy(l10n),
            
            const SizedBox(height: 32),
            
            // Reviews Section
            ProductReviewsSection(
              productId: product.id,
              averageRating: product.analytics.rating,
              reviewCount: product.analytics.reviewCount,
              onWriteReview: () => _writeReview(product),
              onViewAllReviews: () => _viewAllReviews(product),
            ),
            
            const SizedBox(height: 32),
            
            // Related Products
            ProductRecommendations(
              productId: product.id,
              categoryId: product.categoryId,
              onProductTap: (relatedProduct) => _navigateToProduct(relatedProduct.id),
            ),
            
            const SizedBox(height: 100), // Bottom padding for floating buttons
          ]),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Product product) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: _showAppBarBackground 
          ? Theme.of(context).colorScheme.surface.withOpacity(0.95)
          : Colors.transparent,
      elevation: _showAppBarBackground ? 4 : 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _shareProduct(product),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.share,
              color: Colors.white,
            ),
          ),
        ),
        IconButton(
          onPressed: () => _toggleWishlist(product),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              ref.watch(isInWishlistProvider(product.id)) 
                  ? Icons.favorite 
                  : Icons.favorite_outline,
              color: ref.watch(isInWishlistProvider(product.id)) 
                  ? NeferColors.error 
                  : Colors.white,
            ),
          ),
        ),
      ],
      title: _showAppBarBackground 
          ? Text(
              product.name,
              style: NeferTypography.sectionHeader.copyWith(
                fontSize: 18,
              ),
            )
          : null,
    );
  }

  Widget _buildProductDescription(Product product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            'Product Description',
            style: NeferTypography.sectionHeader.copyWith(
              color: NeferColors.hieroglyphGray,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.description,
            style: NeferTypography.bodyMedium.copyWith(
              height: 1.6,
            ),
          ),
          
          if (product.variants.attributes.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Specifications',
              style: NeferTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: NeferColors.hieroglyphGray,
              ),
            ),
            const SizedBox(height: 12),
            ...product.variants.attributes.map((attribute) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${attribute.key}:',
                      style: NeferTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      attribute.value,
                      style: NeferTypography.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildReturnPolicy(AppLocalizations? l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NeferColors.pharaohGold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: NeferColors.pharaohGold.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_return,
                color: NeferColors.pharaohGold,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Return Policy',
                style: NeferTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: NeferColors.hieroglyphGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Free returns within 30 days\n'
            '• Items must be in original condition\n'
            '• Return shipping is free for defective items\n'
            '• Refund processed within 5-7 business days',
            style: NeferTypography.bodyMedium.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // Event Handlers
  void _showImageViewer(BuildContext context, List<ProductImage> images, int initialIndex) {
    // Implement image viewer with zoom functionality
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _shareProduct(Product product) {
    // Implement product sharing
    // Share.share('Check out this amazing product: ${product.name}');
  }

  void _toggleWishlist(Product product) {
    ref.read(wishlistControllerProvider.notifier).toggleWishlist(product.id);
  }

  void _addToCart(Product product) {
    if (product.hasVariants && (_selectedSizeId == null || _selectedColorId == null)) {
      _showVariantSelectionDialog();
      return;
    }

    ref.read(cartControllerProvider.notifier).addToCart(
      product.id,
      _quantity,
      sizeId: _selectedSizeId,
      colorId: _selectedColorId,
    );

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

  void _buyNow(Product product) {
    _addToCart(product);
    context.pushNamed(RouteNames.checkout);
  }

  void _writeReview(Product product) {
    context.pushNamed(RouteNames.writeReview, 
      pathParameters: {'productId': product.id});
  }

  void _viewAllReviews(Product product) {
    context.pushNamed(RouteNames.productReviews, 
      pathParameters: {'productId': product.id});
  }

  void _navigateToProduct(String productId) {
    context.pushNamed(RouteNames.productDetails, 
      pathParameters: {'id': productId});
  }

  void _showVariantSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Options'),
        content: const Text('Please select size and color before adding to cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Image viewer screen for product images
class ImageViewerScreen extends StatelessWidget {
  final List<ProductImage> images;
  final int initialIndex;

  const ImageViewerScreen({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                images[index].url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 64,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
