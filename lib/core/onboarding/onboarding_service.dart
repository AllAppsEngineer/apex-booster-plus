import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const _key = 'apex_onboarding_done';

  final SharedPreferences _prefs;

  const OnboardingService(this._prefs);

  bool isDone() => _prefs.getBool(_key) ?? false;

  Future<void> markDone() => _prefs.setBool(_key, true);
}
