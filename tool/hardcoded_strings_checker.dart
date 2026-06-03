// LANG-U2 — Hardcoded strings guardian.
//
// Pure Dart library (no Flutter, no dart:io) for testing and for the CLI
// runner [tool/check_hardcoded_strings.dart].
//
// Usage:
//   final checker = HardcodedStringsChecker();
//   final issues  = checker.checkContent('lib/foo.dart', fileContent);

enum Severity { high, medium }

/// A single finding: one hardcoded PT-BR string in a specific file/line.
class HardcodedStringIssue {
  final String file;
  final int line;
  final String content;   // trimmed source line
  final String match;     // the blocked phrase or term found
  final Severity severity;
  final String suggestion;

  const HardcodedStringIssue({
    required this.file,
    required this.line,
    required this.content,
    required this.match,
    required this.severity,
    required this.suggestion,
  });

  @override
  String toString() =>
      '${severity.name.toUpperCase()}  $file:$line\n'
      '  line   : $content\n'
      '  match  : "$match"\n'
      '  suggest: $suggestion';
}

class HardcodedStringsChecker {
  // ── Phrases checked first — HIGH severity ────────────────────────────────
  // Longer / more specific phrases listed before shorter ones to avoid
  // double-reporting when a phrase contains a shorter blocked sub-phrase.
  static const List<String> blockedPhrases = [
    'Nenhum perfil definido',
    'App vinculado ao cadastro',
    'App instalado e acessível',
    'Adicionado em',
    'Atualizado em',
    'ABRIR JOGO',
    'Abrir Jogo',
    'Abrir jogo',
    'Preparar sessão',
    'Preparar Sessão',
    'PREPARAR SESSÃO',
    'Detalhe do Jogo',
    'Detalhe do jogo',
  ];

  // ── Single terms — MEDIUM severity ───────────────────────────────────────
  static const List<String> blockedTerms = [
    'Desempenho',
    'Qualidade',
    'Economia',
    'Equilibrado',
    'Favorito',
  ];

  // ── Whitelist — brand names and language-neutral technical terms ──────────
  // These strings are accepted as-is in any language.
  // Intentionally excludes: JOGO, JUEGO, GAME (badges must come from AppStrings).
  static const Set<String> whitelist = {
    'Apex Booster+',
    'APEX BOOSTER+',
    'APEX SCAN',
    'Apex Scan',
    'GFX',
    'RAM',
    'FPS',
    'GPU',
    'Ping',
    'OK',
    'ms',
    'MB',
    'SCAN',
    'GO',
    'NOTIF',
    'APPS',
  };

  /// Scans [content] (the full text of [filePath]) line by line and returns
  /// every hardcoded PT-BR string found **inside string literals** in UI code,
  /// outside imports and comments.
  List<HardcodedStringIssue> checkContent(String filePath, String content) {
    final issues = <HardcodedStringIssue>[];
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final lineNum = i + 1;
      // Strip imports, full-line comments, and trailing inline comments.
      final effective = _effectiveLine(lines[i]);
      if (effective == null) continue;

      // Only examine text inside quoted string literals, so identifiers like
      // `s.gfxProfileDesempenho` are never flagged.
      final literals = _extractStringLiterals(effective);
      if (literals.isEmpty) continue;
      final combined = literals.join(' ');

      // ── Phrases first (HIGH) ─────────────────────────────────────────────
      HardcodedStringIssue? phraseIssue;
      for (final phrase in blockedPhrases) {
        if (!combined.contains(phrase)) continue;
        if (whitelist.contains(phrase)) continue;
        phraseIssue = HardcodedStringIssue(
          file: filePath,
          line: lineNum,
          content: lines[i].trim(),
          match: phrase,
          severity: Severity.high,
          suggestion:
              'Replace hardcoded PT-BR string with AppStrings: "$phrase"',
        );
        break; // one issue per line
      }
      if (phraseIssue != null) {
        issues.add(phraseIssue);
        continue; // phrase already flagged this line — skip term check
      }

      // ── Single terms (MEDIUM) ────────────────────────────────────────────
      for (final term in blockedTerms) {
        if (!combined.contains(term)) continue;
        if (whitelist.contains(term)) continue;
        issues.add(HardcodedStringIssue(
          file: filePath,
          line: lineNum,
          content: lines[i].trim(),
          match: term,
          severity: Severity.medium,
          suggestion:
              'Replace hardcoded PT-BR term with AppStrings: "$term"',
        ));
        break; // one issue per line
      }
    }

    return issues;
  }

  /// Returns all string literal contents from [line] (between single or double
  /// quotes), respecting backslash escapes.
  List<String> _extractStringLiterals(String line) {
    final result = <String>[];
    var i = 0;

    while (i < line.length) {
      final c = line[i];
      if (c == "'" || c == '"') {
        final quote = c;
        final start = i + 1;
        i++;
        while (i < line.length) {
          if (line[i] == '\\') {
            i += 2; // skip backslash + escaped char
            continue;
          }
          if (line[i] == quote) break;
          i++;
        }
        if (i <= line.length) {
          result.add(line.substring(start, i < line.length ? i : line.length));
        }
        i++;
      } else {
        i++;
      }
    }

    return result;
  }

  // Returns null when the line should be skipped entirely.
  // Otherwise returns the effective content with inline comments stripped.
  String? _effectiveLine(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    if (t.startsWith('import ') || t.startsWith('export ')) return null;
    if (t.startsWith('//') || t.startsWith('*') || t.startsWith('/*')) {
      return null;
    }

    // Strip trailing inline comment, respecting quoted strings.
    final ci = _inlineCommentIndex(t);
    if (ci == 0) return null; // line starts with // after trim — impossible
    return ci > 0 ? t.substring(0, ci) : t;
  }

  // Returns the index of the first '//' that appears outside a quoted string,
  // or -1 when no inline comment is found.
  int _inlineCommentIndex(String line) {
    var inSingle = false;
    var inDouble = false;

    for (int i = 0; i < line.length - 1; i++) {
      final c = line[i];

      if (c == r'\') {
        i++; // skip escaped character
        continue;
      }
      if (c == "'" && !inDouble) {
        inSingle = !inSingle;
        continue;
      }
      if (c == '"' && !inSingle) {
        inDouble = !inDouble;
        continue;
      }
      if (!inSingle && !inDouble && c == '/' && line[i + 1] == '/') {
        return i;
      }
    }
    return -1;
  }
}
