import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';

/// Authentication state provider
/// Manages user authentication state across the app
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final SecureStorageService _storageService;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  AuthProvider()
      : _authService = AuthService.instance,
        _storageService = SecureStorageService.instance {
    _initialize();
  }

  // ===========================================================================
  // GETTERS
  // ===========================================================================

  /// Current authenticated user
  AppUser? get currentUser => _currentUser;

  /// Whether authentication is in progress
  bool get isLoading => _isLoading;

  /// Error message from last operation
  String? get errorMessage => _errorMessage;

  /// Whether the provider has finished initializing
  bool get isInitialized => _isInitialized;

  /// Whether a user is currently signed in (including guest)
  bool get isSignedIn => _currentUser != null;

  /// Whether the current user is a guest
  bool get isGuest => _currentUser?.isGuest ?? false;

  /// Whether the current user can sync to cloud
  bool get canSyncToCloud => _currentUser?.canSyncToCloud ?? false;

  /// Get user ID for database queries
  String get userId => _currentUser?.effectiveUserId ?? 'guest';

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Initialize auth state
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check for existing Firebase auth
      if (_authService.isSignedIn) {
        _currentUser = _authService.currentUser;
      } else {
        // Check for saved guest session
        final guestId = _storageService.getGuestUserId();
        if (guestId != null) {
          _currentUser = AppUser(
            uid: guestId,
            isGuest: true,
          );
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();

    // Listen to auth state changes
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  /// Handle Firebase auth state changes
  void _onAuthStateChanged(dynamic firebaseUser) {
    if (firebaseUser != null) {
      _currentUser = AppUser(
        uid: firebaseUser.uid as String?,
        email: firebaseUser.email as String?,
        displayName: firebaseUser.displayName as String?,
        isGuest: false,
        emailVerified: firebaseUser.emailVerified as bool? ?? false,
      );
      // Clear guest ID if signing in with real account
      _storageService.clearGuestUserId();
    } else if (!isGuest) {
      // Only clear if not in guest mode
      _currentUser = null;
    }
    notifyListeners();
  }

  // ===========================================================================
  // AUTHENTICATION METHODS
  // ===========================================================================

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );

      // If was guest, we might want to migrate data
      final wasGuest = isGuest;
      final oldGuestId = _currentUser?.uid;

      _currentUser = user;
      await _storageService.clearGuestUserId();

      _isLoading = false;
      notifyListeners();

      // Return guest info for potential data migration
      if (wasGuest && oldGuestId != null) {
        debugPrint('Converted guest $oldGuestId to account ${user.uid}');
      }

      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      _currentUser = user;
      await _storageService.clearGuestUserId();

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Continue as guest
  Future<bool> continueAsGuest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final guestUser = _authService.createGuestUser();
      _currentUser = guestUser;

      // Save guest ID for persistence
      await _storageService.setGuestUserId(guestUser.uid!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to start guest mode';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!isGuest) {
        await _authService.signOut();
      }

      await _storageService.clearGuestUserId();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      debugPrint('Error signing out: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ===========================================================================
  // PASSWORD MANAGEMENT
  // ===========================================================================

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to send reset email';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===========================================================================
  // GUEST CONVERSION
  // ===========================================================================

  /// Convert guest account to full account
  Future<bool> convertGuestToAccount({
    required String email,
    required String password,
  }) async {
    if (!isGuest) {
      _errorMessage = 'Not in guest mode';
      notifyListeners();
      return false;
    }

    final oldGuestId = _currentUser?.uid;

    final success = await signUp(email: email, password: password);

    if (success && oldGuestId != null) {
      // Data migration should be handled by the payment provider
      debugPrint('Guest $oldGuestId converted to ${_currentUser?.uid}');
    }

    return success;
  }

  // ===========================================================================
  // UTILITY
  // ===========================================================================

  /// Refresh user data
  Future<void> refreshUser() async {
    if (_authService.isSignedIn) {
      _currentUser = _authService.currentUser;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
