class SessionRecord {
  final String id;
  final String gameId;
  final String gameName;
  final String? packageName;
  final DateTime launchedAt;

  /// attempted | success | failed
  final String launchStatus;

  final bool focusModeAvailable;
  final bool focusModeAttempted;

  /// notAvailable | noPermission | enabled | error | skipped
  final String? focusModeResult;

  final bool metricsAvailable;
  final int? memoryAvailableMb;
  final int? memoryTotalMb;
  final String? memoryState;
  final int? apexLatencyMs;
  final String? gfxProfile;

  const SessionRecord({
    required this.id,
    required this.gameId,
    required this.gameName,
    this.packageName,
    required this.launchedAt,
    required this.launchStatus,
    required this.focusModeAvailable,
    required this.focusModeAttempted,
    this.focusModeResult,
    required this.metricsAvailable,
    this.memoryAvailableMb,
    this.memoryTotalMb,
    this.memoryState,
    this.apexLatencyMs,
    this.gfxProfile,
  });

  SessionRecord copyWith({
    String? id,
    String? gameId,
    String? gameName,
    String? packageName,
    DateTime? launchedAt,
    String? launchStatus,
    bool? focusModeAvailable,
    bool? focusModeAttempted,
    String? focusModeResult,
    bool? metricsAvailable,
    int? memoryAvailableMb,
    int? memoryTotalMb,
    String? memoryState,
    int? apexLatencyMs,
    String? gfxProfile,
    bool clearPackageName = false,
    bool clearFocusModeResult = false,
    bool clearMemoryState = false,
    bool clearGfxProfile = false,
  }) {
    return SessionRecord(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      gameName: gameName ?? this.gameName,
      packageName: clearPackageName ? null : (packageName ?? this.packageName),
      launchedAt: launchedAt ?? this.launchedAt,
      launchStatus: launchStatus ?? this.launchStatus,
      focusModeAvailable: focusModeAvailable ?? this.focusModeAvailable,
      focusModeAttempted: focusModeAttempted ?? this.focusModeAttempted,
      focusModeResult:
          clearFocusModeResult ? null : (focusModeResult ?? this.focusModeResult),
      metricsAvailable: metricsAvailable ?? this.metricsAvailable,
      memoryAvailableMb: memoryAvailableMb ?? this.memoryAvailableMb,
      memoryTotalMb: memoryTotalMb ?? this.memoryTotalMb,
      memoryState:
          clearMemoryState ? null : (memoryState ?? this.memoryState),
      apexLatencyMs: apexLatencyMs ?? this.apexLatencyMs,
      gfxProfile: clearGfxProfile ? null : (gfxProfile ?? this.gfxProfile),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionRecord &&
        other.id == id &&
        other.gameId == gameId &&
        other.gameName == gameName &&
        other.packageName == packageName &&
        other.launchedAt == launchedAt &&
        other.launchStatus == launchStatus &&
        other.focusModeAvailable == focusModeAvailable &&
        other.focusModeAttempted == focusModeAttempted &&
        other.focusModeResult == focusModeResult &&
        other.metricsAvailable == metricsAvailable &&
        other.memoryAvailableMb == memoryAvailableMb &&
        other.memoryTotalMb == memoryTotalMb &&
        other.memoryState == memoryState &&
        other.apexLatencyMs == apexLatencyMs &&
        other.gfxProfile == gfxProfile;
  }

  @override
  int get hashCode => Object.hash(
        id,
        gameId,
        gameName,
        packageName,
        launchedAt,
        launchStatus,
        focusModeAvailable,
        focusModeAttempted,
        focusModeResult,
        metricsAvailable,
        memoryAvailableMb,
        memoryTotalMb,
        memoryState,
        apexLatencyMs,
        gfxProfile,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'gameName': gameName,
      'packageName': packageName,
      'launchedAt': launchedAt.toIso8601String(),
      'launchStatus': launchStatus,
      'focusModeAvailable': focusModeAvailable,
      'focusModeAttempted': focusModeAttempted,
      'focusModeResult': focusModeResult,
      'metricsAvailable': metricsAvailable,
      'memoryAvailableMb': memoryAvailableMb,
      'memoryTotalMb': memoryTotalMb,
      'memoryState': memoryState,
      'apexLatencyMs': apexLatencyMs,
      'gfxProfile': gfxProfile,
    };
  }

  static SessionRecord fromJson(Map<String, dynamic> map) {
    return SessionRecord(
      id: map['id'] as String,
      gameId: map['gameId'] as String,
      gameName: map['gameName'] as String,
      packageName: map['packageName'] as String?,
      launchedAt: DateTime.parse(map['launchedAt'] as String),
      launchStatus: map['launchStatus'] as String,
      focusModeAvailable: (map['focusModeAvailable'] as bool?) ?? false,
      focusModeAttempted: (map['focusModeAttempted'] as bool?) ?? false,
      focusModeResult: map['focusModeResult'] as String?,
      metricsAvailable: (map['metricsAvailable'] as bool?) ?? false,
      memoryAvailableMb: map['memoryAvailableMb'] as int?,
      memoryTotalMb: map['memoryTotalMb'] as int?,
      memoryState: map['memoryState'] as String?,
      apexLatencyMs: map['apexLatencyMs'] as int?,
      gfxProfile: map['gfxProfile'] as String?,
    );
  }

  @override
  String toString() {
    return 'SessionRecord('
        'id: $id, '
        'gameId: $gameId, '
        'gameName: $gameName, '
        'packageName: $packageName, '
        'launchedAt: $launchedAt, '
        'launchStatus: $launchStatus, '
        'focusModeAvailable: $focusModeAvailable, '
        'focusModeAttempted: $focusModeAttempted, '
        'focusModeResult: $focusModeResult, '
        'metricsAvailable: $metricsAvailable, '
        'memoryAvailableMb: $memoryAvailableMb, '
        'memoryTotalMb: $memoryTotalMb, '
        'memoryState: $memoryState, '
        'apexLatencyMs: $apexLatencyMs, '
        'gfxProfile: $gfxProfile'
        ')';
  }
}
