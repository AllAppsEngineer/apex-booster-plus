import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/accessibility/low_distraction_service.dart';

void main() {
  group('LowDistractionService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('load returns false when nothing is saved', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(LowDistractionService(prefs).load(), false);
    });

    test('load returns false when key is explicitly false', () async {
      SharedPreferences.setMockInitialValues({'apex_low_distraction': false});
      final prefs = await SharedPreferences.getInstance();
      expect(LowDistractionService(prefs).load(), false);
    });

    test('load returns true when key is saved as true', () async {
      SharedPreferences.setMockInitialValues({'apex_low_distraction': true});
      final prefs = await SharedPreferences.getInstance();
      expect(LowDistractionService(prefs).load(), true);
    });

    test('save(true) persists and load reflects the change', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LowDistractionService(prefs);
      await service.save(true);
      expect(service.load(), true);
    });

    test('save(false) after save(true) resets to false', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = LowDistractionService(prefs);
      await service.save(true);
      await service.save(false);
      expect(service.load(), false);
    });

    test('new instance reads same persisted value', () async {
      final prefs = await SharedPreferences.getInstance();
      await LowDistractionService(prefs).save(true);
      expect(LowDistractionService(prefs).load(), true);
    });

    test('lowDistractionNotifier defaults to false', () {
      expect(lowDistractionNotifier.value, false);
    });
  });
}
