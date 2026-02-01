import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import 'database_service.dart';
import 'secure_storage_service.dart';

/// Mock Sync service - Local only implementation
/// In a real app, this would sync with a cloud backend
class SyncService {
  static SyncService? _instance;
  final Connectivity _connectivity;
  final DatabaseService _databaseService;
  final SecureStorageService _storageService;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  // Callbacks for sync status updates
  Function(SyncStatus)? onSyncStatusChanged;

  SyncService._()
      : _connectivity = Connectivity(),
        _databaseService = DatabaseService.instance,
        _storageService = SecureStorageService.instance;

  /// Get singleton instance
  static SyncService get instance {
    _instance ??= SyncService._();
    return _instance!;
  }

  // ===========================================================================
  // CONNECTIVITY
  // ===========================================================================

  /// Check if device has internet connectivity
  Future<bool> hasConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Start listening to connectivity changes
  void startConnectivityListener({
    required String userId,
    required bool isGuest,
  }) {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none) && !isGuest) {
        // Connection restored - in a real app this would trigger sync
        debugPrint('Connection restored - sync would happen here');
      }
    });
  }

  /// Stop listening to connectivity changes
  void stopConnectivityListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  // ===========================================================================
  // SYNC OPERATIONS (Mock - Local Only)
  // ===========================================================================

  /// Mock sync - just marks all payments as synced locally
  Future<SyncResult> syncPayments(String userId) async {
    if (_isSyncing) {
      return SyncResult(
        status: SyncStatus.alreadySyncing,
        message: 'Sync already in progress',
      );
    }

    _isSyncing = true;
    onSyncStatusChanged?.call(SyncStatus.syncing);

    try {
      // Simulate sync delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Get unsynced payments and mark them as synced
      final unsyncedPayments = await _databaseService.getUnsyncedPayments(userId);
      int syncedCount = 0;

      for (final payment in unsyncedPayments) {
        await _databaseService.markPaymentAsSynced(payment.id);
        syncedCount++;
      }

      // Update last sync time
      await _storageService.setLastSyncTime(DateTime.now());

      _isSyncing = false;
      onSyncStatusChanged?.call(SyncStatus.synced);

      return SyncResult(
        status: SyncStatus.synced,
        message: 'Local sync completed',
        uploadedCount: syncedCount,
        downloadedCount: 0,
      );
    } catch (e) {
      _isSyncing = false;
      onSyncStatusChanged?.call(SyncStatus.error);

      debugPrint('Sync error: $e');
      return SyncResult(
        status: SyncStatus.error,
        message: 'Sync failed: ${e.toString()}',
      );
    }
  }

  // ===========================================================================
  // REAL-TIME SYNC (Mock - No-op)
  // ===========================================================================

  /// Start real-time sync listener (mock - no-op)
  void startRealtimeSync(String userId, Function(List<Payment>) onPaymentsChanged) {
    // No-op in mock implementation
    debugPrint('Real-time sync not available in offline mode');
  }

  /// Stop real-time sync (mock - no-op)
  void stopRealtimeSync() {
    // No-op in mock implementation
  }

  // ===========================================================================
  // UTILITY
  // ===========================================================================

  /// Force full sync (mock)
  Future<SyncResult> forceFullSync(String userId) async {
    await _storageService.deleteSetting('last_sync_time');
    return await syncPayments(userId);
  }

  /// Get sync status
  SyncStatus get currentStatus {
    if (_isSyncing) return SyncStatus.syncing;
    return SyncStatus.idle;
  }

  /// Dispose resources
  void dispose() {
    stopConnectivityListener();
    stopRealtimeSync();
  }
}

/// Sync status enum
enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
  noConnection,
  alreadySyncing,
}

/// Sync result with details
class SyncResult {
  final SyncStatus status;
  final String message;
  final int uploadedCount;
  final int downloadedCount;

  SyncResult({
    required this.status,
    required this.message,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
  });

  bool get isSuccess => status == SyncStatus.synced;

  int get totalSynced => uploadedCount + downloadedCount;

  @override
  String toString() {
    return 'SyncResult(status: $status, uploaded: $uploadedCount, downloaded: $downloadedCount)';
  }
}
