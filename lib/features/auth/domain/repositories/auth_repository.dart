import '../entities/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<User> signInWithEmailAndPassword(String email, String password);
  
  /// Sign up with email and password
  Future<User> signUpWithEmailAndPassword(String email, String password, String displayName);
  
  /// Sign in with Google
  Future<User> signInWithGoogle();
  
  /// Sign in with Apple
  Future<User> signInWithApple();
  
  /// Sign out
  Future<void> signOut();
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);
  
  /// Get current user
  Future<User?> getCurrentUser();
  
  /// Stream of authentication state changes
  Stream<User?> authStateChanges();
  
  /// Update user profile
  Future<void> updateUserProfile(User user);
  
  /// Delete user account
  Future<void> deleteAccount();
  
  /// Verify email
  Future<void> verifyEmail();
  
  /// Check if email is verified
  Future<bool> isEmailVerified();
  
  /// Refresh user token
  Future<void> refreshToken();
}
