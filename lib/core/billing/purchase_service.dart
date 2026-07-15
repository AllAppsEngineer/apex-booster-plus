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
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers);
  Future<bool> buyNonConsumable(PurchaseParam purchaseParam);
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

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) =>
      _iap.queryProductDetails(identifiers);

  @override
  Future<bool> buyNonConsumable(PurchaseParam purchaseParam) =>
      _iap.buyNonConsumable(purchaseParam: purchaseParam);
}

/// Thrown by [PurchaseService.buy] when the store or the product is not
/// reachable (offline, store unavailable, product not configured yet).
///
/// The UI must render a friendly "unavailable" state for this, never a crash.
class PurchaseUnavailableException implements Exception {
  const PurchaseUnavailableException();
}

/// Thrown by [PurchaseService.buy] when the store responded but the purchase
/// attempt itself failed (query or buy call errored).
///
/// The UI must render a friendly error state for this, never a crash.
class PurchaseFailedException implements Exception {
  const PurchaseFailedException();
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
    ensureSubscribed();

    try {
      final available = await _client.isAvailable();
      if (!available) return;
      await _client.restorePurchases();
    } catch (_) {
      // Offline or store unavailable: keep the last known cached state.
    }
  }

  /// Subscribes to [purchaseStream] without querying the store.
  ///
  /// Safe to call multiple times (at most one subscription is ever created)
  /// and safe to call before or after [startupCheck]. Use this when a screen
  /// needs to receive purchase confirmations (e.g. from [buy]) without
  /// triggering an active restore/availability round-trip to the store.
  void ensureSubscribed() {
    _subscription ??= _client.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object _, StackTrace __) {},
    );
  }

  /// Starts the purchase flow for [kApexFullUnlockProductId].
  ///
  /// Returns once the purchase has been *initiated* — completion (or
  /// failure) arrives later through [purchaseStream] and is handled by
  /// [_handlePurchaseUpdates]. Never leaves the unlock state in a fake
  /// "purchased" state: only a real [PurchaseStatus.purchased] or
  /// [PurchaseStatus.restored] update flips [unlockNotifier].
  Future<void> buy() async {
    bool available;
    try {
      available = await _client.isAvailable();
    } catch (_) {
      throw const PurchaseUnavailableException();
    }
    if (!available) throw const PurchaseUnavailableException();

    final ProductDetailsResponse response;
    try {
      response = await _client.queryProductDetails({kApexFullUnlockProductId});
    } catch (_) {
      throw const PurchaseFailedException();
    }
    if (response.error != null || response.productDetails.isEmpty) {
      throw const PurchaseUnavailableException();
    }

    try {
      await _client.buyNonConsumable(
        PurchaseParam(productDetails: response.productDetails.first),
      );
    } catch (_) {
      throw const PurchaseFailedException();
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
