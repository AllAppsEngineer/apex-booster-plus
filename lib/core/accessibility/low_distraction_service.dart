import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global notifier for the Low Distraction Mode preference.
///
/// Initialized in [main] from [SharedPreferences] before [runApp].
/// Widgets that adapt their behaviour to this setting should listen to it
/// via [ListenableBuilder] or [ValueListenableBuilder].
final lowDistractionNotifier = ValueNotifier<bool>(false);

/// Persists and restores the Low Distraction Mode preference.
///
/// Key: [_key]. Value: boolean (default [false]).
class LowDistractionService {
  static const _key = 'apex_low_distraction';

  final SharedPreferences _prefs;

  const LowDistractionService(this._prefs);

  /// Returns the stored value, or [false] when absent.
  bool load() => _prefs.getBool(_key) ?? false;

  /// Writes [value] so it survives app restarts.
  Future<void> save(bool value) => _prefs.setBool(_key, value);
}
