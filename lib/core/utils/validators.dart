/// Input validation utilities for the Payment Reminder App
/// Provides reusable validation functions for forms
library;

class Validators {
  Validators._();

  /// Email validation regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validate email format
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmedValue = value.trim();

    if (!_emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password
  /// Requires minimum 6 characters
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validate password with strength requirements
  /// Requires: minimum 8 chars, 1 uppercase, 1 lowercase, 1 number
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validate confirm password matches original
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate required text field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate payment title
  /// Must be non-empty and not exceed 100 characters
  static String? validatePaymentTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Payment title is required';
    }

    if (value.trim().length > 100) {
      return 'Title cannot exceed 100 characters';
    }

    return null;
  }

  /// Validate amount
  /// Must be a positive number greater than 0
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }

    // Remove currency symbols and commas
    final cleanedValue = value.replaceAll(RegExp(r'[^\d.]'), '');

    final amount = double.tryParse(cleanedValue);

    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    if (amount > 999999999) {
      return 'Amount is too large';
    }

    return null;
  }

  /// Parse amount string to double
  /// Returns 0.0 if parsing fails
  static double parseAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 0.0;
    }

    // Remove currency symbols and commas
    final cleanedValue = value.replaceAll(RegExp(r'[^\d.]'), '');

    return double.tryParse(cleanedValue) ?? 0.0;
  }

  /// Validate notes field
  /// Cannot exceed 500 characters
  static String? validateNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Notes are optional
    }

    if (value.length > 500) {
      return 'Notes cannot exceed 500 characters';
    }

    return null;
  }

  /// Validate due date
  /// Must not be null for new payments
  static String? validateDueDate(DateTime? value) {
    if (value == null) {
      return 'Due date is required';
    }
    return null;
  }

  /// Check if a string is a valid positive number
  static bool isValidPositiveNumber(String value) {
    final number = double.tryParse(value);
    return number != null && number > 0;
  }

  /// Calculate password strength (0-4)
  /// 0: Very weak, 1: Weak, 2: Fair, 3: Strong, 4: Very strong
  static int calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;

    // Length check
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;

    // Character variety checks
    if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]'))) {
      strength++;
    }

    if (password.contains(RegExp(r'[0-9]'))) {
      strength++;
    }

    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      strength++;
    }

    // Cap at 4
    return strength > 4 ? 4 : strength;
  }

  /// Get password strength label
  static String getPasswordStrengthLabel(int strength) {
    switch (strength) {
      case 0:
        return 'Very Weak';
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Strong';
      case 4:
        return 'Very Strong';
      default:
        return 'Unknown';
    }
  }

  /// Get password strength as a record with strength value and label
  static ({int strength, String label}) getPasswordStrength(String password) {
    final strength = calculatePasswordStrength(password);
    return (strength: strength, label: getPasswordStrengthLabel(strength));
  }
}
