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
}
