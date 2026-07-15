import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';

void main() {
  final langs = AppLanguage.values;

  group('AppStrings — unlock section', () {
    for (final lang in langs) {
      group('lang=$lang', () {
        late AppStrings s;
        setUp(() => s = AppStrings(lang));

        test('unlockCardTitle is non-empty', () => expect(s.unlockCardTitle, isNotEmpty));
        test('unlockCardSubtitle is non-empty', () => expect(s.unlockCardSubtitle, isNotEmpty));
        test('unlockCardAction is non-empty', () => expect(s.unlockCardAction, isNotEmpty));
        test('unlockScreenTitle is non-empty', () => expect(s.unlockScreenTitle, isNotEmpty));
        test('unlockBenefitsLabel is non-empty', () => expect(s.unlockBenefitsLabel, isNotEmpty));
        test('unlockBenefit1 is non-empty', () => expect(s.unlockBenefit1, isNotEmpty));
        test('unlockBenefit2 is non-empty', () => expect(s.unlockBenefit2, isNotEmpty));
        test('unlockBenefit3 is non-empty', () => expect(s.unlockBenefit3, isNotEmpty));
        test('unlockPriceLabel is non-empty', () => expect(s.unlockPriceLabel, isNotEmpty));
        test('unlockPriceNote is non-empty', () => expect(s.unlockPriceNote, isNotEmpty));
        test('unlockBuyButton is non-empty', () => expect(s.unlockBuyButton, isNotEmpty));
        test('unlockRestoreButton is non-empty', () => expect(s.unlockRestoreButton, isNotEmpty));
        test('unlockUnlockedTitle is non-empty', () => expect(s.unlockUnlockedTitle, isNotEmpty));
        test('unlockUnlockedDesc is non-empty', () => expect(s.unlockUnlockedDesc, isNotEmpty));
        test('unlockUnavailableTitle is non-empty', () => expect(s.unlockUnavailableTitle, isNotEmpty));
        test('unlockUnavailableDesc is non-empty', () => expect(s.unlockUnavailableDesc, isNotEmpty));
        test('unlockErrorTitle is non-empty', () => expect(s.unlockErrorTitle, isNotEmpty));
        test('unlockErrorDesc is non-empty', () => expect(s.unlockErrorDesc, isNotEmpty));
        test('unlockRestoreSuccess is non-empty', () => expect(s.unlockRestoreSuccess, isNotEmpty));
        test('unlockRestoreNotFound is non-empty', () => expect(s.unlockRestoreNotFound, isNotEmpty));
        test('unlockDisclaimer is non-empty', () => expect(s.unlockDisclaimer, isNotEmpty));

        test('unlockPriceLabel mentions the approved price', () {
          expect(s.unlockPriceLabel, anyOf(contains('2,99'), contains('2.99')));
        });

        test('none of the unlock strings promise real FPS/ping/CPU/GPU boost', () {
          final all = [
            s.unlockCardTitle,
            s.unlockCardSubtitle,
            s.unlockCardAction,
            s.unlockScreenTitle,
            s.unlockBenefitsLabel,
            s.unlockBenefit1,
            s.unlockBenefit2,
            s.unlockBenefit3,
            s.unlockPriceLabel,
            s.unlockPriceNote,
            s.unlockBuyButton,
            s.unlockRestoreButton,
            s.unlockUnlockedTitle,
            s.unlockUnlockedDesc,
            s.unlockUnavailableTitle,
            s.unlockUnavailableDesc,
            s.unlockErrorTitle,
            s.unlockErrorDesc,
            s.unlockRestoreSuccess,
            s.unlockRestoreNotFound,
            s.unlockDisclaimer,
          ].join(' ').toLowerCase();

          expect(all, isNot(contains('fps')));
          expect(all, isNot(contains('ping')));
          expect(all, isNot(contains('boost real')));
          expect(all, isNot(contains('gpu')));
          expect(all, isNot(contains('cpu')));
        });
      });
    }
  });
}
