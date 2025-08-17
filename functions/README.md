# 🔥 Nefer Firebase Cloud Functions (Dart)

This directory contains the Firebase Cloud Functions for the Nefer e-commerce application, written in **Dart** using the Functions Framework.

## 📁 Structure

```
functions/
├── bin/
│   └── main.dart             # Main entry point
├── lib/src/
│   ├── admin/
│   │   └── admin_functions.dart      # Admin management functions
│   ├── auth/
│   │   └── auth_functions.dart       # Authentication functions
│   ├── products/
│   │   └── product_functions.dart    # Product management functions
│   ├── orders/
│   │   └── order_functions.dart      # Order management functions
│   ├── payments/
│   │   └── payment_functions.dart    # Payment processing functions
│   ├── notifications/
│   │   └── notification_functions.dart # Notification functions
│   ├── analytics/
│   │   └── analytics_functions.dart  # Analytics functions
│   └── core/
│       ├── firebase_service.dart     # Firebase service wrapper
│       └── middleware.dart           # Request middleware
├── pubspec.yaml              # Dart dependencies
└── README.md                 # This file
```

## 🚀 Getting Started

### Prerequisites

- Dart SDK 3.2.0+
- Firebase CLI
- Docker (for local development)

### Installation

1. **Install dependencies**
   ```bash
   cd functions
   dart pub get
   ```

2. **Build the project**
   ```bash
   dart compile exe bin/main.dart -o bin/server
   ```

3. **Run locally**
   ```bash
   dart run bin/main.dart
   # or
   ./bin/server
   ```

4. **Deploy to Firebase**
   ```bash
   firebase deploy --only functions
   ```

## 📋 Available Scripts

```bash
# Install dependencies
dart pub get

# Run the server locally
dart run bin/main.dart

# Build executable
dart compile exe bin/main.dart -o bin/server

# Run tests
dart test

# Analyze code
dart analyze

# Format code
dart format .
```

## 🔧 Functions Overview

### Admin Functions (`/admin/*`)

- `POST /admin/users/role` - Set user role and permissions
- `POST /admin/users/create` - Create new admin user
- `POST /admin/users/{userId}/suspend` - Suspend user account
- `POST /admin/users/{userId}/activate` - Activate user account
- `DELETE /admin/users/{userId}` - Delete user account
- `GET /admin/users` - Get all users (admin only)
- `POST /admin/users/{userId}/reset-password` - Reset user password
- `GET /admin/stats` - Get admin dashboard statistics

### Authentication Functions (`/auth/*`)

- `POST /auth/validate-token` - Validate authentication token
- `POST /auth/refresh-token` - Refresh user token with updated claims
- `POST /auth/verify-email` - Verify user email

### Product Functions (`/products/*`)

- `POST /products` - Create new product
- `PUT /products/{productId}` - Update existing product
- `DELETE /products/{productId}` - Delete product
- `GET /products` - Get products with filtering
- `GET /products/search` - Search products
- `GET /products/{productId}` - Get product by ID
- `GET /products/{productId}/recommendations` - Get product recommendations

### Order Functions (`/orders/*`)

- `POST /orders` - Create new order
- `PUT /orders/{orderId}/status` - Update order status
- `POST /orders/{orderId}/cancel` - Cancel order
- `GET /orders/{orderId}` - Get order details
- `GET /users/{userId}/orders` - Get user's orders

### Payment Functions (`/payments/*`)

- `POST /payments/intent` - Create payment intent
- `POST /payments/confirm` - Confirm payment
- `POST /payments/refund` - Process refund
- `POST /payments/webhook` - Handle Stripe webhooks

### Notification Functions (`/notifications/*`)

- `POST /notifications/send` - Send push notification
- `POST /notifications/bulk` - Send bulk notifications
- `POST /notifications/schedule` - Schedule notification
- `GET /users/{userId}/notifications` - Get user notifications
- `PUT /notifications/{notificationId}/read` - Mark notification as read

### Analytics Functions (`/analytics/*`)

- `POST /analytics/track` - Track user events
- `GET /analytics/sales` - Generate sales reports
- `GET /analytics/users` - Generate user reports
- `GET /analytics/products` - Generate product reports

## 🔐 Security

### Authentication

All functions that require authentication check for:
- Valid Firebase Auth token in `Authorization: Bearer <token>` header
- User role and permissions
- Rate limiting (60 requests per minute)

### Authorization

Functions implement role-based access control:
- `customer` - Basic user permissions
- `moderator` - Content moderation permissions
- `admin` - Full administrative permissions
- `super_admin` - System-level permissions

### Middleware

The application uses several middleware layers:
- **CORS** - Cross-origin resource sharing
- **Authentication** - Token validation
- **Rate Limiting** - Request throttling
- **Logging** - Request/response logging
- **Validation** - Input validation
- **Security Headers** - Security-related HTTP headers

## 📊 Monitoring

### Logging

Functions use structured logging with different levels:
- `INFO` - Normal operations
- `WARNING` - Potential issues
- `SEVERE` - Errors and failures

### Error Handling

Comprehensive error handling with:
- Custom error responses
- Proper HTTP status codes
- User-friendly error messages
- Stack trace logging for debugging

## 🧪 Testing

### Unit Tests

```bash
dart test
```

### Integration Tests

```bash
dart test test/integration/
```

## 🚀 Deployment

### Local Development

```bash
# Set environment variables
export FIREBASE_PROJECT_ID="your-project-id"
export FIREBASE_DATABASE_URL="https://your-project.firebaseio.com"

# Run the server
dart run bin/main.dart
```

### Firebase Deployment

```bash
# Deploy to Firebase
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:function-name
```

### Docker Deployment

```bash
# Build Docker image
docker build -t nefer-functions .

# Run container
docker run -p 8080:8080 nefer-functions
```

## 📝 Environment Variables

Set these environment variables:

```bash
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
STRIPE_SECRET_KEY=sk_test_...
SENDGRID_API_KEY=SG...
```

## 🔧 Configuration

### Firebase Configuration

The functions automatically initialize Firebase Admin SDK using:
- Service account credentials from environment variables
- Default application credentials (in Cloud Functions environment)

### Dart Configuration

Key dependencies in `pubspec.yaml`:
- `functions_framework` - HTTP functions framework
- `firebase_admin` - Firebase Admin SDK
- `shelf` - HTTP server and middleware
- `shelf_router` - HTTP routing

## 📚 API Documentation

### Base URL

- Local: `http://localhost:8080`
- Production: `https://your-region-your-project.cloudfunctions.net/function`

### Authentication

Include Firebase ID token in Authorization header:
```
Authorization: Bearer <firebase-id-token>
```

### Request/Response Format

All requests and responses use JSON format:

```json
// Success Response
{
  "success": true,
  "data": { ... },
  "timestamp": "2024-01-01T00:00:00.000Z"
}

// Error Response
{
  "success": false,
  "error": {
    "message": "Error description",
    "details": { ... }
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Rate Limiting

- 60 requests per minute per IP address
- 30 search requests per minute per IP address
- 5 login attempts per hour per IP address

## 🐛 Troubleshooting

### Common Issues

1. **Firebase initialization error**
   - Check environment variables
   - Verify service account credentials
   - Ensure Firebase project is properly configured

2. **Authentication failures**
   - Verify Firebase ID token is valid
   - Check token expiration
   - Ensure user has required permissions

3. **Database connection issues**
   - Check Firebase Database URL
   - Verify database rules
   - Ensure network connectivity

### Debug Mode

Enable debug logging by setting log level:
```dart
Logger.root.level = Level.ALL;
```

## 📞 Support

- Email: dev@nefer-ecommerce.com
- Documentation: https://docs.nefer-ecommerce.com
- Issues: https://github.com/nefer/issues

## 🏗️ Architecture

The functions follow a clean architecture pattern:

```
Request → Middleware → Router → Function Handler → Firebase Service → Response
```

Each function is responsible for:
1. Input validation
2. Authentication/authorization
3. Business logic execution
4. Database operations
5. Response formatting

This ensures maintainable, testable, and scalable code.
