import 'package:flutter/services.dart';

/// Opens external URLs (e.g. Privacy Policy) via the native Android intent
/// resolver. Reuses the existing `/apps` MethodChannel — no new pub
/// dependency and no AndroidManifest changes required, since `startActivity`
/// with an implicit ACTION_VIEW intent is resolved by the OS regardless of
/// package-visibility `<queries>` declarations.
class ExternalUrlService {
  static const _channel =
      MethodChannel('com.allappsengineer.apex_booster_plus/apps');

  /// Throws [PlatformException] with code 'INVALID_URL' if [url] is not an
  /// https URL, 'ACTIVITY_NOT_FOUND' if no app can handle it, or
  /// 'OPEN_URL_ERROR' on unexpected native failure.
  Future<void> openUrl(String url) async {
    await _channel.invokeMethod<void>('openUrl', {'url': url});
  }
}
