import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository using Firebase
class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseDatabase _firebaseDatabase;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseDatabase firebaseDatabase,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _firebaseDatabase = firebaseDatabase,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<domain.User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('Sign in failed');
      }
      
      return await _getUserFromFirebase(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<domain.User> signUpWithEmailAndPassword(
    String email, 
    String password, 
    String displayName,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('Sign up failed');
      }
      
      // Update display name
      await credential.user!.updateDisplayName(displayName);
      
      // Create user profile in database
      final user = await _createUserProfile(credential.user!, displayName);
      
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<domain.User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw Exception('Google sign in failed');
      }
      
      return await _getUserFromFirebase(userCredential.user!);
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<domain.User> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      final oauthCredential = firebase_auth.OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      
      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      
      if (userCredential.user == null) {
        throw Exception('Apple sign in failed');
      }
      
      return await _getUserFromFirebase(userCredential.user!);
    } catch (e) {
      throw Exception('Apple sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<domain.User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;
      
      return await _getUserFromFirebase(firebaseUser);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<domain.User?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      try {
        return await _getUserFromFirebase(firebaseUser);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<void> updateUserProfile(domain.User user) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw Exception('No authenticated user');
      }
      
      // Update Firebase Auth profile
      await firebaseUser.updateDisplayName(user.displayName);
      if (user.photoURL != null) {
        await firebaseUser.updatePhotoURL(user.photoURL);
      }
      
      // Update user data in database
      await _updateUserInDatabase(user);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw Exception('No authenticated user');
      }
      
      // Delete user data from database
      await _firebaseDatabase.ref('users/${firebaseUser.uid}').remove();
      
      // Delete Firebase Auth account
      await firebaseUser.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  @override
  Future<void> verifyEmail() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw Exception('No authenticated user');
      }
      
      await firebaseUser.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return false;
      
      await firebaseUser.reload();
      return firebaseUser.emailVerified;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> refreshToken() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return;
      
      await firebaseUser.getIdToken(true);
    } catch (e) {
      // Handle refresh error silently
    }
  }

  // Helper methods
  Future<domain.User> _getUserFromFirebase(firebase_auth.User firebaseUser) async {
    try {
      // Get user data from database
      final snapshot = await _firebaseDatabase.ref('users/${firebaseUser.uid}').get();
      
      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        return domain.User.fromJson({
          'uid': firebaseUser.uid,
          'email': firebaseUser.email ?? '',
          'displayName': firebaseUser.displayName,
          'photoURL': firebaseUser.photoURL,
          'phoneNumber': firebaseUser.phoneNumber,
          'emailVerified': firebaseUser.emailVerified,
          'isAnonymous': firebaseUser.isAnonymous,
          ...userData,
        });
      } else {
        // Create new user profile if doesn't exist
        return await _createUserProfile(firebaseUser, firebaseUser.displayName ?? '');
      }
    } catch (e) {
      // Return basic user info if database read fails
      return domain.User(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        phoneNumber: firebaseUser.phoneNumber,
        emailVerified: firebaseUser.emailVerified,
        isAnonymous: firebaseUser.isAnonymous,
        role: domain.UserRoles.customer,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    }
  }

  Future<domain.User> _createUserProfile(
    firebase_auth.User firebaseUser, 
    String displayName,
  ) async {
    final now = DateTime.now();
    final user = domain.User(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: displayName.isNotEmpty ? displayName : null,
      photoURL: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      emailVerified: firebaseUser.emailVerified,
      isAnonymous: firebaseUser.isAnonymous,
      role: domain.UserRoles.customer,
      profile: const domain.UserProfile(),
      preferences: const domain.UserPreferences(),
      createdAt: now,
      lastLoginAt: now,
      updatedAt: now,
    );
    
    // Save to database
    await _updateUserInDatabase(user);
    
    return user;
  }

  Future<void> _updateUserInDatabase(domain.User user) async {
    await _firebaseDatabase.ref('users/${user.uid}').set(user.toJson());
  }

  Exception _handleFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email address');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'email-already-in-use':
        return Exception('An account already exists with this email address');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please try again later');
      case 'operation-not-allowed':
        return Exception('This sign-in method is not enabled');
      default:
        return Exception(e.message ?? 'Authentication failed');
    }
  }
}
