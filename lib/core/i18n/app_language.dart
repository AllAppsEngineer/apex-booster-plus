import 'package:flutter/foundation.dart';

enum AppLanguage { ptBr, en, es }

extension AppLanguageExt on AppLanguage {
  String get code => switch (this) {
    AppLanguage.ptBr => 'pt_BR',
    AppLanguage.en   => 'en',
    AppLanguage.es   => 'es',
  };

  /// Short label shown in the Settings card.
  String get label => switch (this) {
    AppLanguage.ptBr => 'Português',
    AppLanguage.en   => 'English',
    AppLanguage.es   => 'Español',
  };

  /// Full native label shown in the language selection sheet.
  String get nativeLabel => switch (this) {
    AppLanguage.ptBr => 'Português (BR)',
    AppLanguage.en   => 'English',
    AppLanguage.es   => 'Español',
  };

  /// Parses a stored enum [name] back to an [AppLanguage].
  /// Falls back to [AppLanguage.ptBr] for null or unrecognised values.
  static AppLanguage fromName(String? name) {
    if (name == null) return AppLanguage.ptBr;
    for (final lang in AppLanguage.values) {
      if (lang.name == name) return lang;
    }
    return AppLanguage.ptBr;
  }
}

/// Global notifier for the active app language.
///
/// Updated by [LanguageService.save] when the user selects a language.
/// [ApexBoosterApp] listens to this and rebuilds [MaterialApp] on each change,
/// propagating the new language to every screen that reads [AppStrings].
final ValueNotifier<AppLanguage> languageNotifier =
    ValueNotifier<AppLanguage>(AppLanguage.ptBr);
