/// DateTime extension methods for convenient date operations
library;

extension DateTimeExtension on DateTime {
  /// Check if this date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if this date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Check if this date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if this date is in the past (before today)
  bool get isPast {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final thisDate = DateTime(year, month, day);
    return thisDate.isBefore(today);
  }

  /// Check if this date is in the future (after today)
  bool get isFuture {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final thisDate = DateTime(year, month, day);
    return thisDate.isAfter(today);
  }

  /// Check if this date is today or in the future
  bool get isTodayOrFuture {
    return isToday || isFuture;
  }

  /// Check if this date is today or in the past
  bool get isTodayOrPast {
    return isToday || isPast;
  }

  /// Get date only (without time component)
  DateTime get dateOnly {
    return DateTime(year, month, day);
  }

  /// Get start of day (midnight)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day (23:59:59.999)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Get start of month
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// Get end of month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1)).dateOnly;
  }

  /// Get end of week (Sunday)
  DateTime get endOfWeek {
    return add(Duration(days: 7 - weekday)).endOfDay;
  }

  /// Get number of days in this month
  int get daysInMonth {
    return DateTime(year, month + 1, 0).day;
  }

  /// Check if this date is the same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Check if this date is the same month as another date
  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  /// Check if this date is the same year as another date
  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  /// Check if this date is within a range (inclusive)
  bool isWithinRange(DateTime start, DateTime end) {
    final thisDate = dateOnly;
    final startDate = start.dateOnly;
    final endDate = end.dateOnly;
    return !thisDate.isBefore(startDate) && !thisDate.isAfter(endDate);
  }

  /// Get days difference from another date
  int daysDifference(DateTime other) {
    return dateOnly.difference(other.dateOnly).inDays;
  }

  /// Get days until this date from today
  int get daysFromNow {
    return dateOnly.difference(DateTime.now().dateOnly).inDays;
  }

  /// Get days since this date from today
  int get daysAgo {
    return DateTime.now().dateOnly.difference(dateOnly).inDays;
  }

  /// Add business days (excluding weekends)
  DateTime addBusinessDays(int days) {
    var result = this;
    var remaining = days.abs();
    final isNegative = days < 0;

    while (remaining > 0) {
      result = isNegative
          ? result.subtract(const Duration(days: 1))
          : result.add(const Duration(days: 1));

      // Skip weekends
      if (result.weekday != DateTime.saturday &&
          result.weekday != DateTime.sunday) {
        remaining--;
      }
    }

    return result;
  }

  /// Get a copy with the specified time
  DateTime withTime(int hour, [int minute = 0, int second = 0]) {
    return DateTime(year, month, day, hour, minute, second);
  }

  /// Get the next occurrence of a specific weekday
  DateTime nextWeekday(int targetWeekday) {
    assert(targetWeekday >= 1 && targetWeekday <= 7);
    var daysToAdd = targetWeekday - weekday;
    if (daysToAdd <= 0) daysToAdd += 7;
    return add(Duration(days: daysToAdd));
  }

  /// Check if this date is a weekend
  bool get isWeekend {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  /// Check if this date is a weekday
  bool get isWeekday {
    return !isWeekend;
  }

  /// Copy with modified fields
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}
