// LANG-U2 — Hardcoded strings guardian CLI runner.
//
// Scans every migrated UI file for hardcoded PT-BR strings that should be
// served through AppStrings instead.
//
// Usage (from project root):
//   dart run tool/check_hardcoded_strings.dart
//
// Exit codes:
//   0 — no issues found
//   1 — one or more hardcoded PT-BR strings detected

// ignore_for_file: avoid_print
import 'dart:io';

import 'hardcoded_strings_checker.dart';

/// UI files that have been migrated to AppStrings and must stay clean.
/// app_strings.dart itself is intentionally excluded — it is the source of
/// truth and contains PT-BR strings by design.
const _targetFiles = [
  'lib/presentation/screens/splash/splash_screen.dart',
  'lib/presentation/screens/welcome/welcome_screen.dart',
  'lib/presentation/screens/how_it_works/how_it_works_screen.dart',
  'lib/presentation/screens/permissions/permissions_screen.dart',
  'lib/presentation/screens/home/home_screen.dart',
  'lib/presentation/screens/home/tabs/configuracoes_tab.dart',
  'lib/presentation/screens/home/tabs/inicio_tab.dart',
  'lib/presentation/screens/home/tabs/biblioteca_tab.dart',
  'lib/presentation/screens/home/tabs/preparar_tab.dart',
  'lib/presentation/screens/home/tabs/historico_tab.dart',
  'lib/presentation/screens/gfx_profile/gfx_profile_screen.dart',
  'lib/presentation/screens/game_detail/game_detail_screen.dart',
  'lib/presentation/widgets/app_picker_sheet.dart',
];

void main() {
  final checker = HardcodedStringsChecker();
  final allIssues = <HardcodedStringIssue>[];
  final missingFiles = <String>[];

  for (final path in _targetFiles) {
    final file = File(path);
    if (!file.existsSync()) {
      missingFiles.add(path);
      continue;
    }
    final content = file.readAsStringSync();
    allIssues.addAll(checker.checkContent(path, content));
  }

  _printHeader();

  if (missingFiles.isNotEmpty) {
    print('⚠  Missing files (update _targetFiles if renamed/moved):');
    for (final f in missingFiles) {
      print('   $f');
    }
    print('');
  }

  if (allIssues.isEmpty) {
    _printClean(_targetFiles.length - missingFiles.length);
    exit(0);
  }

  _printReport(allIssues);
  exit(1);
}

void _printHeader() {
  print('');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('  LANG-U2 — Hardcoded Strings Guardian');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('');
}

void _printClean(int fileCount) {
  print('  ✓  No hardcoded PT-BR strings found.');
  print('     Scanned $fileCount file(s).');
  print('');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('');
}

void _printReport(List<HardcodedStringIssue> issues) {
  final highs = issues.where((i) => i.severity == Severity.high).length;
  final meds = issues.where((i) => i.severity == Severity.medium).length;

  print('  Found ${issues.length} issue(s) — HIGH: $highs  MEDIUM: $meds');
  print('');

  // Group by file for readability
  final byFile = <String, List<HardcodedStringIssue>>{};
  for (final issue in issues) {
    byFile.putIfAbsent(issue.file, () => []).add(issue);
  }

  for (final entry in byFile.entries) {
    print('  ${entry.key}');
    for (final issue in entry.value) {
      final sev = issue.severity == Severity.high ? 'HIGH  ' : 'MEDIUM';
      print('    [$sev] line ${issue.line}: "${issue.match}"');
      print('           ${issue.content}');
      print('           → ${issue.suggestion}');
      print('');
    }
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('  FAIL — fix the issues above and re-run.');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('');
}
