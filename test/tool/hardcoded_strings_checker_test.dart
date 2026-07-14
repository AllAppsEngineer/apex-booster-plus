import 'package:flutter_test/flutter_test.dart';
import '../../tool/hardcoded_strings_checker.dart';

void main() {
  final checker = HardcodedStringsChecker();

  // ── Blocked phrases — HIGH severity ────────────────────────────────────────

  group('blocked phrases — HIGH severity', () {
    test('detects "Nenhum perfil definido"', () {
      final issues = checker.checkContent(
        'test.dart',
        "  Text('Nenhum perfil definido'),",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
      expect(issues.first.match, 'Nenhum perfil definido');
      expect(issues.first.line, 1);
    });

    test('detects "Adicionado em"', () {
      final issues = checker.checkContent(
        'test.dart',
        "  Text('Adicionado em \$date'),",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
    });

    test('detects "Atualizado em"', () {
      final issues = checker.checkContent(
        'test.dart',
        "  Text('Atualizado em \$date'),",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
    });

    test('detects "Abrir jogo" (lowercase j)', () {
      final issues = checker.checkContent(
        'test.dart',
        "  Text('Abrir jogo'),",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
    });

    test('detects "Abrir Jogo" (uppercase J)', () {
      final issues = checker.checkContent(
        'test.dart',
        "  label: 'Abrir Jogo',",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
    });

    test('detects "ABRIR JOGO" (all-caps)', () {
      final issues = checker.checkContent(
        'test.dart',
        "  Text('ABRIR JOGO'),",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
    });

    test('detects "Preparar sessão"', () {
      final issues = checker.checkContent(
        'test.dart',
        "  Text('Preparar sessão'),",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
    });

    test('detects "Preparar Sessão" (uppercase S)', () {
      final issues = checker.checkContent(
        'test.dart',
        "  title: 'Preparar Sessão',",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
    });

    test('detects "Detalhe do Jogo"', () {
      final issues = checker.checkContent(
        'test.dart',
        "  title: 'Detalhe do Jogo',",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
    });

    test('detects "Detalhe do jogo" (lowercase j)', () {
      final issues = checker.checkContent(
        'test.dart',
        "  title: 'Detalhe do jogo',",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
    });

    test('detects "App vinculado ao cadastro"', () {
      final issues = checker.checkContent(
        'test.dart',
        "  Text('App vinculado ao cadastro'),",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
    });

    test('detects "App instalado e acessível"', () {
      final issues = checker.checkContent(
        'test.dart',
        "  Text('App instalado e acessível'),",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
    });
  });

  // ── Blocked terms — MEDIUM severity ────────────────────────────────────────

  group('blocked terms — MEDIUM severity', () {
    test('detects "Desempenho"', () {
      final issues = checker.checkContent(
        'test.dart',
        "  Text('Desempenho'),",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.medium);
      expect(issues.first.match, 'Desempenho');
    });

    test('detects "Qualidade"', () {
      final issues = checker.checkContent(
        'test.dart',
        "  label: 'Qualidade',",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.medium);
    });

    test('detects "Economia"', () {
      final issues = checker.checkContent(
        'test.dart',
        "  Text('Economia'),",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.medium);
    });

    test('detects "Equilibrado"', () {
      final issues = checker.checkContent(
        'test.dart',
        "  label: 'Equilibrado',",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.medium);
    });

    test('detects "Favorito"', () {
      final issues = checker.checkContent(
        'test.dart',
        "  tooltip: 'Favorito',",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.medium);
    });

    test('detects term co-existing with whitelisted GFX in same line', () {
      // GFX is whitelisted but Qualidade is blocked — must still flag
      final issues = checker.checkContent(
        'test.dart',
        "  label: 'GFX Qualidade',",
      );
      expect(issues, hasLength(1));
      expect(issues.first.match, 'Qualidade');
    });
  });

  // ── Skip patterns ───────────────────────────────────────────────────────────

  group('skip patterns', () {
    test('skips import lines', () {
      final issues = checker.checkContent(
        'test.dart',
        "import 'package:foo/Desempenho/screen.dart';",
      );
      expect(issues, isEmpty);
    });

    test('skips export lines', () {
      final issues = checker.checkContent(
        'test.dart',
        "export 'package:foo/Equilibrado.dart';",
      );
      expect(issues, isEmpty);
    });

    test('skips full-line // comments', () {
      final issues = checker.checkContent(
        'test.dart',
        '  // Desempenho é um perfil GFX',
      );
      expect(issues, isEmpty);
    });

    test('skips block comment * lines', () {
      final issues = checker.checkContent(
        'test.dart',
        '  * Adicionado em fase anterior',
      );
      expect(issues, isEmpty);
    });

    test('skips /* block comment opener', () {
      final issues = checker.checkContent(
        'test.dart',
        '  /* Adicionado em algum lugar */',
      );
      expect(issues, isEmpty);
    });

    test('skips empty lines', () {
      final issues = checker.checkContent('test.dart', '');
      expect(issues, isEmpty);
    });

    test('strips inline comment before checking', () {
      final issues = checker.checkContent(
        'test.dart',
        '  final x = true; // Desempenho ativo',
      );
      expect(issues, isEmpty);
    });

    test('strips inline comment — phrase after //', () {
      final issues = checker.checkContent(
        'test.dart',
        '  final ok = true; // Adicionado em fase 2',
      );
      expect(issues, isEmpty);
    });

    test('strips inline comment — phrase as string literal inside comment', () {
      // Without comment stripping this would extract 'Adicionado em' from the
      // comment's string literal and falsely flag the line.
      final issues = checker.checkContent(
        'test.dart',
        "  final x = 'ok'; // was 'Adicionado em' before migration",
      );
      expect(issues, isEmpty);
    });
  });

  // ── Whitelist ───────────────────────────────────────────────────────────────

  group('whitelist — accepted terms produce no false positives', () {
    test('Apex Booster+ is not flagged', () {
      final issues = checker.checkContent('test.dart', "Text('Apex Booster+'),");
      expect(issues, isEmpty);
    });

    test('APEX BOOSTER+ is not flagged', () {
      final issues = checker.checkContent('test.dart', "Text('APEX BOOSTER+'),");
      expect(issues, isEmpty);
    });

    test('APEX SCAN is not flagged', () {
      final issues = checker.checkContent('test.dart', "Text('APEX SCAN'),");
      expect(issues, isEmpty);
    });

    test('Apex Scan is not flagged', () {
      final issues = checker.checkContent('test.dart', "title: 'Apex Scan',");
      expect(issues, isEmpty);
    });

    test('GFX is not flagged', () {
      final issues = checker.checkContent('test.dart', "Text('GFX'),");
      expect(issues, isEmpty);
    });

    test('RAM is not flagged', () {
      final issues = checker.checkContent('test.dart', "label: 'RAM',");
      expect(issues, isEmpty);
    });

    test('FPS is not flagged', () {
      final issues = checker.checkContent('test.dart', "Text('FPS'),");
      expect(issues, isEmpty);
    });

    test('GPU is not flagged', () {
      final issues = checker.checkContent('test.dart', "label: 'GPU',");
      expect(issues, isEmpty);
    });

    test('Ping is not flagged', () {
      final issues = checker.checkContent('test.dart', "label: 'Ping',");
      expect(issues, isEmpty);
    });

    test('OK is not flagged', () {
      final issues = checker.checkContent('test.dart', "Text('OK'),");
      expect(issues, isEmpty);
    });

    test('ms is not flagged', () {
      final issues = checker.checkContent('test.dart', "unit: 'ms',");
      expect(issues, isEmpty);
    });

    test('MB is not flagged', () {
      final issues = checker.checkContent('test.dart', "unit: 'MB',");
      expect(issues, isEmpty);
    });

    test('SCAN badge is not flagged', () {
      final issues = checker.checkContent('test.dart', "badge: 'SCAN',");
      expect(issues, isEmpty);
    });

    test('GO badge is not flagged', () {
      final issues = checker.checkContent('test.dart', "badge: 'GO',");
      expect(issues, isEmpty);
    });

    test('NOTIF badge is not flagged', () {
      final issues = checker.checkContent('test.dart', "badge: 'NOTIF',");
      expect(issues, isEmpty);
    });

    test('APPS badge is not flagged', () {
      final issues = checker.checkContent('test.dart', "badge: 'APPS',");
      expect(issues, isEmpty);
    });
  });

  // ── JOGO/JUEGO/GAME not whitelisted ─────────────────────────────────────────

  group('JOGO/JUEGO/GAME not whitelisted — phrase detection still works', () {
    test('"Detalhe do Jogo" is detected (Jogo not whitelisted)', () {
      final issues = checker.checkContent(
        'test.dart',
        "  title: 'Detalhe do Jogo',",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
    });

    test('"Abrir Jogo" is detected (Jogo not whitelisted)', () {
      final issues = checker.checkContent(
        'test.dart',
        "  Text('Abrir Jogo'),",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
    });
  });

  // ── AppStrings usage is clean ────────────────────────────────────────────────

  group('AppStrings usage — not flagged', () {
    test('s.gfxProfileDesempenho getter call is not flagged', () {
      final issues = checker.checkContent(
        'test.dart',
        '  Text(s.gfxProfileDesempenho),',
      );
      expect(issues, isEmpty);
    });

    test('s.prepGfxMsgPerformance call is not flagged', () {
      final issues = checker.checkContent(
        'test.dart',
        '  Text(s.prepGfxMsgPerformance),',
      );
      expect(issues, isEmpty);
    });

    test('s.libFavoriteTooltip call is not flagged', () {
      final issues = checker.checkContent(
        'test.dart',
        '  tooltip: s.libFavoriteTooltip,',
      );
      expect(issues, isEmpty);
    });
  });

  // ── Multi-line content and line numbers ─────────────────────────────────────

  group('multi-line content', () {
    test('reports correct line number for second line', () {
      final issues = checker.checkContent(
        'test.dart',
        "final x = 'ok';\nText('Desempenho'),\nfinal y = 'test';",
      );
      expect(issues, hasLength(1));
      expect(issues.first.line, 2);
    });

    test('reports multiple issues across different lines', () {
      final issues = checker.checkContent(
        'test.dart',
        "Text('Desempenho'),\nText('Qualidade'),\nText('Economia'),",
      );
      expect(issues, hasLength(3));
    });

    test('reports at most one issue per line (phrase wins over term)', () {
      // "Adicionado em Desempenho" contains both a phrase and a term
      final issues = checker.checkContent(
        'test.dart',
        "Text('Adicionado em Desempenho'),",
      );
      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.high);
    });

    test('correctly stores file path', () {
      final issues = checker.checkContent(
        'lib/screens/foo.dart',
        "Text('Desempenho'),",
      );
      expect(issues.first.file, 'lib/screens/foo.dart');
    });
  });

  // ── Issue fields ─────────────────────────────────────────────────────────────

  group('issue fields', () {
    test('HIGH issue has non-empty suggestion', () {
      final issues = checker.checkContent(
        'test.dart',
        "Text('Adicionado em 2024'),",
      );
      expect(issues.first.severity, Severity.high);
      expect(issues.first.suggestion, isNotEmpty);
    });

    test('MEDIUM issue has non-empty suggestion', () {
      final issues = checker.checkContent(
        'test.dart',
        "label: 'Equilibrado',",
      );
      expect(issues.first.severity, Severity.medium);
      expect(issues.first.suggestion, isNotEmpty);
    });

    test('issue stores trimmed line content', () {
      final issues = checker.checkContent(
        'test.dart',
        "    Text('Desempenho'),",
      );
      expect(issues.first.content, "Text('Desempenho'),");
    });
  });
}
