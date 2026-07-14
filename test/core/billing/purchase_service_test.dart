import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:apex_booster_plus/core/billing/purchase_service.dart';

class _FakeBillingClient implements BillingClient {
  _FakeBillingClient({this.available = true, this.availableError, this.restoreError});

  bool available;
  Object? availableError;
  Object? restoreError;
  int restoreCallCount = 0;
  final List<PurchaseDetails> completedPurchases = [];
  final _controller = StreamController<List<PurchaseDetails>>.broadcast();

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _controller.stream;

  @override
  Future<bool> isAvailable() async {
    if (availableError != null) throw availableError!;
    return available;
  }

  @override
  Future<void> restorePurchases() async {
    restoreCallCount++;
    if (restoreError != null) throw restoreError!;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completedPurchases.add(purchase);
  }

  void emit(List<PurchaseDetails> purchases) => _controller.add(purchases);

  void dispose() => _controller.close();
}

PurchaseDetails _purchase({
  required String productId,
  required PurchaseStatus status,
  bool pendingCompletePurchase = false,
}) {
  final details = PurchaseDetails(
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local',
      serverVerificationData: 'server',
      source: 'test',
    ),
    transactionDate: null,
    status: status,
  );
  details.pendingCompletePurchase = pendingCompletePurchase;
  return details;
}

void main() {
  group('PurchaseService', () {
    test('does not throw and keeps unlock unchanged when billing is unavailable', () async {
      final fake = _FakeBillingClient(available: false);
      final notifier = ValueNotifier<bool>(false);
      final service = PurchaseService(
        client: fake,
        unlockNotifier: notifier,
        persistUnlock: (_) async {},
      );

      await service.startupCheck();

      expect(notifier.value, false);
      expect(fake.restoreCallCount, 0);
      fake.dispose();
    });

    test('calls restorePurchases when billing is available', () async {
      final fake = _FakeBillingClient(available: true);
      final notifier = ValueNotifier<bool>(false);
      final service = PurchaseService(
        client: fake,
        unlockNotifier: notifier,
        persistUnlock: (_) async {},
      );

      await service.startupCheck();

      expect(fake.restoreCallCount, 1);
      fake.dispose();
    });

    test('does not throw when isAvailable() fails (offline)', () async {
      final fake = _FakeBillingClient(availableError: Exception('offline'));
      final notifier = ValueNotifier<bool>(false);
      final service = PurchaseService(
        client: fake,
        unlockNotifier: notifier,
        persistUnlock: (_) async {},
      );

      await service.startupCheck();

      expect(notifier.value, false);
      fake.dispose();
    });

    test('does not throw when restorePurchases() fails', () async {
      final fake = _FakeBillingClient(restoreError: Exception('store unreachable'));
      final notifier = ValueNotifier<bool>(false);
      final service = PurchaseService(
        client: fake,
        unlockNotifier: notifier,
        persistUnlock: (_) async {},
      );

      await service.startupCheck();

      expect(notifier.value, false);
      fake.dispose();
    });

    test('sets unlocked and persists when a purchased update arrives for the tracked product', () async {
      final fake = _FakeBillingClient();
      final notifier = ValueNotifier<bool>(false);
      bool? persisted;
      final service = PurchaseService(
        client: fake,
        unlockNotifier: notifier,
        persistUnlock: (value) async => persisted = value,
      );

      await service.startupCheck();
      fake.emit([
        _purchase(productId: kApexFullUnlockProductId, status: PurchaseStatus.purchased),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.value, true);
      expect(persisted, true);
      fake.dispose();
    });

    test('sets unlocked when a restored update arrives for the tracked product', () async {
      final fake = _FakeBillingClient();
      final notifier = ValueNotifier<bool>(false);
      bool? persisted;
      final service = PurchaseService(
        client: fake,
        unlockNotifier: notifier,
        persistUnlock: (value) async => persisted = value,
      );

      await service.startupCheck();
      fake.emit([
        _purchase(productId: kApexFullUnlockProductId, status: PurchaseStatus.restored),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.value, true);
      expect(persisted, true);
      fake.dispose();
    });

    test('completes purchases that are pending completion', () async {
      final fake = _FakeBillingClient();
      final notifier = ValueNotifier<bool>(false);
      final service = PurchaseService(
        client: fake,
        unlockNotifier: notifier,
        persistUnlock: (_) async {},
      );
      final purchase = _purchase(
        productId: kApexFullUnlockProductId,
        status: PurchaseStatus.purchased,
        pendingCompletePurchase: true,
      );

      await service.startupCheck();
      fake.emit([purchase]);
      await Future<void>.delayed(Duration.zero);

      expect(fake.completedPurchases, [purchase]);
      fake.dispose();
    });

    test('ignores purchase updates for other product ids', () async {
      final fake = _FakeBillingClient();
      final notifier = ValueNotifier<bool>(false);
      final service = PurchaseService(
        client: fake,
        unlockNotifier: notifier,
        persistUnlock: (_) async {},
      );

      await service.startupCheck();
      fake.emit([
        _purchase(productId: 'some_other_product', status: PurchaseStatus.purchased),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.value, false);
      fake.dispose();
    });

    test('ignores purchase updates that are pending, canceled or errored', () async {
      final fake = _FakeBillingClient();
      final notifier = ValueNotifier<bool>(false);
      final service = PurchaseService(
        client: fake,
        unlockNotifier: notifier,
        persistUnlock: (_) async {},
      );

      await service.startupCheck();
      fake.emit([
        _purchase(productId: kApexFullUnlockProductId, status: PurchaseStatus.pending),
        _purchase(productId: kApexFullUnlockProductId, status: PurchaseStatus.canceled),
        _purchase(productId: kApexFullUnlockProductId, status: PurchaseStatus.error),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.value, false);
      fake.dispose();
    });
  });
}
