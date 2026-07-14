import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/billing/apex_unlock_notifier.dart';

void main() {
  group('ApexUnlockCacheService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('load returns false when nothing is saved', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(ApexUnlockCacheService(prefs).load(), false);
    });

    test('load returns true when key is saved as true', () async {
      SharedPreferences.setMockInitialValues({'apex_unlock_purchased': true});
      final prefs = await SharedPreferences.getInstance();
      expect(ApexUnlockCacheService(prefs).load(), true);
    });

    test('save(true) persists and load reflects the change', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = ApexUnlockCacheService(prefs);
      await service.save(true);
      expect(service.load(), true);
    });

    test('new instance reads same persisted value', () async {
      final prefs = await SharedPreferences.getInstance();
      await ApexUnlockCacheService(prefs).save(true);
      expect(ApexUnlockCacheService(prefs).load(), true);
    });

    test('apexUnlockNotifier defaults to false', () {
      expect(apexUnlockNotifier.value, false);
    });
  });
}
