import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../core/constants/app_constants.dart';
import '../models/payment.dart';
import '../models/reminder.dart';

/// SQLite database service for offline-first storage
/// Handles all local database operations for payments and reminders
class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._();

  /// Get singleton instance
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// Get database instance, initializing if needed
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, AppConfig.databaseName);

    return await openDatabase(
      path,
      version: AppConfig.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create payments table
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        dueDate TEXT NOT NULL,
        category TEXT NOT NULL,
        frequency TEXT NOT NULL,
        notes TEXT,
        status TEXT NOT NULL,
        reminderEnabled INTEGER NOT NULL DEFAULT 1,
        reminderTypes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        isDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create reminders table
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        paymentId TEXT NOT NULL,
        scheduledTime TEXT NOT NULL,
        type TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        hasTriggered INTEGER NOT NULL DEFAULT 0,
        notificationId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (paymentId) REFERENCES payments (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for faster queries
    await db.execute(
      'CREATE INDEX idx_payments_userId ON payments (userId)',
    );
    await db.execute(
      'CREATE INDEX idx_payments_dueDate ON payments (dueDate)',
    );
    await db.execute(
      'CREATE INDEX idx_payments_status ON payments (status)',
    );
    await db.execute(
      'CREATE INDEX idx_reminders_paymentId ON reminders (paymentId)',
    );
    await db.execute(
      'CREATE INDEX idx_reminders_scheduledTime ON reminders (scheduledTime)',
    );
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE payments ADD COLUMN newField TEXT');
    // }
  }

  // ===========================================================================
  // PAYMENT OPERATIONS
  // ===========================================================================

  /// Insert a new payment
  Future<void> insertPayment(Payment payment) async {
    final db = await database;
    await db.insert(
      'payments',
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing payment
  Future<void> updatePayment(Payment payment) async {
    final db = await database;
    await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  /// Soft delete a payment (mark as deleted)
  Future<void> softDeletePayment(String paymentId) async {
    final db = await database;
    await db.update(
      'payments',
      {
        'isDeleted': 1,
        'isSynced': 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [paymentId],
    );
  }

  /// Permanently delete a payment
  Future<void> deletePayment(String paymentId) async {
    final db = await database;
    await db.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [paymentId],
    );
  }

  /// Get a payment by ID
  Future<Payment?> getPaymentById(String paymentId) async {
    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'id = ? AND isDeleted = 0',
      whereArgs: [paymentId],
    );

    if (maps.isEmpty) return null;
    return Payment.fromMap(maps.first);
  }

  /// Get all payments for a user
  Future<List<Payment>> getPaymentsByUserId(String userId) async {
    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'userId = ? AND isDeleted = 0',
      whereArgs: [userId],
      orderBy: 'dueDate ASC',
    );

    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  /// Get payments by status
  Future<List<Payment>> getPaymentsByStatus(
    String userId,
    PaymentStatus status,
  ) async {
    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'userId = ? AND status = ? AND isDeleted = 0',
      whereArgs: [userId, status.name],
      orderBy: 'dueDate ASC',
    );

    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  /// Get payments by category
  Future<List<Payment>> getPaymentsByCategory(
    String userId,
    PaymentCategory category,
  ) async {
    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'userId = ? AND category = ? AND isDeleted = 0',
      whereArgs: [userId, category.name],
      orderBy: 'dueDate ASC',
    );

    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  /// Get upcoming payments (due date >= today, not paid)
  Future<List<Payment>> getUpcomingPayments(String userId) async {
    final today = DateTime.now();
    final todayString = DateTime(today.year, today.month, today.day)
        .toIso8601String();

    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'userId = ? AND dueDate >= ? AND status != ? AND isDeleted = 0',
      whereArgs: [userId, todayString, PaymentStatus.paid.name],
      orderBy: 'dueDate ASC',
    );

    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  /// Get overdue payments
  Future<List<Payment>> getOverduePayments(String userId) async {
    final today = DateTime.now();
    final todayString = DateTime(today.year, today.month, today.day)
        .toIso8601String();

    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'userId = ? AND dueDate < ? AND status != ? AND isDeleted = 0',
      whereArgs: [userId, todayString, PaymentStatus.paid.name],
      orderBy: 'dueDate ASC',
    );

    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  /// Get payments due within a date range
  Future<List<Payment>> getPaymentsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'userId = ? AND dueDate >= ? AND dueDate <= ? AND isDeleted = 0',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'dueDate ASC',
    );

    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  /// Get payments that need syncing
  Future<List<Payment>> getUnsyncedPayments(String userId) async {
    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'userId = ? AND isSynced = 0',
      whereArgs: [userId],
    );

    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  /// Mark payment as synced
  Future<void> markPaymentAsSynced(String paymentId) async {
    final db = await database;
    await db.update(
      'payments',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [paymentId],
    );
  }

  /// Search payments by title
  Future<List<Payment>> searchPayments(String userId, String query) async {
    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'userId = ? AND title LIKE ? AND isDeleted = 0',
      whereArgs: [userId, '%$query%'],
      orderBy: 'dueDate ASC',
    );

    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  /// Update overdue statuses for all payments
  Future<int> updateOverdueStatuses(String userId) async {
    final today = DateTime.now();
    final todayString = DateTime(today.year, today.month, today.day)
        .toIso8601String();

    final db = await database;
    return await db.update(
      'payments',
      {
        'status': PaymentStatus.overdue.name,
        'updatedAt': DateTime.now().toIso8601String(),
        'isSynced': 0,
      },
      where: 'userId = ? AND dueDate < ? AND status = ? AND isDeleted = 0',
      whereArgs: [userId, todayString, PaymentStatus.upcoming.name],
    );
  }

  // ===========================================================================
  // REMINDER OPERATIONS
  // ===========================================================================

  /// Insert a new reminder
  Future<void> insertReminder(Reminder reminder) async {
    final db = await database;
    await db.insert(
      'reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple reminders
  Future<void> insertReminders(List<Reminder> reminders) async {
    final db = await database;
    final batch = db.batch();

    for (final reminder in reminders) {
      batch.insert(
        'reminders',
        reminder.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Update a reminder
  Future<void> updateReminder(Reminder reminder) async {
    final db = await database;
    await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  /// Delete a reminder
  Future<void> deleteReminder(String reminderId) async {
    final db = await database;
    await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [reminderId],
    );
  }

  /// Delete all reminders for a payment
  Future<void> deleteRemindersForPayment(String paymentId) async {
    final db = await database;
    await db.delete(
      'reminders',
      where: 'paymentId = ?',
      whereArgs: [paymentId],
    );
  }

  /// Get reminders for a payment
  Future<List<Reminder>> getRemindersForPayment(String paymentId) async {
    final db = await database;
    final maps = await db.query(
      'reminders',
      where: 'paymentId = ?',
      whereArgs: [paymentId],
      orderBy: 'scheduledTime ASC',
    );

    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  /// Get active reminders that need to be scheduled
  Future<List<Reminder>> getActiveReminders() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final maps = await db.query(
      'reminders',
      where: 'isActive = 1 AND hasTriggered = 0 AND scheduledTime > ?',
      whereArgs: [now],
      orderBy: 'scheduledTime ASC',
    );

    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  /// Mark reminder as triggered
  Future<void> markReminderAsTriggered(String reminderId) async {
    final db = await database;
    await db.update(
      'reminders',
      {'hasTriggered': 1},
      where: 'id = ?',
      whereArgs: [reminderId],
    );
  }

  // ===========================================================================
  // UTILITY OPERATIONS
  // ===========================================================================

  /// Get payment counts by status
  Future<Map<PaymentStatus, int>> getPaymentCounts(String userId) async {
    final db = await database;

    final counts = <PaymentStatus, int>{};

    for (final status in PaymentStatus.values) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM payments WHERE userId = ? AND status = ? AND isDeleted = 0',
        [userId, status.name],
      );
      counts[status] = Sqflite.firstIntValue(result) ?? 0;
    }

    return counts;
  }

  /// Get total amount due (upcoming + overdue)
  Future<double> getTotalAmountDue(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM payments WHERE userId = ? AND status != ? AND isDeleted = 0',
      [userId, PaymentStatus.paid.name],
    );

    final total = result.first['total'];
    if (total == null) return 0.0;
    return (total as num).toDouble();
  }

  /// Clear all data for a user
  Future<void> clearUserData(String userId) async {
    final db = await database;

    // Delete reminders first (foreign key constraint)
    await db.delete(
      'reminders',
      where: 'paymentId IN (SELECT id FROM payments WHERE userId = ?)',
      whereArgs: [userId],
    );

    // Delete payments
    await db.delete(
      'payments',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete the database (for testing/reset)
  Future<void> deleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, AppConfig.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
