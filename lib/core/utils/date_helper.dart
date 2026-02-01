/// Date and time helper utilities for the Payment Reminder App
/// Provides formatting, parsing, and comparison functions
library;

import 'package:intl/intl.dart';

class DateHelper {
  DateHelper._();

  // =============================================================================
  // DATE FORMATTERS
  // =============================================================================

  /// Format: January 15, 2024
  static final DateFormat fullDateFormat = DateFormat('MMMM d, y');

  /// Format: Jan 15, 2024
  static final DateFormat shortDateFormat = DateFormat('MMM d, y');

  /// Format: 01/15/2024
  static final DateFormat numericDateFormat = DateFormat('MM/dd/y');

  /// Format: January 2024
  static final DateFormat monthYearFormat = DateFormat('MMMM y');

  /// Format: Jan 15
  static final DateFormat dayMonthFormat = DateFormat('MMM d');

  /// Format: 15
  static final DateFormat dayFormat = DateFormat('d');

  /// Format: Mon, Jan 15
  static final DateFormat weekdayFormat = DateFormat('E, MMM d');

  /// Format: 2:30 PM
  static final DateFormat timeFormat = DateFormat('h:mm a');

  /// Format: January 15, 2024 at 2:30 PM
  static final DateFormat fullDateTimeFormat = DateFormat('MMMM d, y \'at\' h:mm a');

  // =============================================================================
  // FORMATTING METHODS
  // =============================================================================

  /// Format date as full readable string (January 15, 2024)
  static String formatFullDate(DateTime date) {
    return fullDateFormat.format(date);
  }

  /// Format date as short string (Jan 15, 2024)
  static String formatShortDate(DateTime date) {
    return shortDateFormat.format(date);
  }

  /// Format date as numeric string (01/15/2024)
  static String formatNumericDate(DateTime date) {
    return numericDateFormat.format(date);
  }

  /// Format date as month and year (January 2024)
  static String formatMonthYear(DateTime date) {
    return monthYearFormat.format(date);
  }

  /// Format time (2:30 PM)
  static String formatTime(DateTime date) {
    return timeFormat.format(date);
  }

  /// Format full date and time (January 15, 2024 at 2:30 PM)
  static String formatFullDateTime(DateTime date) {
    return fullDateTimeFormat.format(date);
  }

  /// Format time only (2:30 PM)
  static String formatTimeOnly(DateTime date) {
    return timeFormat.format(date);
  }

  /// Format relative date (2 hours ago, Yesterday, etc.)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return hours == 1 ? '1 hour ago' : '$hours hours ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return days == 1 ? 'Yesterday' : '$days days ago';
    } else {
      return shortDateFormat.format(date);
    }
  }

  // =============================================================================
  // RELATIVE DATE METHODS
  // =============================================================================

  /// Get relative date string (Today, Tomorrow, Yesterday, or formatted date)
  static String getRelativeDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = dateOnly.difference(today).inDays;

    switch (difference) {
      case -1:
        return 'Yesterday';
      case 0:
        return 'Today';
      case 1:
        return 'Tomorrow';
      default:
        if (difference > 1 && difference <= 7) {
          return DateFormat('EEEE').format(date); // Day name (Monday, Tuesday, etc.)
        } else if (difference > 7 && date.year == now.year) {
          return dayMonthFormat.format(date); // Jan 15
        } else {
          return shortDateFormat.format(date); // Jan 15, 2024
        }
    }
  }

  /// Get days remaining string
  static String getDaysRemainingString(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;

    if (difference < 0) {
      final overdueDays = -difference;
      return overdueDays == 1 ? '1 day overdue' : '$overdueDays days overdue';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference <= 7) {
      return 'Due in $difference days';
    } else if (difference <= 30) {
      final weeks = (difference / 7).floor();
      return weeks == 1 ? 'Due in 1 week' : 'Due in $weeks weeks';
    } else {
      final months = (difference / 30).floor();
      return months == 1 ? 'Due in 1 month' : 'Due in $months months';
    }
  }

  // =============================================================================
  // COMPARISON METHODS
  // =============================================================================

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is in the past (before today)
  static bool isPast(DateTime date) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.isBefore(today);
  }

  /// Check if date is in the future (after today)
  static bool isFuture(DateTime date) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.isAfter(today);
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if date is within current week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOnly = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);

    return !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
  }

  /// Check if date is within current month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // =============================================================================
  // DATE CALCULATION METHODS
  // =============================================================================

  /// Get start of day (midnight)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59.999)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Get days in month
  static int daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Calculate next due date based on frequency
  static DateTime calculateNextDueDate(
    DateTime currentDueDate,
    int frequencyDays,
  ) {
    if (frequencyDays <= 0) {
      return currentDueDate; // One-time payment, no next date
    }
    return currentDueDate.add(Duration(days: frequencyDays));
  }

  // =============================================================================
  // PARSING METHODS
  // =============================================================================

  /// Try to parse a date string, returns null if invalid
  static DateTime? tryParse(String dateString) {
    try {
      // Try ISO format first
      return DateTime.parse(dateString);
    } catch (_) {
      // Try common formats
      final formats = [
        'MM/dd/yyyy',
        'dd/MM/yyyy',
        'yyyy-MM-dd',
        'MMM d, yyyy',
        'MMMM d, yyyy',
      ];

      for (final format in formats) {
        try {
          return DateFormat(format).parse(dateString);
        } catch (_) {
          continue;
        }
      }

      return null;
    }
  }

  /// Get ISO string for storage
  static String toIsoString(DateTime date) {
    return date.toIso8601String();
  }

  /// Parse ISO string from storage
  static DateTime fromIsoString(String isoString) {
    return DateTime.parse(isoString);
  }
}
