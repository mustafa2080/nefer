import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_controller.freezed.dart';

/// Authentication state
@freezed
class AuthState with _$AuthState {
  const factory AuthState.loading() = _Loading;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.error(String message, [StackTrace? stackTrace]) = _Error;
}

/// Authentication controller
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AuthState.loading()) {
    _initializeAuth();
  }

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e, stackTrace) {
      state = AuthState.error(e.toString(), stackTrace);
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = const AuthState.loading();
      final user = await _authRepository.signInWithEmailAndPassword(email, password);
      state = AuthState.authenticated(user);
      return true;
    } catch (e, stackTrace) {
      state = AuthState.error(e.toString(), stackTrace);
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmailAndPassword(
    String email, 
    String password, 
    String displayName,
  ) async {
    try {
      state = const AuthState.loading();
      final user = await _authRepository.signUpWithEmailAndPassword(
        email, 
        password, 
        displayName,
      );
      state = AuthState.authenticated(user);
      return true;
    } catch (e, stackTrace) {
      state = AuthState.error(e.toString(), stackTrace);
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      state = const AuthState.loading();
      final user = await _authRepository.signInWithGoogle();
      state = AuthState.authenticated(user);
      return true;
    } catch (e, stackTrace) {
      state = AuthState.error(e.toString(), stackTrace);
      return false;
    }
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      state = const AuthState.loading();
      final user = await _authRepository.signInWithApple();
      state = AuthState.authenticated(user);
      return true;
    } catch (e, stackTrace) {
      state = AuthState.error(e.toString(), stackTrace);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e, stackTrace) {
      state = AuthState.error(e.toString(), stackTrace);
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _authRepository.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(User user) async {
    try {
      await _authRepository.updateUserProfile(user);
      state = AuthState.authenticated(user);
      return true;
    } catch (e, stackTrace) {
      state = AuthState.error(e.toString(), stackTrace);
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    try {
      await _authRepository.deleteAccount();
      state = const AuthState.unauthenticated();
      return true;
    } catch (e, stackTrace) {
      state = AuthState.error(e.toString(), stackTrace);
      return false;
    }
  }

  /// Verify email
  Future<bool> verifyEmail() async {
    try {
      await _authRepository.verifyEmail();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      return await _authRepository.isEmailVerified();
    } catch (e) {
      return false;
    }
  }

  /// Refresh token
  Future<void> refreshToken() async {
    try {
      await _authRepository.refreshToken();
    } catch (e) {
      // Handle refresh error silently
    }
  }

  /// Get auth state stream
  Stream<AuthState> get authStateStream async* {
    yield state;
    
    await for (final user in _authRepository.authStateChanges()) {
      if (user != null) {
        yield AuthState.authenticated(user);
      } else {
        yield const AuthState.unauthenticated();
      }
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => state.maybeWhen(
    authenticated: (_) => true,
    orElse: () => false,
  );

  /// Check if user is loading
  bool get isLoading => state.maybeWhen(
    loading: () => true,
    orElse: () => false,
  );

  /// Get current user
  User? get currentUser => state.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );

  /// Get error message
  String? get errorMessage => state.maybeWhen(
    error: (message, _) => message,
    orElse: () => null,
  );

  /// Clear error
  void clearError() {
    if (state is _Error) {
      state = const AuthState.unauthenticated();
    }
  }
}

/// Auth state extensions
extension AuthStateExtension on AuthState {
  bool get isLoading => this is _Loading;
  bool get isAuthenticated => this is _Authenticated;
  bool get isUnauthenticated => this is _Unauthenticated;
  bool get hasError => this is _Error;
  
  User? get user => maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
  
  String? get error => maybeWhen(
    error: (message, _) => message,
    orElse: () => null,
  );
}
