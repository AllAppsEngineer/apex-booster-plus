import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../data/datasources/installed_apps_datasource.dart';
import '../../../domain/entities/session_record.dart';
import '../../widgets/apex_background.dart';
import '../../widgets/apex_result_card.dart';

/// Fechamento local e honesto de uma sessão preparada (PREMIUM-U3A).
///
/// Recebe o [SessionRecord] já salvo — nunca recalcula métricas nem promete
/// nada técnico. Esta subetapa cria apenas a tela/rota; a integração com o
/// SnackBar pós-sucesso e o Histórico acontece em PREMIUM-U3B.
class ResultCardScreen extends StatelessWidget {
  final SessionRecord? session;

  const ResultCardScreen({super.key, this.session});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: languageNotifier,
      builder: (context, _) {
        final s = AppStrings(languageNotifier.value);
        final record = session;
        return Scaffold(
          backgroundColor: const Color(0xFF050505),
          body: ApexBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _Header(title: s.resultCardHeaderLabel, onBack: () => context.pop()),
                  Expanded(
                    child: record == null
                        ? _ErrorState(s: s, onBack: () => context.pop())
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                            child: ApexResultCard(
                              session: record,
                              onReopenGame: (record.packageName != null &&
                                      record.packageName!.isNotEmpty)
                                  ? () => InstalledAppsDatasource()
                                      .launchApp(record.packageName!)
                                  : null,
                              onCreateSocialCard: record.gameId.isNotEmpty
                                  ? () => context.push('/share-studio/${record.gameId}')
                                  : null,
                              onClose: () => context.pop(),
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error state ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final AppStrings s;
  final VoidCallback onBack;

  const _ErrorState({required this.s, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textGray.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 20),
            Text(
              s.resultCardErrorTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.resultCardErrorDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGray, fontSize: 13),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onBack,
              child: Text(s.actionBack),
            ),
          ],
        ),
      ),
    );
  }
}
