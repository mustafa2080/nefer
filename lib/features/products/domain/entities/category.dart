import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// Category entity
@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    String? parentId,
    required String imageUrl,
    required String iconUrl,
    @Default([]) List<Category> subcategories,
    @Default([]) List<String> tags,
    @Default(0) int order,
    @Default(true) bool isActive,
    @Default(false) bool isFeatured,
    @Default(0) int productCount,
    CategorySEO? seo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

/// Category SEO
@freezed
class CategorySEO with _$CategorySEO {
  const factory CategorySEO({
    String? metaTitle,
    String? metaDescription,
    @Default([]) List<String> keywords,
    String? slug,
    String? canonicalUrl,
  }) = _CategorySEO;

  factory CategorySEO.fromJson(Map<String, dynamic> json) => _$CategorySEOFromJson(json);
}

// Extensions
extension CategoryExtension on Category {
  /// Check if category has subcategories
  bool get hasSubcategories => subcategories.isNotEmpty;
  
  /// Check if category is root (no parent)
  bool get isRoot => parentId == null;
  
  /// Get category level (0 for root, 1 for first level, etc.)
  int get level {
    if (isRoot) return 0;
    // This would need to be calculated based on parent hierarchy
    return 1; // Simplified for now
  }
  
  /// Get category path (for breadcrumbs)
  String get path {
    // This would need to be calculated based on parent hierarchy
    return name; // Simplified for now
  }
  
  /// Get SEO-friendly slug
  String get slug {
    return seo?.slug ?? name.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9-]'), '');
  }
  
  /// Get display name based on locale
  String getDisplayName(String locale) {
    return locale == 'ar' ? nameAr : name;
  }
  
  /// Get display description based on locale
  String getDisplayDescription(String locale) {
    return locale == 'ar' ? descriptionAr : description;
  }
  
  /// Check if category has products
  bool get hasProducts => productCount > 0;
  
  /// Get active subcategories
  List<Category> get activeSubcategories {
    return subcategories.where((cat) => cat.isActive).toList();
  }
  
  /// Get featured subcategories
  List<Category> get featuredSubcategories {
    return subcategories.where((cat) => cat.isFeatured && cat.isActive).toList();
  }
}

/// Predefined categories for Egyptian marketplace
class EgyptianCategories {
  static const Category fashion = Category(
    id: 'fashion',
    name: 'Fashion & Clothing',
    nameAr: 'الأزياء والملابس',
    description: 'Trendy fashion and clothing for all occasions',
    descriptionAr: 'أزياء عصرية وملابس لجميع المناسبات',
    imageUrl: 'assets/images/categories/fashion.jpg',
    iconUrl: 'assets/icons/fashion.svg',
    isFeatured: true,
    subcategories: [
      Category(
        id: 'mens-fashion',
        name: 'Men\'s Fashion',
        nameAr: 'أزياء رجالية',
        description: 'Stylish clothing for men',
        descriptionAr: 'ملابس أنيقة للرجال',
        parentId: 'fashion',
        imageUrl: 'assets/images/categories/mens-fashion.jpg',
        iconUrl: 'assets/icons/mens-fashion.svg',
      ),
      Category(
        id: 'womens-fashion',
        name: 'Women\'s Fashion',
        nameAr: 'أزياء نسائية',
        description: 'Elegant clothing for women',
        descriptionAr: 'ملابس أنيقة للنساء',
        parentId: 'fashion',
        imageUrl: 'assets/images/categories/womens-fashion.jpg',
        iconUrl: 'assets/icons/womens-fashion.svg',
      ),
    ],
  );

  static const Category electronics = Category(
    id: 'electronics',
    name: 'Electronics',
    nameAr: 'الإلكترونيات',
    description: 'Latest gadgets and electronic devices',
    descriptionAr: 'أحدث الأجهزة والمعدات الإلكترونية',
    imageUrl: 'assets/images/categories/electronics.jpg',
    iconUrl: 'assets/icons/electronics.svg',
    isFeatured: true,
    subcategories: [
      Category(
        id: 'smartphones',
        name: 'Smartphones',
        nameAr: 'الهواتف الذكية',
        description: 'Latest smartphones and accessories',
        descriptionAr: 'أحدث الهواتف الذكية والإكسسوارات',
        parentId: 'electronics',
        imageUrl: 'assets/images/categories/smartphones.jpg',
        iconUrl: 'assets/icons/smartphones.svg',
      ),
      Category(
        id: 'laptops',
        name: 'Laptops & Computers',
        nameAr: 'أجهزة الكمبيوتر المحمولة',
        description: 'Laptops, desktops and computer accessories',
        descriptionAr: 'أجهزة كمبيوتر محمولة ومكتبية وإكسسوارات',
        parentId: 'electronics',
        imageUrl: 'assets/images/categories/laptops.jpg',
        iconUrl: 'assets/icons/laptops.svg',
      ),
    ],
  );

  static const Category homeGarden = Category(
    id: 'home-garden',
    name: 'Home & Garden',
    nameAr: 'المنزل والحديقة',
    description: 'Everything for your home and garden',
    descriptionAr: 'كل ما تحتاجه لمنزلك وحديقتك',
    imageUrl: 'assets/images/categories/home-garden.jpg',
    iconUrl: 'assets/icons/home-garden.svg',
    isFeatured: true,
  );

  static const Category beauty = Category(
    id: 'beauty',
    name: 'Beauty & Personal Care',
    nameAr: 'الجمال والعناية الشخصية',
    description: 'Beauty products and personal care items',
    descriptionAr: 'منتجات التجميل وأدوات العناية الشخصية',
    imageUrl: 'assets/images/categories/beauty.jpg',
    iconUrl: 'assets/icons/beauty.svg',
    isFeatured: true,
  );

  static const Category sports = Category(
    id: 'sports',
    name: 'Sports & Outdoors',
    nameAr: 'الرياضة والأنشطة الخارجية',
    description: 'Sports equipment and outdoor gear',
    descriptionAr: 'معدات رياضية وأدوات الأنشطة الخارجية',
    imageUrl: 'assets/images/categories/sports.jpg',
    iconUrl: 'assets/icons/sports.svg',
  );

  static const Category books = Category(
    id: 'books',
    name: 'Books & Media',
    nameAr: 'الكتب والوسائط',
    description: 'Books, magazines, and digital media',
    descriptionAr: 'كتب ومجلات ووسائط رقمية',
    imageUrl: 'assets/images/categories/books.jpg',
    iconUrl: 'assets/icons/books.svg',
  );

  static const Category automotive = Category(
    id: 'automotive',
    name: 'Automotive',
    nameAr: 'السيارات',
    description: 'Car parts and automotive accessories',
    descriptionAr: 'قطع غيار السيارات والإكسسوارات',
    imageUrl: 'assets/images/categories/automotive.jpg',
    iconUrl: 'assets/icons/automotive.svg',
  );

  static const Category toys = Category(
    id: 'toys',
    name: 'Toys & Games',
    nameAr: 'الألعاب',
    description: 'Toys and games for all ages',
    descriptionAr: 'ألعاب وتسلية لجميع الأعمار',
    imageUrl: 'assets/images/categories/toys.jpg',
    iconUrl: 'assets/icons/toys.svg',
  );

  static const Category food = Category(
    id: 'food',
    name: 'Food & Beverages',
    nameAr: 'الطعام والمشروبات',
    description: 'Fresh food and beverages',
    descriptionAr: 'طعام طازج ومشروبات',
    imageUrl: 'assets/images/categories/food.jpg',
    iconUrl: 'assets/icons/food.svg',
  );

  static const Category jewelry = Category(
    id: 'jewelry',
    name: 'Jewelry & Accessories',
    nameAr: 'المجوهرات والإكسسوارات',
    description: 'Fine jewelry and fashion accessories',
    descriptionAr: 'مجوهرات فاخرة وإكسسوارات الموضة',
    imageUrl: 'assets/images/categories/jewelry.jpg',
    iconUrl: 'assets/icons/jewelry.svg',
  );

  /// Get all predefined categories
  static List<Category> get allCategories => [
    fashion,
    electronics,
    homeGarden,
    beauty,
    sports,
    books,
    automotive,
    toys,
    food,
    jewelry,
  ];

  /// Get featured categories
  static List<Category> get featuredCategories => 
    allCategories.where((cat) => cat.isFeatured).toList();

  /// Get category by ID
  static Category? getCategoryById(String id) {
    try {
      return allCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search categories by name
  static List<Category> searchCategories(String query, [String locale = 'en']) {
    final lowerQuery = query.toLowerCase();
    return allCategories.where((cat) {
      final name = locale == 'ar' ? cat.nameAr : cat.name;
      return name.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
