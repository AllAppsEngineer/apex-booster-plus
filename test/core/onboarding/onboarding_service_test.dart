import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/onboarding/onboarding_service.dart';

void main() {
  group('OnboardingService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('isDone returns false when nothing is saved', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService(prefs);
      expect(service.isDone(), false);
    });

    test('isDone returns false when key is explicitly set to false', () async {
      SharedPreferences.setMockInitialValues({'apex_onboarding_done': false});
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService(prefs);
      expect(service.isDone(), false);
    });

    test('isDone returns true when key is already saved as true', () async {
      SharedPreferences.setMockInitialValues({'apex_onboarding_done': true});
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService(prefs);
      expect(service.isDone(), true);
    });

    test('markDone persists onboarding completion', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService(prefs);
      await service.markDone();
      expect(service.isDone(), true);
    });

    test('markDone is idempotent: calling twice still returns true', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = OnboardingService(prefs);
      await service.markDone();
      await service.markDone();
      expect(service.isDone(), true);
    });

    test('new instance reads same persisted value', () async {
      final prefs = await SharedPreferences.getInstance();
      await OnboardingService(prefs).markDone();
      final service2 = OnboardingService(prefs);
      expect(service2.isDone(), true);
    });
  });
}
