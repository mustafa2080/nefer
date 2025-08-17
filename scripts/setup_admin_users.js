#!/usr/bin/env node

/**
 * Setup script to create initial admin users for Nefer app
 * 
 * This script creates two admin users with full dashboard access.
 * Run this script after setting up Firebase project.
 * 
 * Usage:
 *   node scripts/setup_admin_users.js
 * 
 * Environment variables required:
 *   FIREBASE_PROJECT_ID - Your Firebase project ID
 *   ADMIN1_EMAIL - Email for first admin user
 *   ADMIN1_PASSWORD - Password for first admin user
 *   ADMIN2_EMAIL - Email for second admin user
 *   ADMIN2_PASSWORD - Password for second admin user
 */

const admin = require('firebase-admin');
const readline = require('readline');

// Initialize Firebase Admin SDK
const serviceAccount = require('../firebase-service-account.json'); // You need to download this from Firebase Console

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: `https://${process.env.FIREBASE_PROJECT_ID || 'your-project-id'}-default-rtdb.firebaseio.com`
});

const auth = admin.auth();
const db = admin.database();

// Create readline interface for user input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Utility function to prompt user input
function prompt(question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer);
    });
  });
}

// Utility function to prompt password (hidden input)
function promptPassword(question) {
  return new Promise((resolve) => {
    process.stdout.write(question);
    process.stdin.setRawMode(true);
    process.stdin.resume();
    process.stdin.setEncoding('utf8');
    
    let password = '';
    
    process.stdin.on('data', function(char) {
      char = char + '';
      
      switch(char) {
        case '\n':
        case '\r':
        case '\u0004':
          process.stdin.setRawMode(false);
          process.stdin.pause();
          process.stdout.write('\n');
          resolve(password);
          break;
        case '\u0003':
          process.exit();
          break;
        case '\u007f': // Backspace
          if (password.length > 0) {
            password = password.slice(0, -1);
            process.stdout.write('\b \b');
          }
          break;
        default:
          password += char;
          process.stdout.write('*');
          break;
      }
    });
  });
}

// Function to create admin user
async function createAdminUser(email, password, displayName) {
  try {
    console.log(`\n🔄 Creating admin user: ${email}`);
    
    // Create user account
    const userRecord = await auth.createUser({
      email,
      password,
      displayName,
      emailVerified: true,
    });
    
    console.log(`✅ User account created with UID: ${userRecord.uid}`);
    
    // Set admin custom claims
    const customClaims = {
      role: 'admin',
      level: 100,
      isAdmin: true,
      permissions: [
        'accessAdminDashboard',
        'manageProducts',
        'manageCategories',
        'manageUsers',
        'manageOrders',
        'manageReviews',
        'manageCoupons',
        'manageFlashSales',
        'viewAnalytics',
        'manageSettings',
        'manageContent',
        'exportData',
        'manageInventory',
        'processRefunds',
        'manageShipping',
        'moderateContent',
      ],
    };
    
    await auth.setCustomUserClaims(userRecord.uid, customClaims);
    console.log(`✅ Admin custom claims set`);
    
    // Create user data in Realtime Database
    const userData = {
      uid: userRecord.uid,
      email,
      displayName,
      role: {
        id: 'admin',
        name: 'admin',
        displayName: 'Administrator',
        displayNameAr: 'مدير النظام',
        permissions: customClaims.permissions,
        level: 100,
        isActive: true,
      },
      profile: {
        firstName: displayName?.split(' ')[0] || 'Admin',
        lastName: displayName?.split(' ').slice(1).join(' ') || 'User',
        verification: {
          emailVerified: true,
          phoneVerified: false,
          identityVerified: true,
        },
      },
      preferences: {
        language: 'en',
        currency: 'USD',
        theme: 'system',
        pushNotifications: true,
        emailNotifications: true,
        smsNotifications: false,
        marketingEmails: false,
        orderUpdates: true,
        promotionalOffers: false,
      },
      status: {
        status: 'active',
        flags: ['admin_user', 'verified'],
      },
      emailVerified: true,
      phoneVerified: false,
      createdAt: admin.database.ServerValue.TIMESTAMP,
      updatedAt: admin.database.ServerValue.TIMESTAMP,
      lastLoginAt: null,
    };
    
    await db.ref(`users/${userRecord.uid}`).set(userData);
    console.log(`✅ User data saved to database`);
    
    // Log admin creation
    const logRef = db.ref('admin_logs').push();
    await logRef.set({
      id: logRef.key,
      adminId: 'system',
      action: 'create_admin_user',
      details: {
        newAdminId: userRecord.uid,
        email,
        displayName,
      },
      timestamp: admin.database.ServerValue.TIMESTAMP,
    });
    
    console.log(`✅ Admin user created successfully!`);
    console.log(`   UID: ${userRecord.uid}`);
    console.log(`   Email: ${email}`);
    console.log(`   Display Name: ${displayName}`);
    
    return userRecord;
    
  } catch (error) {
    console.error(`❌ Error creating admin user:`, error.message);
    throw error;
  }
}

// Function to verify admin user
async function verifyAdminUser(uid) {
  try {
    const userRecord = await auth.getUser(uid);
    const customClaims = userRecord.customClaims || {};
    
    console.log(`\n🔍 Verifying admin user: ${userRecord.email}`);
    console.log(`   Role: ${customClaims.role}`);
    console.log(`   Is Admin: ${customClaims.isAdmin}`);
    console.log(`   Level: ${customClaims.level}`);
    console.log(`   Email Verified: ${userRecord.emailVerified}`);
    
    if (customClaims.role === 'admin' && customClaims.isAdmin === true) {
      console.log(`✅ Admin verification successful`);
      return true;
    } else {
      console.log(`❌ Admin verification failed`);
      return false;
    }
  } catch (error) {
    console.error(`❌ Error verifying admin user:`, error.message);
    return false;
  }
}

// Main setup function
async function setupAdminUsers() {
  console.log('🏛️  Nefer Admin Users Setup');
  console.log('============================\n');
  
  try {
    // Check if we're using environment variables or prompting
    let admin1Email = process.env.ADMIN1_EMAIL;
    let admin1Password = process.env.ADMIN1_PASSWORD;
    let admin2Email = process.env.ADMIN2_EMAIL;
    let admin2Password = process.env.ADMIN2_PASSWORD;
    
    // If environment variables are not set, prompt for input
    if (!admin1Email || !admin1Password || !admin2Email || !admin2Password) {
      console.log('Environment variables not found. Please enter admin details manually.\n');
      
      // First admin user
      console.log('👤 First Admin User:');
      admin1Email = await prompt('Email: ');
      admin1Password = await promptPassword('Password: ');
      const admin1Name = await prompt('Display Name: ');
      
      console.log('\n👤 Second Admin User:');
      admin2Email = await prompt('Email: ');
      admin2Password = await promptPassword('Password: ');
      const admin2Name = await prompt('Display Name: ');
      
      // Create first admin user
      const admin1 = await createAdminUser(admin1Email, admin1Password, admin1Name);
      
      // Create second admin user
      const admin2 = await createAdminUser(admin2Email, admin2Password, admin2Name);
      
      // Verify both admin users
      await verifyAdminUser(admin1.uid);
      await verifyAdminUser(admin2.uid);
      
    } else {
      console.log('Using environment variables for admin setup.\n');
      
      // Create first admin user
      const admin1 = await createAdminUser(admin1Email, admin1Password, 'Admin User 1');
      
      // Create second admin user
      const admin2 = await createAdminUser(admin2Email, admin2Password, 'Admin User 2');
      
      // Verify both admin users
      await verifyAdminUser(admin1.uid);
      await verifyAdminUser(admin2.uid);
    }
    
    console.log('\n🎉 Admin setup completed successfully!');
    console.log('\nNext steps:');
    console.log('1. Deploy Firebase Security Rules: firebase deploy --only database');
    console.log('2. Deploy Cloud Functions: firebase deploy --only functions');
    console.log('3. Test admin login in your app');
    console.log('4. Access admin dashboard at: https://your-app.web.app/admin');
    
  } catch (error) {
    console.error('\n❌ Setup failed:', error.message);
    process.exit(1);
  } finally {
    rl.close();
    process.exit(0);
  }
}

// Run the setup
if (require.main === module) {
  setupAdminUsers();
}

module.exports = {
  createAdminUser,
  verifyAdminUser,
  setupAdminUsers,
};
