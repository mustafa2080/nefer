# Nefer (نفِر) - Pharaonic E-commerce App Blueprint
## Production-Ready Implementation Guide

### Executive Summary
Nefer is a luxury Pharaonic-themed e-commerce mobile application built with Flutter, targeting Android and iOS platforms. The app combines ancient Egyptian elegance with modern commerce functionality, featuring a comprehensive admin dashboard, offline-first architecture, and enterprise-grade security.

**Key Metrics Target:**
- Cold start: <2s
- Frame budget: 16ms (60fps)
- Offline capability: 80% of features
- Multi-language: Arabic (RTL) + English
- Platform coverage: Android 7+ (API 24+), iOS 12+

---

## 1. App Identity & Brand Guidelines

### Brand Narrative
"Nefer" (نفِر) embodies the timeless elegance of ancient Egyptian civilization, where pharaohs ruled with divine authority and artisans created treasures that lasted millennia. The app transforms modern e-commerce into a luxurious journey through digital bazaars, where every interaction feels like discovering artifacts in a royal tomb.

**Design Principles:**
1. **Regal Elegance**: Every element should feel worthy of a pharaoh
2. **Mystical Discovery**: Shopping as archaeological exploration
3. **Timeless Luxury**: Premium feel without ostentation
4. **Cultural Respect**: Authentic Egyptian motifs, not stereotypes
5. **Modern Functionality**: Ancient aesthetics, contemporary UX

### Color Palette & Tokens

```dart
// lib/core/theme/app_colors.dart
class NeferColors {
  // Primary Pharaonic Palette
  static const Color pharaohGold = Color(0xFFD4AF37);      // Primary gold
  static const Color lapisBlue = Color(0xFF1E3A8A);        // Deep royal blue
  static const Color sandstoneBeige = Color(0xFFF5E6D3);   // Warm neutral
  static const Color turquoiseAccent = Color(0xFF40E0D0);  // Highlight color
  static const Color papyrusWhite = Color(0xFFFAF7F0);     // Off-white
  static const Color hieroglyphGray = Color(0xFF4A5568);   // Text secondary
  
  // Dark Mode Variants
  static const Color darkPharaohGold = Color(0xFFB8941F);
  static const Color darkLapisBlue = Color(0xFF0F1419);
  static const Color darkSandstone = Color(0xFF2D2A26);
  static const Color darkTurquoise = Color(0xFF2DD4BF);
  static const Color darkPapyrus = Color(0xFF1A1A1A);
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Gradients
  static const LinearGradient pharaohGradient = LinearGradient(
    colors: [pharaohGold, Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient mysticalGradient = LinearGradient(
    colors: [lapisBlue, Color(0xFF1E40AF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
```

### Typography System

```dart
// lib/core/theme/app_typography.dart
class NeferTypography {
  // Display fonts for headers (Pharaonic feel)
  static const String displayFont = 'Cinzel'; // Elegant serif
  static const String bodyFont = 'Inter';     // Modern sans-serif
  static const String arabicFont = 'Amiri';   // Arabic typography
  
  // Text Styles
  static const TextStyle pharaohTitle = TextStyle(
    fontFamily: displayFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    height: 1.2,
  );
  
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: displayFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
}
```

### Iconography & Motifs

**Icon Strategy:**
- Primary: Custom Pharaonic-inspired icons (ankh, scarab, eye of Horus)
- Secondary: Material Design 3 icons for functionality
- Decorative: Hieroglyphic dividers, papyrus textures, lotus borders

**Animation Motifs:**
- Scarab beetles for loading states
- Papyrus unfurling for page transitions
- Golden shimmer for premium interactions
- Sand particle effects for empty states

---

## 2. Information Architecture & Navigation

### Navigation Structure

```
Bottom Navigation (5 tabs):
├── Home (🏛️ Temple icon)
├── Categories (📜 Scroll icon) 
├── Cart (🏺 Amphora icon)
├── Orders (⚱️ Canopic jar icon)
└── Profile (👤 Pharaoh mask icon)

Global Elements:
├── Search (🔍 Magnifying glass in AppBar)
├── Wishlist (♥️ Heart - floating action)
├── Notifications (🔔 Bell with badge)
└── Settings (⚙️ Gear in profile)
```

### Animated AppBar Concept

**"Wings of Horus" AppBar:**
- Collapsed: Simple title with golden accent
- Expanded: Animated wings spread from center
- Parallax: Background hieroglyphs scroll at different speeds
- Hero transitions: Product images fly into AppBar space

```dart
// Pseudo-code for animated AppBar
class PharaohAppBar extends StatefulWidget {
  final String title;
  final bool showWings;
  final VoidCallback? onSearchTap;
  
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: showWings ? 200 : 80,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedWingsBackground(),
        title: HieroglyphicTitle(title),
        centerTitle: true,
      ),
      actions: [
        SearchIconButton(onTap: onSearchTap),
        NotificationBell(),
      ],
    );
  }
}
```

### Deep Linking Strategy

```
nefer://
├── product/{productId}
├── category/{categoryId}
├── order/{orderId}
├── flash-sale/{saleId}
├── coupon/{couponCode}
├── chat/{conversationId}
└── admin/{section}
```

---

## 3. System Architecture Overview

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    NEFER ARCHITECTURE                       │
├─────────────────────────────────────────────────────────────┤
│  PRESENTATION LAYER                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Mobile    │  │   Tablet    │  │  Admin Web  │        │
│  │   Flutter   │  │   Flutter   │  │   Flutter   │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│  STATE MANAGEMENT (Riverpod)                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Auth State  │  │ Cart State  │  │ Product     │        │
│  │ Provider    │  │ Provider    │  │ State       │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│  BUSINESS LOGIC LAYER                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Auth Repo   │  │ Product     │  │ Order Repo  │        │
│  │             │  │ Repo        │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│  DATA LAYER                                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Firebase    │  │ Local Cache │  │ External    │        │
│  │ Services    │  │ (Hive)      │  │ APIs        │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│  FIREBASE BACKEND                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Realtime    │  │ Cloud       │  │ Storage     │        │
│  │ Database    │  │ Functions   │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

### State Management Choice: Riverpod

**Why Riverpod over Bloc:**
1. **Compile-time safety**: Eliminates runtime provider errors
2. **Better testing**: Easy mocking and overrides
3. **Less boilerplate**: More concise than Bloc events/states
4. **Auto-disposal**: Automatic memory management
5. **DevTools integration**: Excellent debugging experience

---

## 4. Project Structure

```
nefer/
├── android/                     # Android-specific files
├── ios/                        # iOS-specific files
├── web/                        # Web admin dashboard
├── lib/
│   ├── main.dart              # App entry point
│   ├── app.dart               # App widget with routing
│   ├── core/                  # Core utilities and shared code
│   │   ├── constants/         # App constants
│   │   ├── theme/            # Theme and styling
│   │   ├── utils/            # Utility functions
│   │   ├── extensions/       # Dart extensions
│   │   ├── errors/           # Error handling
│   │   └── network/          # Network utilities
│   ├── features/             # Feature-based modules
│   │   ├── auth/             # Authentication
│   │   ├── home/             # Home screen
│   │   ├── products/         # Product catalog
│   │   ├── cart/             # Shopping cart
│   │   ├── orders/           # Order management
│   │   ├── profile/          # User profile
│   │   ├── admin/            # Admin dashboard
│   │   └── shared/           # Shared widgets
│   ├── data/                 # Data layer
│   │   ├── models/           # Data models
│   │   ├── repositories/     # Repository implementations
│   │   ├── datasources/      # Data sources (remote/local)
│   │   └── services/         # External services
│   └── generated/            # Generated files (l10n, etc.)
├── assets/                   # Static assets
│   ├── images/              # Image assets
│   ├── icons/               # Custom icons
│   ├── fonts/               # Custom fonts
│   └── animations/          # Lottie animations
├── test/                    # Unit and widget tests
├── integration_test/        # Integration tests
├── docs/                    # Documentation
└── scripts/                 # Build and deployment scripts
```

---

## 5. Screen-by-Screen Specifications

### 5.1 Splash Screen

**Purpose**: Brand introduction with loading states
**Duration**: 2-3 seconds maximum

**Widget Tree:**
```
Scaffold
└── AnimatedContainer
    ├── BackgroundGradient (mysticalGradient)
    ├── Center
    │   ├── Column
    │   │   ├── AnimatedLogo (scarab transformation)
    │   │   ├── SizedBox(height: 24)
    │   │   ├── Text("نفِر" / "Nefer")
    │   │   └── SizedBox(height: 32)
    │   └── LoadingIndicator (golden scarab spinner)
    └── Positioned (bottom: safe area)
        └── Text("Powered by Ancient Wisdom")
```

**Animations:**
- Logo: Scarab unfolds wings (1.5s, Curves.easeOutCubic)
- Text: Fade in with slight scale (0.5s delay)
- Background: Subtle particle effect

**States:**
- Loading: Show spinner
- Error: Retry button with error message
- Success: Navigate to appropriate screen

**Analytics Events:**
```dart
Analytics.logEvent('app_open', {
  'timestamp': DateTime.now().toIso8601String(),
  'platform': Platform.operatingSystem,
  'app_version': packageInfo.version,
});
```

### 5.2 Authentication Screens

#### Login Screen

**User Stories:**
- As a user, I want to login with email/password
- As a user, I want to login with social providers
- As a user, I want to reset my password
- As a user, I want to remember my login

**Widget Tree:**
```
Scaffold
├── SafeArea
├── SingleChildScrollView
│   └── Padding
│       └── Column
│           ├── PharaohAppBar(title: "Welcome Back")
│           ├── SizedBox(height: 32)
│           ├── HieroglyphicDivider()
│           ├── LoginForm
│           │   ├── EmailField (with pharaoh icon)
│           │   ├── PasswordField (with ankh icon)
│           │   ├── RememberMeCheckbox
│           │   └── LoginButton (golden gradient)
│           ├── SocialLoginSection
│           │   ├── GoogleSignInButton
│           │   ├── AppleSignInButton (iOS only)
│           │   └── FacebookSignInButton
│           ├── ForgotPasswordLink
│           └── SignUpPrompt
└── LoadingOverlay (when authenticating)
```

**Form Validation:**
```dart
class LoginValidation {
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'Password is required';
    if (value!.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}
```

**States:**
- Idle: Form ready for input
- Loading: Show spinner, disable inputs
- Error: Show error message with retry
- Success: Navigate to home

**Animations:**
- Form fields: Slide up with stagger (0.1s intervals)
- Error messages: Shake animation
- Success: Confetti scarab effect

#### Register Screen

**Additional Fields:**
- Full Name (with validation)
- Phone Number (with country picker)
- Terms & Conditions checkbox
- Marketing consent checkbox

**Validation Rules:**
- Name: 2-50 characters, letters and spaces only
- Phone: Valid international format
- Password: 8+ chars, 1 uppercase, 1 number, 1 special char

### 5.3 Home Screen

**Purpose**: Product discovery and navigation hub

**Widget Tree:**
```
Scaffold
├── NestedScrollView
│   ├── SliverAppBar (Wings of Horus)
│   │   ├── SearchBar
│   │   ├── NotificationBell
│   │   └── CartIcon (with badge)
│   └── SliverList
│       ├── WelcomeSection
│       │   ├── PersonalizedGreeting
│       │   └── WeatherWidget (Cairo time)
│       ├── FlashSalesCarousel
│       │   └── CountdownTimer
│       ├── CategoriesGrid (2x3)
│       ├── RecommendedProducts
│       │   └── HorizontalProductList
│       ├── TrendingSection
│       ├── RecentlyViewedSection
│       └── PromotionalBanner
└── FloatingActionButton (Wishlist quick access)
```

**Skeleton Loading:**
```dart
class HomeScreenSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShimmerContainer(height: 200), // Flash sales
        SizedBox(height: 16),
        ShimmerGrid(itemCount: 6, aspectRatio: 1.2), // Categories
        SizedBox(height: 16),
        ShimmerList(itemCount: 5, height: 280), // Products
      ],
    );
  }
}
```

**Personalization Logic:**
- Time-based greetings (Good morning/afternoon/evening)
- Weather integration for seasonal products
- Recently viewed products (last 10)
- Recommendations based on browsing history

### 5.4 Product List Screen

**Purpose**: Browse products by category or search

**Widget Tree:**
```
Scaffold
├── SliverAppBar
│   ├── CategoryTitle
│   ├── SearchField
│   └── FilterButton
├── SliverPersistentHeader
│   └── SortAndFilterBar
│       ├── SortDropdown
│       ├── FilterChips
│       └── ViewToggle (grid/list)
└── SliverGrid/SliverList
    └── ProductCard (with animations)
```

**Filter Options:**
- Price range (slider with min/max)
- Brand (multi-select)
- Rating (4+ stars, 3+ stars, etc.)
- Discount (on sale, 50%+ off, etc.)
- Size (for clothing)
- Color (color picker)
- Availability (in stock only)

**Sort Options:**
- Relevance (default)
- Price: Low to High
- Price: High to Low
- Customer Rating
- Newest First
- Best Selling

**Infinite Scroll Implementation:**
```dart
class ProductListController extends StateNotifier<ProductListState> {
  static const int pageSize = 20;

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final products = await productRepository.getProducts(
        offset: state.products.length,
        limit: pageSize,
        filters: state.filters,
        sortBy: state.sortBy,
      );

      state = state.copyWith(
        products: [...state.products, ...products],
        hasMore: products.length == pageSize,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
```

### 5.5 Product Details Screen

**Purpose**: Detailed product information and purchase decision

**Widget Tree:**
```
Scaffold
├── CustomScrollView
│   ├── SliverAppBar
│   │   ├── ProductImageCarousel
│   │   ├── WishlistButton
│   │   └── ShareButton
│   ├── SliverToBoxAdapter
│   │   ├── ProductInfo
│   │   │   ├── Title & Brand
│   │   │   ├── PriceSection (with discount)
│   │   │   ├── RatingAndReviews
│   │   │   └── AvailabilityStatus
│   │   ├── VariantSelector (size, color)
│   │   ├── QuantitySelector
│   │   ├── ActionButtons
│   │   │   ├── AddToCartButton
│   │   │   └── BuyNowButton
│   │   ├── ProductDescription
│   │   ├── SpecificationTable
│   │   ├── ReviewsSection
│   │   └── RecommendedProducts
│   └── SliverFillRemaining
└── BottomSheet (when adding to cart)
    └── CartSuccessAnimation
```

**Image Carousel Features:**
- Pinch to zoom
- Swipe navigation
- Thumbnail strip
- Full-screen mode
- 360° view (if available)

**Variant Selection Logic:**
```dart
class ProductVariantController extends StateNotifier<ProductVariantState> {
  void selectSize(String size) {
    final updatedVariant = state.selectedVariant.copyWith(size: size);
    final availability = checkAvailability(updatedVariant);

    state = state.copyWith(
      selectedVariant: updatedVariant,
      isAvailable: availability.inStock,
      estimatedDelivery: availability.deliveryDate,
      price: calculatePrice(updatedVariant),
    );
  }

  void selectColor(String color) {
    final updatedVariant = state.selectedVariant.copyWith(color: color);
    final availability = checkAvailability(updatedVariant);

    state = state.copyWith(
      selectedVariant: updatedVariant,
      isAvailable: availability.inStock,
      estimatedDelivery: availability.deliveryDate,
      price: calculatePrice(updatedVariant),
      selectedImages: getImagesForColor(color),
    );
  }
}
```

**Add to Cart Animation:**
```dart
class AddToCartAnimation extends StatefulWidget {
  final Product product;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Transform.translate(
            offset: Offset(
              slideAnimation.value * MediaQuery.of(context).size.width,
              0,
            ),
            child: Container(
              // Product card flying to cart
            ),
          ),
        );
      },
    );
  }
}
```

### 5.6 Shopping Cart Screen

**Purpose**: Review selected items before checkout

**Widget Tree:**
```
Scaffold
├── AppBar (title: "Your Cart")
├── CartItemsList
│   └── CartItemCard
│       ├── ProductImage
│       ├── ProductDetails
│       ├── QuantityControls
│       ├── PriceDisplay
│       └── RemoveButton
├── CouponSection
│   ├── CouponInput
│   └── AppliedCoupons
├── PriceSummary
│   ├── SubtotalRow
│   ├── DiscountRow
│   ├── ShippingRow
│   ├── TaxRow
│   └── TotalRow
└── CheckoutButton
```

**Cart Persistence Strategy:**
```dart
class CartRepository {
  // Anonymous cart (local storage)
  Future<void> saveAnonymousCart(Cart cart) async {
    await hiveBox.put('anonymous_cart', cart.toJson());
  }

  // Authenticated cart (Firebase + local sync)
  Future<void> syncAuthenticatedCart(String userId, Cart cart) async {
    // Save to Firebase
    await database.ref('carts/$userId').set(cart.toJson());
    // Update local cache
    await hiveBox.put('cart_$userId', cart.toJson());
  }

  // Merge carts when user logs in
  Future<Cart> mergeAnonymousCart(String userId) async {
    final anonymousCart = await getAnonymousCart();
    final userCart = await getUserCart(userId);

    return Cart.merge(anonymousCart, userCart);
  }
}
```

### 5.7 Checkout & Payment Screen

**Purpose**: Complete purchase with payment processing

**Multi-Step Checkout Flow:**
1. **Shipping Address**
2. **Delivery Options**
3. **Payment Method**
4. **Order Review**
5. **Payment Processing**
6. **Order Confirmation**

**Payment Integration (Stripe Example):**
```dart
class PaymentService {
  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required PaymentMethod paymentMethod,
    required Order order,
  }) async {
    try {
      // Create payment intent via Cloud Function
      final paymentIntent = await createPaymentIntent(
        amount: (amount * 100).round(), // Convert to cents
        currency: currency,
        orderId: order.id,
      );

      // Confirm payment with Stripe
      final result = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntent.clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: order.billingAddress.toBillingDetails(),
          ),
        ),
      );

      if (result.status == PaymentIntentStatus.Succeeded) {
        // Update order status
        await orderRepository.updateOrderStatus(
          order.id,
          OrderStatus.paid,
        );

        // Generate invoice
        await generateInvoice(order);

        return PaymentResult.success(result.paymentIntent!.id);
      }

      return PaymentResult.failed(result.status.toString());
    } catch (e) {
      return PaymentResult.error(e.toString());
    }
  }
}
```

### 5.8 Order Tracking Screen

**Purpose**: Real-time order status and delivery tracking

**Order Status Flow:**
```
Created → Paid → Confirmed → Packed → Shipped → Out for Delivery → Delivered
                    ↓
                 Cancelled (before packed)
                    ↓
                 Refunded
```

**Widget Tree:**
```
Scaffold
├── AppBar (title: "Order #12345")
├── OrderStatusTimeline
│   ├── StatusStep (created)
│   ├── StatusStep (paid)
│   ├── StatusStep (confirmed)
│   ├── StatusStep (packed)
│   ├── StatusStep (shipped)
│   ├── StatusStep (out_for_delivery)
│   └── StatusStep (delivered)
├── DeliveryInfo
│   ├── EstimatedDelivery
│   ├── TrackingNumber
│   └── CourierInfo
├── OrderItems
└── ActionButtons
    ├── CancelOrderButton (if applicable)
    ├── ContactSupportButton
    └── ReorderButton
```

**Real-time Updates:**
```dart
class OrderTrackingController extends StateNotifier<OrderTrackingState> {
  StreamSubscription? _orderSubscription;

  void startTracking(String orderId) {
    _orderSubscription = database
        .ref('orders/$orderId')
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        final order = Order.fromJson(event.snapshot.value as Map);
        state = state.copyWith(order: order);

        // Send push notification for status changes
        if (order.status != state.order?.status) {
          _sendStatusUpdateNotification(order);
        }
      }
    });
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
}
```

---

## 6. Data Models & Firebase Structure

### 6.1 Realtime Database Schema

**Database Structure:**
```json
{
  "users": {
    "userId": {
      "profile": {
        "email": "user@example.com",
        "displayName": "John Doe",
        "phoneNumber": "+1234567890",
        "photoURL": "https://...",
        "preferredLanguage": "en",
        "theme": "light",
        "createdAt": "2024-01-01T00:00:00Z",
        "lastLoginAt": "2024-01-15T10:30:00Z"
      },
      "addresses": {
        "addressId": {
          "type": "home|work|other",
          "name": "Home Address",
          "street": "123 Main St",
          "city": "Cairo",
          "state": "Cairo Governorate",
          "country": "Egypt",
          "postalCode": "12345",
          "isDefault": true
        }
      },
      "preferences": {
        "notifications": {
          "orderUpdates": true,
          "promotions": false,
          "newProducts": true
        },
        "privacy": {
          "shareData": false,
          "personalizedAds": true
        }
      }
    }
  },

  "products": {
    "productId": {
      "basic": {
        "name": "Pharaoh's Golden Necklace",
        "nameAr": "قلادة الفرعون الذهبية",
        "description": "Exquisite golden necklace...",
        "descriptionAr": "قلادة ذهبية رائعة...",
        "brand": "Ancient Treasures",
        "category": "jewelry",
        "subcategory": "necklaces",
        "sku": "AT-GN-001",
        "status": "active|inactive|out_of_stock",
        "createdAt": "2024-01-01T00:00:00Z",
        "updatedAt": "2024-01-15T10:30:00Z"
      },
      "pricing": {
        "basePrice": 299.99,
        "salePrice": 249.99,
        "currency": "USD",
        "discountPercentage": 16.67,
        "taxRate": 0.14
      },
      "inventory": {
        "totalStock": 50,
        "reservedStock": 5,
        "availableStock": 45,
        "lowStockThreshold": 10,
        "variants": {
          "variantId": {
            "size": "M",
            "color": "Gold",
            "sku": "AT-GN-001-M-GOLD",
            "stock": 15,
            "priceAdjustment": 0
          }
        }
      },
      "media": {
        "images": [
          {
            "url": "https://storage.googleapis.com/...",
            "alt": "Front view",
            "order": 0,
            "isMain": true
          }
        ],
        "videos": [
          {
            "url": "https://storage.googleapis.com/...",
            "thumbnail": "https://storage.googleapis.com/...",
            "duration": 30
          }
        ]
      },
      "attributes": {
        "material": "18k Gold",
        "weight": "25g",
        "dimensions": "45cm length",
        "care": "Clean with soft cloth"
      },
      "seo": {
        "metaTitle": "Pharaoh's Golden Necklace - Ancient Treasures",
        "metaDescription": "Discover the elegance...",
        "keywords": ["jewelry", "necklace", "gold", "pharaoh"]
      },
      "analytics": {
        "views": 1250,
        "purchases": 45,
        "conversionRate": 3.6,
        "averageRating": 4.7,
        "reviewCount": 23
      }
    }
  },

  "categories": {
    "categoryId": {
      "name": "Jewelry",
      "nameAr": "المجوهرات",
      "description": "Exquisite jewelry collection",
      "descriptionAr": "مجموعة مجوهرات رائعة",
      "parentId": null,
      "level": 0,
      "order": 1,
      "isActive": true,
      "image": "https://storage.googleapis.com/...",
      "icon": "jewelry_icon",
      "subcategories": ["necklaces", "rings", "bracelets"]
    }
  },

  "carts": {
    "userId": {
      "items": {
        "itemId": {
          "productId": "product123",
          "variantId": "variant456",
          "quantity": 2,
          "unitPrice": 249.99,
          "totalPrice": 499.98,
          "addedAt": "2024-01-15T10:30:00Z"
        }
      },
      "summary": {
        "itemCount": 3,
        "subtotal": 749.97,
        "discount": 50.00,
        "shipping": 15.00,
        "tax": 105.00,
        "total": 819.97
      },
      "appliedCoupons": ["WELCOME10"],
      "updatedAt": "2024-01-15T10:35:00Z"
    }
  },

  "orders": {
    "orderId": {
      "basic": {
        "orderNumber": "NF-2024-001234",
        "userId": "user123",
        "status": "delivered",
        "createdAt": "2024-01-10T14:30:00Z",
        "updatedAt": "2024-01-15T16:45:00Z"
      },
      "items": {
        "itemId": {
          "productId": "product123",
          "variantId": "variant456",
          "quantity": 2,
          "unitPrice": 249.99,
          "totalPrice": 499.98,
          "productSnapshot": {
            "name": "Pharaoh's Golden Necklace",
            "image": "https://storage.googleapis.com/..."
          }
        }
      },
      "pricing": {
        "subtotal": 749.97,
        "discount": 50.00,
        "shipping": 15.00,
        "tax": 105.00,
        "total": 819.97,
        "currency": "USD"
      },
      "shipping": {
        "address": {
          "name": "John Doe",
          "street": "123 Main St",
          "city": "Cairo",
          "country": "Egypt",
          "postalCode": "12345"
        },
        "method": "standard",
        "estimatedDelivery": "2024-01-17T00:00:00Z",
        "trackingNumber": "TN123456789",
        "courier": "DHL"
      },
      "payment": {
        "method": "card",
        "status": "completed",
        "transactionId": "txn_123456",
        "paidAt": "2024-01-10T14:32:00Z"
      },
      "timeline": {
        "created": "2024-01-10T14:30:00Z",
        "paid": "2024-01-10T14:32:00Z",
        "confirmed": "2024-01-10T15:00:00Z",
        "packed": "2024-01-11T09:00:00Z",
        "shipped": "2024-01-11T16:00:00Z",
        "out_for_delivery": "2024-01-15T08:00:00Z",
        "delivered": "2024-01-15T16:45:00Z"
      }
    }
  },

  "reviews": {
    "productId": {
      "reviewId": {
        "userId": "user123",
        "rating": 5,
        "title": "Amazing quality!",
        "comment": "This necklace exceeded my expectations...",
        "verified": true,
        "helpful": 12,
        "reported": 0,
        "createdAt": "2024-01-12T10:00:00Z",
        "images": ["https://storage.googleapis.com/..."],
        "response": {
          "adminId": "admin456",
          "message": "Thank you for your feedback!",
          "respondedAt": "2024-01-13T09:00:00Z"
        }
      }
    }
  },

  "coupons": {
    "couponId": {
      "code": "WELCOME10",
      "type": "percentage|fixed",
      "value": 10,
      "minOrderValue": 100,
      "maxDiscount": 50,
      "usageLimit": 1000,
      "usedCount": 245,
      "userLimit": 1,
      "validFrom": "2024-01-01T00:00:00Z",
      "validUntil": "2024-12-31T23:59:59Z",
      "isActive": true,
      "applicableCategories": ["jewelry", "clothing"],
      "excludedProducts": ["product789"]
    }
  },

  "flash_sales": {
    "saleId": {
      "name": "Pharaoh's Weekend Sale",
      "description": "Exclusive weekend discounts",
      "startTime": "2024-01-20T00:00:00Z",
      "endTime": "2024-01-21T23:59:59Z",
      "isActive": true,
      "products": {
        "productId": {
          "originalPrice": 299.99,
          "salePrice": 199.99,
          "discountPercentage": 33.33,
          "stockLimit": 20,
          "soldCount": 8
        }
      }
    }
  },

  "notifications": {
    "userId": {
      "notificationId": {
        "type": "order_update|promotion|general",
        "title": "Order Shipped!",
        "body": "Your order #NF-2024-001234 has been shipped",
        "data": {
          "orderId": "order123",
          "deepLink": "nefer://order/order123"
        },
        "isRead": false,
        "createdAt": "2024-01-15T10:00:00Z"
      }
    }
  },

  "chat": {
    "conversationId": {
      "userId": "user123",
      "status": "active|closed|escalated",
      "assignedAgent": "agent456",
      "createdAt": "2024-01-15T14:00:00Z",
      "lastMessageAt": "2024-01-15T14:30:00Z",
      "messages": {
        "messageId": {
          "senderId": "user123",
          "senderType": "user|agent|bot",
          "content": "I need help with my order",
          "type": "text|image|file",
          "timestamp": "2024-01-15T14:00:00Z",
          "isRead": true
        }
      }
    }
  },

  "complaints": {
    "complaintId": {
      "userId": "user123",
      "orderId": "order123",
      "type": "product_quality|delivery|service|other",
      "priority": "low|medium|high|urgent",
      "status": "open|in_progress|resolved|closed",
      "title": "Product arrived damaged",
      "description": "The necklace arrived with scratches...",
      "attachments": ["https://storage.googleapis.com/..."],
      "assignedTo": "support123",
      "createdAt": "2024-01-16T09:00:00Z",
      "resolvedAt": null,
      "resolution": null
    }
  },

  "app_config": {
    "features": {
      "flashSalesEnabled": true,
      "chatbotEnabled": true,
      "reviewsEnabled": true,
      "wishlistEnabled": true,
      "recommendationsEnabled": true
    },
    "maintenance": {
      "isActive": false,
      "message": "We're updating our systems...",
      "estimatedEnd": "2024-01-20T02:00:00Z"
    },
    "versions": {
      "minSupportedVersion": "1.0.0",
      "latestVersion": "1.2.0",
      "forceUpdate": false
    }
  }
}
```

### 6.2 Data Model Classes

```dart
// lib/data/models/product.dart
class Product {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String brand;
  final String category;
  final String subcategory;
  final String sku;
  final ProductStatus status;
  final ProductPricing pricing;
  final ProductInventory inventory;
  final ProductMedia media;
  final Map<String, dynamic> attributes;
  final ProductAnalytics analytics;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.brand,
    required this.category,
    required this.subcategory,
    required this.sku,
    required this.status,
    required this.pricing,
    required this.inventory,
    required this.media,
    required this.attributes,
    required this.analytics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['basic']['name'] as String,
      nameAr: json['basic']['nameAr'] as String,
      description: json['basic']['description'] as String,
      descriptionAr: json['basic']['descriptionAr'] as String,
      brand: json['basic']['brand'] as String,
      category: json['basic']['category'] as String,
      subcategory: json['basic']['subcategory'] as String,
      sku: json['basic']['sku'] as String,
      status: ProductStatus.fromString(json['basic']['status']),
      pricing: ProductPricing.fromJson(json['pricing']),
      inventory: ProductInventory.fromJson(json['inventory']),
      media: ProductMedia.fromJson(json['media']),
      attributes: Map<String, dynamic>.from(json['attributes']),
      analytics: ProductAnalytics.fromJson(json['analytics']),
      createdAt: DateTime.parse(json['basic']['createdAt']),
      updatedAt: DateTime.parse(json['basic']['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'basic': {
        'name': name,
        'nameAr': nameAr,
        'description': description,
        'descriptionAr': descriptionAr,
        'brand': brand,
        'category': category,
        'subcategory': subcategory,
        'sku': sku,
        'status': status.value,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      },
      'pricing': pricing.toJson(),
      'inventory': inventory.toJson(),
      'media': media.toJson(),
      'attributes': attributes,
      'analytics': analytics.toJson(),
    };
  }
}

enum ProductStatus {
  active('active'),
  inactive('inactive'),
  outOfStock('out_of_stock');

  const ProductStatus(this.value);
  final String value;

  static ProductStatus fromString(String value) {
    return ProductStatus.values.firstWhere((e) => e.value == value);
  }
}

class ProductPricing {
  final double basePrice;
  final double? salePrice;
  final String currency;
  final double? discountPercentage;
  final double taxRate;

  const ProductPricing({
    required this.basePrice,
    this.salePrice,
    required this.currency,
    this.discountPercentage,
    required this.taxRate,
  });

  double get effectivePrice => salePrice ?? basePrice;
  bool get isOnSale => salePrice != null && salePrice! < basePrice;

  factory ProductPricing.fromJson(Map<String, dynamic> json) {
    return ProductPricing(
      basePrice: (json['basePrice'] as num).toDouble(),
      salePrice: json['salePrice'] != null
          ? (json['salePrice'] as num).toDouble()
          : null,
      currency: json['currency'] as String,
      discountPercentage: json['discountPercentage'] != null
          ? (json['discountPercentage'] as num).toDouble()
          : null,
      taxRate: (json['taxRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basePrice': basePrice,
      'salePrice': salePrice,
      'currency': currency,
      'discountPercentage': discountPercentage,
      'taxRate': taxRate,
    };
  }
}
```

---

## 7. Security & Firebase Rules

### 7.1 Realtime Database Security Rules

```javascript
// database.rules.json
{
  "rules": {
    // Public read access for products and categories
    "products": {
      ".read": true,
      ".write": "auth != null && (auth.token.role == 'admin' || auth.token.role == 'owner')",
      "$productId": {
        "analytics": {
          "views": {
            ".write": "auth != null" // Allow authenticated users to increment views
          }
        }
      }
    },

    "categories": {
      ".read": true,
      ".write": "auth != null && (auth.token.role == 'admin' || auth.token.role == 'owner')"
    },

    // User-specific data
    "users": {
      "$userId": {
        ".read": "auth != null && auth.uid == $userId",
        ".write": "auth != null && auth.uid == $userId",
        "profile": {
          ".validate": "newData.hasChildren(['email', 'displayName'])"
        }
      }
    },

    // Cart access
    "carts": {
      "$userId": {
        ".read": "auth != null && auth.uid == $userId",
        ".write": "auth != null && auth.uid == $userId"
      }
    },

    // Orders - users can read their own, admins can read all
    "orders": {
      ".read": "auth != null && (auth.token.role == 'admin' || auth.token.role == 'owner')",
      "$orderId": {
        ".read": "auth != null && (auth.uid == data.child('basic/userId').val() || auth.token.role == 'admin' || auth.token.role == 'owner')",
        ".write": "auth != null && (auth.token.role == 'admin' || auth.token.role == 'owner')"
      }
    },

    // Reviews - public read, authenticated write for own reviews
    "reviews": {
      ".read": true,
      "$productId": {
        "$reviewId": {
          ".write": "auth != null && (auth.uid == data.child('userId').val() || !data.exists())",
          ".validate": "newData.hasChildren(['userId', 'rating', 'comment']) && newData.child('rating').isNumber() && newData.child('rating').val() >= 1 && newData.child('rating').val() <= 5"
        }
      }
    },

    // Coupons - public read, admin write
    "coupons": {
      ".read": true,
      ".write": "auth != null && (auth.token.role == 'admin' || auth.token.role == 'owner')"
    },

    // Flash sales - public read, admin write
    "flash_sales": {
      ".read": true,
      ".write": "auth != null && (auth.token.role == 'admin' || auth.token.role == 'owner')"
    },

    // Notifications - user-specific
    "notifications": {
      "$userId": {
        ".read": "auth != null && auth.uid == $userId",
        ".write": "auth != null && (auth.uid == $userId || auth.token.role == 'admin' || auth.token.role == 'owner')"
      }
    },

    // Chat - users can access their conversations, agents can access assigned ones
    "chat": {
      "$conversationId": {
        ".read": "auth != null && (auth.uid == data.child('userId').val() || auth.uid == data.child('assignedAgent').val() || auth.token.role == 'admin')",
        ".write": "auth != null && (auth.uid == data.child('userId').val() || auth.uid == data.child('assignedAgent').val() || auth.token.role == 'admin')",
        "messages": {
          "$messageId": {
            ".validate": "newData.hasChildren(['senderId', 'content', 'timestamp'])"
          }
        }
      }
    },

    // Complaints - users can create and view their own, support can access assigned ones
    "complaints": {
      ".read": "auth != null && (auth.token.role == 'admin' || auth.token.role == 'support')",
      "$complaintId": {
        ".read": "auth != null && (auth.uid == data.child('userId').val() || auth.uid == data.child('assignedTo').val() || auth.token.role == 'admin')",
        ".write": "auth != null && (auth.uid == data.child('userId').val() || auth.token.role == 'admin' || auth.token.role == 'support')"
      }
    },

    // App config - public read, admin write
    "app_config": {
      ".read": true,
      ".write": "auth != null && (auth.token.role == 'admin' || auth.token.role == 'owner')"
    },

    // Admin-only sections
    "admin": {
      ".read": "auth != null && (auth.token.role == 'admin' || auth.token.role == 'owner')",
      ".write": "auth != null && (auth.token.role == 'admin' || auth.token.role == 'owner')"
    }
  }
}
```

### 7.2 Firebase Storage Security Rules

```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Product images - public read, admin write
    match /products/{productId}/{imageId} {
      allow read: if true;
      allow write: if request.auth != null
        && (request.auth.token.role == 'admin' || request.auth.token.role == 'owner')
        && request.resource.size < 5 * 1024 * 1024 // 5MB limit
        && request.resource.contentType.matches('image/.*');
    }

    // User profile images - user-specific
    match /users/{userId}/profile/{imageId} {
      allow read: if true;
      allow write: if request.auth != null
        && request.auth.uid == userId
        && request.resource.size < 2 * 1024 * 1024 // 2MB limit
        && request.resource.contentType.matches('image/.*');
    }

    // Review images - authenticated users only
    match /reviews/{productId}/{reviewId}/{imageId} {
      allow read: if true;
      allow write: if request.auth != null
        && request.resource.size < 3 * 1024 * 1024 // 3MB limit
        && request.resource.contentType.matches('image/.*');
    }

    // Order invoices - user-specific and admin access
    match /invoices/{orderId}.pdf {
      allow read: if request.auth != null
        && (resource.metadata.userId == request.auth.uid
            || request.auth.token.role == 'admin'
            || request.auth.token.role == 'owner');
      allow write: if request.auth != null
        && (request.auth.token.role == 'admin' || request.auth.token.role == 'owner')
        && request.resource.contentType == 'application/pdf';
    }

    // Complaint attachments - user and support access
    match /complaints/{complaintId}/{attachmentId} {
      allow read: if request.auth != null
        && (resource.metadata.userId == request.auth.uid
            || request.auth.token.role == 'admin'
            || request.auth.token.role == 'support');
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024; // 10MB limit
    }

    // Chat attachments - conversation participants only
    match /chat/{conversationId}/{attachmentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.resource.size < 5 * 1024 * 1024; // 5MB limit
    }
  }
}
```

### 7.3 Custom Claims Setup

```dart
// lib/data/services/auth_service.dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> setUserRole(String userId, UserRole role) async {
    final callable = _functions.httpsCallable('setUserRole');
    await callable.call({
      'userId': userId,
      'role': role.value,
    });

    // Force token refresh to get new claims
    await _auth.currentUser?.getIdToken(true);
  }

  Future<UserRole?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final idTokenResult = await user.getIdTokenResult();
    final role = idTokenResult.claims?['role'] as String?;

    return role != null ? UserRole.fromString(role) : UserRole.user;
  }

  Future<bool> hasPermission(Permission permission) async {
    final role = await getCurrentUserRole();
    return role?.hasPermission(permission) ?? false;
  }
}

enum UserRole {
  user('user'),
  support('support'),
  moderator('moderator'),
  admin('admin'),
  owner('owner');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.user,
    );
  }

  bool hasPermission(Permission permission) {
    switch (this) {
      case UserRole.owner:
        return true; // Owner has all permissions
      case UserRole.admin:
        return permission != Permission.manageOwners;
      case UserRole.moderator:
        return [
          Permission.viewProducts,
          Permission.editProducts,
          Permission.viewOrders,
          Permission.editOrders,
          Permission.viewUsers,
          Permission.manageComplaints,
          Permission.manageChat,
        ].contains(permission);
      case UserRole.support:
        return [
          Permission.viewProducts,
          Permission.viewOrders,
          Permission.viewUsers,
          Permission.manageComplaints,
          Permission.manageChat,
        ].contains(permission);
      case UserRole.user:
        return [
          Permission.viewProducts,
          Permission.manageOwnProfile,
          Permission.manageOwnOrders,
        ].contains(permission);
    }
  }
}

enum Permission {
  viewProducts,
  editProducts,
  deleteProducts,
  viewOrders,
  editOrders,
  viewUsers,
  editUsers,
  manageComplaints,
  manageChat,
  manageCoupons,
  manageFlashSales,
  viewAnalytics,
  manageOwnProfile,
  manageOwnOrders,
  manageOwners,
}
```

---

## 8. Cloud Functions

### 8.1 Core Cloud Functions (TypeScript)

```typescript
// functions/src/index.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { stripe } from './services/stripe';
import { generateInvoicePDF } from './services/invoice';
import { sendEmail } from './services/email';
import { calculateRecommendations } from './services/recommendations';

admin.initializeApp();

// Set user role (admin only)
export const setUserRole = functions.https.onCall(async (data, context) => {
  // Verify admin permission
  if (!context.auth?.token.role || !['admin', 'owner'].includes(context.auth.token.role)) {
    throw new functions.https.HttpsError('permission-denied', 'Insufficient permissions');
  }

  const { userId, role } = data;

  try {
    await admin.auth().setCustomUserClaims(userId, { role });
    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Failed to set user role');
  }
});

// Create payment intent
export const createPaymentIntent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { amount, currency, orderId } = data;

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      metadata: {
        orderId,
        userId: context.auth.uid,
      },
    });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Payment intent creation failed');
  }
});

// Handle successful payment webhook
export const handlePaymentSuccess = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'] as string;
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET!);
  } catch (err) {
    console.error('Webhook signature verification failed:', err);
    return res.status(400).send('Webhook Error');
  }

  if (event.type === 'payment_intent.succeeded') {
    const paymentIntent = event.data.object;
    const orderId = paymentIntent.metadata.orderId;

    // Update order status
    await admin.database().ref(`orders/${orderId}/payment`).update({
      status: 'completed',
      transactionId: paymentIntent.id,
      paidAt: admin.database.ServerValue.TIMESTAMP,
    });

    // Update order timeline
    await admin.database().ref(`orders/${orderId}/timeline/paid`).set(
      admin.database.ServerValue.TIMESTAMP
    );

    // Generate and send invoice
    await generateAndSendInvoice(orderId);

    // Send confirmation notification
    await sendOrderConfirmationNotification(orderId);
  }

  res.json({ received: true });
});

// Generate invoice PDF
async function generateAndSendInvoice(orderId: string) {
  const orderSnapshot = await admin.database().ref(`orders/${orderId}`).once('value');
  const order = orderSnapshot.val();

  if (!order) return;

  // Generate PDF
  const pdfBuffer = await generateInvoicePDF(order);

  // Upload to Storage
  const bucket = admin.storage().bucket();
  const file = bucket.file(`invoices/${orderId}.pdf`);

  await file.save(pdfBuffer, {
    metadata: {
      contentType: 'application/pdf',
      metadata: {
        userId: order.basic.userId,
        orderId: orderId,
      },
    },
  });

  // Get download URL
  const [downloadURL] = await file.getSignedUrl({
    action: 'read',
    expires: Date.now() + 365 * 24 * 60 * 60 * 1000, // 1 year
  });

  // Send email with invoice
  await sendEmail({
    to: order.shipping.address.email,
    subject: `Invoice for Order #${order.basic.orderNumber}`,
    template: 'invoice',
    data: {
      order,
      invoiceUrl: downloadURL,
    },
  });
}

// Order status update trigger
export const onOrderStatusUpdate = functions.database
  .ref('/orders/{orderId}/basic/status')
  .onUpdate(async (change, context) => {
    const orderId = context.params.orderId;
    const newStatus = change.after.val();
    const oldStatus = change.before.val();

    if (newStatus === oldStatus) return;

    // Update timeline
    await admin.database().ref(`orders/${orderId}/timeline/${newStatus}`).set(
      admin.database.ServerValue.TIMESTAMP
    );

    // Send push notification
    await sendOrderStatusNotification(orderId, newStatus);

    // Handle specific status changes
    switch (newStatus) {
      case 'confirmed':
        await handleOrderConfirmed(orderId);
        break;
      case 'shipped':
        await handleOrderShipped(orderId);
        break;
      case 'delivered':
        await handleOrderDelivered(orderId);
        break;
    }
  });

// Product view counter
export const incrementProductViews = functions.database
  .ref('/products/{productId}/analytics/views')
  .onWrite(async (change, context) => {
    const productId = context.params.productId;

    // Update recommendations based on view patterns
    await updateProductRecommendations(productId);
  });

// Generate recommendations
export const updateRecommendations = functions.pubsub
  .schedule('every 6 hours')
  .onRun(async (context) => {
    const recommendations = await calculateRecommendations();

    // Update recommendations in database
    await admin.database().ref('recommendations').set(recommendations);

    return null;
  });
```

---

## 9. State Management with Riverpod

### 9.1 Provider Architecture

```dart
// lib/core/providers/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Core service providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) => FirebaseDatabase.instance);

// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    auth: ref.read(firebaseAuthProvider),
    database: ref.read(firebaseDatabaseProvider),
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    database: ref.read(firebaseDatabaseProvider),
    storage: ref.read(firebaseStorageProvider),
  );
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    database: ref.read(firebaseDatabaseProvider),
    hive: ref.read(hiveProvider),
  );
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    database: ref.read(firebaseDatabaseProvider),
    functions: ref.read(firebaseFunctionsProvider),
  );
});

// State providers
final authStateProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});

final cartStateProvider = StateNotifierProvider<CartController, CartState>((ref) {
  return CartController(
    cartRepository: ref.read(cartRepositoryProvider),
    authState: ref.read(authStateProvider),
  );
});

final productListStateProvider = StateNotifierProvider.family<
    ProductListController, ProductListState, ProductListParams>((ref, params) {
  return ProductListController(
    repository: ref.read(productRepositoryProvider),
    params: params,
  );
});

// Stream providers for real-time data
final userStreamProvider = StreamProvider.family<User?, String>((ref, userId) {
  return ref.read(authRepositoryProvider).getUserStream(userId);
});

final cartStreamProvider = StreamProvider<Cart?>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState.user == null) return Stream.value(null);

  return ref.read(cartRepositoryProvider).getCartStream(authState.user!.uid);
});

final orderStreamProvider = StreamProvider.family<Order?, String>((ref, orderId) {
  return ref.read(orderRepositoryProvider).getOrderStream(orderId);
});
```

### 9.2 Auth State Management

```dart
// lib/features/auth/controllers/auth_controller.dart
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AuthController(this._authRepository) : super(const AuthState.initial()) {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AuthState.loading();

    try {
      final result = await _authRepository.signInWithEmailAndPassword(email, password);
      result.fold(
        (failure) => state = AuthState.error(failure.message),
        (user) => state = AuthState.authenticated(user),
      );
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required String phoneNumber,
  }) async {
    state = const AuthState.loading();

    try {
      final result = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: phoneNumber,
      );

      result.fold(
        (failure) => state = AuthState.error(failure.message),
        (user) => state = AuthState.authenticated(user),
      );
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AuthState.unauthenticated();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authRepository.resetPassword(email);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
```

### 9.3 Product State Management

```dart
// lib/features/products/controllers/product_list_controller.dart
class ProductListController extends StateNotifier<ProductListState> {
  final ProductRepository _repository;
  final ProductListParams _params;

  ProductListController({
    required ProductRepository repository,
    required ProductListParams params,
  }) : _repository = repository, _params = params, super(const ProductListState.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (state.isLoading) return;

    state = const ProductListState.loading();

    try {
      final products = await _repository.getProducts(
        category: _params.category,
        filters: _params.filters,
        sortBy: _params.sortBy,
        limit: 20,
      );

      state = ProductListState.loaded(
        products: products,
        hasMore: products.length == 20,
        filters: _params.filters,
        sortBy: _params.sortBy,
      );
    } catch (e) {
      state = ProductListState.error(e.toString());
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! _Loaded || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    state = currentState.copyWith(isLoadingMore: true);

    try {
      final moreProducts = await _repository.getProducts(
        category: _params.category,
        filters: currentState.filters,
        sortBy: currentState.sortBy,
        offset: currentState.products.length,
        limit: 20,
      );

      state = currentState.copyWith(
        products: [...currentState.products, ...moreProducts],
        hasMore: moreProducts.length == 20,
        isLoadingMore: false,
      );
    } catch (e) {
      state = currentState.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  void applyFilters(ProductFilters filters) {
    _params = _params.copyWith(filters: filters);
    loadProducts();
  }

  void applySorting(ProductSortBy sortBy) {
    _params = _params.copyWith(sortBy: sortBy);
    loadProducts();
  }

  void search(String query) {
    _params = _params.copyWith(searchQuery: query);
    loadProducts();
  }
}

@freezed
class ProductListState with _$ProductListState {
  const factory ProductListState.loading() = _Loading;
  const factory ProductListState.loaded({
    required List<Product> products,
    required bool hasMore,
    required ProductFilters filters,
    required ProductSortBy sortBy,
    @Default(false) bool isLoadingMore,
    String? error,
  }) = _Loaded;
  const factory ProductListState.error(String message) = _Error;
}

@freezed
class ProductListParams with _$ProductListParams {
  const factory ProductListParams({
    String? category,
    String? searchQuery,
    @Default(ProductFilters()) ProductFilters filters,
    @Default(ProductSortBy.relevance) ProductSortBy sortBy,
  }) = _ProductListParams;
}
```

### 9.4 Cart State Management

```dart
// lib/features/cart/controllers/cart_controller.dart
class CartController extends StateNotifier<CartState> {
  final CartRepository _cartRepository;
  final AuthState _authState;
  StreamSubscription<Cart?>? _cartSubscription;

  CartController({
    required CartRepository cartRepository,
    required AuthState authState,
  }) : _cartRepository = cartRepository, _authState = authState, super(const CartState.loading()) {
    _initializeCart();
  }

  void _initializeCart() {
    if (_authState is _Authenticated) {
      final user = (_authState as _Authenticated).user;
      _cartSubscription = _cartRepository.getCartStream(user.uid).listen((cart) {
        if (cart != null) {
          state = CartState.loaded(cart);
        } else {
          state = const CartState.empty();
        }
      });
    } else {
      _loadAnonymousCart();
    }
  }

  Future<void> _loadAnonymousCart() async {
    try {
      final cart = await _cartRepository.getAnonymousCart();
      if (cart.items.isEmpty) {
        state = const CartState.empty();
      } else {
        state = CartState.loaded(cart);
      }
    } catch (e) {
      state = const CartState.empty();
    }
  }

  Future<void> addItem({
    required Product product,
    required ProductVariant variant,
    required int quantity,
  }) async {
    final currentState = state;
    if (currentState is! _Loaded && currentState is! _Empty) return;

    try {
      // Optimistic update
      final currentCart = currentState is _Loaded ? currentState.cart : Cart.empty();
      final updatedCart = currentCart.addItem(
        CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productId: product.id,
          variantId: variant.id,
          quantity: quantity,
          unitPrice: variant.price,
          product: product,
          variant: variant,
        ),
      );

      state = CartState.loaded(updatedCart);

      // Persist to repository
      if (_authState is _Authenticated) {
        final user = (_authState as _Authenticated).user;
        await _cartRepository.updateCart(user.uid, updatedCart);
      } else {
        await _cartRepository.saveAnonymousCart(updatedCart);
      }

      // Show success feedback
      _showAddToCartSuccess(product);
    } catch (e) {
      // Revert optimistic update
      if (currentState is _Loaded) {
        state = currentState;
      }
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateItemQuantity(String itemId, int quantity) async {
    final currentState = state;
    if (currentState is! _Loaded) return;

    try {
      final updatedCart = currentState.cart.updateItemQuantity(itemId, quantity);
      state = CartState.loaded(updatedCart);

      if (_authState is _Authenticated) {
        final user = (_authState as _Authenticated).user;
        await _cartRepository.updateCart(user.uid, updatedCart);
      } else {
        await _cartRepository.saveAnonymousCart(updatedCart);
      }
    } catch (e) {
      state = currentState.copyWith(error: e.toString());
    }
  }

  Future<void> removeItem(String itemId) async {
    final currentState = state;
    if (currentState is! _Loaded) return;

    try {
      final updatedCart = currentState.cart.removeItem(itemId);

      if (updatedCart.items.isEmpty) {
        state = const CartState.empty();
      } else {
        state = CartState.loaded(updatedCart);
      }

      if (_authState is _Authenticated) {
        final user = (_authState as _Authenticated).user;
        await _cartRepository.updateCart(user.uid, updatedCart);
      } else {
        await _cartRepository.saveAnonymousCart(updatedCart);
      }
    } catch (e) {
      state = currentState.copyWith(error: e.toString());
    }
  }

  Future<void> applyCoupon(String couponCode) async {
    final currentState = state;
    if (currentState is! _Loaded) return;

    try {
      state = currentState.copyWith(isApplyingCoupon: true);

      final validatedCoupon = await _cartRepository.validateCoupon(
        couponCode,
        currentState.cart,
      );

      final updatedCart = currentState.cart.applyCoupon(validatedCoupon);
      state = CartState.loaded(updatedCart);

      if (_authState is _Authenticated) {
        final user = (_authState as _Authenticated).user;
        await _cartRepository.updateCart(user.uid, updatedCart);
      } else {
        await _cartRepository.saveAnonymousCart(updatedCart);
      }
    } catch (e) {
      state = currentState.copyWith(
        isApplyingCoupon: false,
        error: e.toString(),
      );
    }
  }

  void _showAddToCartSuccess(Product product) {
    // This would trigger a UI notification
    // Implementation depends on your notification system
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}

@freezed
class CartState with _$CartState {
  const factory CartState.loading() = _Loading;
  const factory CartState.empty() = _Empty;
  const factory CartState.loaded(
    Cart cart, {
    @Default(false) bool isApplyingCoupon,
    String? error,
  }) = _Loaded;
}
```

---

## 10. Offline-First Strategy & Sync

### 10.1 Local Storage with Hive

```dart
// lib/data/local/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String productsBox = 'products';
  static const String categoriesBox = 'categories';
  static const String cartBox = 'cart';
  static const String userBox = 'user';
  static const String ordersBox = 'orders';
  static const String syncQueueBox = 'sync_queue';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(CartAdapter());
    Hive.registerAdapter(OrderAdapter());
    Hive.registerAdapter(SyncItemAdapter());

    // Open boxes
    await Hive.openBox<Product>(productsBox);
    await Hive.openBox<Category>(categoriesBox);
    await Hive.openBox<Cart>(cartBox);
    await Hive.openBox<User>(userBox);
    await Hive.openBox<Order>(ordersBox);
    await Hive.openBox<SyncItem>(syncQueueBox);
  }

  static Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  static Future<void> clearAllData() async {
    await Hive.box<Product>(productsBox).clear();
    await Hive.box<Category>(categoriesBox).clear();
    await Hive.box<Cart>(cartBox).clear();
    await Hive.box<User>(userBox).clear();
    await Hive.box<Order>(ordersBox).clear();
    await Hive.box<SyncItem>(syncQueueBox).clear();
  }
}

// Sync queue item for offline operations
@HiveType(typeId: 5)
class SyncItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final SyncOperation operation;

  @HiveField(2)
  final String entityType;

  @HiveField(3)
  final String entityId;

  @HiveField(4)
  final Map<String, dynamic> data;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final int retryCount;

  SyncItem({
    required this.id,
    required this.operation,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });
}

@HiveType(typeId: 6)
enum SyncOperation {
  @HiveField(0)
  create,
  @HiveField(1)
  update,
  @HiveField(2)
  delete,
}
```

### 10.2 Sync Service

```dart
// lib/data/services/sync_service.dart
class SyncService {
  final FirebaseDatabase _database;
  final Box<SyncItem> _syncQueue;
  final ConnectivityService _connectivity;

  SyncService({
    required FirebaseDatabase database,
    required Box<SyncItem> syncQueue,
    required ConnectivityService connectivity,
  }) : _database = database, _syncQueue = syncQueue, _connectivity = connectivity;

  // Queue offline operations
  Future<void> queueOperation({
    required SyncOperation operation,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    final syncItem = SyncItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      operation: operation,
      entityType: entityType,
      entityId: entityId,
      data: data,
      createdAt: DateTime.now(),
    );

    await _syncQueue.add(syncItem);
  }

  // Process sync queue when online
  Future<void> processSyncQueue() async {
    if (!await _connectivity.isConnected) return;

    final items = _syncQueue.values.toList();

    for (final item in items) {
      try {
        await _processItem(item);
        await item.delete(); // Remove from queue on success
      } catch (e) {
        // Increment retry count
        final updatedItem = SyncItem(
          id: item.id,
          operation: item.operation,
          entityType: item.entityType,
          entityId: item.entityId,
          data: item.data,
          createdAt: item.createdAt,
          retryCount: item.retryCount + 1,
        );

        // Remove if max retries reached
        if (updatedItem.retryCount >= 3) {
          await item.delete();
        } else {
          await item.save();
        }
      }
    }
  }

  Future<void> _processItem(SyncItem item) async {
    final ref = _database.ref('${item.entityType}/${item.entityId}');

    switch (item.operation) {
      case SyncOperation.create:
      case SyncOperation.update:
        await ref.set(item.data);
        break;
      case SyncOperation.delete:
        await ref.remove();
        break;
    }
  }

  // Sync data from server to local
  Future<void> syncFromServer() async {
    if (!await _connectivity.isConnected) return;

    try {
      // Sync products
      await _syncProducts();

      // Sync categories
      await _syncCategories();

      // Sync user-specific data if authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _syncUserData(user.uid);
      }
    } catch (e) {
      print('Sync error: $e');
    }
  }

  Future<void> _syncProducts() async {
    final snapshot = await _database.ref('products').once();
    if (snapshot.snapshot.exists) {
      final productsBox = Hive.box<Product>('products');
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;

      for (final entry in data.entries) {
        final product = Product.fromJson(Map<String, dynamic>.from(entry.value));
        await productsBox.put(entry.key, product);
      }
    }
  }

  Future<void> _syncCategories() async {
    final snapshot = await _database.ref('categories').once();
    if (snapshot.snapshot.exists) {
      final categoriesBox = Hive.box<Category>('categories');
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;

      for (final entry in data.entries) {
        final category = Category.fromJson(Map<String, dynamic>.from(entry.value));
        await categoriesBox.put(entry.key, category);
      }
    }
  }

  Future<void> _syncUserData(String userId) async {
    // Sync cart
    final cartSnapshot = await _database.ref('carts/$userId').once();
    if (cartSnapshot.snapshot.exists) {
      final cartBox = Hive.box<Cart>('cart');
      final cart = Cart.fromJson(Map<String, dynamic>.from(cartSnapshot.snapshot.value));
      await cartBox.put('user_cart', cart);
    }

    // Sync orders
    final ordersSnapshot = await _database.ref('orders').orderByChild('basic/userId').equalTo(userId).once();
    if (ordersSnapshot.snapshot.exists) {
      final ordersBox = Hive.box<Order>('orders');
      final data = ordersSnapshot.snapshot.value as Map<dynamic, dynamic>;

      for (final entry in data.entries) {
        final order = Order.fromJson(Map<String, dynamic>.from(entry.value));
        await ordersBox.put(entry.key, order);
      }
    }
  }
}
```

### 10.3 Offline Repository Implementation

```dart
// lib/data/repositories/offline_product_repository.dart
class OfflineProductRepository implements ProductRepository {
  final FirebaseDatabase _database;
  final Box<Product> _productsBox;
  final SyncService _syncService;
  final ConnectivityService _connectivity;

  OfflineProductRepository({
    required FirebaseDatabase database,
    required Box<Product> productsBox,
    required SyncService syncService,
    required ConnectivityService connectivity,
  }) : _database = database,
       _productsBox = productsBox,
       _syncService = syncService,
       _connectivity = connectivity;

  @override
  Future<List<Product>> getProducts({
    String? category,
    ProductFilters? filters,
    ProductSortBy? sortBy,
    int? offset,
    int? limit,
  }) async {
    // Try online first
    if (await _connectivity.isConnected) {
      try {
        return await _getProductsOnline(
          category: category,
          filters: filters,
          sortBy: sortBy,
          offset: offset,
          limit: limit,
        );
      } catch (e) {
        // Fall back to offline
        return _getProductsOffline(
          category: category,
          filters: filters,
          sortBy: sortBy,
          offset: offset,
          limit: limit,
        );
      }
    } else {
      // Use offline data
      return _getProductsOffline(
        category: category,
        filters: filters,
        sortBy: sortBy,
        offset: offset,
        limit: limit,
      );
    }
  }

  Future<List<Product>> _getProductsOnline({
    String? category,
    ProductFilters? filters,
    ProductSortBy? sortBy,
    int? offset,
    int? limit,
  }) async {
    Query query = _database.ref('products');

    // Apply category filter
    if (category != null) {
      query = query.orderByChild('basic/category').equalTo(category);
    }

    // Apply limit
    if (limit != null) {
      query = query.limitToFirst(limit);
    }

    final snapshot = await query.once();
    if (!snapshot.snapshot.exists) return [];

    final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
    List<Product> products = [];

    for (final entry in data.entries) {
      final product = Product.fromJson(Map<String, dynamic>.from(entry.value));
      products.add(product);

      // Cache locally
      await _productsBox.put(entry.key, product);
    }

    // Apply client-side filters and sorting
    return _applyFiltersAndSorting(products, filters, sortBy, offset, limit);
  }

  List<Product> _getProductsOffline({
    String? category,
    ProductFilters? filters,
    ProductSortBy? sortBy,
    int? offset,
    int? limit,
  }) {
    List<Product> products = _productsBox.values.toList();

    // Apply category filter
    if (category != null) {
      products = products.where((p) => p.category == category).toList();
    }

    return _applyFiltersAndSorting(products, filters, sortBy, offset, limit);
  }

  List<Product> _applyFiltersAndSorting(
    List<Product> products,
    ProductFilters? filters,
    ProductSortBy? sortBy,
    int? offset,
    int? limit,
  ) {
    // Apply filters
    if (filters != null) {
      products = products.where((product) {
        // Price range filter
        if (filters.minPrice != null && product.pricing.effectivePrice < filters.minPrice!) {
          return false;
        }
        if (filters.maxPrice != null && product.pricing.effectivePrice > filters.maxPrice!) {
          return false;
        }

        // Brand filter
        if (filters.brands.isNotEmpty && !filters.brands.contains(product.brand)) {
          return false;
        }

        // Rating filter
        if (filters.minRating != null && product.analytics.averageRating < filters.minRating!) {
          return false;
        }

        // Availability filter
        if (filters.inStockOnly && product.inventory.availableStock <= 0) {
          return false;
        }

        return true;
      }).toList();
    }

    // Apply sorting
    if (sortBy != null) {
      switch (sortBy) {
        case ProductSortBy.priceLowToHigh:
          products.sort((a, b) => a.pricing.effectivePrice.compareTo(b.pricing.effectivePrice));
          break;
        case ProductSortBy.priceHighToLow:
          products.sort((a, b) => b.pricing.effectivePrice.compareTo(a.pricing.effectivePrice));
          break;
        case ProductSortBy.rating:
          products.sort((a, b) => b.analytics.averageRating.compareTo(a.analytics.averageRating));
          break;
        case ProductSortBy.newest:
          products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case ProductSortBy.bestSelling:
          products.sort((a, b) => b.analytics.purchases.compareTo(a.analytics.purchases));
          break;
        case ProductSortBy.relevance:
        default:
          // Keep original order for relevance
          break;
      }
    }

    // Apply pagination
    if (offset != null) {
      products = products.skip(offset).toList();
    }
    if (limit != null) {
      products = products.take(limit).toList();
    }

    return products;
  }

  @override
  Future<Product?> getProduct(String productId) async {
    // Try local first for better performance
    final localProduct = _productsBox.get(productId);
    if (localProduct != null) {
      // Update view count offline
      await _incrementViewCount(productId);
      return localProduct;
    }

    // Try online if not in cache
    if (await _connectivity.isConnected) {
      try {
        final snapshot = await _database.ref('products/$productId').once();
        if (snapshot.snapshot.exists) {
          final product = Product.fromJson(Map<String, dynamic>.from(snapshot.snapshot.value));

          // Cache locally
          await _productsBox.put(productId, product);

          // Update view count
          await _incrementViewCount(productId);

          return product;
        }
      } catch (e) {
        print('Error fetching product online: $e');
      }
    }

    return null;
  }

  Future<void> _incrementViewCount(String productId) async {
    if (await _connectivity.isConnected) {
      try {
        await _database.ref('products/$productId/analytics/views').runTransaction((currentValue) {
          return Transaction.success((currentValue as int? ?? 0) + 1);
        });
      } catch (e) {
        // Queue for offline sync
        await _syncService.queueOperation(
          operation: SyncOperation.update,
          entityType: 'products',
          entityId: '$productId/analytics/views',
          data: {'increment': 1},
        );
      }
    } else {
      // Queue for offline sync
      await _syncService.queueOperation(
        operation: SyncOperation.update,
        entityType: 'products',
        entityId: '$productId/analytics/views',
        data: {'increment': 1},
      );
    }
  }
}
```

---

## 11. Performance Optimization & Budget

### 11.1 Performance Targets

**Frame Budget:**
- Target: 60fps (16.67ms per frame)
- Critical: No frame drops during scrolling
- Animations: Smooth 60fps for all transitions

**Memory Budget:**
- App size: <100MB installed
- RAM usage: <200MB during normal operation
- Image cache: Max 50MB

**Network Budget:**
- Initial load: <2MB
- Product images: <500KB each
- API responses: <100KB each

### 11.2 Image Optimization Strategy

```dart
// lib/core/services/image_service.dart
class ImageService {
  static const int maxImageSize = 1024; // Max width/height
  static const int compressionQuality = 85;
  static const int thumbnailSize = 300;

  static Future<File> compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Invalid image');

    // Resize if too large
    img.Image resized = image;
    if (image.width > maxImageSize || image.height > maxImageSize) {
      resized = img.copyResize(
        image,
        width: image.width > image.height ? maxImageSize : null,
        height: image.height > image.width ? maxImageSize : null,
      );
    }

    // Compress
    final compressedBytes = img.encodeJpg(resized, quality: compressionQuality);

    // Save compressed image
    final compressedFile = File('${imageFile.path}_compressed.jpg');
    await compressedFile.writeAsBytes(compressedBytes);

    return compressedFile;
  }

  static Future<File> generateThumbnail(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Invalid image');

    final thumbnail = img.copyResize(image, width: thumbnailSize);
    final thumbnailBytes = img.encodeJpg(thumbnail, quality: 80);

    final thumbnailFile = File('${imageFile.path}_thumb.jpg');
    await thumbnailFile.writeAsBytes(thumbnailBytes);

    return thumbnailFile;
  }
}

// Optimized image widget
class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final String? thumbnailUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedNetworkImage({
    Key? key,
    required this.imageUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) {
        if (thumbnailUrl != null) {
          return CachedNetworkImage(
            imageUrl: thumbnailUrl!,
            width: width,
            height: height,
            fit: fit,
            placeholder: (context, url) => placeholder ?? const ShimmerPlaceholder(),
          );
        }
        return placeholder ?? const ShimmerPlaceholder();
      },
      errorWidget: (context, url, error) => errorWidget ?? const ErrorImageWidget(),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      maxWidthDiskCache: (width ?? 400).toInt(),
      maxHeightDiskCache: (height ?? 400).toInt(),
    );
  }
}
```

### 11.3 List Performance Optimization

```dart
// lib/widgets/optimized_product_list.dart
class OptimizedProductList extends StatefulWidget {
  final List<Product> products;
  final VoidCallback? onLoadMore;
  final bool hasMore;

  const OptimizedProductList({
    Key? key,
    required this.products,
    this.onLoadMore,
    this.hasMore = false,
  }) : super(key: key);

  @override
  State<OptimizedProductList> createState() => _OptimizedProductListState();
}

class _OptimizedProductListState extends State<OptimizedProductList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.products.length + (widget.hasMore ? 1 : 0),
      cacheExtent: 1000, // Pre-cache items
      itemBuilder: (context, index) {
        if (index >= widget.products.length) {
          return const LoadingIndicator();
        }

        return ProductCard(
          key: ValueKey(widget.products[index].id),
          product: widget.products[index],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// Optimized product card with lazy loading
class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true; // Keep state when scrolling

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Card(
      child: InkWell(
        onTap: () => _navigateToProduct(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with hero animation
            Hero(
              tag: 'product-${widget.product.id}',
              child: OptimizedNetworkImage(
                imageUrl: widget.product.media.images.first.url,
                thumbnailUrl: widget.product.media.images.first.thumbnailUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.brand,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget.product.pricing.isOnSale) ...[
                        Text(
                          '\$${widget.product.pricing.basePrice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '\$${widget.product.pricing.effectivePrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: NeferColors.pharaohGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      RatingStars(
                        rating: widget.product.analytics.averageRating,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${widget.product.analytics.reviewCount})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProduct(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/product',
      arguments: widget.product.id,
    );
  }
}
```

### 11.4 Animation Performance

```dart
// lib/widgets/animations/pharaoh_animations.dart
class PharaohAnimations {
  // Optimized scarab loading animation
  static Widget scarabLoader({double size = 50}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ScarabPainter(),
        child: AnimatedBuilder(
          animation: AnimationController(
            duration: const Duration(seconds: 2),
            vsync: Ticker.instance,
          )..repeat(),
          builder: (context, child) {
            return Transform.rotate(
              angle: (AnimationController.of(context)?.value ?? 0) * 2 * math.pi,
              child: child,
            );
          },
        ),
      ),
    );
  }

  // Optimized shimmer effect
  static Widget shimmerEffect({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: duration,
      child: child,
    );
  }

  // Page transition with papyrus effect
  static PageRouteBuilder papyrusTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}

// Custom painter for scarab
class ScarabPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeferColors.pharaohGold
      ..style = PaintingStyle.fill;

    final path = Path();
    // Draw scarab shape (simplified)
    path.addOval(Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.6,
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

---

## 12. Testing Strategy

### 12.1 Testing Pyramid

```
                    E2E Tests (5%)
                 ┌─────────────────┐
                 │ Critical Flows  │
                 │ - Login/Signup  │
                 │ - Purchase Flow │
                 │ - Order Tracking│
                 └─────────────────┘

              Integration Tests (15%)
           ┌─────────────────────────┐
           │ Feature Integration     │
           │ - Cart Operations       │
           │ - Product Search        │
           │ - Payment Processing    │
           │ - Offline Sync          │
           └─────────────────────────┘

            Widget Tests (30%)
        ┌─────────────────────────────┐
        │ UI Component Testing        │
        │ - Product Cards             │
        │ - Forms & Validation        │
        │ - Navigation                │
        │ - Animations                │
        └─────────────────────────────┘

              Unit Tests (50%)
    ┌─────────────────────────────────────┐
    │ Business Logic & Data Layer         │
    │ - Repository Methods                │
    │ - State Management                  │
    │ - Utility Functions                 │
    │ - Model Serialization               │
    └─────────────────────────────────────┘
```

### 12.2 Unit Tests

```dart
// test/data/repositories/product_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([FirebaseDatabase, DatabaseReference])
void main() {
  group('ProductRepository', () {
    late ProductRepository repository;
    late MockFirebaseDatabase mockDatabase;
    late MockDatabaseReference mockRef;

    setUp(() {
      mockDatabase = MockFirebaseDatabase();
      mockRef = MockDatabaseReference();
      repository = ProductRepositoryImpl(database: mockDatabase);

      when(mockDatabase.ref(any)).thenReturn(mockRef);
    });

    group('getProducts', () {
      test('should return list of products when successful', () async {
        // Arrange
        final mockSnapshot = MockDataSnapshot();
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.value).thenReturn({
          'product1': {
            'basic': {
              'name': 'Test Product',
              'category': 'jewelry',
              'createdAt': '2024-01-01T00:00:00Z',
              'updatedAt': '2024-01-01T00:00:00Z',
            },
            'pricing': {
              'basePrice': 99.99,
              'currency': 'USD',
              'taxRate': 0.1,
            },
            // ... other required fields
          },
        });

        when(mockRef.once()).thenAnswer((_) async => MockDatabaseEvent(mockSnapshot));

        // Act
        final result = await repository.getProducts();

        // Assert
        expect(result, isA<List<Product>>());
        expect(result.length, equals(1));
        expect(result.first.name, equals('Test Product'));
      });

      test('should return empty list when no products exist', () async {
        // Arrange
        final mockSnapshot = MockDataSnapshot();
        when(mockSnapshot.exists).thenReturn(false);
        when(mockRef.once()).thenAnswer((_) async => MockDatabaseEvent(mockSnapshot));

        // Act
        final result = await repository.getProducts();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception when database error occurs', () async {
        // Arrange
        when(mockRef.once()).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.getProducts(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getProduct', () {
      test('should return product when found', () async {
        // Arrange
        const productId = 'product1';
        final mockSnapshot = MockDataSnapshot();
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.value).thenReturn({
          'basic': {
            'name': 'Test Product',
            'category': 'jewelry',
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z',
          },
          'pricing': {
            'basePrice': 99.99,
            'currency': 'USD',
            'taxRate': 0.1,
          },
          // ... other required fields
        });

        when(mockRef.once()).thenAnswer((_) async => MockDatabaseEvent(mockSnapshot));

        // Act
        final result = await repository.getProduct(productId);

        // Assert
        expect(result, isA<Product>());
        expect(result?.name, equals('Test Product'));
        verify(mockDatabase.ref('products/$productId')).called(1);
      });

      test('should return null when product not found', () async {
        // Arrange
        const productId = 'nonexistent';
        final mockSnapshot = MockDataSnapshot();
        when(mockSnapshot.exists).thenReturn(false);
        when(mockRef.once()).thenAnswer((_) async => MockDatabaseEvent(mockSnapshot));

        // Act
        final result = await repository.getProduct(productId);

        // Assert
        expect(result, isNull);
      });
    });
  });
}
```

### 12.3 Widget Tests

```dart
// test/widgets/product_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  group('ProductCard Widget', () {
    late Product testProduct;

    setUp(() {
      testProduct = Product(
        id: 'test-product',
        name: 'Test Pharaoh Necklace',
        nameAr: 'قلادة الفرعون التجريبية',
        brand: 'Ancient Treasures',
        pricing: ProductPricing(
          basePrice: 299.99,
          salePrice: 249.99,
          currency: 'USD',
          taxRate: 0.14,
        ),
        media: ProductMedia(
          images: [
            ProductImage(
              url: 'https://example.com/image.jpg',
              thumbnailUrl: 'https://example.com/thumb.jpg',
              alt: 'Test image',
            ),
          ],
        ),
        analytics: ProductAnalytics(
          averageRating: 4.5,
          reviewCount: 23,
        ),
        // ... other required fields
      );
    });

    testWidgets('should display product information correctly', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(product: testProduct),
            ),
          ),
        );

        // Verify product name is displayed
        expect(find.text('Test Pharaoh Necklace'), findsOneWidget);

        // Verify brand is displayed
        expect(find.text('Ancient Treasures'), findsOneWidget);

        // Verify price is displayed
        expect(find.text('\$249.99'), findsOneWidget);

        // Verify original price with strikethrough
        expect(find.text('\$299.99'), findsOneWidget);

        // Verify rating is displayed
        expect(find.byType(RatingStars), findsOneWidget);
        expect(find.text('(23)'), findsOneWidget);
      });
    });

    testWidgets('should navigate to product details on tap', (tester) async {
      bool navigationCalled = false;

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(product: testProduct),
            ),
            onGenerateRoute: (settings) {
              if (settings.name == '/product') {
                navigationCalled = true;
                return MaterialPageRoute(
                  builder: (context) => const Scaffold(body: Text('Product Details')),
                );
              }
              return null;
            },
          ),
        );

        // Tap on the product card
        await tester.tap(find.byType(ProductCard));
        await tester.pumpAndSettle();

        expect(navigationCalled, isTrue);
      });
    });

    testWidgets('should show sale badge when product is on sale', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(product: testProduct),
            ),
          ),
        );

        // Should show sale indicator (strikethrough price)
        final originalPriceWidget = tester.widget<Text>(
          find.text('\$299.99'),
        );
        expect(
          originalPriceWidget.style?.decoration,
          equals(TextDecoration.lineThrough),
        );
      });
    });
  });
}

// test/widgets/auth/login_form_test.dart
void main() {
  group('LoginForm Widget', () {
    testWidgets('should validate email field correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Find email field
      final emailField = find.byKey(const Key('email_field'));
      expect(emailField, findsOneWidget);

      // Test empty email
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Email is required'), findsOneWidget);

      // Test invalid email
      await tester.enterText(emailField, 'invalid-email');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Please enter a valid email'), findsOneWidget);

      // Test valid email
      await tester.enterText(emailField, 'test@example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Email is required'), findsNothing);
      expect(find.text('Please enter a valid email'), findsNothing);
    });

    testWidgets('should validate password field correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      final passwordField = find.byKey(const Key('password_field'));
      expect(passwordField, findsOneWidget);

      // Test empty password
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Password is required'), findsOneWidget);

      // Test short password
      await tester.enterText(passwordField, '123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);

      // Test valid password
      await tester.enterText(passwordField, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Password is required'), findsNothing);
      expect(find.text('Password must be at least 6 characters'), findsNothing);
    });
  });
}
```

### 12.4 Integration Tests

```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nefer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Nefer App Integration Tests', () {
    testWidgets('complete purchase flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Navigate through onboarding (if first time)
      if (find.text('Get Started').tryEvaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
      }

      // 2. Login
      await _performLogin(tester);

      // 3. Browse products
      await _browseProducts(tester);

      // 4. Add product to cart
      await _addProductToCart(tester);

      // 5. Go to cart
      await _navigateToCart(tester);

      // 6. Proceed to checkout
      await _proceedToCheckout(tester);

      // 7. Complete payment (test mode)
      await _completePayment(tester);

      // 8. Verify order confirmation
      await _verifyOrderConfirmation(tester);
    });

    testWidgets('offline functionality', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Load app while online
      await _performLogin(tester);
      await _browseProducts(tester);

      // 2. Simulate going offline
      await _simulateOfflineMode(tester);

      // 3. Verify cached content is available
      expect(find.byType(ProductCard), findsWidgets);

      // 4. Add items to cart offline
      await _addProductToCart(tester);

      // 5. Verify cart persists offline
      await _navigateToCart(tester);
      expect(find.byType(CartItemCard), findsWidgets);

      // 6. Go back online and verify sync
      await _simulateOnlineMode(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify data is synced
      await _verifyDataSync(tester);
    });
  });
}

Future<void> _performLogin(WidgetTester tester) async {
  // Navigate to login if not already logged in
  if (find.text('Login').tryEvaluate().isNotEmpty) {
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Enter credentials
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'password123',
    );

    // Tap login button
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Wait for navigation to home
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }
}

Future<void> _browseProducts(WidgetTester tester) async {
  // Verify home screen is loaded
  expect(find.byType(ProductCard), findsWidgets);

  // Scroll to load more products
  await tester.drag(
    find.byType(ListView).first,
    const Offset(0, -500),
  );
  await tester.pumpAndSettle();
}

Future<void> _addProductToCart(WidgetTester tester) async {
  // Tap on first product
  await tester.tap(find.byType(ProductCard).first);
  await tester.pumpAndSettle();

  // Verify product details screen
  expect(find.byType(ProductDetailsScreen), findsOneWidget);

  // Add to cart
  await tester.tap(find.text('Add to Cart'));
  await tester.pumpAndSettle();

  // Verify success message or animation
  expect(find.text('Added to cart'), findsOneWidget);
}

Future<void> _navigateToCart(WidgetTester tester) async {
  // Tap cart icon in bottom navigation
  await tester.tap(find.byIcon(Icons.shopping_cart));
  await tester.pumpAndSettle();

  // Verify cart screen
  expect(find.byType(CartScreen), findsOneWidget);
  expect(find.byType(CartItemCard), findsWidgets);
}

Future<void> _proceedToCheckout(WidgetTester tester) async {
  // Tap checkout button
  await tester.tap(find.text('Proceed to Checkout'));
  await tester.pumpAndSettle();

  // Fill shipping address
  await _fillShippingAddress(tester);

  // Select delivery option
  await _selectDeliveryOption(tester);

  // Continue to payment
  await tester.tap(find.text('Continue to Payment'));
  await tester.pumpAndSettle();
}

Future<void> _fillShippingAddress(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('full_name_field')),
    'John Doe',
  );
  await tester.enterText(
    find.byKey(const Key('street_field')),
    '123 Main Street',
  );
  await tester.enterText(
    find.byKey(const Key('city_field')),
    'Cairo',
  );
  await tester.enterText(
    find.byKey(const Key('postal_code_field')),
    '12345',
  );
}

Future<void> _selectDeliveryOption(WidgetTester tester) async {
  await tester.tap(find.text('Standard Delivery'));
  await tester.pumpAndSettle();
}

Future<void> _completePayment(WidgetTester tester) async {
  // Enter test card details
  await tester.enterText(
    find.byKey(const Key('card_number_field')),
    '4242424242424242',
  );
  await tester.enterText(
    find.byKey(const Key('expiry_field')),
    '12/25',
  );
  await tester.enterText(
    find.byKey(const Key('cvv_field')),
    '123',
  );

  // Complete payment
  await tester.tap(find.text('Pay Now'));
  await tester.pumpAndSettle(const Duration(seconds: 5));
}

Future<void> _verifyOrderConfirmation(WidgetTester tester) async {
  // Verify order confirmation screen
  expect(find.byType(OrderConfirmationScreen), findsOneWidget);
  expect(find.text('Order Confirmed'), findsOneWidget);
  expect(find.textContaining('Order #'), findsOneWidget);
}

Future<void> _simulateOfflineMode(WidgetTester tester) async {
  // This would require a mock network service
  // Implementation depends on your connectivity service
}

Future<void> _simulateOnlineMode(WidgetTester tester) async {
  // This would require a mock network service
  // Implementation depends on your connectivity service
}

Future<void> _verifyDataSync(WidgetTester tester) async {
  // Verify that offline changes are synced
  // Check cart items, user data, etc.
}
```

---

## 13. CI/CD Pipeline

### 13.1 GitHub Actions Workflow

```yaml
# .github/workflows/ci_cd.yml
name: Nefer CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
  release:
    types: [ published ]

env:
  FLUTTER_VERSION: '3.16.0'
  JAVA_VERSION: '17'

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: ${{ env.JAVA_VERSION }}

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: ${{ env.FLUTTER_VERSION }}
        channel: 'stable'

    - name: Get dependencies
      run: flutter pub get

    - name: Verify formatting
      run: dart format --output=none --set-exit-if-changed .

    - name: Analyze project source
      run: flutter analyze

    - name: Run unit tests
      run: flutter test --coverage

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info

    - name: Run integration tests
      uses: reactivecircus/android-emulator-runner@v2
      with:
        api-level: 29
        script: flutter test integration_test/

  build_android:
    name: Build Android
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' || github.event_name == 'release'

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: ${{ env.JAVA_VERSION }}

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: ${{ env.FLUTTER_VERSION }}
        channel: 'stable'

    - name: Get dependencies
      run: flutter pub get

    - name: Setup environment
      run: |
        echo "${{ secrets.ENV_PROD }}" > .env.prod
        echo "${{ secrets.GOOGLE_SERVICES_JSON }}" | base64 -d > android/app/google-services.json

    - name: Setup signing
      run: |
        echo "${{ secrets.KEYSTORE }}" | base64 -d > android/app/keystore.jks
        echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" >> android/key.properties
        echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
        echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
        echo "storeFile=keystore.jks" >> android/key.properties

    - name: Build APK
      run: flutter build apk --release --flavor prod

    - name: Build App Bundle
      run: flutter build appbundle --release --flavor prod

    - name: Upload APK artifact
      uses: actions/upload-artifact@v3
      with:
        name: android-apk
        path: build/app/outputs/flutter-apk/app-prod-release.apk

    - name: Upload App Bundle artifact
      uses: actions/upload-artifact@v3
      with:
        name: android-aab
        path: build/app/outputs/bundle/prodRelease/app-prod-release.aab

  build_ios:
    name: Build iOS
    needs: test
    runs-on: macos-latest
    if: github.event_name == 'push' || github.event_name == 'release'

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: ${{ env.FLUTTER_VERSION }}
        channel: 'stable'

    - name: Get dependencies
      run: flutter pub get

    - name: Setup environment
      run: |
        echo "${{ secrets.ENV_PROD }}" > .env.prod
        echo "${{ secrets.GOOGLE_SERVICE_INFO_PLIST }}" | base64 -d > ios/Runner/GoogleService-Info.plist

    - name: Setup certificates
      env:
        P12_PASSWORD: ${{ secrets.P12_PASSWORD }}
        PROVISIONING_PROFILE: ${{ secrets.PROVISIONING_PROFILE }}
        CERTIFICATE_P12: ${{ secrets.CERTIFICATE_P12 }}
      run: |
        # Create temporary keychain
        security create-keychain -p "${{ secrets.KEYCHAIN_PASSWORD }}" build.keychain
        security default-keychain -s build.keychain
        security unlock-keychain -p "${{ secrets.KEYCHAIN_PASSWORD }}" build.keychain

        # Import certificate
        echo "$CERTIFICATE_P12" | base64 -d > certificate.p12
        security import certificate.p12 -k build.keychain -P "$P12_PASSWORD" -T /usr/bin/codesign

        # Install provisioning profile
        mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
        echo "$PROVISIONING_PROFILE" | base64 -d > ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision

    - name: Build iOS
      run: |
        flutter build ios --release --no-codesign
        cd ios
        xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination generic/platform=iOS -archivePath Runner.xcarchive archive
        xcodebuild -exportArchive -archivePath Runner.xcarchive -exportPath . -exportOptionsPlist ExportOptions.plist

    - name: Upload IPA artifact
      uses: actions/upload-artifact@v3
      with:
        name: ios-ipa
        path: ios/Runner.ipa

  deploy_android:
    name: Deploy to Play Store
    needs: build_android
    runs-on: ubuntu-latest
    if: github.event_name == 'release'

    steps:
    - name: Download App Bundle
      uses: actions/download-artifact@v3
      with:
        name: android-aab

    - name: Deploy to Play Store
      uses: r0adkll/upload-google-play@v1
      with:
        serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
        packageName: com.company.nefer
        releaseFiles: app-prod-release.aab
        track: production
        status: completed

  deploy_ios:
    name: Deploy to App Store
    needs: build_ios
    runs-on: macos-latest
    if: github.event_name == 'release'

    steps:
    - name: Download IPA
      uses: actions/download-artifact@v3
      with:
        name: ios-ipa

    - name: Deploy to App Store
      env:
        APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
      run: |
        xcrun altool --upload-app --type ios --file Runner.ipa --apiKey "$APP_STORE_CONNECT_API_KEY" --apiIssuer "${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}"
```

### 13.2 Environment Configuration

```dart
// lib/core/config/app_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late AppEnvironment _environment;

  static AppEnvironment get environment => _environment;

  static Future<void> initialize(AppEnvironment env) async {
    _environment = env;

    switch (env) {
      case AppEnvironment.development:
        await dotenv.load(fileName: '.env.dev');
        break;
      case AppEnvironment.staging:
        await dotenv.load(fileName: '.env.staging');
        break;
      case AppEnvironment.production:
        await dotenv.load(fileName: '.env.prod');
        break;
    }
  }

  // Firebase Configuration
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseDatabaseUrl => dotenv.env['FIREBASE_DATABASE_URL'] ?? '';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';

  // Payment Configuration
  static String get stripePublishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get paypalClientId => dotenv.env['PAYPAL_CLIENT_ID'] ?? '';

  // API Configuration
  static String get baseApiUrl => dotenv.env['BASE_API_URL'] ?? '';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';

  // Feature Flags
  static bool get enableAnalytics => dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
  static bool get enableCrashlytics => dotenv.env['ENABLE_CRASHLYTICS']?.toLowerCase() == 'true';
  static bool get enablePerformanceMonitoring => dotenv.env['ENABLE_PERFORMANCE']?.toLowerCase() == 'true';

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'Nefer';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static int get buildNumber => int.tryParse(dotenv.env['BUILD_NUMBER'] ?? '1') ?? 1;

  // Debug Configuration
  static bool get isDebugMode => _environment == AppEnvironment.development;
  static bool get enableLogging => dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';
  static String get logLevel => dotenv.env['LOG_LEVEL'] ?? 'info';
}

enum AppEnvironment {
  development,
  staging,
  production,
}

// Environment files:
// .env.dev
/*
FIREBASE_PROJECT_ID=nefer-dev
FIREBASE_API_KEY=dev_api_key
FIREBASE_DATABASE_URL=https://nefer-dev-default-rtdb.firebaseio.com
FIREBASE_STORAGE_BUCKET=nefer-dev.appspot.com
STRIPE_PUBLISHABLE_KEY=pk_test_...
BASE_API_URL=https://api-dev.nefer.com
ENABLE_ANALYTICS=false
ENABLE_CRASHLYTICS=false
ENABLE_LOGGING=true
LOG_LEVEL=debug
APP_NAME=Nefer Dev
*/

// .env.prod
/*
FIREBASE_PROJECT_ID=ecommerceapp-b0900
FIREBASE_API_KEY=AIzaSyBosE85Ks07okXe_qt-e5yU3GpDxTPOn_8
FIREBASE_DATABASE_URL=https://ecommerceapp-b0900-default-rtdb.firebaseio.com
FIREBASE_STORAGE_BUCKET=ecommerceapp-b0900.firebasestorage.app
STRIPE_PUBLISHABLE_KEY=pk_live_...
BASE_API_URL=https://api.nefer.com
ENABLE_ANALYTICS=true
ENABLE_CRASHLYTICS=true
ENABLE_LOGGING=false
LOG_LEVEL=error
APP_NAME=Nefer
*/
```

---

## 14. Localization & RTL Support

### 14.1 Localization Setup

```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true
```

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

```json
// lib/l10n/app_en.arb
{
  "@@locale": "en",
  "appTitle": "Nefer",
  "welcome": "Welcome to Nefer",
  "login": "Login",
  "register": "Register",
  "email": "Email",
  "password": "Password",
  "forgotPassword": "Forgot Password?",
  "signIn": "Sign In",
  "signUp": "Sign Up",
  "home": "Home",
  "categories": "Categories",
  "cart": "Cart",
  "orders": "Orders",
  "profile": "Profile",
  "search": "Search",
  "searchProducts": "Search products...",
  "addToCart": "Add to Cart",
  "buyNow": "Buy Now",
  "price": "Price",
  "rating": "Rating",
  "reviews": "Reviews",
  "description": "Description",
  "specifications": "Specifications",
  "checkout": "Checkout",
  "shippingAddress": "Shipping Address",
  "paymentMethod": "Payment Method",
  "orderSummary": "Order Summary",
  "subtotal": "Subtotal",
  "shipping": "Shipping",
  "tax": "Tax",
  "total": "Total",
  "placeOrder": "Place Order",
  "orderConfirmed": "Order Confirmed",
  "trackOrder": "Track Order",
  "orderNumber": "Order Number: {orderNumber}",
  "@orderNumber": {
    "placeholders": {
      "orderNumber": {
        "type": "String"
      }
    }
  },
  "itemsInCart": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemsInCart": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

```json
// lib/l10n/app_ar.arb
{
  "@@locale": "ar",
  "appTitle": "نفِر",
  "welcome": "مرحباً بك في نفِر",
  "login": "تسجيل الدخول",
  "register": "إنشاء حساب",
  "email": "البريد الإلكتروني",
  "password": "كلمة المرور",
  "forgotPassword": "نسيت كلمة المرور؟",
  "signIn": "دخول",
  "signUp": "إنشاء حساب",
  "home": "الرئيسية",
  "categories": "الفئات",
  "cart": "السلة",
  "orders": "الطلبات",
  "profile": "الملف الشخصي",
  "search": "بحث",
  "searchProducts": "البحث عن المنتجات...",
  "addToCart": "أضف إلى السلة",
  "buyNow": "اشتري الآن",
  "price": "السعر",
  "rating": "التقييم",
  "reviews": "المراجعات",
  "description": "الوصف",
  "specifications": "المواصفات",
  "checkout": "الدفع",
  "shippingAddress": "عنوان الشحن",
  "paymentMethod": "طريقة الدفع",
  "orderSummary": "ملخص الطلب",
  "subtotal": "المجموع الفرعي",
  "shipping": "الشحن",
  "tax": "الضريبة",
  "total": "المجموع",
  "placeOrder": "تأكيد الطلب",
  "orderConfirmed": "تم تأكيد الطلب",
  "trackOrder": "تتبع الطلب",
  "orderNumber": "رقم الطلب: {orderNumber}",
  "itemsInCart": "{count, plural, =0{لا توجد عناصر} =1{عنصر واحد} =2{عنصران} few{{count} عناصر} many{{count} عنصراً} other{{count} عنصر}}"
}
```

### 14.2 RTL Support Implementation

```dart
// lib/core/theme/rtl_theme.dart
class RTLTheme {
  static ThemeData getRTLTheme(ThemeData baseTheme, Locale locale) {
    if (locale.languageCode == 'ar') {
      return baseTheme.copyWith(
        // RTL-specific adjustments
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: baseTheme.textTheme.apply(
          fontFamily: NeferTypography.arabicFont,
        ),
        inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        cardTheme: baseTheme.cardTheme.copyWith(
          margin: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
        ),
      );
    }
    return baseTheme;
  }

  static EdgeInsets getDirectionalPadding({
    required BuildContext context,
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return EdgeInsets.only(
      left: isRTL ? end : start,
      top: top,
      right: isRTL ? start : end,
      bottom: bottom,
    );
  }

  static Alignment getDirectionalAlignment({
    required BuildContext context,
    required Alignment ltrAlignment,
    required Alignment rtlAlignment,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return isRTL ? rtlAlignment : ltrAlignment;
  }
}

// RTL-aware widgets
class DirectionalIcon extends StatelessWidget {
  final IconData icon;
  final IconData? rtlIcon;
  final double? size;
  final Color? color;

  const DirectionalIcon({
    Key? key,
    required this.icon,
    this.rtlIcon,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final iconToUse = (isRTL && rtlIcon != null) ? rtlIcon! : icon;

    return Icon(
      iconToUse,
      size: size,
      color: color,
    );
  }
}

class DirectionalPadding extends StatelessWidget {
  final Widget child;
  final double start;
  final double top;
  final double end;
  final double bottom;

  const DirectionalPadding({
    Key? key,
    required this.child,
    this.start = 0,
    this.top = 0,
    this.end = 0,
    this.bottom = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RTLTheme.getDirectionalPadding(
        context: context,
        start: start,
        top: top,
        end: end,
        bottom: bottom,
      ),
      child: child,
    );
  }
}
```

---

## 15. Analytics & Monitoring

### 15.1 Analytics Implementation

```dart
// lib/core/services/analytics_service.dart
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // E-commerce Events
  static Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required String itemCategory,
    required double value,
    required String currency,
  }) async {
    await _analytics.logViewItem(
      currency: currency,
      value: value,
      parameters: {
        'item_id': itemId,
        'item_name': itemName,
        'item_category': itemCategory,
        'content_type': 'product',
      },
    );
  }

  static Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required String itemCategory,
    required double value,
    required String currency,
    required int quantity,
  }) async {
    await _analytics.logAddToCart(
      currency: currency,
      value: value,
      parameters: {
        'item_id': itemId,
        'item_name': itemName,
        'item_category': itemCategory,
        'quantity': quantity,
      },
    );
  }

  static Future<void> logBeginCheckout({
    required double value,
    required String currency,
    required List<Map<String, dynamic>> items,
  }) async {
    await _analytics.logBeginCheckout(
      value: value,
      currency: currency,
      parameters: {
        'items': items,
        'num_items': items.length,
      },
    );
  }

  static Future<void> logPurchase({
    required String transactionId,
    required double value,
    required String currency,
    required List<Map<String, dynamic>> items,
    String? coupon,
  }) async {
    await _analytics.logPurchase(
      currency: currency,
      transactionId: transactionId,
      value: value,
      parameters: {
        'items': items,
        'coupon': coupon,
        'num_items': items.length,
      },
    );
  }

  // Custom Events
  static Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  // User Properties
  static Future<void> setUserProperties({
    String? userId,
    String? userType,
    String? preferredLanguage,
    String? country,
  }) async {
    if (userId != null) {
      await _analytics.setUserId(id: userId);
    }

    await _analytics.setUserProperty(
      name: 'user_type',
      value: userType,
    );

    await _analytics.setUserProperty(
      name: 'preferred_language',
      value: preferredLanguage,
    );

    await _analytics.setUserProperty(
      name: 'country',
      value: country,
    );
  }

  // Error Tracking
  static Future<void> recordError({
    required dynamic exception,
    StackTrace? stackTrace,
    String? reason,
    Map<String, dynamic>? context,
  }) async {
    await _crashlytics.recordError(
      exception,
      stackTrace,
      reason: reason,
      information: context?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
    );
  }

  // Performance Monitoring
  static HttpMetric newHttpMetric({
    required String url,
    required HttpMethod httpMethod,
  }) {
    return FirebasePerformance.instance.newHttpMetric(url, httpMethod);
  }

  static Trace newTrace(String traceName) {
    return FirebasePerformance.instance.newTrace(traceName);
  }
}

// Analytics Events Constants
class AnalyticsEvents {
  // E-commerce
  static const String viewItem = 'view_item';
  static const String addToCart = 'add_to_cart';
  static const String removeFromCart = 'remove_from_cart';
  static const String beginCheckout = 'begin_checkout';
  static const String addPaymentInfo = 'add_payment_info';
  static const String purchase = 'purchase';

  // User Actions
  static const String login = 'login';
  static const String signUp = 'sign_up';
  static const String search = 'search';
  static const String selectContent = 'select_content';
  static const String share = 'share';

  // Custom Events
  static const String viewCategory = 'view_category';
  static const String applyFilter = 'apply_filter';
  static const String sortProducts = 'sort_products';
  static const String addToWishlist = 'add_to_wishlist';
  static const String removeFromWishlist = 'remove_from_wishlist';
  static const String applyCoupon = 'apply_coupon';
  static const String startChat = 'start_chat';
  static const String submitReview = 'submit_review';
  static const String trackOrder = 'track_order';
  static const String contactSupport = 'contact_support';
}
```

---

## 16. Final Implementation Checklist

### 16.1 Development Phases

**Phase 1: Foundation (Weeks 1-2)**
- [ ] Project setup and configuration
- [ ] Firebase integration
- [ ] Basic authentication
- [ ] Theme and localization setup
- [ ] Core navigation structure

**Phase 2: Core Features (Weeks 3-6)**
- [ ] Product catalog and details
- [ ] Shopping cart functionality
- [ ] User profile management
- [ ] Search and filtering
- [ ] Offline-first implementation

**Phase 3: E-commerce Features (Weeks 7-10)**
- [ ] Checkout and payment integration
- [ ] Order management and tracking
- [ ] Reviews and ratings
- [ ] Wishlist functionality
- [ ] Coupon and discount system

**Phase 4: Advanced Features (Weeks 11-14)**
- [ ] Flash sales implementation
- [ ] Recommendation engine
- [ ] Push notifications
- [ ] Chat and support system
- [ ] Admin dashboard (web)

**Phase 5: Polish & Launch (Weeks 15-16)**
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] App store preparation
- [ ] CI/CD pipeline setup
- [ ] Production deployment

### 16.2 Acceptance Criteria

**Authentication & User Management**
- [ ] Users can register with email/password
- [ ] Users can login with email/password
- [ ] Users can reset forgotten passwords
- [ ] Users can update profile information
- [ ] Users can manage shipping addresses
- [ ] Social login integration (optional)

**Product Catalog**
- [ ] Products display with images, prices, ratings
- [ ] Product details with full information
- [ ] Category-based browsing
- [ ] Search functionality with filters
- [ ] Sort options (price, rating, newest)
- [ ] Infinite scroll pagination

**Shopping Cart & Checkout**
- [ ] Add/remove items from cart
- [ ] Update item quantities
- [ ] Apply coupon codes
- [ ] Calculate taxes and shipping
- [ ] Multiple payment methods
- [ ] Order confirmation and receipt

**Order Management**
- [ ] View order history
- [ ] Track order status in real-time
- [ ] Cancel orders (when applicable)
- [ ] Reorder functionality
- [ ] Download invoices

**Offline Functionality**
- [ ] Browse cached products offline
- [ ] Add items to cart offline
- [ ] Sync data when back online
- [ ] Handle network connectivity changes

**Performance Requirements**
- [ ] App launches in <2 seconds
- [ ] Smooth 60fps animations
- [ ] Images load progressively
- [ ] Memory usage <200MB
- [ ] App size <100MB

**Accessibility & Localization**
- [ ] Full RTL support for Arabic
- [ ] Screen reader compatibility
- [ ] High contrast mode support
- [ ] Large text support
- [ ] Keyboard navigation

This comprehensive blueprint provides a production-ready roadmap for building the Nefer e-commerce app. The implementation follows industry best practices, includes robust error handling, and scales to handle enterprise-level requirements.
```
```
```
