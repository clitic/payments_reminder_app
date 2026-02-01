import 'package:flutter/material.dart';

/// App-wide constants for the Payment Reminder App
/// Contains enums, color codes, and configuration values

// =============================================================================
// PAYMENT CATEGORY ENUM
// =============================================================================

/// Categories for organizing payments
enum PaymentCategory {
  rent('Rent', Icons.home, Color(0xFF6366F1)),
  utilities('Utilities', Icons.electrical_services, Color(0xFF8B5CF6)),
  loan('Loan', Icons.account_balance, Color(0xFFEC4899)),
  subscription('Subscription', Icons.subscriptions, Color(0xFF14B8A6)),
  education('Education', Icons.school, Color(0xFFF59E0B)),
  other('Other', Icons.category, Color(0xFF6B7280));

  const PaymentCategory(this.displayName, this.icon, this.color);

  final String displayName;
  final IconData icon;
  final Color color;

  /// Convert string to enum
  static PaymentCategory fromString(String value) {
    return PaymentCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => PaymentCategory.other,
    );
  }
}

// =============================================================================
// PAYMENT FREQUENCY ENUM
// =============================================================================

/// Frequency options for recurring payments
enum PaymentFrequency {
  oneTime('One-time', 0),
  weekly('Weekly', 7),
  monthly('Monthly', 30),
  yearly('Yearly', 365);

  const PaymentFrequency(this.displayName, this.intervalDays);

  final String displayName;
  final int intervalDays;

  /// Convert string to enum
  static PaymentFrequency fromString(String value) {
    return PaymentFrequency.values.firstWhere(
      (frequency) => frequency.name == value,
      orElse: () => PaymentFrequency.oneTime,
    );
  }
}

// =============================================================================
// PAYMENT STATUS ENUM
// =============================================================================

/// Status of a payment
enum PaymentStatus {
  upcoming('Upcoming', Color(0xFFFBBF24), Color(0xFF92400E)),
  paid('Paid', Color(0xFF34D399), Color(0xFF065F46)),
  overdue('Overdue', Color(0xFFF87171), Color(0xFF991B1B));

  const PaymentStatus(this.displayName, this.backgroundColor, this.textColor);

  final String displayName;
  final Color backgroundColor;
  final Color textColor;

  /// Convert string to enum
  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PaymentStatus.upcoming,
    );
  }
}

// =============================================================================
// REMINDER TYPE ENUM
// =============================================================================

/// Types of reminder timing
enum ReminderType {
  oneDayBefore('1 day before', Duration(days: 1)),
  threeHoursBefore('3 hours before', Duration(hours: 3)),
  onDueDate('On due date', Duration.zero);

  const ReminderType(this.displayName, this.duration);

  final String displayName;
  final Duration duration;

  /// Convert string to enum
  static ReminderType fromString(String value) {
    return ReminderType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ReminderType.onDueDate,
    );
  }
}

// =============================================================================
// APP CONFIGURATION
// =============================================================================

/// Application configuration constants
class AppConfig {
  AppConfig._();

  /// App name displayed in UI
  static const String appName = 'Payment Reminder';

  /// App version
  static const String appVersion = '1.0.0';

  /// Database name for SQLite
  static const String databaseName = 'payments_reminder.db';

  /// Database version
  static const int databaseVersion = 1;

  /// Hive box names
  static const String settingsBox = 'settings_box';
  static const String secureBox = 'secure_box';

  /// Notification channel configuration
  static const String notificationChannelId = 'payment_reminders';
  static const String notificationChannelName = 'Payment Reminders';
  static const String notificationChannelDescription =
      'Notifications for upcoming payment reminders';

  /// Sync configuration
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxRetryAttempts = 3;

  /// Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  /// Padding and spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  /// Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  /// Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
}
