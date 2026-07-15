import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/billing/apex_unlock_notifier.dart';
import 'package:apex_booster_plus/core/billing/purchase_service.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_badge.dart';

enum _StoreAvailability { checking, available, unavailable }

/// Dedicated screen for the one-time unlock (`apex_full_unlock`).
///
/// Consumes [PurchaseService]/[apexUnlockNotifier] from BILL-U1A. Never
/// blocks or crashes when the store/product is unavailable (debug builds
/// without a configured Play Console product): it degrades to a friendly
/// "unavailable" state instead.
class ApexUnlockScreen extends StatefulWidget {
  const ApexUnlockScreen({super.key, BillingClient? client}) : _client = client;

  final BillingClient? _client;

  @override
  State<ApexUnlockScreen> createState() => _ApexUnlockScreenState();
}

class _ApexUnlockScreenState extends State<ApexUnlockScreen> {
  late final BillingClient _client = widget._client ?? InAppPurchaseBillingClient();
  late final PurchaseService _service = PurchaseService(
    client: _client,
    unlockNotifier: apexUnlockNotifier,
    persistUnlock: _persistUnlock,
  );

  _StoreAvailability _availability = _StoreAvailability.checking;
  bool _buying = false;
  bool _restoring = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Subscribes so a purchase confirmation triggered by _onBuy() is
    // received. Does not query the store — that only happens explicitly,
    // via _checkAvailability() (read-only) and the "Restaurar compra" button.
    _service.ensureSubscribed();
    _checkAvailability();
  }

  Future<void> _persistUnlock(bool unlocked) async {
    final prefs = await SharedPreferences.getInstance();
    await ApexUnlockCacheService(prefs).save(unlocked);
  }

  Future<void> _checkAvailability() async {
    try {
      final available = await _client.isAvailable();
      if (!mounted) return;
      setState(() {
        _availability = available ? _StoreAvailability.available : _StoreAvailability.unavailable;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _availability = _StoreAvailability.unavailable);
    }
  }

  Future<void> _onBuy() async {
    setState(() {
      _buying = true;
      _errorMessage = null;
    });
    try {
      await _service.buy();
      if (!mounted) return;
      setState(() => _buying = false);
    } on PurchaseUnavailableException {
      if (!mounted) return;
      setState(() {
        _buying = false;
        _availability = _StoreAvailability.unavailable;
      });
    } catch (_) {
      if (!mounted) return;
      final s = AppStrings(languageNotifier.value);
      setState(() {
        _buying = false;
        _errorMessage = s.unlockErrorDesc;
      });
    }
  }

  Future<void> _onRestore() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _restoring = true;
      _errorMessage = null;
    });
    await _service.startupCheck();
    if (!mounted) return;
    final s = AppStrings(languageNotifier.value);
    setState(() => _restoring = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(apexUnlockNotifier.value ? s.unlockRestoreSuccess : s.unlockRestoreNotFound),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([languageNotifier, apexUnlockNotifier]),
      builder: (context, _) {
        final s = AppStrings(languageNotifier.value);
        return Scaffold(
          backgroundColor: const Color(0xFF050505),
          body: ApexBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _Header(title: s.unlockScreenTitle, onBack: () => context.pop()),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: apexUnlockNotifier.value
                          ? _UnlockedCard(s: s)
                          : _LockedContent(
                              s: s,
                              availability: _availability,
                              buying: _buying,
                              restoring: _restoring,
                              errorMessage: _errorMessage,
                              onBuy: _onBuy,
                              onRestore: _onRestore,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.06, end: 0, duration: 280.ms);
  }
}

// ─── Locked content (benefits, price, buy/restore) ──────────────────────────

class _LockedContent extends StatelessWidget {
  final AppStrings s;
  final _StoreAvailability availability;
  final bool buying;
  final bool restoring;
  final String? errorMessage;
  final VoidCallback onBuy;
  final VoidCallback onRestore;

  const _LockedContent({
    required this.s,
    required this.availability,
    required this.buying,
    required this.restoring,
    required this.errorMessage,
    required this.onBuy,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final canBuy = availability == _StoreAvailability.available && !buying;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BenefitsCard(s: s),
        const SizedBox(height: 12),
        _PriceCard(s: s),
        if (availability == _StoreAvailability.unavailable) ...[
          const SizedBox(height: 12),
          _MessageBanner(
            title: s.unlockUnavailableTitle,
            desc: s.unlockUnavailableDesc,
            color: AppColors.energyOrange,
          ),
        ],
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          _MessageBanner(
            title: s.unlockErrorTitle,
            desc: errorMessage!,
            color: const Color(0xFFEF4444),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: canBuy ? onBuy : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.apexGreen,
              disabledBackgroundColor: AppColors.apexGreen.withValues(alpha: 0.25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: buying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                  )
                : Text(
                    s.unlockBuyButton,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            onPressed: restoring ? null : onRestore,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.cyberBlue.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: restoring
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cyberBlue),
                  )
                : Text(
                    s.unlockRestoreButton,
                    style: const TextStyle(color: AppColors.cyberBlue, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          s.unlockDisclaimer,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textGray.withValues(alpha: 0.7),
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}

class _BenefitsCard extends StatelessWidget {
  final AppStrings s;
  const _BenefitsCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.apexGreen.withValues(alpha: 0.08),
            AppColors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.apexGreen.withValues(alpha: 0.22), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ApexBadge(label: s.unlockCardTitle, color: AppColors.apexGreen),
          const SizedBox(height: 12),
          Text(
            s.unlockBenefitsLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          _BenefitRow(text: s.unlockBenefit1),
          _BenefitRow(text: s.unlockBenefit2),
          _BenefitRow(text: s.unlockBenefit3),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.04, end: 0, duration: 380.ms);
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.apexGreen.withValues(alpha: 0.85)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.textGray, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final AppStrings s;
  const _PriceCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cyberBlue.withValues(alpha: 0.08),
            AppColors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cyberBlue.withValues(alpha: 0.22), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.unlockPriceLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            s.unlockPriceNote,
            style: TextStyle(color: AppColors.textGray, fontSize: 12),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 80.ms, duration: 500.ms).slideY(begin: 0.04, end: 0, duration: 380.ms);
  }
}

class _MessageBanner extends StatelessWidget {
  final String title;
  final String desc;
  final Color color;

  const _MessageBanner({required this.title, required this.desc, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(color: AppColors.textGray, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Unlocked state ──────────────────────────────────────────────────────────

class _UnlockedCard extends StatelessWidget {
  final AppStrings s;
  const _UnlockedCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.apexGreen.withValues(alpha: 0.10),
            AppColors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.apexGreen.withValues(alpha: 0.28), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_open_rounded, color: AppColors.apexGreen, size: 28),
          const SizedBox(height: 12),
          Text(
            s.unlockUnlockedTitle,
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            s.unlockUnlockedDesc,
            style: TextStyle(color: AppColors.textGray, fontSize: 13),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.04, end: 0, duration: 380.ms);
  }
}
