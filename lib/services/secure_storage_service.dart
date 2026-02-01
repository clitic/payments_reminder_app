import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import '../core/constants/app_constants.dart';

/// Secure storage service using Hive with encryption
/// Handles encrypted storage for sensitive data and app settings
class SecureStorageService {
  static SecureStorageService? _instance;
  static Box? _settingsBox;
  static Box? _secureBox;
  static const FlutterSecureStorage _flutterSecureStorage =
      FlutterSecureStorage();

  SecureStorageService._();

  /// Get singleton instance
  static SecureStorageService get instance {
    _instance ??= SecureStorageService._();
    return _instance!;
  }

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    await Hive.initFlutter();

    // Get or generate encryption key
    final encryptionKey = await _getOrCreateEncryptionKey();

    // Open encrypted secure box
    _secureBox = await Hive.openBox(
      AppConfig.secureBox,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    // Open settings box (not encrypted, for non-sensitive settings)
    _settingsBox = await Hive.openBox(AppConfig.settingsBox);
  }

  /// Get or create encryption key from secure storage
  Future<List<int>> _getOrCreateEncryptionKey() async {
    const keyName = 'hive_encryption_key';

    // Try to get existing key
    String? storedKey = await _flutterSecureStorage.read(key: keyName);

    if (storedKey == null) {
      // Generate new key
      final key = Hive.generateSecureKey();
      storedKey = base64Encode(key);
      await _flutterSecureStorage.write(key: keyName, value: storedKey);
    }

    return base64Decode(storedKey);
  }

  // ===========================================================================
  // SECURE DATA STORAGE
  // ===========================================================================

  /// Store encrypted data
  Future<void> setSecure(String key, dynamic value) async {
    await _secureBox?.put(key, value);
  }

  /// Get encrypted data
  T? getSecure<T>(String key, {T? defaultValue}) {
    return _secureBox?.get(key, defaultValue: defaultValue) as T?;
  }

  /// Delete encrypted data
  Future<void> deleteSecure(String key) async {
    await _secureBox?.delete(key);
  }

  /// Clear all secure data
  Future<void> clearSecure() async {
    await _secureBox?.clear();
  }

  // ===========================================================================
  // SETTINGS STORAGE
  // ===========================================================================

  /// Store setting
  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  /// Get setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox?.get(key, defaultValue: defaultValue) as T?;
  }

  /// Delete setting
  Future<void> deleteSetting(String key) async {
    await _settingsBox?.delete(key);
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    await _settingsBox?.clear();
  }

  // ===========================================================================
  // SPECIFIC SETTINGS
  // ===========================================================================

  // Biometric Lock
  static const String _biometricEnabledKey = 'biometric_enabled';

  Future<void> setBiometricEnabled(bool enabled) async {
    await setSetting(_biometricEnabledKey, enabled);
  }

  bool getBiometricEnabled() {
    return getSetting<bool>(_biometricEnabledKey, defaultValue: false) ?? false;
  }

  // Theme Mode
  static const String _themeModeKey = 'theme_mode';

  Future<void> setThemeMode(String mode) async {
    await setSetting(_themeModeKey, mode);
  }

  String getThemeMode() {
    return getSetting<String>(_themeModeKey, defaultValue: 'system') ?? 'system';
  }

  // Notifications Enabled
  static const String _notificationsEnabledKey = 'notifications_enabled';

  Future<void> setNotificationsEnabled(bool enabled) async {
    await setSetting(_notificationsEnabledKey, enabled);
  }

  bool getNotificationsEnabled() {
    return getSetting<bool>(_notificationsEnabledKey, defaultValue: true) ??
        true;
  }

  // Default Reminder Types
  static const String _defaultReminderTypesKey = 'default_reminder_types';

  Future<void> setDefaultReminderTypes(List<String> types) async {
    await setSetting(_defaultReminderTypesKey, types);
  }

  List<String> getDefaultReminderTypes() {
    final types = getSetting<List<dynamic>>(_defaultReminderTypesKey);
    if (types == null) {
      return ['oneDayBefore', 'onDueDate']; // Default reminder types
    }
    return types.cast<String>();
  }

  // Last Sync Time
  static const String _lastSyncTimeKey = 'last_sync_time';

  Future<void> setLastSyncTime(DateTime time) async {
    await setSetting(_lastSyncTimeKey, time.toIso8601String());
  }

  DateTime? getLastSyncTime() {
    final timeStr = getSetting<String>(_lastSyncTimeKey);
    if (timeStr == null) return null;
    return DateTime.tryParse(timeStr);
  }

  // Guest User ID
  static const String _guestUserIdKey = 'guest_user_id';

  Future<void> setGuestUserId(String id) async {
    await setSecure(_guestUserIdKey, id);
  }

  String? getGuestUserId() {
    return getSecure<String>(_guestUserIdKey);
  }

  Future<void> clearGuestUserId() async {
    await deleteSecure(_guestUserIdKey);
  }

  // User Session
  static const String _userSessionKey = 'user_session';

  Future<void> setUserSession(Map<String, dynamic> session) async {
    await setSecure(_userSessionKey, jsonEncode(session));
  }

  Map<String, dynamic>? getUserSession() {
    final sessionStr = getSecure<String>(_userSessionKey);
    if (sessionStr == null) return null;
    return jsonDecode(sessionStr) as Map<String, dynamic>;
  }

  Future<void> clearUserSession() async {
    await deleteSecure(_userSessionKey);
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Hash a string (for password comparison, etc.)
  String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Clear all data
  Future<void> clearAll() async {
    await clearSettings();
    await clearSecure();
    await _flutterSecureStorage.deleteAll();
  }

  /// Close all boxes
  Future<void> close() async {
    await _settingsBox?.close();
    await _secureBox?.close();
  }
}
