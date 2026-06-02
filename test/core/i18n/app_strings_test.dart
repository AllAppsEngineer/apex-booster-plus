import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/domain/entities/gfx_profile.dart';

void main() {
  const ptBr = AppStrings(AppLanguage.ptBr);
  const en = AppStrings(AppLanguage.en);
  const es = AppStrings(AppLanguage.es);

  // ─── Non-empty strings ───────────────────────────────────────────────────────

  group('AppStrings — non-empty for all languages', () {
    void expectNonEmpty(String Function(AppStrings) getter, String name) {
      test('$name is non-empty', () {
        expect(getter(ptBr), isNotEmpty, reason: 'ptBr.$name');
        expect(getter(en), isNotEmpty, reason: 'en.$name');
        expect(getter(es), isNotEmpty, reason: 'es.$name');
      });
    }

    expectNonEmpty((s) => s.appTagline, 'appTagline');
    expectNonEmpty((s) => s.appModel, 'appModel');
    expectNonEmpty((s) => s.appDisclaimer, 'appDisclaimer');
    expectNonEmpty((s) => s.appVersion, 'appVersion');
    expectNonEmpty((s) => s.settingsTitle, 'settingsTitle');
    expectNonEmpty((s) => s.settingsSubtitle, 'settingsSubtitle');
    expectNonEmpty((s) => s.navHome, 'navHome');
    expectNonEmpty((s) => s.navLibrary, 'navLibrary');
    expectNonEmpty((s) => s.navPrepare, 'navPrepare');
    expectNonEmpty((s) => s.navHistory, 'navHistory');
    expectNonEmpty((s) => s.navSettings, 'navSettings');
    expectNonEmpty((s) => s.navExitSnackBar, 'navExitSnackBar');
    expectNonEmpty((s) => s.languageTitle, 'languageTitle');
    expectNonEmpty((s) => s.languageSubtitle, 'languageSubtitle');
    expectNonEmpty((s) => s.languageSheetTitle, 'languageSheetTitle');
    expectNonEmpty((s) => s.focusTitle, 'focusTitle');
    expectNonEmpty((s) => s.focusDescription, 'focusDescription');
    expectNonEmpty((s) => s.clearHistoryTitle, 'clearHistoryTitle');
    expectNonEmpty((s) => s.clearHistorySuccess, 'clearHistorySuccess');
    expectNonEmpty((s) => s.homeTitle, 'homeTitle');
    expectNonEmpty((s) => s.homeSubtitle, 'homeSubtitle');
    expectNonEmpty((s) => s.historyTitle, 'historyTitle');
    expectNonEmpty((s) => s.historyEmptyTitle, 'historyEmptyTitle');
    expectNonEmpty((s) => s.prepTitle, 'prepTitle');
    expectNonEmpty((s) => s.prepContinue, 'prepContinue');
    expectNonEmpty((s) => s.gfxTitle, 'gfxTitle');
    expectNonEmpty((s) => s.gfxNoneLabel, 'gfxNoneLabel');
    expectNonEmpty((s) => s.libraryAddGame, 'libraryAddGame');
    expectNonEmpty((s) => s.libraryEmptyTitle, 'libraryEmptyTitle');
    expectNonEmpty((s) => s.detailOpenGame, 'detailOpenGame');
  });

  // ─── Strings differ between languages ────────────────────────────────────────

  group('AppStrings — ptBr ≠ en for translated strings', () {
    test('appTagline', () {
      expect(ptBr.appTagline, isNot(equals(en.appTagline)));
    });

    test('settingsTitle', () {
      expect(ptBr.settingsTitle, isNot(equals(en.settingsTitle)));
    });

    test('navHome', () {
      expect(ptBr.navHome, isNot(equals(en.navHome)));
    });

    test('navHistory', () {
      expect(ptBr.navHistory, isNot(equals(en.navHistory)));
    });

    test('languageTitle', () {
      expect(ptBr.languageTitle, isNot(equals(en.languageTitle)));
    });

    test('historyTitle', () {
      expect(ptBr.historyTitle, isNot(equals(en.historyTitle)));
    });

    test('prepTitle', () {
      expect(ptBr.prepTitle, isNot(equals(en.prepTitle)));
    });

    test('clearHistoryTitle', () {
      expect(ptBr.clearHistoryTitle, isNot(equals(en.clearHistoryTitle)));
    });

    test('appModel', () {
      expect(ptBr.appModel, isNot(equals(en.appModel)));
    });
  });

  // ─── Dynamic methods ──────────────────────────────────────────────────────────

  group('AppStrings — dynamic time methods', () {
    test('timeMinutesAgo is non-empty for all languages', () {
      expect(ptBr.timeMinutesAgo(5), isNotEmpty);
      expect(en.timeMinutesAgo(5), isNotEmpty);
      expect(es.timeMinutesAgo(5), isNotEmpty);
    });

    test('timeHoursAgo differs between ptBr and en', () {
      expect(ptBr.timeHoursAgo(2), isNot(equals(en.timeHoursAgo(2))));
    });

    test('timeDaysAgo is non-empty for all languages', () {
      expect(ptBr.timeDaysAgo(3), isNotEmpty);
      expect(en.timeDaysAgo(3), isNotEmpty);
      expect(es.timeDaysAgo(3), isNotEmpty);
    });
  });

  group('AppStrings — dynamic count methods', () {
    test('gameCountStat singular for ptBr', () {
      expect(ptBr.gameCountStat(1), contains('jogo adicionado'));
    });

    test('gameCountStat plural for ptBr', () {
      expect(ptBr.gameCountStat(2), contains('jogos adicionados'));
    });

    test('gameCountStat singular for en', () {
      expect(en.gameCountStat(1), contains('game added'));
    });

    test('gameCountStat plural for en', () {
      expect(en.gameCountStat(3), contains('games added'));
    });

    test('sessionCountStat singular for ptBr', () {
      expect(ptBr.sessionCountStat(1), contains('sessão registrada'));
    });

    test('sessionCountStat plural for ptBr', () {
      expect(ptBr.sessionCountStat(0), contains('sessões registradas'));
    });

    test('sessionCountStat singular for en', () {
      expect(en.sessionCountStat(1), contains('session recorded'));
    });

    test('sessionCountStat plural for en', () {
      expect(en.sessionCountStat(5), contains('sessions recorded'));
    });

    test('libraryGameCount singular for ptBr', () {
      expect(ptBr.libraryGameCount(1), contains('jogo'));
      expect(ptBr.libraryGameCount(1), isNot(contains('jogos')));
    });

    test('libraryGameCount plural for ptBr', () {
      expect(ptBr.libraryGameCount(4), contains('jogos'));
    });
  });

  // ─── GFX profile ──────────────────────────────────────────────────────────────

  group('AppStrings — GFX profile', () {
    test('gfxProfileLabel returns non-empty for all profiles and languages', () {
      for (final profile in GfxProfile.values) {
        expect(ptBr.gfxProfileLabel(profile), isNotEmpty,
            reason: 'ptBr.gfxProfileLabel(${profile.name})');
        expect(en.gfxProfileLabel(profile), isNotEmpty,
            reason: 'en.gfxProfileLabel(${profile.name})');
        expect(es.gfxProfileLabel(profile), isNotEmpty,
            reason: 'es.gfxProfileLabel(${profile.name})');
      }
    });

    test('gfxProfileDescription returns non-empty for all profiles and languages',
        () {
      for (final profile in GfxProfile.values) {
        expect(ptBr.gfxProfileDescription(profile), isNotEmpty,
            reason: 'ptBr.gfxProfileDescription(${profile.name})');
        expect(en.gfxProfileDescription(profile), isNotEmpty,
            reason: 'en.gfxProfileDescription(${profile.name})');
        expect(es.gfxProfileDescription(profile), isNotEmpty,
            reason: 'es.gfxProfileDescription(${profile.name})');
      }
    });

    test('gfxProfileLabel for ptBr matches GfxProfile.label (canonical key)', () {
      for (final profile in GfxProfile.values) {
        expect(ptBr.gfxProfileLabel(profile), profile.label,
            reason: '${profile.name} label must match canonical key in ptBr');
      }
    });

    test('gfxProfileLabel for en differs from ptBr (performance)', () {
      expect(
        ptBr.gfxProfileLabel(GfxProfile.performance),
        isNot(equals(en.gfxProfileLabel(GfxProfile.performance))),
      );
    });

    test('gfxProfileLabel for en differs from ptBr (quality)', () {
      expect(
        ptBr.gfxProfileLabel(GfxProfile.quality),
        isNot(equals(en.gfxProfileLabel(GfxProfile.quality))),
      );
    });
  });

  // ─── GFX scan messages ────────────────────────────────────────────────────────

  group('AppStrings — GFX scan messages', () {
    test('prepGfxMsgNone is non-empty for all languages', () {
      expect(ptBr.prepGfxMsgNone, isNotEmpty);
      expect(en.prepGfxMsgNone, isNotEmpty);
      expect(es.prepGfxMsgNone, isNotEmpty);
    });

    test('prepGfxMsgNone differs between ptBr and en', () {
      expect(ptBr.prepGfxMsgNone, isNot(equals(en.prepGfxMsgNone)));
    });

    test('prepGfxMsgPerformance differs between ptBr and en', () {
      expect(ptBr.prepGfxMsgPerformance, isNot(equals(en.prepGfxMsgPerformance)));
    });
  });

  // ─── InicioTab loading subtitles — LANG-U1.3A ────────────────────────────────

  group('AppStrings — InicioTab loading subtitles', () {
    test('homeLibraryLoadingSubtitle is non-empty for all languages', () {
      expect(ptBr.homeLibraryLoadingSubtitle, isNotEmpty);
      expect(en.homeLibraryLoadingSubtitle, isNotEmpty);
      expect(es.homeLibraryLoadingSubtitle, isNotEmpty);
    });

    test('homeLibraryLoadingSubtitle differs ptBr vs en', () {
      expect(
        ptBr.homeLibraryLoadingSubtitle,
        isNot(equals(en.homeLibraryLoadingSubtitle)),
      );
    });

    test('homeHistoryLoadingSubtitle is non-empty for all languages', () {
      expect(ptBr.homeHistoryLoadingSubtitle, isNotEmpty);
      expect(en.homeHistoryLoadingSubtitle, isNotEmpty);
      expect(es.homeHistoryLoadingSubtitle, isNotEmpty);
    });

    test('homeHistoryLoadingSubtitle differs ptBr vs en', () {
      expect(
        ptBr.homeHistoryLoadingSubtitle,
        isNot(equals(en.homeHistoryLoadingSubtitle)),
      );
    });
  });

  // ─── memoryStateLabel — LANG-U1.3A fix ──────────────────────────────────────

  group('AppStrings — memoryStateLabel', () {
    test('"normal" → ptBr: "normal"', () {
      expect(ptBr.memoryStateLabel('normal'), equals('normal'));
    });

    test('"normal" → en: "stable"', () {
      expect(en.memoryStateLabel('normal'), equals('stable'));
    });

    test('"normal" → es: "estable"', () {
      expect(es.memoryStateLabel('normal'), equals('estable'));
    });

    test('"low" → ptBr: "baixa"', () {
      expect(ptBr.memoryStateLabel('low'), equals('baixa'));
    });

    test('"low" → en: "low"', () {
      expect(en.memoryStateLabel('low'), equals('low'));
    });

    test('"low" → es: "baja"', () {
      expect(es.memoryStateLabel('low'), equals('baja'));
    });

    test('unknown state falls back to original value', () {
      expect(ptBr.memoryStateLabel('unknown_state'), equals('unknown_state'));
      expect(en.memoryStateLabel('unknown_state'), equals('unknown_state'));
      expect(es.memoryStateLabel('unknown_state'), equals('unknown_state'));
    });
  });

  // ─── historyRamChip — LANG-U1.3A fix ────────────────────────────────────────

  group('AppStrings — historyRamChip', () {
    test('ptBr contains "livre"', () {
      expect(ptBr.historyRamChip('3.2', 'normal'), contains('livre'));
    });

    test('en contains "free"', () {
      expect(en.historyRamChip('3.2', 'normal'), contains('free'));
    });

    test('es contains "libres"', () {
      expect(es.historyRamChip('3.2', 'normal'), contains('libres'));
    });

    test('ptBr "normal" state stays "normal"', () {
      expect(ptBr.historyRamChip('3.2', 'normal'), contains('normal'));
    });

    test('en "normal" state becomes "stable"', () {
      expect(en.historyRamChip('3.0', 'normal'), contains('stable'));
      expect(en.historyRamChip('3.0', 'normal'), isNot(contains('normal')));
    });

    test('es "normal" state becomes "estable"', () {
      expect(es.historyRamChip('2.8', 'normal'), contains('estable'));
      expect(es.historyRamChip('2.8', 'normal'), isNot(contains('normal')));
    });

    test('includes value for all languages', () {
      expect(ptBr.historyRamChip('3.2', 'normal'), contains('3.2'));
      expect(en.historyRamChip('3.0', 'normal'), contains('3.0'));
      expect(es.historyRamChip('2.8', 'normal'), contains('2.8'));
    });

    test('ptBr ≠ en', () {
      expect(
        ptBr.historyRamChip('3.2', 'normal'),
        isNot(equals(en.historyRamChip('3.2', 'normal'))),
      );
    });

    test('en ≠ es', () {
      expect(
        en.historyRamChip('3.2', 'normal'),
        isNot(equals(es.historyRamChip('3.2', 'normal'))),
      );
    });
  });

  // ─── relativeTime — LANG-U1.3A ───────────────────────────────────────────────

  group('AppStrings — relativeTime', () {
    final anchor = DateTime(2024, 6, 15, 12, 0, 0);

    test('returns timeJustNow when diff < 1 minute', () {
      final dt = anchor.subtract(const Duration(seconds: 30));
      expect(ptBr.relativeTime(dt, now: anchor), equals(ptBr.timeJustNow));
      expect(en.relativeTime(dt, now: anchor), equals(en.timeJustNow));
      expect(es.relativeTime(dt, now: anchor), equals(es.timeJustNow));
    });

    test('returns timeMinutesAgo when diff is 1-59 min', () {
      final dt = anchor.subtract(const Duration(minutes: 30));
      expect(
        ptBr.relativeTime(dt, now: anchor),
        equals(ptBr.timeMinutesAgo(30)),
      );
      expect(
        en.relativeTime(dt, now: anchor),
        equals(en.timeMinutesAgo(30)),
      );
    });

    test('returns timeHoursAgo when diff is 1-23 h', () {
      final dt = anchor.subtract(const Duration(hours: 3));
      expect(
        ptBr.relativeTime(dt, now: anchor),
        equals(ptBr.timeHoursAgo(3)),
      );
      expect(
        en.relativeTime(dt, now: anchor),
        equals(en.timeHoursAgo(3)),
      );
    });

    test('returns timeYesterday when diff is 24-47 h', () {
      final dt = anchor.subtract(const Duration(hours: 25));
      expect(ptBr.relativeTime(dt, now: anchor), equals(ptBr.timeYesterday));
      expect(en.relativeTime(dt, now: anchor), equals(en.timeYesterday));
      expect(es.relativeTime(dt, now: anchor), equals(es.timeYesterday));
    });

    test('returns timeDaysAgo when diff is 2-6 days', () {
      final dt = anchor.subtract(const Duration(days: 3));
      expect(
        ptBr.relativeTime(dt, now: anchor),
        equals(ptBr.timeDaysAgo(3)),
      );
      expect(
        en.relativeTime(dt, now: anchor),
        equals(en.timeDaysAgo(3)),
      );
    });

    test('returns formatted date DD/MM/YYYY when diff >= 7 days', () {
      final dt = DateTime(2024, 6, 1, 8, 0, 0);
      expect(ptBr.relativeTime(dt, now: anchor), equals('01/06/2024'));
      expect(en.relativeTime(dt, now: anchor), equals('01/06/2024'));
    });

    test('relativeTime output differs between ptBr and en for 30 min ago', () {
      final dt = anchor.subtract(const Duration(minutes: 30));
      expect(
        ptBr.relativeTime(dt, now: anchor),
        isNot(equals(en.relativeTime(dt, now: anchor))),
      );
    });

    test('relativeTime output differs between ptBr and en for yesterday', () {
      final dt = anchor.subtract(const Duration(hours: 25));
      expect(
        ptBr.relativeTime(dt, now: anchor),
        isNot(equals(en.relativeTime(dt, now: anchor))),
      );
    });
  });

  // ─── Onboarding — LANG-U1.3B ────────────────────────────────────────────────

  group('AppStrings — Welcome screen strings', () {
    test('welcomeCardBibTitle is non-empty for all languages', () {
      expect(ptBr.welcomeCardBibTitle, isNotEmpty);
      expect(en.welcomeCardBibTitle, isNotEmpty);
      expect(es.welcomeCardBibTitle, isNotEmpty);
    });

    test('welcomeCardBibTitle differs ptBr vs en', () {
      expect(ptBr.welcomeCardBibTitle, isNot(equals(en.welcomeCardBibTitle)));
    });

    test('welcomeCardBibSubtitle is non-empty for all languages', () {
      expect(ptBr.welcomeCardBibSubtitle, isNotEmpty);
      expect(en.welcomeCardBibSubtitle, isNotEmpty);
      expect(es.welcomeCardBibSubtitle, isNotEmpty);
    });

    test('welcomeCardScanTitle is non-empty for all languages', () {
      expect(ptBr.welcomeCardScanTitle, isNotEmpty);
      expect(en.welcomeCardScanTitle, isNotEmpty);
      expect(es.welcomeCardScanTitle, isNotEmpty);
    });

    test('welcomeCardScanTitle differs ptBr vs en', () {
      expect(ptBr.welcomeCardScanTitle, isNot(equals(en.welcomeCardScanTitle)));
    });

    test('welcomeCardGoTitle is non-empty for all languages', () {
      expect(ptBr.welcomeCardGoTitle, isNotEmpty);
      expect(en.welcomeCardGoTitle, isNotEmpty);
      expect(es.welcomeCardGoTitle, isNotEmpty);
    });

    test('welcomeCtaStart is non-empty for all languages', () {
      expect(ptBr.welcomeCtaStart, isNotEmpty);
      expect(en.welcomeCtaStart, isNotEmpty);
      expect(es.welcomeCtaStart, isNotEmpty);
    });

    test('welcomeCtaStart differs ptBr vs en', () {
      expect(ptBr.welcomeCtaStart, isNot(equals(en.welcomeCtaStart)));
    });
  });

  group('AppStrings — HowItWorks screen strings', () {
    test('howItWorksTitle is non-empty for all languages', () {
      expect(ptBr.howItWorksTitle, isNotEmpty);
      expect(en.howItWorksTitle, isNotEmpty);
      expect(es.howItWorksTitle, isNotEmpty);
    });

    test('howItWorksTitle differs ptBr vs en', () {
      expect(ptBr.howItWorksTitle, isNot(equals(en.howItWorksTitle)));
    });

    test('howItWorksCardBibSubtitle is non-empty for all languages', () {
      expect(ptBr.howItWorksCardBibSubtitle, isNotEmpty);
      expect(en.howItWorksCardBibSubtitle, isNotEmpty);
      expect(es.howItWorksCardBibSubtitle, isNotEmpty);
    });

    test('howItWorksCardBibSubtitle differs ptBr vs en', () {
      expect(
        ptBr.howItWorksCardBibSubtitle,
        isNot(equals(en.howItWorksCardBibSubtitle)),
      );
    });

    test('howItWorksCardGfxSubtitle is non-empty for all languages', () {
      expect(ptBr.howItWorksCardGfxSubtitle, isNotEmpty);
      expect(en.howItWorksCardGfxSubtitle, isNotEmpty);
      expect(es.howItWorksCardGfxSubtitle, isNotEmpty);
    });

    test('howItWorksCardScanSubtitle is non-empty for all languages', () {
      expect(ptBr.howItWorksCardScanSubtitle, isNotEmpty);
      expect(en.howItWorksCardScanSubtitle, isNotEmpty);
      expect(es.howItWorksCardScanSubtitle, isNotEmpty);
    });

    test('howItWorksCardGoSubtitle is non-empty for all languages', () {
      expect(ptBr.howItWorksCardGoSubtitle, isNotEmpty);
      expect(en.howItWorksCardGoSubtitle, isNotEmpty);
      expect(es.howItWorksCardGoSubtitle, isNotEmpty);
    });

    test('howItWorksCta is non-empty for all languages', () {
      expect(ptBr.howItWorksCta, isNotEmpty);
      expect(en.howItWorksCta, isNotEmpty);
      expect(es.howItWorksCta, isNotEmpty);
    });

    test('howItWorksCta differs ptBr vs en', () {
      expect(ptBr.howItWorksCta, isNot(equals(en.howItWorksCta)));
    });
  });

  // ─── GFX Profile screen — LANG-U1.4A ────────────────────────────────────────

  group('AppStrings — GFX Profile screen strings', () {
    test('gfxTitle is non-empty for all languages', () {
      expect(ptBr.gfxTitle, isNotEmpty);
      expect(en.gfxTitle, isNotEmpty);
      expect(es.gfxTitle, isNotEmpty);
    });

    test('gfxTitle differs ptBr vs en', () {
      expect(ptBr.gfxTitle, isNot(equals(en.gfxTitle)));
    });

    test('gfxBackTooltip is non-empty for all languages', () {
      expect(ptBr.gfxBackTooltip, isNotEmpty);
      expect(en.gfxBackTooltip, isNotEmpty);
      expect(es.gfxBackTooltip, isNotEmpty);
    });

    test('gfxBackTooltip differs ptBr vs en', () {
      expect(ptBr.gfxBackTooltip, isNot(equals(en.gfxBackTooltip)));
    });

    test('gfxCurrentPrefix is non-empty for all languages', () {
      expect(ptBr.gfxCurrentPrefix, isNotEmpty);
      expect(en.gfxCurrentPrefix, isNotEmpty);
      expect(es.gfxCurrentPrefix, isNotEmpty);
    });

    test('gfxCurrentPrefix differs ptBr vs en', () {
      expect(ptBr.gfxCurrentPrefix, isNot(equals(en.gfxCurrentPrefix)));
    });

    test('gfxInstruction is non-empty for all languages', () {
      expect(ptBr.gfxInstruction, isNotEmpty);
      expect(en.gfxInstruction, isNotEmpty);
      expect(es.gfxInstruction, isNotEmpty);
    });

    test('gfxInstruction differs ptBr vs en', () {
      expect(ptBr.gfxInstruction, isNot(equals(en.gfxInstruction)));
    });

    test('gfxFootnote is non-empty for all languages', () {
      expect(ptBr.gfxFootnote, isNotEmpty);
      expect(en.gfxFootnote, isNotEmpty);
      expect(es.gfxFootnote, isNotEmpty);
    });

    test('gfxFootnote differs ptBr vs en', () {
      expect(ptBr.gfxFootnote, isNot(equals(en.gfxFootnote)));
    });

    test('gfxNotFoundTitle is non-empty for all languages', () {
      expect(ptBr.gfxNotFoundTitle, isNotEmpty);
      expect(en.gfxNotFoundTitle, isNotEmpty);
      expect(es.gfxNotFoundTitle, isNotEmpty);
    });

    test('gfxNotFoundTitle differs ptBr vs en', () {
      expect(ptBr.gfxNotFoundTitle, isNot(equals(en.gfxNotFoundTitle)));
    });

    test('gfxNotFoundDesc is non-empty for all languages', () {
      expect(ptBr.gfxNotFoundDesc, isNotEmpty);
      expect(en.gfxNotFoundDesc, isNotEmpty);
      expect(es.gfxNotFoundDesc, isNotEmpty);
    });

    test('gfxNoneLabel is non-empty for all languages', () {
      expect(ptBr.gfxNoneLabel, isNotEmpty);
      expect(en.gfxNoneLabel, isNotEmpty);
      expect(es.gfxNoneLabel, isNotEmpty);
    });

    test('gfxNoneLabel differs ptBr vs en', () {
      expect(ptBr.gfxNoneLabel, isNot(equals(en.gfxNoneLabel)));
    });

    test('gfxNoneDesc is non-empty for all languages', () {
      expect(ptBr.gfxNoneDesc, isNotEmpty);
      expect(en.gfxNoneDesc, isNotEmpty);
      expect(es.gfxNoneDesc, isNotEmpty);
    });

    test('gfxNoneDesc differs ptBr vs en', () {
      expect(ptBr.gfxNoneDesc, isNot(equals(en.gfxNoneDesc)));
    });

    test('gfxCurrentPrefix ptBr starts with "Atual"', () {
      expect(ptBr.gfxCurrentPrefix, contains('Atual'));
    });

    test('gfxCurrentPrefix en starts with "Current"', () {
      expect(en.gfxCurrentPrefix, contains('Current'));
    });

    test('gfxCurrentPrefix es starts with "Actual"', () {
      expect(es.gfxCurrentPrefix, contains('Actual'));
    });
  });

  group('AppStrings — Permissions screen strings', () {
    test('permissionsTitle is non-empty for all languages', () {
      expect(ptBr.permissionsTitle, isNotEmpty);
      expect(en.permissionsTitle, isNotEmpty);
      expect(es.permissionsTitle, isNotEmpty);
    });

    test('permissionsTitle differs ptBr vs en', () {
      expect(ptBr.permissionsTitle, isNot(equals(en.permissionsTitle)));
    });

    test('permissionsSubtitle is non-empty for all languages', () {
      expect(ptBr.permissionsSubtitle, isNotEmpty);
      expect(en.permissionsSubtitle, isNotEmpty);
      expect(es.permissionsSubtitle, isNotEmpty);
    });

    test('permissionsCardNotifTitle is non-empty for all languages', () {
      expect(ptBr.permissionsCardNotifTitle, isNotEmpty);
      expect(en.permissionsCardNotifTitle, isNotEmpty);
      expect(es.permissionsCardNotifTitle, isNotEmpty);
    });

    test('permissionsCardNotifTitle differs ptBr vs en', () {
      expect(
        ptBr.permissionsCardNotifTitle,
        isNot(equals(en.permissionsCardNotifTitle)),
      );
    });

    test('permissionsCardNotifSubtitle is non-empty for all languages', () {
      expect(ptBr.permissionsCardNotifSubtitle, isNotEmpty);
      expect(en.permissionsCardNotifSubtitle, isNotEmpty);
      expect(es.permissionsCardNotifSubtitle, isNotEmpty);
    });

    test('permissionsCardAppsTitle is non-empty for all languages', () {
      expect(ptBr.permissionsCardAppsTitle, isNotEmpty);
      expect(en.permissionsCardAppsTitle, isNotEmpty);
      expect(es.permissionsCardAppsTitle, isNotEmpty);
    });

    test('permissionsCardAppsSubtitle is non-empty for all languages', () {
      expect(ptBr.permissionsCardAppsSubtitle, isNotEmpty);
      expect(en.permissionsCardAppsSubtitle, isNotEmpty);
      expect(es.permissionsCardAppsSubtitle, isNotEmpty);
    });

    test('permissionsCardNetBadge differs ptBr vs en', () {
      expect(
        ptBr.permissionsCardNetBadge,
        isNot(equals(en.permissionsCardNetBadge)),
      );
    });

    test('permissionsCardNetTitle is non-empty for all languages', () {
      expect(ptBr.permissionsCardNetTitle, isNotEmpty);
      expect(en.permissionsCardNetTitle, isNotEmpty);
      expect(es.permissionsCardNetTitle, isNotEmpty);
    });

    test('permissionsCardNetTitle differs ptBr vs en', () {
      expect(
        ptBr.permissionsCardNetTitle,
        isNot(equals(en.permissionsCardNetTitle)),
      );
    });

    test('permissionsCardNetSubtitle is non-empty for all languages', () {
      expect(ptBr.permissionsCardNetSubtitle, isNotEmpty);
      expect(en.permissionsCardNetSubtitle, isNotEmpty);
      expect(es.permissionsCardNetSubtitle, isNotEmpty);
    });

    test('permissionsCardFocusTitle is non-empty for all languages', () {
      expect(ptBr.permissionsCardFocusTitle, isNotEmpty);
      expect(en.permissionsCardFocusTitle, isNotEmpty);
      expect(es.permissionsCardFocusTitle, isNotEmpty);
    });

    test('permissionsCardFocusSubtitle is non-empty for all languages', () {
      expect(ptBr.permissionsCardFocusSubtitle, isNotEmpty);
      expect(en.permissionsCardFocusSubtitle, isNotEmpty);
      expect(es.permissionsCardFocusSubtitle, isNotEmpty);
    });

    test('permissionsCardFocusSubtitle differs ptBr vs en', () {
      expect(
        ptBr.permissionsCardFocusSubtitle,
        isNot(equals(en.permissionsCardFocusSubtitle)),
      );
    });

    test('permissionsTrustMessage is non-empty for all languages', () {
      expect(ptBr.permissionsTrustMessage, isNotEmpty);
      expect(en.permissionsTrustMessage, isNotEmpty);
      expect(es.permissionsTrustMessage, isNotEmpty);
    });

    test('permissionsTrustMessage differs ptBr vs en', () {
      expect(
        ptBr.permissionsTrustMessage,
        isNot(equals(en.permissionsTrustMessage)),
      );
    });

    test('permissionsCta is non-empty for all languages', () {
      expect(ptBr.permissionsCta, isNotEmpty);
      expect(en.permissionsCta, isNotEmpty);
      expect(es.permissionsCta, isNotEmpty);
    });

    test('permissionsCta differs ptBr vs en', () {
      expect(ptBr.permissionsCta, isNot(equals(en.permissionsCta)));
    });
  });

  // ─── PrepararTab new strings — LANG-U1.4B ────────────────────────────────────

  group('AppStrings — PrepararTab new strings (LANG-U1.4B)', () {
    test('snapshotLocalReading is non-empty for all languages', () {
      expect(ptBr.snapshotLocalReading, isNotEmpty);
      expect(en.snapshotLocalReading, isNotEmpty);
      expect(es.snapshotLocalReading, isNotEmpty);
    });

    test('snapshotLocalReading differs ptBr vs en', () {
      expect(ptBr.snapshotLocalReading, isNot(equals(en.snapshotLocalReading)));
    });

    test('snapshotMemoryCritical is non-empty for all languages', () {
      expect(ptBr.snapshotMemoryCritical, isNotEmpty);
      expect(en.snapshotMemoryCritical, isNotEmpty);
      expect(es.snapshotMemoryCritical, isNotEmpty);
    });

    test('snapshotMemoryNormal is non-empty for all languages', () {
      expect(ptBr.snapshotMemoryNormal, isNotEmpty);
      expect(en.snapshotMemoryNormal, isNotEmpty);
      expect(es.snapshotMemoryNormal, isNotEmpty);
    });

    test('snapshotLatencyTimeout is non-empty for all languages', () {
      expect(ptBr.snapshotLatencyTimeout, isNotEmpty);
      expect(en.snapshotLatencyTimeout, isNotEmpty);
      expect(es.snapshotLatencyTimeout, isNotEmpty);
    });

    test('snapshotLatencyTimeout differs ptBr vs en', () {
      expect(ptBr.snapshotLatencyTimeout, isNot(equals(en.snapshotLatencyTimeout)));
    });

    test('snapshotLatencyNoNetwork is non-empty for all languages', () {
      expect(ptBr.snapshotLatencyNoNetwork, isNotEmpty);
      expect(en.snapshotLatencyNoNetwork, isNotEmpty);
      expect(es.snapshotLatencyNoNetwork, isNotEmpty);
    });

    test('snapshotLatencyNoNetwork differs ptBr vs en', () {
      expect(ptBr.snapshotLatencyNoNetwork, isNot(equals(en.snapshotLatencyNoNetwork)));
    });

    test('snapshotFocusAvailable is non-empty for all languages', () {
      expect(ptBr.snapshotFocusAvailable, isNotEmpty);
      expect(en.snapshotFocusAvailable, isNotEmpty);
      expect(es.snapshotFocusAvailable, isNotEmpty);
    });

    test('snapshotFocusAvailable differs ptBr vs en', () {
      expect(ptBr.snapshotFocusAvailable, isNot(equals(en.snapshotFocusAvailable)));
    });

    test('snapshotFocusPermissionRequired is non-empty for all languages', () {
      expect(ptBr.snapshotFocusPermissionRequired, isNotEmpty);
      expect(en.snapshotFocusPermissionRequired, isNotEmpty);
      expect(es.snapshotFocusPermissionRequired, isNotEmpty);
    });

    test('snapshotFocusPermissionRequired differs ptBr vs en', () {
      expect(
        ptBr.snapshotFocusPermissionRequired,
        isNot(equals(en.snapshotFocusPermissionRequired)),
      );
    });

    test('prepGameBadge is non-empty for all languages', () {
      expect(ptBr.prepGameBadge, isNotEmpty);
      expect(en.prepGameBadge, isNotEmpty);
      expect(es.prepGameBadge, isNotEmpty);
    });

    test('prepGameBadge ptBr is JOGO', () {
      expect(ptBr.prepGameBadge, 'JOGO');
    });

    test('prepGameBadge en is GAME', () {
      expect(en.prepGameBadge, 'GAME');
    });

    test('prepGameBadge es is JUEGO', () {
      expect(es.prepGameBadge, 'JUEGO');
    });

    test('prepGfxDefault is non-empty for all languages', () {
      expect(ptBr.prepGfxDefault, isNotEmpty);
      expect(en.prepGfxDefault, isNotEmpty);
      expect(es.prepGfxDefault, isNotEmpty);
    });

    test('prepGfxDefault differs ptBr vs en', () {
      expect(ptBr.prepGfxDefault, isNot(equals(en.prepGfxDefault)));
    });

    test('prepFavoriteLabel is non-empty for all languages', () {
      expect(ptBr.prepFavoriteLabel, isNotEmpty);
      expect(en.prepFavoriteLabel, isNotEmpty);
      expect(es.prepFavoriteLabel, isNotEmpty);
    });

    test('prepFavoriteLabel differs ptBr vs en', () {
      expect(ptBr.prepFavoriteLabel, isNot(equals(en.prepFavoriteLabel)));
    });

    test('prepScanStatusReady is non-empty for all languages', () {
      expect(ptBr.prepScanStatusReady, isNotEmpty);
      expect(en.prepScanStatusReady, isNotEmpty);
      expect(es.prepScanStatusReady, isNotEmpty);
    });

    test('prepScanStatusReady differs ptBr vs en', () {
      expect(ptBr.prepScanStatusReady, isNot(equals(en.prepScanStatusReady)));
    });

    test('prepScanStatusIncomplete is non-empty for all languages', () {
      expect(ptBr.prepScanStatusIncomplete, isNotEmpty);
      expect(en.prepScanStatusIncomplete, isNotEmpty);
      expect(es.prepScanStatusIncomplete, isNotEmpty);
    });

    test('prepScanStatusIncomplete differs ptBr vs en', () {
      expect(ptBr.prepScanStatusIncomplete, isNot(equals(en.prepScanStatusIncomplete)));
    });

    test('prepScanSubtitle is non-empty for all languages', () {
      expect(ptBr.prepScanSubtitle, isNotEmpty);
      expect(en.prepScanSubtitle, isNotEmpty);
      expect(es.prepScanSubtitle, isNotEmpty);
    });

    test('prepScanSubtitle differs ptBr vs en', () {
      expect(ptBr.prepScanSubtitle, isNot(equals(en.prepScanSubtitle)));
    });

    test('prepSelectGame is non-empty for all languages', () {
      expect(ptBr.prepSelectGame, isNotEmpty);
      expect(en.prepSelectGame, isNotEmpty);
      expect(es.prepSelectGame, isNotEmpty);
    });

    test('prepSelectGame differs ptBr vs en', () {
      expect(ptBr.prepSelectGame, isNot(equals(en.prepSelectGame)));
    });
  });
}
