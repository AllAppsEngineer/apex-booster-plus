// CAPTURE-DISCLOSURE-U1: divulgação clara de gravação/áudio/armazenamento,
// exibida após a escolha de modo/duração e antes de armSession()/RECORD_AUDIO/
// MediaProjection. Cancelar aborta o fluxo sem persistir confirmação.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/data/services/external_url_service.dart';
import 'package:apex_booster_plus/data/services/screen_capture_service.dart';

/// Bump when the disclosure copy changes materially — users who already
/// acknowledged an older version will see the sheet again.
const int kCaptureDisclosureVersion = 1;

const String _ackVersionKey = 'apex_capture_disclosure_ack_version';

class CaptureDisclosureSheet extends StatelessWidget {
  const CaptureDisclosureSheet({super.key, required this.mode});

  final CaptureMode mode;

  /// Shows the disclosure sheet only if the user hasn't acknowledged the
  /// current [kCaptureDisclosureVersion] yet. Returns true if the capture
  /// flow may proceed (already acknowledged, or just confirmed now) and
  /// false if the user cancelled — callers must not invoke armSession(),
  /// RECORD_AUDIO or MediaProjection when this returns false.
  static Future<bool> maybeShow(
    BuildContext context, {
    required CaptureMode mode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return false;

    final ackVersion = prefs.getInt(_ackVersionKey) ?? 0;
    if (ackVersion >= kCaptureDisclosureVersion) return true;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CaptureDisclosureSheet(mode: mode),
    );
    if (confirmed != true) return false;

    await prefs.setInt(_ackVersionKey, kCaptureDisclosureVersion);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    final isVideo = mode == CaptureMode.video;

    final bullets = <String>[
      isVideo
          ? s.captureDisclosureVideoScreen
          : s.captureDisclosureScreenshotScreen,
      if (isVideo) ...[
        s.captureDisclosureAudioAttempt,
        s.captureDisclosureAudioUnavailable,
        s.captureDisclosureAudioFallback,
      ],
      s.captureDisclosureStorage,
      s.captureDisclosureExport,
      s.captureDisclosureFloatingButton,
    ];

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.apexGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.apexGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isVideo
                        ? s.captureDisclosureTitleVideo
                        : s.captureDisclosureTitleScreenshot,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final bullet in bullets) ...[
              _DisclosureBullet(text: bullet),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 4),
            InkWell(
              onTap: () => _openPrivacyPolicy(context, s),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  s.captureDisclosurePrivacyLink,
                  style: TextStyle(
                    color: AppColors.cyberBlue.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.cyberBlue.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textGray,
                      side: BorderSide(
                        color: AppColors.textGray.withValues(alpha: 0.25),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      s.actionCancel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.apexGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text(
                      s.captureDisclosureContinue,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPrivacyPolicy(BuildContext context, AppStrings s) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ExternalUrlService().openUrl(s.privacyPolicyUrl);
    } on PlatformException {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(s.aboutPrivacyOpenError),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _DisclosureBullet extends StatelessWidget {
  const _DisclosureBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: Icon(Icons.circle, size: 5, color: AppColors.textGray),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
