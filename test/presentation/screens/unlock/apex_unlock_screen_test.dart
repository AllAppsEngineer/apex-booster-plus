import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:apex_booster_plus/core/billing/apex_unlock_notifier.dart';
import 'package:apex_booster_plus/core/billing/purchase_service.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/presentation/screens/unlock/apex_unlock_screen.dart';

class _FakeBillingClient implements BillingClient {
  _FakeBillingClient({
    this.available = true,
    this.buyError,
    List<ProductDetails>? products,
    this.notFoundIDs = const [],
    this.restoredPurchases = const [],
  }) : _products = products ??
            [
              ProductDetails(
                id: kApexFullUnlockProductId,
                title: 'Apex Booster+ Unlock',
                description: 'One-time unlock',
                price: 'R\$ 2,99',
                rawPrice: 2.99,
                currencyCode: 'BRL',
              ),
            ];

  bool available;
  Object? buyError;
  final List<ProductDetails> _products;
  final List<String> notFoundIDs;
  final List<PurchaseDetails> restoredPurchases;
  final List<PurchaseParam> buyNonConsumableCalls = [];
  final _controller = StreamController<List<PurchaseDetails>>.broadcast();

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _controller.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> restorePurchases() async {
    if (restoredPurchases.isNotEmpty) {
      _controller.add(restoredPurchases);
      await Future<void>.delayed(Duration.zero);
    }
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) async =>
      ProductDetailsResponse(productDetails: _products, notFoundIDs: notFoundIDs);

  @override
  Future<bool> buyNonConsumable(PurchaseParam purchaseParam) async {
    if (buyError != null) throw buyError!;
    buyNonConsumableCalls.add(purchaseParam);
    return true;
  }

  void emit(List<PurchaseDetails> purchases) => _controller.add(purchases);

  void dispose() => _controller.close();
}

PurchaseDetails _purchase({
  required String productId,
  required PurchaseStatus status,
}) {
  return PurchaseDetails(
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local',
      serverVerificationData: 'server',
      source: 'test',
    ),
    transactionDate: null,
    status: status,
  );
}

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  final s = AppStrings(AppLanguage.ptBr);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    apexUnlockNotifier.value = false;
  });

  testWidgets('shows the locked state with benefits, price and both buttons when the store is available',
      (tester) async {
    final fake = _FakeBillingClient(available: true);
    await tester.pumpWidget(_wrap(ApexUnlockScreen(client: fake)));
    await tester.pumpAndSettle();

    expect(find.text(s.unlockScreenTitle), findsOneWidget);
    expect(find.text(s.unlockBenefit1), findsOneWidget);
    expect(find.text(s.unlockPriceLabel), findsOneWidget);
    expect(find.text(s.unlockBuyButton), findsOneWidget);
    expect(find.text(s.unlockRestoreButton), findsOneWidget);
    expect(tester.takeException(), isNull);
    fake.dispose();
  });

  testWidgets('shows the unavailable state and disables buying when the store is unavailable',
      (tester) async {
    final fake = _FakeBillingClient(available: false);
    await tester.pumpWidget(_wrap(ApexUnlockScreen(client: fake)));
    await tester.pumpAndSettle();

    expect(find.text(s.unlockUnavailableTitle), findsOneWidget);

    await tester.tap(find.text(s.unlockBuyButton));
    await tester.pumpAndSettle();

    expect(fake.buyNonConsumableCalls, isEmpty);
    expect(tester.takeException(), isNull);
    fake.dispose();
  });

  testWidgets('shows the unlocked state and hides buy/restore buttons when already unlocked',
      (tester) async {
    apexUnlockNotifier.value = true;
    final fake = _FakeBillingClient(available: true);
    await tester.pumpWidget(_wrap(ApexUnlockScreen(client: fake)));
    await tester.pumpAndSettle();

    expect(find.text(s.unlockUnlockedTitle), findsOneWidget);
    expect(find.text(s.unlockBuyButton), findsNothing);
    expect(find.text(s.unlockRestoreButton), findsNothing);
    fake.dispose();
  });

  testWidgets('tapping Desbloquear agora starts the purchase and flips to unlocked once the store confirms it',
      (tester) async {
    final fake = _FakeBillingClient(available: true);
    await tester.pumpWidget(_wrap(ApexUnlockScreen(client: fake)));
    await tester.pumpAndSettle();

    await tester.tap(find.text(s.unlockBuyButton));
    await tester.pump();

    expect(fake.buyNonConsumableCalls, hasLength(1));

    fake.emit([_purchase(productId: kApexFullUnlockProductId, status: PurchaseStatus.purchased)]);
    await tester.pumpAndSettle();

    expect(apexUnlockNotifier.value, true);
    expect(find.text(s.unlockUnlockedTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
    fake.dispose();
  });

  testWidgets('shows a friendly error state when the purchase attempt fails, without crashing',
      (tester) async {
    final fake = _FakeBillingClient(available: true, buyError: Exception('payment declined'));
    await tester.pumpWidget(_wrap(ApexUnlockScreen(client: fake)));
    await tester.pumpAndSettle();

    await tester.tap(find.text(s.unlockBuyButton));
    await tester.pumpAndSettle();

    expect(find.text(s.unlockErrorTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
    fake.dispose();
  });

  testWidgets('switches to the unavailable state when the product is not found during buy, without crashing',
      (tester) async {
    final fake = _FakeBillingClient(
      available: true,
      products: const [],
      notFoundIDs: const [kApexFullUnlockProductId],
    );
    await tester.pumpWidget(_wrap(ApexUnlockScreen(client: fake)));
    await tester.pumpAndSettle();

    await tester.tap(find.text(s.unlockBuyButton));
    await tester.pumpAndSettle();

    expect(find.text(s.unlockUnavailableTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
    fake.dispose();
  });

  testWidgets('tapping Restaurar compra shows a success message when a restored purchase arrives',
      (tester) async {
    final fake = _FakeBillingClient(
      available: true,
      restoredPurchases: [_purchase(productId: kApexFullUnlockProductId, status: PurchaseStatus.restored)],
    );
    await tester.pumpWidget(_wrap(ApexUnlockScreen(client: fake)));
    await tester.pumpAndSettle();

    await tester.tap(find.text(s.unlockRestoreButton));
    await tester.pumpAndSettle();

    expect(find.text(s.unlockRestoreSuccess), findsOneWidget);
    expect(apexUnlockNotifier.value, true);
    fake.dispose();
  });

  testWidgets('tapping Restaurar compra shows a not-found message when nothing is restored',
      (tester) async {
    final fake = _FakeBillingClient(available: true, restoredPurchases: const []);
    await tester.pumpWidget(_wrap(ApexUnlockScreen(client: fake)));
    await tester.pumpAndSettle();

    await tester.tap(find.text(s.unlockRestoreButton));
    await tester.pumpAndSettle();

    expect(find.text(s.unlockRestoreNotFound), findsOneWidget);
    expect(apexUnlockNotifier.value, false);
    fake.dispose();
  });
}
