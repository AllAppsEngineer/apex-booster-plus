import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/language_service.dart';

void main() {
  group('LanguageService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('load returns ptBr when nothing is saved', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LanguageService(prefs);
      expect(service.load(), AppLanguage.ptBr);
    });

    test('load returns ptBr for invalid stored value', () async {
      SharedPreferences.setMockInitialValues(
          {'apex_app_language': 'french'});
      final prefs = await SharedPreferences.getInstance();
      final service = LanguageService(prefs);
      expect(service.load(), AppLanguage.ptBr);
    });

    test('load returns ptBr for empty stored value', () async {
      SharedPreferences.setMockInitialValues({'apex_app_language': ''});
      final prefs = await SharedPreferences.getInstance();
      final service = LanguageService(prefs);
      expect(service.load(), AppLanguage.ptBr);
    });

    test('save and load roundtrip for en', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LanguageService(prefs);
      await service.save(AppLanguage.en);
      expect(service.load(), AppLanguage.en);
    });

    test('save and load roundtrip for es', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LanguageService(prefs);
      await service.save(AppLanguage.es);
      expect(service.load(), AppLanguage.es);
    });

    test('save and load roundtrip for ptBr', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LanguageService(prefs);
      await service.save(AppLanguage.ptBr);
      expect(service.load(), AppLanguage.ptBr);
    });

    test('overwriting en with es returns es on next load', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LanguageService(prefs);
      await service.save(AppLanguage.en);
      await service.save(AppLanguage.es);
      expect(service.load(), AppLanguage.es);
    });
  });
}
