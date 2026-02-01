import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';

/// Payment model representing a payment record
/// Supports serialization for SQLite and Firestore
class Payment {
  /// Unique identifier for the payment
  final String id;

  /// User ID who owns this payment
  final String userId;

  /// Payment title/description
  final String title;

  /// Payment amount
  final double amount;

  /// Due date for the payment
  final DateTime dueDate;

  /// Payment category (Rent, Utilities, Loan, etc.)
  final PaymentCategory category;

  /// Payment frequency (One-time, Weekly, Monthly, Yearly)
  final PaymentFrequency frequency;

  /// Optional notes
  final String? notes;

  /// Payment status (Upcoming, Paid, Overdue)
  PaymentStatus status;

  /// Whether reminder is enabled for this payment
  final bool reminderEnabled;

  /// Reminder types enabled for this payment
  final List<ReminderType> reminderTypes;

  /// Timestamp when payment was created
  final DateTime createdAt;

  /// Timestamp when payment was last updated
  DateTime updatedAt;

  /// Whether the payment has been synced to cloud
  bool isSynced;

  /// Whether the payment is marked for deletion (soft delete)
  bool isDeleted;

  /// Constructor
  Payment({
    String? id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.frequency = PaymentFrequency.oneTime,
    this.notes,
    this.status = PaymentStatus.upcoming,
    this.reminderEnabled = true,
    this.reminderTypes = const [
      ReminderType.oneDayBefore,
      ReminderType.onDueDate,
    ],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy with modified fields
  Payment copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    DateTime? dueDate,
    PaymentCategory? category,
    PaymentFrequency? frequency,
    String? notes,
    PaymentStatus? status,
    bool? reminderEnabled,
    List<ReminderType>? reminderTypes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTypes: reminderTypes ?? this.reminderTypes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Convert to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'category': category.name,
      'frequency': frequency.name,
      'notes': notes,
      'status': status.name,
      'reminderEnabled': reminderEnabled ? 1 : 0,
      'reminderTypes': reminderTypes.map((e) => e.name).join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  /// Create from SQLite Map
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['dueDate'] as String),
      category: PaymentCategory.fromString(map['category'] as String),
      frequency: PaymentFrequency.fromString(map['frequency'] as String),
      notes: map['notes'] as String?,
      status: PaymentStatus.fromString(map['status'] as String),
      reminderEnabled: map['reminderEnabled'] == 1,
      reminderTypes: (map['reminderTypes'] as String?)
              ?.split(',')
              .where((e) => e.isNotEmpty)
              .map((e) => ReminderType.fromString(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isSynced: map['isSynced'] == 1,
      isDeleted: map['isDeleted'] == 1,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'category': category.name,
      'frequency': frequency.name,
      'notes': notes,
      'status': status.name,
      'reminderEnabled': reminderEnabled,
      'reminderTypes': reminderTypes.map((e) => e.name).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  /// Create from Firestore document
  factory Payment.fromFirestore(Map<String, dynamic> doc) {
    return Payment(
      id: doc['id'] as String,
      userId: doc['userId'] as String,
      title: doc['title'] as String,
      amount: (doc['amount'] as num).toDouble(),
      dueDate: DateTime.parse(doc['dueDate'] as String),
      category: PaymentCategory.fromString(doc['category'] as String),
      frequency: PaymentFrequency.fromString(doc['frequency'] as String),
      notes: doc['notes'] as String?,
      status: PaymentStatus.fromString(doc['status'] as String),
      reminderEnabled: doc['reminderEnabled'] as bool? ?? true,
      reminderTypes: (doc['reminderTypes'] as List<dynamic>?)
              ?.map((e) => ReminderType.fromString(e as String))
              .toList() ??
          [],
      createdAt: DateTime.parse(doc['createdAt'] as String),
      updatedAt: DateTime.parse(doc['updatedAt'] as String),
      isSynced: true, // Data from Firestore is synced
      isDeleted: doc['isDeleted'] as bool? ?? false,
    );
  }

  /// Check if payment is overdue
  bool get isOverdue {
    if (status == PaymentStatus.paid) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isBefore(today);
  }

  /// Check if payment is due today
  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  /// Get days until due date (negative if overdue)
  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  /// Update status based on due date and current status
  void updateStatusIfNeeded() {
    if (status == PaymentStatus.paid) return;

    if (isOverdue) {
      status = PaymentStatus.overdue;
    } else {
      status = PaymentStatus.upcoming;
    }
    updatedAt = DateTime.now();
  }

  /// Mark payment as paid
  Payment markAsPaid() {
    return copyWith(
      status: PaymentStatus.paid,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
  }

  /// Mark payment as unpaid (revert to upcoming/overdue)
  Payment markAsUnpaid() {
    final newStatus = isOverdue ? PaymentStatus.overdue : PaymentStatus.upcoming;
    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Payment(id: $id, title: $title, amount: $amount, dueDate: $dueDate, status: $status)';
  }
}
