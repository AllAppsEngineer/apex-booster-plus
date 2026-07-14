import 'package:shared_preferences/shared_preferences.dart';
import 'app_language.dart';

/// Persists and restores the selected [AppLanguage] via SharedPreferences.
///
/// Key: [_key]. Value: the enum [name] (e.g. 'en', 'es', 'ptBr').
/// Falls back to [AppLanguage.ptBr] when the stored value is absent or invalid.
class LanguageService {
  static const _key = 'apex_app_language';

  final SharedPreferences _prefs;

  const LanguageService(this._prefs);

  /// Reads the stored language choice. Returns [AppLanguage.ptBr] when absent
  /// or if the stored value no longer maps to a valid [AppLanguage].
  AppLanguage load() {
    final saved = _prefs.getString(_key);
    return AppLanguageExt.fromName(saved);
  }

  /// Writes [lang] so it survives app restarts.
  Future<void> save(AppLanguage lang) => _prefs.setString(_key, lang.name);
}
