enum FocusModeResult { success, noPermission, notActive, error }

abstract class FocusModeService {
  Future<bool> isPermissionGranted();
  Future<void> openSettings();
  Future<FocusModeResult> saveAndEnable();
  Future<FocusModeResult> restore();
}
