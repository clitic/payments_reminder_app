import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../core/constants/app_strings.dart';
import 'secure_storage_service.dart';

/// Biometric authentication service
/// Handles fingerprint and Face ID authentication for app lock
class BiometricService {
  static BiometricService? _instance;
  final LocalAuthentication _localAuth;
  final SecureStorageService _storageService;

  BiometricService._()
      : _localAuth = LocalAuthentication(),
        _storageService = SecureStorageService.instance;

  /// Get singleton instance
  static BiometricService get instance {
    _instance ??= BiometricService._();
    return _instance!;
  }

  // ===========================================================================
  // CAPABILITY CHECKS
  // ===========================================================================

  /// Check if device supports biometrics
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint('Error checking device support: $e');
      return false;
    }
  }

  /// Check if biometrics can be used (enrolled and available)
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      debugPrint('Error checking biometrics: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Check if biometrics are available and can be used
  Future<BiometricAvailability> checkBiometricAvailability() async {
    final isSupported = await isDeviceSupported();
    if (!isSupported) {
      return BiometricAvailability(
        isAvailable: false,
        reason: 'Device does not support biometric authentication',
      );
    }

    final canAuthenticate = await canCheckBiometrics();
    if (!canAuthenticate) {
      return BiometricAvailability(
        isAvailable: false,
        reason: 'No biometrics enrolled. Please set up fingerprint or Face ID in device settings.',
      );
    }

    final biometrics = await getAvailableBiometrics();
    if (biometrics.isEmpty) {
      return BiometricAvailability(
        isAvailable: false,
        reason: 'No biometric methods available',
      );
    }

    return BiometricAvailability(
      isAvailable: true,
      availableTypes: biometrics,
    );
  }

  // ===========================================================================
  // AUTHENTICATION
  // ===========================================================================

  /// Authenticate using biometrics
  Future<BiometricResult> authenticate({
    String? reason,
    bool biometricOnly = false,
  }) async {
    try {
      final availability = await checkBiometricAvailability();
      if (!availability.isAvailable) {
        return BiometricResult(
          success: false,
          message: availability.reason ?? 'Biometrics not available',
        );
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason ?? AppStrings.authenticateToAccess,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      return BiometricResult(
        success: authenticated,
        message: authenticated
            ? 'Authentication successful'
            : 'Authentication failed',
      );
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    }
  }

  /// Authenticate to unlock the app
  Future<BiometricResult> authenticateToUnlock() async {
    return await authenticate(
      reason: AppStrings.authenticateToAccess,
      biometricOnly: false, // Allow PIN/password fallback
    );
  }

  // ===========================================================================
  // SETTINGS
  // ===========================================================================

  /// Check if biometric lock is enabled
  bool isBiometricLockEnabled() {
    return _storageService.getBiometricEnabled();
  }

  /// Enable biometric lock
  Future<BiometricResult> enableBiometricLock() async {
    // First verify biometrics work
    final result = await authenticate(
      reason: 'Verify your identity to enable biometric lock',
      biometricOnly: true,
    );

    if (result.success) {
      await _storageService.setBiometricEnabled(true);
      return BiometricResult(
        success: true,
        message: 'Biometric lock enabled',
      );
    }

    return BiometricResult(
      success: false,
      message: result.message,
    );
  }

  /// Disable biometric lock
  Future<BiometricResult> disableBiometricLock() async {
    // Verify identity before disabling
    final result = await authenticate(
      reason: 'Verify your identity to disable biometric lock',
    );

    if (result.success) {
      await _storageService.setBiometricEnabled(false);
      return BiometricResult(
        success: true,
        message: 'Biometric lock disabled',
      );
    }

    return BiometricResult(
      success: false,
      message: result.message,
    );
  }

  // ===========================================================================
  // ERROR HANDLING
  // ===========================================================================

  /// Handle platform exceptions from local_auth
  BiometricResult _handlePlatformException(PlatformException e) {
    String message;

    switch (e.code) {
      case 'NotAvailable':
        message = 'Biometric authentication is not available';
        break;
      case 'NotEnrolled':
        message = 'No biometrics enrolled. Please set up in device settings.';
        break;
      case 'LockedOut':
        message = 'Too many attempts. Biometrics temporarily locked.';
        break;
      case 'PermanentlyLockedOut':
        message = 'Biometrics permanently locked. Use device PIN/password.';
        break;
      case 'PasscodeNotSet':
        message = 'Device passcode not set. Please set up a passcode first.';
        break;
      case 'OtherOperatingSystem':
        message = 'Biometrics not supported on this platform';
        break;
      default:
        message = e.message ?? 'Authentication error occurred';
    }

    debugPrint('Biometric error: ${e.code} - ${e.message}');

    return BiometricResult(
      success: false,
      message: message,
      errorCode: e.code,
    );
  }

  /// Cancel any ongoing authentication
  Future<void> cancelAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      debugPrint('Error cancelling authentication: $e');
    }
  }

  // ===========================================================================
  // UTILITY
  // ===========================================================================

  /// Get human-readable name for biometric type
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  /// Get all available biometric type names
  Future<List<String>> getAvailableBiometricNames() async {
    final types = await getAvailableBiometrics();
    return types.map(getBiometricTypeName).toList();
  }
}

/// Biometric availability result
class BiometricAvailability {
  final bool isAvailable;
  final String? reason;
  final List<BiometricType> availableTypes;

  BiometricAvailability({
    required this.isAvailable,
    this.reason,
    this.availableTypes = const [],
  });
}

/// Biometric authentication result
class BiometricResult {
  final bool success;
  final String message;
  final String? errorCode;

  BiometricResult({
    required this.success,
    required this.message,
    this.errorCode,
  });

  @override
  String toString() {
    return 'BiometricResult(success: $success, message: $message)';
  }
}
