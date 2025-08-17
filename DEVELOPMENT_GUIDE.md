# 🏛️ Nefer Development Guide

This comprehensive guide will help you set up, develop, and deploy the Nefer e-commerce application.

## 🚀 Quick Start

### Automated Setup
```bash
# Make setup script executable
chmod +x scripts/setup_nefer_app.sh

# Run automated setup
./scripts/setup_nefer_app.sh
```

### Manual Setup
If you prefer manual setup or the automated script fails:

1. **Install Prerequisites**
   ```bash
   # Install Flutter SDK (3.16.0+)
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Install Node.js (16+)
   # Install Git
   ```

2. **Clone and Setup**
   ```bash
   git clone <repository-url>
   cd nefer
   flutter pub get
   flutter gen-l10n
   flutter packages pub run build_runner build
   ```

3. **Firebase Configuration**
   ```bash
   firebase login
   firebase init
   firebase deploy --only database,functions
   ```

## 🏗️ Development Workflow

### Running the App

#### Development Mode
```bash
# Run on connected device/emulator
flutter run --flavor dev

# Run with hot reload
flutter run --flavor dev --hot

# Run on specific device
flutter run --flavor dev -d <device-id>
```

#### Web Development (Admin Dashboard)
```bash
# Run web version
flutter run -d chrome --web-port 8080

# Build web version
flutter build web --release
```

### Code Generation

#### Generate Models and Providers
```bash
# Watch for changes and auto-generate
flutter packages pub run build_runner watch

# One-time generation
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### Generate Localization
```bash
# Generate l10n files
flutter gen-l10n

# Add new translations in lib/l10n/
```

### Testing

#### Unit Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/auth_test.dart
```

#### Integration Tests
```bash
# Run integration tests
flutter test integration_test/

# Run on specific device
flutter test integration_test/ -d <device-id>
```

#### Widget Tests
```bash
# Run widget tests
flutter test test/widgets/

# Run with verbose output
flutter test test/widgets/ --verbose
```

## 📱 Platform-Specific Development

### Android Development

#### Setup
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Build debug APK
flutter build apk --debug --flavor dev

# Build release APK
flutter build apk --release --flavor prod

# Build App Bundle
flutter build appbundle --release --flavor prod
```

#### Debugging
```bash
# View logs
flutter logs

# Debug on device
flutter attach

# Profile performance
flutter run --profile --flavor dev
```

### iOS Development

#### Setup
```bash
# Install pods
cd ios && pod install && cd ..

# Build iOS
flutter build ios --release --flavor prod

# Run on simulator
flutter run -d "iPhone 14 Pro"
```

#### Debugging
```bash
# View iOS logs
flutter logs

# Debug on device
flutter attach -d <ios-device-id>
```

### Web Development

#### Admin Dashboard
```bash
# Run admin dashboard
flutter run -d chrome --web-port 8080 --dart-define=FLUTTER_WEB_USE_SKIA=true

# Build for production
flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true
```

## 🔧 Development Tools

### VS Code Extensions
- Flutter
- Dart
- Firebase
- GitLens
- Error Lens
- Bracket Pair Colorizer

### Android Studio Plugins
- Flutter
- Dart
- Firebase
- ADB Idea

### Useful Commands

#### Flutter Doctor
```bash
# Check Flutter installation
flutter doctor

# Check for issues
flutter doctor -v
```

#### Clean and Reset
```bash
# Clean build files
flutter clean

# Reset pub cache
flutter pub cache repair

# Reset iOS pods
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
```

#### Performance Analysis
```bash
# Profile app performance
flutter run --profile

# Analyze bundle size
flutter build apk --analyze-size

# Memory profiling
flutter run --profile --trace-startup
```

## 🎨 Design System Development

### Theme Development
```dart
// Update themes in lib/core/theme/
// Test with both light and dark modes
// Ensure accessibility compliance
```

### Component Development
```dart
// Create reusable components in lib/features/shared/presentation/widgets/
// Follow naming convention: PharaohComponentName
// Include documentation and examples
```

### Animation Development
```dart
// Use AnimationController for complex animations
// Prefer implicit animations for simple effects
// Test on different devices for performance
```

## 🔥 Firebase Development

### Realtime Database
```bash
# Deploy rules
firebase deploy --only database

# Import data
firebase database:set / data.json

# Export data
firebase database:get / > backup.json
```

### Cloud Functions
```bash
# Deploy functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:functionName

# View logs
firebase functions:log
```

### Storage
```bash
# Deploy storage rules
firebase deploy --only storage

# Upload files
firebase storage:upload local-file.jpg gs://bucket/remote-file.jpg
```

### Authentication
```bash
# Export users
firebase auth:export users.json

# Import users
firebase auth:import users.json
```

## 🧪 Testing Strategy

### Test Structure
```
test/
├── unit/                 # Unit tests
│   ├── models/
│   ├── services/
│   └── controllers/
├── widget/               # Widget tests
│   ├── screens/
│   └── components/
├── integration/          # Integration tests
│   ├── auth_flow_test.dart
│   ├── purchase_flow_test.dart
│   └── admin_flow_test.dart
└── mocks/               # Mock objects
```

### Writing Tests
```dart
// Unit test example
testWidgets('should display product name', (tester) async {
  await tester.pumpWidget(ProductCard(product: mockProduct));
  expect(find.text('Test Product'), findsOneWidget);
});

// Integration test example
testWidgets('complete purchase flow', (tester) async {
  // Test full user journey
});
```

## 📊 Performance Optimization

### App Performance
```bash
# Profile app startup
flutter run --profile --trace-startup

# Analyze build size
flutter build apk --analyze-size

# Memory profiling
flutter run --profile --trace-systrace
```

### Code Optimization
- Use `const` constructors where possible
- Implement lazy loading for large lists
- Optimize image loading and caching
- Use `ListView.builder` for dynamic lists
- Implement proper state management

### Database Optimization
- Index frequently queried fields
- Use pagination for large datasets
- Implement proper caching strategies
- Optimize Firebase rules for performance

## 🚀 Deployment

### Development Deployment
```bash
# Deploy to Firebase Hosting (staging)
firebase use staging
firebase deploy --only hosting

# Deploy Cloud Functions
firebase deploy --only functions
```

### Production Deployment
```bash
# Build production apps
flutter build apk --release --flavor prod
flutter build ios --release --flavor prod
flutter build web --release

# Deploy to app stores
# Deploy web to production hosting
```

### CI/CD Pipeline
```yaml
# GitHub Actions example
name: Build and Deploy
on:
  push:
    branches: [main]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --release
```

## 🐛 Debugging

### Common Issues

#### Build Failures
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --debug
```

#### Firebase Issues
```bash
# Check Firebase configuration
firebase projects:list
firebase use <project-id>

# Verify rules
firebase database:rules:get
```

#### Performance Issues
```bash
# Profile performance
flutter run --profile
flutter run --trace-startup
```

### Debug Tools
- Flutter Inspector
- Firebase Console
- Chrome DevTools
- Android Studio Profiler
- Xcode Instruments

## 📚 Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Firebase Community](https://firebase.google.com/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

### Learning
- [Flutter Codelabs](https://codelabs.developers.google.com/?cat=Flutter)
- [Firebase Codelabs](https://codelabs.developers.google.com/?cat=Firebase)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

---

**Happy coding! 🏛️ Build amazing experiences with Nefer! ✨**
