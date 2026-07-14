import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';

void main() {
  final langs = AppLanguage.values;

  group('AppStrings — social section', () {
    for (final lang in langs) {
      group('lang=$lang', () {
        late AppStrings s;
        setUp(() => s = AppStrings(lang));

        test('socialStudioTitle is non-empty', () => expect(s.socialStudioTitle, isNotEmpty));
        test('socialStudioSubtitle is non-empty', () => expect(s.socialStudioSubtitle, isNotEmpty));
        test('socialStudioCaptionHint is non-empty', () => expect(s.socialStudioCaptionHint, isNotEmpty));
        test('socialStudioExport is non-empty', () => expect(s.socialStudioExport, isNotEmpty));
        test('socialStudioWatermark is non-empty', () => expect(s.socialStudioWatermark, isNotEmpty));
        test('socialStudioCreateCard is non-empty', () => expect(s.socialStudioCreateCard, isNotEmpty));
        test('navSocial is non-empty', () => expect(s.navSocial, isNotEmpty));
        test('socialTabTitle is non-empty', () => expect(s.socialTabTitle, isNotEmpty));
        test('socialTabSubtitle is non-empty', () => expect(s.socialTabSubtitle, isNotEmpty));
        test('socialTabCreateBadge is non-empty', () => expect(s.socialTabCreateBadge, isNotEmpty));
        test('socialTabPickGameEmpty is non-empty', () => expect(s.socialTabPickGameEmpty, isNotEmpty));
        test('socialPresetPortrait is non-empty', () => expect(s.socialPresetPortrait, isNotEmpty));
        test('socialPresetSquare is non-empty', () => expect(s.socialPresetSquare, isNotEmpty));
        test('socialPresetLandscape is non-empty', () => expect(s.socialPresetLandscape, isNotEmpty));
        test('privacyGuardTitle is non-empty', () => expect(s.privacyGuardTitle, isNotEmpty));
        test('privacyGuardBody is non-empty', () => expect(s.privacyGuardBody, isNotEmpty));
        test('privacyGuardNoAutoPost is non-empty', () => expect(s.privacyGuardNoAutoPost, isNotEmpty));
        test('privacyGuardConfirm is non-empty', () => expect(s.privacyGuardConfirm, isNotEmpty));
        test('privacyGuardCancel is non-empty', () => expect(s.privacyGuardCancel, isNotEmpty));
        test('apexStudioFitFill is non-empty', () => expect(s.apexStudioFitFill, isNotEmpty));
        test('apexStudioFitContain is non-empty', () => expect(s.apexStudioFitContain, isNotEmpty));
        test('apexStudioVideoPreviewLabel is non-empty', () => expect(s.apexStudioVideoPreviewLabel, isNotEmpty));
        test('apexStudioPickApexCapture is non-empty', () => expect(s.apexStudioPickApexCapture, isNotEmpty));
        test('apexStudioCapturesSheetTitle is non-empty', () => expect(s.apexStudioCapturesSheetTitle, isNotEmpty));
        test('apexStudioCapturesEmpty is non-empty', () => expect(s.apexStudioCapturesEmpty, isNotEmpty));

        test('socialStudioWatermark does not contain FPS', () {
          expect(s.socialStudioWatermark.toLowerCase(), isNot(contains('fps')));
        });
        test('socialStudioWatermark does not contain boost real', () {
          expect(s.socialStudioWatermark.toLowerCase(), isNot(contains('boost real')));
        });

        test('captureModeVideoSubtitle is non-empty',
            () => expect(s.captureModeVideoSubtitle, isNotEmpty));
        test('captureModeVideoSubtitle no longer hardcodes a fixed duration',
            () {
          expect(s.captureModeVideoSubtitle.toLowerCase(), isNot(contains('10s')));
        });
        test('videoDurationDialogTitle is non-empty',
            () => expect(s.videoDurationDialogTitle, isNotEmpty));
        for (final seconds in [10, 15, 30, 60]) {
          test('videoDurationOptionLabel($seconds) mentions $seconds', () {
            expect(s.videoDurationOptionLabel(seconds), contains('$seconds'));
          });
        }
      });
    }
  });
}
