# 🏛️ Nefer Admin System Setup Guide

This guide will help you set up the complete admin system for the Nefer e-commerce app, including creating admin users and configuring role-based access control.

## 📋 Overview

The Nefer admin system provides:
- **Two-tier user system**: Regular users and Admin users
- **Role-based access control** with granular permissions
- **Complete admin dashboard** for managing all app aspects
- **Firebase Security Rules** for data protection
- **Cloud Functions** for admin operations

## 🔧 Prerequisites

Before setting up the admin system, ensure you have:

1. **Firebase project** created and configured
2. **Firebase CLI** installed and authenticated
3. **Node.js** (v16 or higher) installed
4. **Flutter project** set up with Firebase

## 🚀 Step-by-Step Setup

### Step 1: Firebase Configuration

#### 1.1 Enable Firebase Services
```bash
# Enable required Firebase services
firebase use your-project-id

# Enable Authentication
firebase auth:enable

# Enable Realtime Database
firebase database:create

# Enable Cloud Functions
firebase functions:config:set
```

#### 1.2 Configure Authentication
In Firebase Console:
1. Go to **Authentication > Sign-in method**
2. Enable **Email/Password** provider
3. Configure **Authorized domains** for your app

### Step 2: Deploy Security Rules

#### 2.1 Deploy Database Rules
```bash
# Copy the provided security rules
cp firebase_security_rules.json database.rules.json

# Deploy the rules
firebase deploy --only database
```

#### 2.2 Verify Rules Deployment
```bash
# Test the rules (optional)
firebase database:rules:get
```

### Step 3: Deploy Cloud Functions

#### 3.1 Install Dependencies
```bash
cd functions
npm install firebase-functions firebase-admin
```

#### 3.2 Deploy Functions
```bash
# Deploy all admin functions
firebase deploy --only functions

# Or deploy specific functions
firebase deploy --only functions:setUserRole,functions:createAdminUser
```

### Step 4: Create Admin Users

#### 4.1 Download Service Account Key
1. Go to **Firebase Console > Project Settings > Service Accounts**
2. Click **Generate new private key**
3. Save as `firebase-service-account.json` in project root

#### 4.2 Set Environment Variables (Optional)
```bash
# Create .env file for admin setup
cat > .env << EOF
FIREBASE_PROJECT_ID=your-project-id
ADMIN1_EMAIL=admin1@yourcompany.com
ADMIN1_PASSWORD=SecurePassword123!
ADMIN2_EMAIL=admin2@yourcompany.com
ADMIN2_PASSWORD=SecurePassword456!
EOF
```

#### 4.3 Run Admin Setup Script
```bash
# Make script executable
chmod +x scripts/setup_admin_users.js

# Run the setup script
node scripts/setup_admin_users.js
```

#### 4.4 Manual Admin Creation (Alternative)
If the script doesn't work, create admins manually:

```javascript
// Use Firebase Console or custom script
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://your-project-default-rtdb.firebaseio.com'
});

// Create admin user
async function createAdmin() {
  const userRecord = await admin.auth().createUser({
    email: 'admin@yourcompany.com',
    password: 'SecurePassword123!',
    displayName: 'Admin User',
    emailVerified: true,
  });

  // Set admin claims
  await admin.auth().setCustomUserClaims(userRecord.uid, {
    role: 'admin',
    level: 100,
    isAdmin: true,
  });

  // Save user data
  await admin.database().ref(`users/${userRecord.uid}`).set({
    uid: userRecord.uid,
    email: 'admin@yourcompany.com',
    displayName: 'Admin User',
    role: {
      id: 'admin',
      name: 'admin',
      displayName: 'Administrator',
      level: 100,
    },
    status: { status: 'active' },
    createdAt: admin.database.ServerValue.TIMESTAMP,
  });
}
```

### Step 5: Configure Flutter App

#### 5.1 Update App Router
Ensure your app router includes admin routes:

```dart
// lib/core/routing/app_router.dart
GoRoute(
  path: '/admin',
  name: RouteNames.admin,
  builder: (context, state) => const AdminDashboardScreen(),
  redirect: (context, state) {
    final user = ref.read(currentUserProvider);
    if (user == null || !user.canAccessAdminDashboard()) {
      return '/login';
    }
    return null;
  },
),
```

#### 5.2 Add Route Guards
```dart
// lib/core/routing/route_guards.dart
class AdminRouteGuard {
  static String? checkAdminAccess(BuildContext context, GoRouterState state) {
    final user = context.read(currentUserProvider);
    
    if (user == null) {
      return '/login';
    }
    
    if (!user.canAccessAdminDashboard()) {
      return '/access-denied';
    }
    
    return null;
  }
}
```

### Step 6: Test Admin System

#### 6.1 Test Admin Login
1. Run your Flutter app
2. Navigate to login screen
3. Login with admin credentials
4. Verify admin dashboard access

#### 6.2 Test Admin Functions
```bash
# Test user role setting
firebase functions:shell
> setUserRole({uid: 'user-id', role: 'admin'})

# Test user creation
> createAdminUser({email: 'test@admin.com', password: 'password123', displayName: 'Test Admin'})
```

#### 6.3 Verify Database Structure
Check Firebase Console > Realtime Database:
```json
{
  "users": {
    "admin-uid": {
      "uid": "admin-uid",
      "email": "admin@company.com",
      "role": {
        "id": "admin",
        "name": "admin",
        "level": 100
      },
      "status": {
        "status": "active"
      }
    }
  }
}
```

## 🔐 Security Considerations

### Authentication Security
- Use strong passwords for admin accounts
- Enable 2FA when available
- Regularly rotate admin passwords
- Monitor admin login activities

### Database Security
- Review security rules regularly
- Audit admin actions via logs
- Implement IP restrictions if needed
- Use Firebase App Check for additional security

### Function Security
- Validate all input parameters
- Log all admin operations
- Implement rate limiting
- Use HTTPS callable functions only

## 🎛️ Admin Dashboard Features

### User Management
- View all users in data table
- Search and filter users
- Edit user profiles and roles
- Suspend/activate user accounts
- Reset user passwords
- Delete user accounts

### Product Management
- Add/edit/delete products
- Manage product categories
- Update inventory levels
- Set product pricing
- Manage product images

### Order Management
- View all orders
- Update order status
- Process refunds
- Manage shipping
- Generate invoices

### Analytics & Reports
- View sales analytics
- User engagement metrics
- Product performance reports
- Revenue tracking
- Export data to CSV/Excel

### System Management
- App configuration settings
- Feature flags management
- Maintenance mode toggle
- Admin activity logs
- System health monitoring

## 🚨 Troubleshooting

### Common Issues

#### Admin Login Fails
```bash
# Check custom claims
firebase auth:export users.json
# Look for admin users and verify claims
```

#### Permission Denied Errors
```bash
# Verify security rules
firebase database:rules:get

# Check user role in database
firebase database:get /users/USER_ID/role
```

#### Functions Not Working
```bash
# Check function logs
firebase functions:log

# Redeploy functions
firebase deploy --only functions --force
```

#### Dashboard Not Loading
1. Check console for JavaScript errors
2. Verify Firebase configuration
3. Ensure user has admin role
4. Check network connectivity

### Debug Commands
```bash
# Check Firebase project
firebase projects:list

# Verify authentication
firebase auth:export users.json

# Check database rules
firebase database:rules:get

# View function logs
firebase functions:log --limit 50
```

## 📞 Support

If you encounter issues:

1. **Check the logs**: Firebase Console > Functions > Logs
2. **Verify permissions**: Ensure admin users have correct roles
3. **Test security rules**: Use Firebase Rules Playground
4. **Review documentation**: Firebase Auth and Database docs

## 🎯 Next Steps

After setting up the admin system:

1. **Customize the dashboard** for your specific needs
2. **Add more admin features** as required
3. **Set up monitoring** and alerting
4. **Train admin users** on the dashboard
5. **Implement backup procedures** for admin data

---

**🏛️ Your Nefer admin system is now ready! Welcome to the digital marketplace of the pharaohs! ✨**
