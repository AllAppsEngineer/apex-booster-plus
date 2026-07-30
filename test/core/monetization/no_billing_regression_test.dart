import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression guard for MONETIZATION-PAID-U1.
///
/// The Apex Booster+ commercial model is now paid-for-download with every
/// feature available from the first install (MONETIZATION-PAID-U0-DOCS).
/// These tests scan the actual source tree so a future change cannot quietly
/// reintroduce Billing, an unlock screen, or a local entitlement flag without
/// failing the suite.
const _bannedPatterns = [
  'apexUnlockNotifier',
  'ApexUnlockCacheService',
  'PurchaseService',
  'BillingClient',
  'InAppPurchaseBillingClient',
  'apex_full_unlock',
  'package:in_app_purchase',
  'core/billing',
  'screens/unlock',
  'get unlock',
];

List<File> _dartFilesUnder(String dirPath) {
  final dir = Directory(dirPath);
  if (!dir.existsSync()) return const [];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
}

void main() {
  test('lib/ contains no reference to Billing, unlock or local entitlement state', () {
    final offenders = <String>[];
    for (final file in _dartFilesUnder('lib')) {
      final content = file.readAsStringSync();
      for (final pattern in _bannedPatterns) {
        if (content.contains(pattern)) {
          offenders.add('${file.path}: "$pattern"');
        }
      }
    }
    expect(offenders, isEmpty, reason: 'Found reintroduced Billing/unlock references:\n${offenders.join('\n')}');
  });

  test('lib/main.dart initializes the app without any PurchaseService/startupCheck', () {
    final content = File('lib/main.dart').readAsStringSync();
    expect(content, isNot(contains('PurchaseService')));
    expect(content, isNot(contains('startupCheck')));
    expect(content, isNot(contains('billing')));
  });

  test('pubspec.yaml no longer declares the in_app_purchase dependency', () {
    final content = File('pubspec.yaml').readAsStringSync();
    expect(content, isNot(contains('in_app_purchase')));
  });

  test('core/routing/app_router.dart no longer imports an unlock screen', () {
    final content = File('lib/core/routing/app_router.dart').readAsStringSync();
    expect(content, isNot(contains('unlock')));
  });
}
