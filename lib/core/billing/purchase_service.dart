import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Product ID for the Apex Booster+ one-time unlock.
///
/// Must match exactly the managed product (non-consumable) configured in
/// Google Play Console. Configuring that product is out of scope for this
/// change.
const String kApexFullUnlockProductId = 'apex_full_unlock';

/// Thin seam over [InAppPurchase] so [PurchaseService] can be unit-tested
/// with a fake, without touching platform channels or a real store.
abstract class BillingClient {
  Future<bool> isAvailable();
  Future<void> restorePurchases();
  Stream<List<PurchaseDetails>> get purchaseStream;
  Future<void> completePurchase(PurchaseDetails purchase);
}

/// Default [BillingClient] backed by the real `in_app_purchase` plugin.
class InAppPurchaseBillingClient implements BillingClient {
  InAppPurchaseBillingClient([InAppPurchase? iap]) : _iap = iap ?? InAppPurchase.instance;

  final InAppPurchase _iap;

  @override
  Future<bool> isAvailable() => _iap.isAvailable();

  @override
  Future<void> restorePurchases() => _iap.restorePurchases();

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) => _iap.completePurchase(purchase);
}

/// Technical foundation for the one-time unlock (`apex_full_unlock`).
///
/// Does not expose any purchase UI. It only subscribes to purchase updates,
/// restores previous purchases on startup and mirrors the result into a
/// local cache via [unlockNotifier]/[persistUnlock]. Every operation is
/// wrapped so billing being unavailable, offline, or erroring never throws
/// past this service and never blocks the app.
class PurchaseService {
  PurchaseService({
    required BillingClient client,
    required ValueNotifier<bool> unlockNotifier,
    required Future<void> Function(bool unlocked) persistUnlock,
  })  : _client = client,
        _unlockNotifier = unlockNotifier,
        _persistUnlock = persistUnlock;

  final BillingClient _client;
  final ValueNotifier<bool> _unlockNotifier;
  final Future<void> Function(bool unlocked) _persistUnlock;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Subscribes to purchase updates and restores previous purchases.
  ///
  /// Safe to call from app startup without awaiting: never throws and never
  /// blocks on network/store availability. If billing is unavailable or the
  /// device is offline, the previously cached unlock state is left as-is.
  Future<void> startupCheck() async {
    _subscription ??= _client.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object _, StackTrace __) {},
    );

    try {
      final available = await _client.isAvailable();
      if (!available) return;
      await _client.restorePurchases();
    } catch (_) {
      // Offline or store unavailable: keep the last known cached state.
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID != kApexFullUnlockProductId) continue;

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _unlockNotifier.value = true;
          unawaited(_persistUnlock(true));
          if (purchase.pendingCompletePurchase) {
            unawaited(_client.completePurchase(purchase));
          }
        case PurchaseStatus.pending:
        case PurchaseStatus.canceled:
        case PurchaseStatus.error:
          break;
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
