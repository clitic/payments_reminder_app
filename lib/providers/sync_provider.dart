import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';
import '../services/secure_storage_service.dart';

/// Sync state provider
/// Manages cloud synchronization status and operations
class SyncProvider extends ChangeNotifier {
  final SyncService _syncService;
  final SecureStorageService _storageService;

  SyncStatus _status = SyncStatus.idle;
  String? _errorMessage;
  DateTime? _lastSyncTime;
  int _pendingChanges = 0;

  SyncProvider()
      : _syncService = SyncService.instance,
        _storageService = SecureStorageService.instance {
    _initialize();
  }

  // ===========================================================================
  // GETTERS
  // ===========================================================================

  /// Current sync status
  SyncStatus get status => _status;

  /// Whether sync is in progress
  bool get isSyncing => _status == SyncStatus.syncing;

  /// Whether last sync was successful
  bool get isSynced => _status == SyncStatus.synced;

  /// Whether there was a sync error
  bool get hasError => _status == SyncStatus.error;

  /// Error message
  String? get errorMessage => _errorMessage;

  /// Last successful sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Number of pending changes to sync
  int get pendingChanges => _pendingChanges;

  /// Whether there are pending changes
  bool get hasPendingChanges => _pendingChanges > 0;

  /// Formatted last sync time
  String get lastSyncTimeFormatted {
    if (_lastSyncTime == null) return 'Never synced';

    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  void _initialize() {
    // Load last sync time from storage
    _lastSyncTime = _storageService.getLastSyncTime();

    // Listen to sync status changes
    _syncService.onSyncStatusChanged = (status) {
      _status = status;
      if (status == SyncStatus.synced) {
        _lastSyncTime = DateTime.now();
        _errorMessage = null;
      }
      notifyListeners();
    };
  }

  // ===========================================================================
  // SYNC OPERATIONS
  // ===========================================================================

  /// Trigger sync for a user
  Future<SyncResult> syncNow(String userId) async {
    if (isSyncing) {
      return SyncResult(
        status: SyncStatus.alreadySyncing,
        message: 'Sync already in progress',
      );
    }

    _status = SyncStatus.syncing;
    _errorMessage = null;
    notifyListeners();

    final result = await _syncService.syncPayments(userId);

    _status = result.status;

    if (result.isSuccess) {
      _lastSyncTime = DateTime.now();
      _pendingChanges = 0;
    } else {
      _errorMessage = result.message;
    }

    notifyListeners();
    return result;
  }

  /// Force full sync
  Future<SyncResult> forceFullSync(String userId) async {
    return await _syncService.forceFullSync(userId);
  }

  /// Start automatic sync with connectivity monitoring
  void startAutoSync({
    required String userId,
    required bool isGuest,
  }) {
    if (isGuest) return; // Don't sync for guest users

    _syncService.startConnectivityListener(
      userId: userId,
      isGuest: isGuest,
    );
  }

  /// Stop automatic sync
  void stopAutoSync() {
    _syncService.stopConnectivityListener();
  }

  // ===========================================================================
  // PENDING CHANGES TRACKING
  // ===========================================================================

  /// Increment pending changes count
  void incrementPendingChanges() {
    _pendingChanges++;
    notifyListeners();
  }

  /// Decrement pending changes count
  void decrementPendingChanges() {
    if (_pendingChanges > 0) {
      _pendingChanges--;
      notifyListeners();
    }
  }

  /// Set pending changes count
  void setPendingChanges(int count) {
    _pendingChanges = count;
    notifyListeners();
  }

  /// Clear pending changes
  void clearPendingChanges() {
    _pendingChanges = 0;
    notifyListeners();
  }

  // ===========================================================================
  // UTILITY
  // ===========================================================================

  /// Clear error
  void clearError() {
    _errorMessage = null;
    _status = SyncStatus.idle;
    notifyListeners();
  }

  /// Check connectivity
  Future<bool> hasConnectivity() async {
    return await _syncService.hasConnectivity();
  }

  /// Dispose resources
  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
}
