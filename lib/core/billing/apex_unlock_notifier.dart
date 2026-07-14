import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global notifier for the one-time unlock (`apex_full_unlock`) state.
///
/// Initialized from the local cache in [main] before [runApp]. Widgets that
/// need to react to the unlock state should listen to it via
/// [ListenableBuilder] or [ValueListenableBuilder]. This is a local cache
/// mirror only — the source of truth is the Play Store, refreshed via
/// [PurchaseService.startupCheck].
final ValueNotifier<bool> apexUnlockNotifier = ValueNotifier<bool>(false);

/// Persists and restores the cached one-time unlock state.
///
/// Key: [_key]. Value: boolean (default `false`). This cache exists so the
/// app can render the correct unlock state instantly at startup without
/// waiting for a Play Store round-trip; it must never be the only signal
/// used to grant a purchase.
class ApexUnlockCacheService {
  static const _key = 'apex_unlock_purchased';

  final SharedPreferences _prefs;

  const ApexUnlockCacheService(this._prefs);

  /// Returns the cached unlock state, or `false` when absent.
  bool load() => _prefs.getBool(_key) ?? false;

  /// Writes [value] so it survives app restarts.
  Future<void> save(bool value) => _prefs.setBool(_key, value);
}
