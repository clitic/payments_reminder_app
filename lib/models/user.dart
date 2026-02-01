/// User model representing an authenticated user
/// Supports both Firebase authenticated users and guest mode
class AppUser {
  /// Firebase UID (null for guest users)
  final String? uid;

  /// User's email address (null for guest users)
  final String? email;

  /// Display name
  final String? displayName;

  /// Whether the user is in guest mode
  final bool isGuest;

  /// Whether email is verified
  final bool emailVerified;

  /// Timestamp when the account was created
  final DateTime createdAt;

  /// Last sign-in timestamp
  final DateTime? lastSignInAt;

  /// Constructor
  AppUser({
    this.uid,
    this.email,
    this.displayName,
    this.isGuest = false,
    this.emailVerified = false,
    DateTime? createdAt,
    this.lastSignInAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a guest user
  factory AppUser.guest() {
    return AppUser(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      isGuest: true,
      createdAt: DateTime.now(),
    );
  }

  /// Create from Firebase User
  factory AppUser.fromFirebaseUser(dynamic firebaseUser) {
    return AppUser(
      uid: firebaseUser.uid as String?,
      email: firebaseUser.email as String?,
      displayName: firebaseUser.displayName as String?,
      isGuest: false,
      emailVerified: firebaseUser.emailVerified as bool? ?? false,
      createdAt: firebaseUser.metadata?.creationTime as DateTime? ?? DateTime.now(),
      lastSignInAt: firebaseUser.metadata?.lastSignInTime as DateTime?,
    );
  }

  /// Create a copy with modified fields
  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? isGuest,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isGuest: isGuest ?? this.isGuest,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  /// Convert to Map for local storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isGuest': isGuest ? 1 : 0,
      'emailVerified': emailVerified ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
    };
  }

  /// Create from Map
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String?,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      isGuest: map['isGuest'] == 1,
      emailVerified: map['emailVerified'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastSignInAt: map['lastSignInAt'] != null
          ? DateTime.parse(map['lastSignInAt'] as String)
          : null,
    );
  }

  /// Get display text (email or Guest)
  String get displayText {
    if (isGuest) return 'Guest User';
    return displayName ?? email ?? 'Unknown User';
  }

  /// Get user ID for data queries (uses uid or guest ID)
  String get effectiveUserId {
    return uid ?? 'guest';
  }

  /// Check if user can sync to cloud
  bool get canSyncToCloud {
    return !isGuest && uid != null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, isGuest: $isGuest)';
  }
}
