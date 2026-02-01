import 'dart:async';
import '../models/user.dart';

/// Authentication service - Mock implementation without Firebase
/// Works fully offline for development without Firebase configuration
class AuthService {
  static AuthService? _instance;
  
  // Mock state
  AppUser? _currentUser;
  final StreamController<dynamic> _authStateController = StreamController<dynamic>.broadcast();

  AuthService._();

  /// Get singleton instance
  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  // ===========================================================================
  // AUTH STATE
  // ===========================================================================

  /// Stream of authentication state changes (mock)
  Stream<dynamic> get authStateChanges => _authStateController.stream;

  /// Get current app user
  AppUser? get currentUser => _currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _currentUser != null;

  // ===========================================================================
  // EMAIL/PASSWORD AUTHENTICATION (Mock)
  // ===========================================================================

  /// Sign up with email and password (mock - stores locally)
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Create mock user
    _currentUser = AppUser(
      uid: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first,
      isGuest: false,
      emailVerified: true,
    );
    
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  /// Sign in with email and password (mock)
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Create mock user
    _currentUser = AppUser(
      uid: 'mock_${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
      isGuest: false,
      emailVerified: true,
    );
    
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  /// Sign out
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  // ===========================================================================
  // PASSWORD MANAGEMENT (Mock)
  // ===========================================================================

  /// Send password reset email (mock - just succeeds)
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock: always succeeds
  }

  /// Update password (mock)
  Future<void> updatePassword(String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock: always succeeds
  }

  /// Re-authenticate user (mock)
  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock: always succeeds
  }

  // ===========================================================================
  // EMAIL VERIFICATION (Mock)
  // ===========================================================================

  /// Send email verification (mock)
  Future<void> sendEmailVerification() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Check email verified (mock - always true)
  Future<bool> checkEmailVerified() async {
    return true;
  }

  // ===========================================================================
  // PROFILE MANAGEMENT (Mock)
  // ===========================================================================

  /// Update display name (mock)
  Future<void> updateDisplayName(String displayName) async {
    if (_currentUser != null) {
      _currentUser = AppUser(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        displayName: displayName,
        isGuest: _currentUser!.isGuest,
        emailVerified: _currentUser!.emailVerified,
      );
    }
  }

  /// Delete account (mock)
  Future<void> deleteAccount() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  // ===========================================================================
  // GUEST MODE
  // ===========================================================================

  /// Create a guest user
  AppUser createGuestUser() {
    return AppUser.guest();
  }

  /// Convert guest to full account
  Future<AppUser> convertGuestToAccount({
    required String email,
    required String password,
  }) async {
    return await signUpWithEmail(email: email, password: password);
  }
  
  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => message;
}
