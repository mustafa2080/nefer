# 🏛️ Nefer (نفِر) - Pharaonic E-commerce App

[![Flutter](https://img.shields.io/badge/Flutter-3.16.0+-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Nefer** is a production-ready, Amazon/Noon-class e-commerce mobile application built with Flutter, featuring a luxurious Pharaonic design theme and comprehensive e-commerce functionality.

## ✨ Features

### 🛍️ E-commerce Core
- **Product Catalog** with advanced search & filters
- **Shopping Cart** with offline persistence
- **Checkout & Payments** (Stripe integration)
- **Order Management** with real-time tracking
- **User Authentication** (Firebase Auth)
- **Reviews & Ratings** system
- **Wishlist** functionality
- **Coupons & Discounts**
- **Flash Sales** with countdown timers

### 🎨 Pharaonic Design System
- **Luxurious Color Palette**: Gold, Lapis Blue, Sandstone Beige
- **Egyptian Typography**: Cinzel (display) + Inter (body) + Amiri (Arabic)
- **Animated Micro-interactions**: Scarab loaders, wing animations
- **Hieroglyphic Patterns**: Subtle background textures
- **Dark/Light Mode** support

### 🌍 Internationalization
- **Bilingual Support**: English & Arabic (نفِر)
- **Full RTL Support** for Arabic users
- **Cultural Adaptations** for Middle Eastern markets
- **Localized Content** and pricing

### 📱 Mobile Excellence
- **Offline-First Architecture** with Hive caching
- **Real-time Sync** when online
- **Push Notifications** (FCM)
- **Deep Linking** support
- **Performance Optimized** (60fps, <2s cold start)
- **Responsive Design** for all screen sizes

### 🔧 Admin Features
- **Flutter Web Dashboard** for management
- **Role-based Access Control** (Owner, Admin, Moderator, Support)
- **Analytics & Reports** with GA4 integration
- **Inventory Management**
- **Order Processing**
- **Customer Support** chat system

## 🏗️ Architecture

### State Management
- **Riverpod** for reactive state management
- **Clean Architecture** with separation of concerns
- **Repository Pattern** for data access
- **Provider-based** dependency injection

### Data Layer
- **Firebase Realtime Database** for real-time data
- **Firebase Storage** for media files
- **Hive** for local caching and offline storage
- **Cloud Functions** for server-side logic

### Security
- **Firebase Security Rules** with role-based access
- **Custom Claims** for user roles
- **Secure Payment Processing** with Stripe
- **Data Encryption** for sensitive information

## 🚀 Getting Started

### Prerequisites
- Flutter 3.16.0 or higher
- Dart 3.2.0 or higher
- Firebase project setup
- Stripe account (for payments)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/nefer-app.git
   cd nefer-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase in your project
   firebase init
   ```

4. **Configure Firebase**
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`
   - Update `lib/firebase_options.dart` with your configuration

5. **Environment Configuration**
   ```bash
   # Copy environment template
   cp .env.example .env.dev
   
   # Edit with your configuration
   nano .env.dev
   ```

6. **Generate Code**
   ```bash
   # Generate localization files
   flutter gen-l10n
   
   # Generate model classes and providers
   flutter packages pub run build_runner build
   ```

7. **Run the App**
   ```bash
   # Development mode
   flutter run --flavor dev
   
   # Production mode
   flutter run --flavor prod --release
   ```

## 📁 Project Structure

```
lib/
├── main.dart                     # App entry point
├── app.dart                      # App configuration
├── core/                         # Core utilities
│   ├── theme/                    # Pharaonic design system
│   ├── routing/                  # Navigation setup
│   ├── services/                 # Core services
│   └── providers/                # Global providers
├── features/                     # Feature modules
│   ├── auth/                     # Authentication
│   ├── home/                     # Home screen
│   ├── products/                 # Product catalog
│   ├── cart/                     # Shopping cart
│   ├── orders/                   # Order management
│   ├── profile/                  # User profile
│   ├── admin/                    # Admin dashboard
│   └── shared/                   # Shared components
├── data/                         # Data layer
│   ├── models/                   # Data models
│   ├── repositories/             # Repository implementations
│   └── services/                 # External services
└── generated/                    # Generated files
```

## 🎨 Design System

### Color Palette
```dart
// Primary Colors
static const Color pharaohGold = Color(0xFFD4AF37);
static const Color lapisBlue = Color(0xFF1E3A8A);
static const Color sandstoneBeige = Color(0xFFF5E6D3);
static const Color turquoiseAccent = Color(0xFF40E0D0);
static const Color papyrusWhite = Color(0xFFFAF7F0);
static const Color hieroglyphGray = Color(0xFF4A5568);
```

### Typography
```dart
// Display Font (Headers)
static const String displayFont = 'Cinzel';

// Body Font (Content)
static const String bodyFont = 'Inter';

// Arabic Font (RTL)
static const String arabicFont = 'Amiri';
```

## 🔥 Firebase Configuration

### Realtime Database Structure
```json
{
  "users": { "userId": { "profile": {}, "addresses": {} } },
  "products": { "productId": { "basic": {}, "pricing": {}, "inventory": {} } },
  "categories": { "categoryId": { "name": "", "subcategories": [] } },
  "carts": { "userId": { "items": {}, "summary": {} } },
  "orders": { "orderId": { "basic": {}, "items": {}, "shipping": {} } },
  "reviews": { "productId": { "reviewId": {} } },
  "coupons": { "couponId": { "code": "", "value": 0 } },
  "flash_sales": { "saleId": { "products": {}, "timing": {} } }
}
```

### Security Rules
```javascript
{
  "rules": {
    "products": { ".read": true, ".write": "auth.token.role == 'admin'" },
    "users": { "$uid": { ".read": "auth.uid == $uid", ".write": "auth.uid == $uid" } },
    "orders": { "$orderId": { ".read": "auth.uid == data.child('userId').val()" } }
  }
}
```

## 🧪 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widgets/

# Integration tests
flutter test integration_test/

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Test Structure
- **Unit Tests**: Business logic and data models
- **Widget Tests**: UI components and interactions
- **Integration Tests**: End-to-end user flows
- **Golden Tests**: Visual regression testing

## 🚀 Deployment

### Android
```bash
# Build APK
flutter build apk --release --flavor prod

# Build App Bundle
flutter build appbundle --release --flavor prod
```

### iOS
```bash
# Build iOS
flutter build ios --release --flavor prod

# Archive and upload
cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release archive
```

### Web (Admin Dashboard)
```bash
# Build web
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

## 📊 Analytics & Monitoring

### Firebase Analytics Events
- `view_item`: Product page views
- `add_to_cart`: Cart additions
- `begin_checkout`: Checkout starts
- `purchase`: Completed orders
- `search`: Product searches

### Performance Monitoring
- App startup time
- Screen rendering performance
- Network request latency
- Crash reporting with Crashlytics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` for linting
- Format code with `dart format`
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Firebase Team** for the backend infrastructure
- **Egyptian Heritage** for design inspiration
- **Open Source Community** for the packages used

## 📞 Support

For support and questions:
- 📧 Email: support@nefer-app.com
- 💬 Discord: [Nefer Community](https://discord.gg/nefer)
- 📖 Documentation: [docs.nefer-app.com](https://docs.nefer-app.com)
- 🐛 Issues: [GitHub Issues](https://github.com/your-org/nefer-app/issues)

---

**Built with ❤️ and ⚡ by the Nefer Team**

*Bringing the elegance of ancient Egypt to modern e-commerce*
