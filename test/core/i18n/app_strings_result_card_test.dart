import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';

void main() {
  final langs = AppLanguage.values;

  group('AppStrings — result card section', () {
    for (final lang in langs) {
      group('lang=$lang', () {
        late AppStrings s;
        setUp(() => s = AppStrings(lang));

        test('resultCardHeaderLabel is non-empty', () => expect(s.resultCardHeaderLabel, isNotEmpty));
        test('resultCardSubtitle is non-empty', () => expect(s.resultCardSubtitle, isNotEmpty));
        test('resultCardSectionPreparation is non-empty', () => expect(s.resultCardSectionPreparation, isNotEmpty));
        test('resultCardProfileLabel is non-empty', () => expect(s.resultCardProfileLabel, isNotEmpty));
        test('resultCardMetricsUnavailable is non-empty', () => expect(s.resultCardMetricsUnavailable, isNotEmpty));
        test('resultCardTimestampPrefix is non-empty', () => expect(s.resultCardTimestampPrefix, isNotEmpty));
        test('resultCardCtaReopen is non-empty', () => expect(s.resultCardCtaReopen, isNotEmpty));
        test('resultCardCtaShare is non-empty', () => expect(s.resultCardCtaShare, isNotEmpty));
        test('resultCardErrorTitle is non-empty', () => expect(s.resultCardErrorTitle, isNotEmpty));
        test('resultCardErrorDesc is non-empty', () => expect(s.resultCardErrorDesc, isNotEmpty));

        test('resultCardMetricsUnavailable does not contain fake zero metrics', () {
          expect(s.resultCardMetricsUnavailable, isNot(contains('0 GB')));
          expect(s.resultCardMetricsUnavailable, isNot(contains('0 ms')));
        });

        test('resultCardCtaReopen does not promise real FPS/boost', () {
          expect(s.resultCardCtaReopen.toLowerCase(), isNot(contains('fps')));
          expect(s.resultCardCtaReopen.toLowerCase(), isNot(contains('boost')));
        });
      });
    }
  });
}
