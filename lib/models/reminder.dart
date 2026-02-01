import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';

/// Reminder model representing a scheduled notification reminder
class Reminder {
  /// Unique identifier for the reminder
  final String id;

  /// Payment ID this reminder is associated with
  final String paymentId;

  /// Scheduled time for the reminder
  final DateTime scheduledTime;

  /// Type of reminder (1 day before, 3 hours before, on due date)
  final ReminderType type;

  /// Whether the reminder is active/enabled
  bool isActive;

  /// Whether the reminder has been triggered
  bool hasTriggered;

  /// Notification ID for flutter_local_notifications
  final int notificationId;

  /// Timestamp when reminder was created
  final DateTime createdAt;

  /// Constructor
  Reminder({
    String? id,
    required this.paymentId,
    required this.scheduledTime,
    required this.type,
    this.isActive = true,
    this.hasTriggered = false,
    int? notificationId,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        notificationId = notificationId ?? _generateNotificationId(paymentId, type),
        createdAt = createdAt ?? DateTime.now();

  /// Generate a unique notification ID based on payment ID and type
  static int _generateNotificationId(String paymentId, ReminderType type) {
    // Create a hash from payment ID and type for unique notification ID
    final combined = '$paymentId-${type.name}';
    return combined.hashCode.abs() % 2147483647; // Max 32-bit signed int
  }

  /// Create a copy with modified fields
  Reminder copyWith({
    String? id,
    String? paymentId,
    DateTime? scheduledTime,
    ReminderType? type,
    bool? isActive,
    bool? hasTriggered,
    int? notificationId,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      hasTriggered: hasTriggered ?? this.hasTriggered,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'paymentId': paymentId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'type': type.name,
      'isActive': isActive ? 1 : 0,
      'hasTriggered': hasTriggered ? 1 : 0,
      'notificationId': notificationId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from Map
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      paymentId: map['paymentId'] as String,
      scheduledTime: DateTime.parse(map['scheduledTime'] as String),
      type: ReminderType.fromString(map['type'] as String),
      isActive: map['isActive'] == 1,
      hasTriggered: map['hasTriggered'] == 1,
      notificationId: map['notificationId'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Check if the scheduled time is in the past
  bool get isScheduledInPast {
    return scheduledTime.isBefore(DateTime.now());
  }

  /// Check if the reminder should be scheduled
  bool get shouldSchedule {
    return isActive && !hasTriggered && !isScheduledInPast;
  }

  /// Mark reminder as triggered
  Reminder markAsTriggered() {
    return copyWith(hasTriggered: true);
  }

  /// Deactivate reminder
  Reminder deactivate() {
    return copyWith(isActive: false);
  }

  /// Snooze reminder by specified duration
  Reminder snooze(Duration duration) {
    return copyWith(
      scheduledTime: DateTime.now().add(duration),
      hasTriggered: false,
    );
  }

  /// Create reminders for a payment based on its due date and reminder types
  static List<Reminder> createForPayment({
    required String paymentId,
    required DateTime dueDate,
    required List<ReminderType> reminderTypes,
  }) {
    final reminders = <Reminder>[];

    for (final type in reminderTypes) {
      final scheduledTime = dueDate.subtract(type.duration);

      // Only create reminder if scheduled time is in the future
      if (scheduledTime.isAfter(DateTime.now())) {
        reminders.add(
          Reminder(
            paymentId: paymentId,
            scheduledTime: scheduledTime,
            type: type,
          ),
        );
      }
    }

    return reminders;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Reminder(id: $id, paymentId: $paymentId, type: $type, scheduledTime: $scheduledTime, isActive: $isActive)';
  }
}
