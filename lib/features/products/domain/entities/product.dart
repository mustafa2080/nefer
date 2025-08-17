import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// Product entity
@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required String categoryId,
    required String categoryName,
    required double price,
    double? originalPrice,
    required String currency,
    required ProductMedia media,
    required ProductVariants variants,
    required ProductInventory inventory,
    required ProductAnalytics analytics,
    required ProductSEO seo,
    @Default([]) List<String> tags,
    @Default([]) List<String> features,
    @Default(true) bool isActive,
    @Default(false) bool isFeatured,
    @Default(false) bool isOnSale,
    @Default(false) bool isNew,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}

/// Product media (images, videos)
@freezed
class ProductMedia with _$ProductMedia {
  const factory ProductMedia({
    @Default([]) List<ProductImage> images,
    @Default([]) List<ProductVideo> videos,
    String? thumbnail,
  }) = _ProductMedia;

  factory ProductMedia.fromJson(Map<String, dynamic> json) => _$ProductMediaFromJson(json);
}

/// Product image
@freezed
class ProductImage with _$ProductImage {
  const factory ProductImage({
    required String id,
    required String url,
    String? alt,
    @Default(0) int order,
    @Default(false) bool isPrimary,
  }) = _ProductImage;

  factory ProductImage.fromJson(Map<String, dynamic> json) => _$ProductImageFromJson(json);
}

/// Product video
@freezed
class ProductVideo with _$ProductVideo {
  const factory ProductVideo({
    required String id,
    required String url,
    String? thumbnail,
    String? title,
    @Default(0) int duration,
    @Default(0) int order,
  }) = _ProductVideo;

  factory ProductVideo.fromJson(Map<String, dynamic> json) => _$ProductVideoFromJson(json);
}

/// Product variants (sizes, colors, etc.)
@freezed
class ProductVariants with _$ProductVariants {
  const factory ProductVariants({
    @Default([]) List<ProductSize> sizes,
    @Default([]) List<ProductColor> colors,
    @Default([]) List<ProductAttribute> attributes,
    @Default([]) List<ProductVariant> combinations,
  }) = _ProductVariants;

  factory ProductVariants.fromJson(Map<String, dynamic> json) => _$ProductVariantsFromJson(json);
}

/// Product size
@freezed
class ProductSize with _$ProductSize {
  const factory ProductSize({
    required String id,
    required String name,
    required String displayName,
    String? description,
    @Default(0) int order,
    @Default(true) bool isAvailable,
  }) = _ProductSize;

  factory ProductSize.fromJson(Map<String, dynamic> json) => _$ProductSizeFromJson(json);
}

/// Product color
@freezed
class ProductColor with _$ProductColor {
  const factory ProductColor({
    required String id,
    required String name,
    required String displayName,
    required String hexCode,
    String? imageUrl,
    @Default(0) int order,
    @Default(true) bool isAvailable,
  }) = _ProductColor;

  factory ProductColor.fromJson(Map<String, dynamic> json) => _$ProductColorFromJson(json);
}

/// Product attribute (material, brand, etc.)
@freezed
class ProductAttribute with _$ProductAttribute {
  const factory ProductAttribute({
    required String key,
    required String value,
    String? displayKey,
    String? displayValue,
    @Default(0) int order,
  }) = _ProductAttribute;

  factory ProductAttribute.fromJson(Map<String, dynamic> json) => _$ProductAttributeFromJson(json);
}

/// Product variant combination
@freezed
class ProductVariant with _$ProductVariant {
  const factory ProductVariant({
    required String id,
    String? sizeId,
    String? colorId,
    double? priceAdjustment,
    required int stock,
    String? sku,
    String? barcode,
    @Default(true) bool isAvailable,
  }) = _ProductVariant;

  factory ProductVariant.fromJson(Map<String, dynamic> json) => _$ProductVariantFromJson(json);
}

/// Product inventory
@freezed
class ProductInventory with _$ProductInventory {
  const factory ProductInventory({
    required int stock,
    @Default(0) int reserved,
    @Default(0) int sold,
    @Default(10) int lowStockThreshold,
    @Default(true) bool trackQuantity,
    @Default(true) bool allowBackorder,
    String? sku,
    String? barcode,
    String? supplier,
    double? costPrice,
  }) = _ProductInventory;

  factory ProductInventory.fromJson(Map<String, dynamic> json) => _$ProductInventoryFromJson(json);
}

/// Product analytics
@freezed
class ProductAnalytics with _$ProductAnalytics {
  const factory ProductAnalytics({
    @Default(0) int views,
    @Default(0) int purchases,
    @Default(0) int cartAdditions,
    @Default(0) int wishlistAdditions,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    @Default(0.0) double conversionRate,
    DateTime? lastViewed,
    DateTime? lastPurchased,
  }) = _ProductAnalytics;

  factory ProductAnalytics.fromJson(Map<String, dynamic> json) => _$ProductAnalyticsFromJson(json);
}

/// Product SEO
@freezed
class ProductSEO with _$ProductSEO {
  const factory ProductSEO({
    String? metaTitle,
    String? metaDescription,
    @Default([]) List<String> keywords,
    String? slug,
    String? canonicalUrl,
    @Default({}) Map<String, String> structuredData,
  }) = _ProductSEO;

  factory ProductSEO.fromJson(Map<String, dynamic> json) => _$ProductSEOFromJson(json);
}

// Extensions
extension ProductExtension on Product {
  /// Check if product is on sale
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  
  /// Get discount percentage
  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }
  
  /// Get discount amount
  double get discountAmount {
    if (!hasDiscount) return 0.0;
    return originalPrice! - price;
  }
  
  /// Check if product is in stock
  bool get isInStock => inventory.stock > 0;
  
  /// Check if product is low stock
  bool get isLowStock => inventory.stock <= inventory.lowStockThreshold;
  
  /// Check if product has variants
  bool get hasVariants => variants.sizes.isNotEmpty || variants.colors.isNotEmpty;
  
  /// Get primary image
  ProductImage? get primaryImage {
    if (media.images.isEmpty) return null;
    
    final primary = media.images.where((img) => img.isPrimary).firstOrNull;
    return primary ?? media.images.first;
  }
  
  /// Get all available sizes
  List<ProductSize> get availableSizes {
    return variants.sizes.where((size) => size.isAvailable).toList();
  }
  
  /// Get all available colors
  List<ProductColor> get availableColors {
    return variants.colors.where((color) => color.isAvailable).toList();
  }
  
  /// Get formatted price
  String getFormattedPrice([String? currencySymbol]) {
    final symbol = currencySymbol ?? _getCurrencySymbol(currency);
    return '$symbol${price.toStringAsFixed(2)}';
  }
  
  /// Get formatted original price
  String? getFormattedOriginalPrice([String? currencySymbol]) {
    if (originalPrice == null) return null;
    final symbol = currencySymbol ?? _getCurrencySymbol(currency);
    return '$symbol${originalPrice!.toStringAsFixed(2)}';
  }
  
  /// Get currency symbol
  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'EGP':
        return 'ج.م';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      default:
        return currency;
    }
  }
  
  /// Get stock status
  String get stockStatus {
    if (!inventory.trackQuantity) return 'In Stock';
    if (inventory.stock <= 0) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }
  
  /// Get rating stars
  int get ratingStars => analytics.rating.round();
  
  /// Check if product can be purchased
  bool get canPurchase => isActive && (isInStock || inventory.allowBackorder);
}
