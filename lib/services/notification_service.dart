import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../core/constants/app_constants.dart';
import '../models/payment.dart';
import '../models/reminder.dart';

/// Notification service for local payment reminders
/// Handles scheduling, displaying, and managing notifications
class NotificationService {
  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  // Callback for when notification is tapped
  static Function(String? payload)? onNotificationTapped;

  NotificationService._()
      : _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Get singleton instance
  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  /// Check if notification service is initialized
  bool get isInitialized => _isInitialized;

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  /// Initialize the notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone database
      tz_data.initializeTimeZones();
      
      // CRITICAL: Set the local timezone from device
      try {
        final String timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('Timezone set to: $timeZoneName');
      } catch (e) {
        // Fallback to a default timezone if detection fails
        debugPrint('Failed to get device timezone: $e, using UTC');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher', // Use app icon
      );

      // iOS initialization settings
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      // Initialize the plugin
      final success = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
      );

      if (success == true) {
        _isInitialized = true;
        await _createNotificationChannel();
      }

      return _isInitialized;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      return false;
    }
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      description: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }

    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin == null) return false;
      
      // Request notification permission (Android 13+)
      final notificationResult = await androidPlugin.requestNotificationsPermission();
      debugPrint('Notification permission result: $notificationResult');
      
      // Request exact alarm permission (Android 12+)
      final exactAlarmResult = await androidPlugin.requestExactAlarmsPermission();
      debugPrint('Exact alarm permission result: $exactAlarmResult');
      
      return notificationResult ?? false;
    }

    return true;
  }

  /// Show an instant notification (for testing)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      debugPrint('Notification service not initialized');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notificationsPlugin.show(id, title, body, details);
    debugPrint('Showed instant notification: $title');
  }

  // ===========================================================================
  // NOTIFICATION CALLBACKS
  // ===========================================================================

  /// Handle notification tap (foreground)
  static void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && onNotificationTapped != null) {
      onNotificationTapped!(payload);
    }
  }

  /// Handle notification tap (background)
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    // Handle background notification
    debugPrint('Background notification: ${response.payload}');
  }

  // ===========================================================================
  // SCHEDULE NOTIFICATIONS
  // ===========================================================================

  /// Schedule a reminder notification
  Future<void> scheduleReminder(Reminder reminder, Payment payment) async {
    if (!_isInitialized) {
      debugPrint('❌ Notification service not initialized');
      return;
    }

    // Don't schedule if in the past
    if (reminder.scheduledTime.isBefore(DateTime.now())) {
      debugPrint('⏭️ Reminder time is in the past, skipping: ${reminder.scheduledTime}');
      return;
    }

    // Build notification content
    final title = _getReminderTitle(reminder.type);
    final body = _getReminderBody(payment, reminder.type);

    // Convert to timezone-aware datetime
    final scheduledTzTime = tz.TZDateTime.from(reminder.scheduledTime, tz.local);

    // Debug logging
    debugPrint('═══════════════════════════════════════════');
    debugPrint('📅 SCHEDULING NOTIFICATION');
    debugPrint('   Payment: ${payment.title}');
    debugPrint('   Reminder Type: ${reminder.type.displayName}');
    debugPrint('   Local DateTime: ${reminder.scheduledTime}');
    debugPrint('   TZ DateTime: $scheduledTzTime');
    debugPrint('   Timezone: ${tz.local.name}');
    debugPrint('   Notification ID: ${reminder.notificationId}');
    debugPrint('═══════════════════════════════════════════');

    // Notification details
    final androidDetails = AndroidNotificationDetails(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      // Add action buttons
      actions: [
        const AndroidNotificationAction(
          'snooze_1h',
          'Snooze 1 hour',
        ),
        const AndroidNotificationAction(
          'mark_paid',
          'Mark Paid',
        ),
      ],
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    // Schedule the notification
    await _notificationsPlugin.zonedSchedule(
      reminder.notificationId,
      title,
      body,
      scheduledTzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: '${payment.id}|${reminder.id}',
    );

    debugPrint('✅ Notification scheduled successfully!');
  }

  /// Schedule all reminders for a payment
  Future<void> schedulePaymentReminders(
    Payment payment,
    List<Reminder> reminders,
  ) async {
    for (final reminder in reminders) {
      if (reminder.isActive && !reminder.hasTriggered) {
        await scheduleReminder(reminder, payment);
      }
    }
  }

  /// Cancel a specific reminder
  Future<void> cancelReminder(Reminder reminder) async {
    await _notificationsPlugin.cancel(reminder.notificationId);
    debugPrint('Cancelled reminder: ${reminder.id}');
  }

  /// Cancel all reminders for a payment
  Future<void> cancelPaymentReminders(List<Reminder> reminders) async {
    for (final reminder in reminders) {
      await cancelReminder(reminder);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('Cancelled all notifications');
  }

  // ===========================================================================
  // SNOOZE FUNCTIONALITY
  // ===========================================================================

  /// Snooze a reminder by 1 hour
  Future<Reminder> snooze1Hour(Reminder reminder, Payment payment) async {
    await cancelReminder(reminder);
    final snoozedReminder = reminder.snooze(const Duration(hours: 1));
    await scheduleReminder(snoozedReminder, payment);
    return snoozedReminder;
  }

  /// Snooze a reminder by 1 day
  Future<Reminder> snooze1Day(Reminder reminder, Payment payment) async {
    await cancelReminder(reminder);
    final snoozedReminder = reminder.snooze(const Duration(days: 1));
    await scheduleReminder(snoozedReminder, payment);
    return snoozedReminder;
  }

  // ===========================================================================
  // IMMEDIATE NOTIFICATIONS
  // ===========================================================================

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) return;

    const androidDetails = AndroidNotificationDetails(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notificationsPlugin.show(id, title, body, details, payload: payload);
  }

  /// Show sync complete notification
  Future<void> showSyncCompleteNotification(int syncedCount) async {
    await showNotification(
      id: 999999,
      title: 'Sync Complete',
      body: 'Successfully synced $syncedCount payments',
    );
  }

  // ===========================================================================
  // PENDING NOTIFICATIONS
  // ===========================================================================

  /// Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Check if a notification is scheduled
  Future<bool> isNotificationScheduled(int notificationId) async {
    final pending = await getPendingNotifications();
    return pending.any((n) => n.id == notificationId);
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Get reminder title based on type
  String _getReminderTitle(ReminderType type) {
    switch (type) {
      case ReminderType.oneDayBefore:
        return '📅 Payment Due Tomorrow';
      case ReminderType.threeHoursBefore:
        return '⏰ Payment Due Soon';
      case ReminderType.onDueDate:
        return '🔔 Payment Due Today';
    }
  }

  /// Get reminder body based on payment and type
  /// Note: Avoid exposing sensitive amount data
  String _getReminderBody(Payment payment, ReminderType type) {
    // Don't expose amount in notification for privacy
    switch (type) {
      case ReminderType.oneDayBefore:
        return 'Your ${payment.category.displayName} payment "${payment.title}" is due tomorrow';
      case ReminderType.threeHoursBefore:
        return 'Your ${payment.category.displayName} payment "${payment.title}" is due in 3 hours';
      case ReminderType.onDueDate:
        return 'Your ${payment.category.displayName} payment "${payment.title}" is due today';
    }
  }
}
