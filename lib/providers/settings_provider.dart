import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../services/secure_storage_service.dart';
import '../services/biometric_service.dart';

/// Settings state provider
/// Manages app preferences and settings
class SettingsProvider extends ChangeNotifier {
  final SecureStorageService _storageService;
  final BiometricService _biometricService;

  bool _isLoading = false;
  String? _errorMessage;

  // Settings values
  ThemeMode _themeMode = ThemeMode.system;
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;
  List<ReminderType> _defaultReminderTypes = [
    ReminderType.oneDayBefore,
    ReminderType.onDueDate,
  ];

  SettingsProvider()
      : _storageService = SecureStorageService.instance,
        _biometricService = BiometricService.instance {
    _loadSettings();
  }

  // ===========================================================================
  // GETTERS
  // ===========================================================================

  /// Whether settings are loading
  bool get isLoading => _isLoading;

  /// Error message
  String? get errorMessage => _errorMessage;

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Whether biometric lock is enabled
  bool get biometricEnabled => _biometricEnabled;

  /// Whether notifications are enabled
  bool get notificationsEnabled => _notificationsEnabled;

  /// Default reminder types for new payments
  List<ReminderType> get defaultReminderTypes => _defaultReminderTypes;

  /// Get last sync time
  DateTime? get lastSyncTime => _storageService.getLastSyncTime();

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Load settings from storage
  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load theme mode
      final themeModeStr = _storageService.getThemeMode();
      _themeMode = _themeModeFromString(themeModeStr);

      // Load biometric setting
      _biometricEnabled = _storageService.getBiometricEnabled();

      // Load notifications setting
      _notificationsEnabled = _storageService.getNotificationsEnabled();

      // Load default reminder types
      final reminderTypesStr = _storageService.getDefaultReminderTypes();
      _defaultReminderTypes = reminderTypesStr
          .map((s) => ReminderType.fromString(s))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load settings';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ===========================================================================
  // THEME SETTINGS
  // ===========================================================================

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storageService.setThemeMode(_themeModeToString(mode));
    notifyListeners();
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // System mode - determine based on current brightness
      await setThemeMode(ThemeMode.dark);
    }
  }

  /// Convert ThemeMode to string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Convert string to ThemeMode
  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // ===========================================================================
  // BIOMETRIC SETTINGS
  // ===========================================================================

  /// Check if biometrics are available
  Future<bool> checkBiometricsAvailable() async {
    final availability = await _biometricService.checkBiometricAvailability();
    return availability.isAvailable;
  }

  /// Enable biometric lock
  Future<bool> enableBiometric() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _biometricService.enableBiometricLock();

    if (result.success) {
      _biometricEnabled = true;
    } else {
      _errorMessage = result.message;
    }

    _isLoading = false;
    notifyListeners();
    return result.success;
  }

  /// Disable biometric lock
  Future<bool> disableBiometric() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _biometricService.disableBiometricLock();

    if (result.success) {
      _biometricEnabled = false;
    } else {
      _errorMessage = result.message;
    }

    _isLoading = false;
    notifyListeners();
    return result.success;
  }

  /// Toggle biometric lock
  Future<bool> toggleBiometric() async {
    if (_biometricEnabled) {
      return await disableBiometric();
    } else {
      return await enableBiometric();
    }
  }

  // ===========================================================================
  // NOTIFICATION SETTINGS
  // ===========================================================================

  /// Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _storageService.setNotificationsEnabled(enabled);
    notifyListeners();
  }

  /// Toggle notifications
  Future<void> toggleNotifications() async {
    await setNotificationsEnabled(!_notificationsEnabled);
  }

  // ===========================================================================
  // REMINDER SETTINGS
  // ===========================================================================

  /// Set default reminder types
  Future<void> setDefaultReminderTypes(List<ReminderType> types) async {
    _defaultReminderTypes = types;
    await _storageService.setDefaultReminderTypes(
      types.map((t) => t.name).toList(),
    );
    notifyListeners();
  }

  /// Toggle a reminder type
  Future<void> toggleReminderType(ReminderType type) async {
    final newTypes = List<ReminderType>.from(_defaultReminderTypes);

    if (newTypes.contains(type)) {
      newTypes.remove(type);
    } else {
      newTypes.add(type);
    }

    await setDefaultReminderTypes(newTypes);
  }

  /// Check if a reminder type is enabled
  bool isReminderTypeEnabled(ReminderType type) {
    return _defaultReminderTypes.contains(type);
  }

  // ===========================================================================
  // UTILITY
  // ===========================================================================

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _isLoading = true;
    notifyListeners();

    try {
      await setThemeMode(ThemeMode.system);
      await setNotificationsEnabled(true);
      await setDefaultReminderTypes([
        ReminderType.oneDayBefore,
        ReminderType.onDueDate,
      ]);

      if (_biometricEnabled) {
        await disableBiometric();
      }
    } catch (e) {
      _errorMessage = 'Failed to reset settings';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get available biometric type names
  Future<List<String>> getAvailableBiometricTypes() async {
    return await _biometricService.getAvailableBiometricNames();
  }
}
