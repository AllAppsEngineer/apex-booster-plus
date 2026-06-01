import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';

void main() {
  group('AppLanguage — labels', () {
    test('ptBr has correct label, code and nativeLabel', () {
      expect(AppLanguage.ptBr.label, 'Português');
      expect(AppLanguage.ptBr.code, 'pt_BR');
      expect(AppLanguage.ptBr.nativeLabel, 'Português (BR)');
    });

    test('en has correct label, code and nativeLabel', () {
      expect(AppLanguage.en.label, 'English');
      expect(AppLanguage.en.code, 'en');
      expect(AppLanguage.en.nativeLabel, 'English');
    });

    test('es has correct label, code and nativeLabel', () {
      expect(AppLanguage.es.label, 'Español');
      expect(AppLanguage.es.code, 'es');
      expect(AppLanguage.es.nativeLabel, 'Español');
    });

    test('all languages have non-empty label, code and nativeLabel', () {
      for (final lang in AppLanguage.values) {
        expect(lang.label, isNotEmpty, reason: '${lang.name}.label');
        expect(lang.code, isNotEmpty, reason: '${lang.name}.code');
        expect(lang.nativeLabel, isNotEmpty, reason: '${lang.name}.nativeLabel');
      }
    });
  });

  group('AppLanguageExt.fromName', () {
    test('returns ptBr for null', () {
      expect(AppLanguageExt.fromName(null), AppLanguage.ptBr);
    });

    test('returns ptBr for empty string', () {
      expect(AppLanguageExt.fromName(''), AppLanguage.ptBr);
    });

    test('returns ptBr for unrecognised value', () {
      expect(AppLanguageExt.fromName('french'), AppLanguage.ptBr);
      expect(AppLanguageExt.fromName('pt'), AppLanguage.ptBr);
      expect(AppLanguageExt.fromName('EN'), AppLanguage.ptBr);
    });

    test('roundtrips each AppLanguage via .name', () {
      for (final lang in AppLanguage.values) {
        expect(AppLanguageExt.fromName(lang.name), lang,
            reason: 'fromName(${lang.name}) should return $lang');
      }
    });
  });
}
