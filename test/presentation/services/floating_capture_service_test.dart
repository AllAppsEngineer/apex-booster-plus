import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/presentation/services/floating_capture_service.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('isEnabled returns false by default', () async {
    final prefs = await SharedPreferences.getInstance();
    expect(FloatingCaptureService.isEnabled(prefs), false);
  });

  test('saveEnabled true persists to SharedPreferences', () async {
    final prefs = await SharedPreferences.getInstance();
    await FloatingCaptureService.saveEnabled(prefs, true);
    expect(FloatingCaptureService.isEnabled(prefs), true);
  });

  test('saveEnabled false persists to SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({'capture_float_enabled': true});
    final prefs = await SharedPreferences.getInstance();
    await FloatingCaptureService.saveEnabled(prefs, false);
    expect(FloatingCaptureService.isEnabled(prefs), false);
  });

  test('isOverlayActive is false by default (overlay never auto-starts)', () {
    expect(FloatingCaptureService.isOverlayActive, false);
  });

  test('disable when not active is idempotent and saves pref false', () async {
    SharedPreferences.setMockInitialValues({'capture_float_enabled': true});
    final prefs = await SharedPreferences.getInstance();
    // Overlay is not active (isOverlayActive == false) — closeOverlay must NOT be called.
    await FloatingCaptureService.disable(prefs);
    expect(FloatingCaptureService.isEnabled(prefs), false);
    expect(FloatingCaptureService.isOverlayActive, false);
  });
}
