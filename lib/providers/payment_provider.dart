import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/payment.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

/// Payment state provider
/// Manages payment CRUD operations, filtering, sorting, and notifications
class PaymentProvider extends ChangeNotifier {
  final DatabaseService _databaseService;
  final NotificationService _notificationService;

  List<Payment> _payments = [];
  List<Payment> _filteredPayments = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  PaymentCategory? _selectedCategory;
  PaymentStatus? _selectedStatus;
  PaymentSortOption _sortOption = PaymentSortOption.dueDate;
  bool _sortAscending = true;

  PaymentProvider()
      : _databaseService = DatabaseService.instance,
        _notificationService = NotificationService.instance;

  // ===========================================================================
  // GETTERS
  // ===========================================================================

  /// All payments
  List<Payment> get payments => _payments;

  /// Filtered and sorted payments
  List<Payment> get filteredPayments => _filteredPayments;

  /// Whether data is loading
  bool get isLoading => _isLoading;

  /// Error message from last operation
  String? get errorMessage => _errorMessage;

  /// Current search query
  String get searchQuery => _searchQuery;

  /// Selected category filter
  PaymentCategory? get selectedCategory => _selectedCategory;

  /// Selected status filter
  PaymentStatus? get selectedStatus => _selectedStatus;

  /// Current sort option
  PaymentSortOption get sortOption => _sortOption;

  /// Whether sorting in ascending order
  bool get sortAscending => _sortAscending;

  /// Upcoming payments
  List<Payment> get upcomingPayments =>
      _payments.where((p) => p.status == PaymentStatus.upcoming).toList();

  /// Paid payments
  List<Payment> get paidPayments =>
      _payments.where((p) => p.status == PaymentStatus.paid).toList();

  /// Overdue payments
  List<Payment> get overduePayments =>
      _payments.where((p) => p.status == PaymentStatus.overdue).toList();

  /// Payment counts by status
  Map<PaymentStatus, int> get paymentCounts => {
        PaymentStatus.upcoming: upcomingPayments.length,
        PaymentStatus.paid: paidPayments.length,
        PaymentStatus.overdue: overduePayments.length,
      };

  /// Total amount due (upcoming + overdue)
  double get totalAmountDue {
    return _payments
        .where((p) => p.status != PaymentStatus.paid)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Total paid amount
  double get totalPaidAmount {
    return paidPayments.fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Payments due today
  List<Payment> get paymentsDueToday {
    final now = DateTime.now();
    return _payments.where((p) {
      return p.dueDate.year == now.year &&
          p.dueDate.month == now.month &&
          p.dueDate.day == now.day &&
          p.status != PaymentStatus.paid;
    }).toList();
  }

  /// Payments due this week
  List<Payment> get paymentsDueThisWeek {
    final now = DateTime.now();
    final endOfWeek = now.add(Duration(days: 7 - now.weekday));
    return _payments.where((p) {
      return p.dueDate.isAfter(now.subtract(const Duration(days: 1))) &&
          p.dueDate.isBefore(endOfWeek) &&
          p.status != PaymentStatus.paid;
    }).toList();
  }

  // ===========================================================================
  // LOAD DATA
  // ===========================================================================

  /// Load payments for a user
  Future<void> loadPayments(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update overdue statuses first
      await _databaseService.updateOverdueStatuses(userId);

      // Load payments
      _payments = await _databaseService.getPaymentsByUserId(userId);

      // Update status for any that might have become overdue
      for (final payment in _payments) {
        payment.updateStatusIfNeeded();
      }

      _applyFiltersAndSort();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load payments';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading payments: $e');
    }
  }

  /// Refresh payments
  Future<void> refreshPayments(String userId) async {
    await loadPayments(userId);
  }

  // ===========================================================================
  // CRUD OPERATIONS
  // ===========================================================================

  /// Add a new payment
  Future<bool> addPayment(Payment payment) async {
    _errorMessage = null;

    try {
      // Insert into database
      await _databaseService.insertPayment(payment);

      // Create and schedule reminders (don't fail payment add if this fails)
      if (payment.reminderEnabled && payment.reminderTypes.isNotEmpty) {
        try {
          final reminders = Reminder.createForPayment(
            paymentId: payment.id,
            dueDate: payment.dueDate,
            reminderTypes: payment.reminderTypes,
          );

          if (reminders.isNotEmpty) {
            await _databaseService.insertReminders(reminders);

            // Schedule notifications (non-critical, don't fail if this fails)
            for (final reminder in reminders) {
              try {
                await _notificationService.scheduleReminder(reminder, payment);
              } catch (e) {
                debugPrint('Error scheduling reminder notification: $e');
              }
            }
          }
        } catch (e) {
          debugPrint('Error creating reminders: $e');
          // Don't fail payment add for reminder issues
        }
      }

      // Add to local list
      _payments.add(payment);
      _applyFiltersAndSort();
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add payment: ${e.toString()}';
      notifyListeners();
      debugPrint('Error adding payment: $e');
      return false;
    }
  }

  /// Update an existing payment
  Future<bool> updatePayment(Payment payment) async {
    _errorMessage = null;

    try {
      final updatedPayment = payment.copyWith(
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      // Update in database
      await _databaseService.updatePayment(updatedPayment);

      // Update reminders (non-critical - don't fail if this fails)
      try {
        await _updateReminders(updatedPayment);
      } catch (e) {
        debugPrint('Error updating reminders: $e');
      }

      // Update in local list
      final index = _payments.indexWhere((p) => p.id == payment.id);
      if (index != -1) {
        _payments[index] = updatedPayment;
      }

      _applyFiltersAndSort();
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update payment: ${e.toString()}';
      notifyListeners();
      debugPrint('Error updating payment: $e');
      return false;
    }
  }

  /// Delete a payment
  Future<bool> deletePayment(String paymentId) async {
    _errorMessage = null;

    try {
      // Cancel reminders first (non-critical - don't fail delete if this fails)
      try {
        final reminders =
            await _databaseService.getRemindersForPayment(paymentId);
        await _notificationService.cancelPaymentReminders(reminders);
        await _databaseService.deleteRemindersForPayment(paymentId);
      } catch (e) {
        debugPrint('Error cancelling reminders during delete: $e');
      }

      // Soft delete payment (for sync)
      await _databaseService.softDeletePayment(paymentId);

      // Remove from local list
      _payments.removeWhere((p) => p.id == paymentId);
      _applyFiltersAndSort();
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete payment: ${e.toString()}';
      notifyListeners();
      debugPrint('Error deleting payment: $e');
      return false;
    }
  }

  /// Mark payment as paid
  Future<bool> markAsPaid(String paymentId) async {
    final payment = _payments.firstWhere(
      (p) => p.id == paymentId,
      orElse: () => throw Exception('Payment not found'),
    );

    final paidPayment = payment.markAsPaid();
    return await updatePayment(paidPayment);
  }

  /// Mark payment as unpaid
  Future<bool> markAsUnpaid(String paymentId) async {
    final payment = _payments.firstWhere(
      (p) => p.id == paymentId,
      orElse: () => throw Exception('Payment not found'),
    );

    final unpaidPayment = payment.markAsUnpaid();
    return await updatePayment(unpaidPayment);
  }

  /// Toggle payment paid status
  Future<bool> togglePaidStatus(String paymentId) async {
    final payment = _payments.firstWhere(
      (p) => p.id == paymentId,
      orElse: () => throw Exception('Payment not found'),
    );

    if (payment.status == PaymentStatus.paid) {
      return await markAsUnpaid(paymentId);
    } else {
      return await markAsPaid(paymentId);
    }
  }

  // ===========================================================================
  // REMINDERS
  // ===========================================================================

  /// Update reminders for a payment
  Future<void> _updateReminders(Payment payment) async {
    // Cancel existing reminders
    final existingReminders =
        await _databaseService.getRemindersForPayment(payment.id);
    await _notificationService.cancelPaymentReminders(existingReminders);
    await _databaseService.deleteRemindersForPayment(payment.id);

    // Create new reminders if enabled
    if (payment.reminderEnabled && payment.status != PaymentStatus.paid) {
      final reminders = Reminder.createForPayment(
        paymentId: payment.id,
        dueDate: payment.dueDate,
        reminderTypes: payment.reminderTypes,
      );

      await _databaseService.insertReminders(reminders);

      for (final reminder in reminders) {
        await _notificationService.scheduleReminder(reminder, payment);
      }
    }
  }

  /// Reschedule all reminders (e.g., after app restart)
  Future<void> rescheduleAllReminders() async {
    try {
      final activeReminders = await _databaseService.getActiveReminders();

      for (final reminder in activeReminders) {
        final payment = await _databaseService.getPaymentById(reminder.paymentId);
        if (payment != null && payment.status != PaymentStatus.paid) {
          await _notificationService.scheduleReminder(reminder, payment);
        }
      }
    } catch (e) {
      debugPrint('Error rescheduling reminders: $e');
    }
  }

  // ===========================================================================
  // SEARCH, FILTER, SORT
  // ===========================================================================

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Set category filter
  void setSelectedCategory(PaymentCategory? category) {
    _selectedCategory = category;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Set status filter
  void setSelectedStatus(PaymentStatus? status) {
    _selectedStatus = status;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Set sort option
  void setSortOption(PaymentSortOption option) {
    if (_sortOption == option) {
      // Toggle ascending/descending
      _sortAscending = !_sortAscending;
    } else {
      _sortOption = option;
      _sortAscending = true;
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedStatus = null;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Apply filters and sort to payments
  void _applyFiltersAndSort() {
    var result = List<Payment>.from(_payments);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (p) => p.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      result = result.where((p) => p.status == _selectedStatus).toList();
    }

    // Apply sort
    result.sort((a, b) {
      int comparison;
      switch (_sortOption) {
        case PaymentSortOption.dueDate:
          comparison = a.dueDate.compareTo(b.dueDate);
          break;
        case PaymentSortOption.amount:
          comparison = a.amount.compareTo(b.amount);
          break;
        case PaymentSortOption.title:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    _filteredPayments = result;
  }

  // ===========================================================================
  // CALENDAR HELPERS
  // ===========================================================================

  /// Get payments for a specific date
  List<Payment> getPaymentsForDate(DateTime date) {
    return _payments.where((p) {
      return p.dueDate.year == date.year &&
          p.dueDate.month == date.month &&
          p.dueDate.day == date.day;
    }).toList();
  }

  /// Get payments for a date range
  Future<List<Payment>> getPaymentsInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    return await _databaseService.getPaymentsInDateRange(userId, start, end);
  }

  /// Get event dates for calendar (dates with payments)
  Map<DateTime, List<Payment>> getPaymentsByDate() {
    final Map<DateTime, List<Payment>> result = {};

    for (final payment in _payments) {
      final date = DateTime(
        payment.dueDate.year,
        payment.dueDate.month,
        payment.dueDate.day,
      );

      if (result.containsKey(date)) {
        result[date]!.add(payment);
      } else {
        result[date] = [payment];
      }
    }

    return result;
  }

  // ===========================================================================
  // DATA MIGRATION
  // ===========================================================================

  /// Migrate payments from guest to authenticated user
  Future<void> migratePaymentsToUser(
    String oldUserId,
    String newUserId,
  ) async {
    try {
      for (final payment in _payments) {
        if (payment.userId == oldUserId) {
          final migratedPayment = payment.copyWith(
            userId: newUserId,
            isSynced: false,
            updatedAt: DateTime.now(),
          );
          await _databaseService.updatePayment(migratedPayment);
        }
      }

      // Reload payments
      await loadPayments(newUserId);
    } catch (e) {
      debugPrint('Error migrating payments: $e');
    }
  }

  // ===========================================================================
  // UTILITY
  // ===========================================================================

  /// Clear all local data
  Future<void> clearAllData(String userId) async {
    try {
      await _notificationService.cancelAllNotifications();
      await _databaseService.clearUserData(userId);
      _payments.clear();
      _filteredPayments.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  /// Get payment by ID
  Payment? getPaymentById(String id) {
    try {
      return _payments.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

/// Sort options for payments
enum PaymentSortOption {
  dueDate,
  amount,
  title,
}
