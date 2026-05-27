import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/session_record.dart';

SessionRecord _minimal() {
  return SessionRecord(
    id: 's1',
    gameId: 'g1',
    gameName: 'Free Fire',
    launchedAt: DateTime(2026, 5, 27, 10, 0, 0),
    launchStatus: 'attempted',
    focusModeAvailable: false,
    focusModeAttempted: false,
    metricsAvailable: false,
  );
}

SessionRecord _full() {
  return SessionRecord(
    id: 's2',
    gameId: 'g2',
    gameName: 'PUBG Mobile',
    packageName: 'com.tencent.ig',
    launchedAt: DateTime(2026, 5, 27, 11, 30, 0),
    launchStatus: 'attempted',
    focusModeAvailable: true,
    focusModeAttempted: true,
    focusModeResult: 'enabled',
    metricsAvailable: true,
    memoryAvailableMb: 3200,
    memoryTotalMb: 8192,
    memoryState: 'Ok',
    apexLatencyMs: 45,
    gfxProfile: 'Desempenho',
  );
}

void main() {
  // --- Construction ---

  group('construction', () {
    test('creates with required fields only', () {
      final r = _minimal();
      expect(r.id, 's1');
      expect(r.gameId, 'g1');
      expect(r.gameName, 'Free Fire');
      expect(r.packageName, isNull);
      expect(r.launchStatus, 'attempted');
      expect(r.focusModeAvailable, isFalse);
      expect(r.focusModeAttempted, isFalse);
      expect(r.focusModeResult, isNull);
      expect(r.metricsAvailable, isFalse);
      expect(r.memoryAvailableMb, isNull);
      expect(r.memoryTotalMb, isNull);
      expect(r.memoryState, isNull);
      expect(r.apexLatencyMs, isNull);
      expect(r.gfxProfile, isNull);
    });

    test('creates with all fields', () {
      final r = _full();
      expect(r.packageName, 'com.tencent.ig');
      expect(r.focusModeResult, 'enabled');
      expect(r.memoryAvailableMb, 3200);
      expect(r.memoryTotalMb, 8192);
      expect(r.memoryState, 'Ok');
      expect(r.apexLatencyMs, 45);
      expect(r.gfxProfile, 'Desempenho');
    });
  });

  // --- launchStatus values ---

  group('launchStatus', () {
    test('accepts attempted', () {
      expect(_minimal().copyWith(launchStatus: 'attempted').launchStatus, 'attempted');
    });

    test('accepts success', () {
      expect(_minimal().copyWith(launchStatus: 'success').launchStatus, 'success');
    });

    test('accepts failed', () {
      expect(_minimal().copyWith(launchStatus: 'failed').launchStatus, 'failed');
    });
  });

  // --- focusModeResult values ---

  group('focusModeResult', () {
    test('accepts notAvailable', () {
      expect(_minimal().copyWith(focusModeResult: 'notAvailable').focusModeResult, 'notAvailable');
    });

    test('accepts noPermission', () {
      expect(_minimal().copyWith(focusModeResult: 'noPermission').focusModeResult, 'noPermission');
    });

    test('accepts enabled', () {
      expect(_minimal().copyWith(focusModeResult: 'enabled').focusModeResult, 'enabled');
    });

    test('accepts error', () {
      expect(_minimal().copyWith(focusModeResult: 'error').focusModeResult, 'error');
    });

    test('accepts skipped', () {
      expect(_minimal().copyWith(focusModeResult: 'skipped').focusModeResult, 'skipped');
    });

    test('clearFocusModeResult sets null', () {
      final r = _full().copyWith(clearFocusModeResult: true);
      expect(r.focusModeResult, isNull);
    });
  });

  // --- toJson / fromJson ---

  group('serialization', () {
    test('round-trip with required fields only', () {
      final original = _minimal();
      final restored = SessionRecord.fromJson(original.toJson());
      expect(restored, equals(original));
    });

    test('round-trip with all fields', () {
      final original = _full();
      final restored = SessionRecord.fromJson(original.toJson());
      expect(restored, equals(original));
    });

    test('toJson includes all keys', () {
      final json = _full().toJson();
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('gameId'), isTrue);
      expect(json.containsKey('gameName'), isTrue);
      expect(json.containsKey('packageName'), isTrue);
      expect(json.containsKey('launchedAt'), isTrue);
      expect(json.containsKey('launchStatus'), isTrue);
      expect(json.containsKey('focusModeAvailable'), isTrue);
      expect(json.containsKey('focusModeAttempted'), isTrue);
      expect(json.containsKey('focusModeResult'), isTrue);
      expect(json.containsKey('metricsAvailable'), isTrue);
      expect(json.containsKey('memoryAvailableMb'), isTrue);
      expect(json.containsKey('memoryTotalMb'), isTrue);
      expect(json.containsKey('memoryState'), isTrue);
      expect(json.containsKey('apexLatencyMs'), isTrue);
      expect(json.containsKey('gfxProfile'), isTrue);
    });

    test('fromJson preserves null optional fields', () {
      final json = _minimal().toJson();
      final restored = SessionRecord.fromJson(json);
      expect(restored.packageName, isNull);
      expect(restored.focusModeResult, isNull);
      expect(restored.memoryAvailableMb, isNull);
      expect(restored.memoryTotalMb, isNull);
      expect(restored.memoryState, isNull);
      expect(restored.apexLatencyMs, isNull);
      expect(restored.gfxProfile, isNull);
    });

    test('fromJson defaults bool fields to false when absent', () {
      final map = {
        'id': 's1',
        'gameId': 'g1',
        'gameName': 'Test',
        'launchedAt': '2026-05-27T10:00:00.000',
        'launchStatus': 'attempted',
      };
      final r = SessionRecord.fromJson(map);
      expect(r.focusModeAvailable, isFalse);
      expect(r.focusModeAttempted, isFalse);
      expect(r.metricsAvailable, isFalse);
    });

    test('launchedAt is preserved as UTC-equivalent after round-trip', () {
      final original = _minimal();
      final restored = SessionRecord.fromJson(original.toJson());
      expect(restored.launchedAt.millisecondsSinceEpoch,
          original.launchedAt.millisecondsSinceEpoch);
    });
  });

  // --- Equality ---

  group('equality', () {
    test('two identical instances are equal', () {
      expect(_minimal(), equals(_minimal()));
    });

    test('different id → not equal', () {
      expect(_minimal().copyWith(id: 's999'), isNot(equals(_minimal())));
    });

    test('different launchStatus → not equal', () {
      expect(
        _minimal().copyWith(launchStatus: 'failed'),
        isNot(equals(_minimal())),
      );
    });

    test('different focusModeResult → not equal', () {
      expect(
        _full().copyWith(focusModeResult: 'error'),
        isNot(equals(_full())),
      );
    });

    test('different memoryTotalMb → not equal', () {
      expect(
        _full().copyWith(memoryTotalMb: 4096),
        isNot(equals(_full())),
      );
    });
  });

  // --- copyWith ---

  group('copyWith', () {
    test('preserves unchanged fields', () {
      final original = _full();
      final copy = original.copyWith(gfxProfile: 'Equilibrado');
      expect(copy.id, original.id);
      expect(copy.gameName, original.gameName);
      expect(copy.launchStatus, original.launchStatus);
      expect(copy.gfxProfile, 'Equilibrado');
    });

    test('clearPackageName sets packageName to null', () {
      final r = _full().copyWith(clearPackageName: true);
      expect(r.packageName, isNull);
    });

    test('clearGfxProfile sets gfxProfile to null', () {
      final r = _full().copyWith(clearGfxProfile: true);
      expect(r.gfxProfile, isNull);
    });
  });

  // --- toString ---

  test('toString contains key fields', () {
    final s = _minimal().toString();
    expect(s, contains('s1'));
    expect(s, contains('Free Fire'));
    expect(s, contains('attempted'));
  });
}
