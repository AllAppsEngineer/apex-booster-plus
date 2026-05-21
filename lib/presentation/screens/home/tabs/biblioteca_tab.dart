import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/data/repositories/shared_preferences_game_library_repository.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/presentation/controllers/game_library_controller.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_badge.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_feature_card.dart';
import 'package:apex_booster_plus/presentation/widgets/app_picker_sheet.dart';

class BibliotecaTab extends StatefulWidget {
  const BibliotecaTab({super.key});

  @override
  State<BibliotecaTab> createState() => _BibliotecaTabState();
}

class _BibliotecaTabState extends State<BibliotecaTab> {
  late GameLibraryController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _controller = GameLibraryController(
      SharedPreferencesGameLibraryRepository(prefs),
    );
    await _controller.loadGames();
    if (mounted) setState(() => _initialized = true);
  }

  Future<void> _openAddGameDialog({
    String initialName = '',
    String initialPackageName = '',
  }) async {
    final result = await showDialog<(String, String?)?>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => _AddGameDialog(
        initialName: initialName,
        initialPackageName: initialPackageName,
      ),
    );

    if (result == null) return;
    if (!mounted) return;

    final (name, rawPkg) = result;
    final pkg = rawPkg?.trim();
    final now = DateTime.now();
    final game = ApexGame(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      packageName: (pkg == null || pkg.isEmpty) ? null : pkg,
      createdAt: now,
      updatedAt: now,
    );
    await _controller.addGame(game);
    if (mounted) setState(() {});
  }

  Future<void> _openPickerSheet() async {
    final result = await showModalBottomSheet<AppPickerResult?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.82,
        child: const AppPickerSheet(),
      ),
    );

    if (result == null || !mounted) return;

    if (result is AppPickerUseManual) {
      await _openAddGameDialog();
      return;
    }
    if (result is AppPickerSelected) {
      await _openAddGameDialog(
        initialName: result.app.appName,
        initialPackageName: result.app.packageName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const ApexBackground(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.cyberBlue),
        ),
      );
    }

    final state = _controller.state;

    if (state.isLoading) {
      return const ApexBackground(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.cyberBlue),
        ),
      );
    }

    return ApexBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BibliotecaHeader(),
              const SizedBox(height: 28),
              if (state.games.isEmpty)
                const _BibliotecaEmptyCard()
              else
                _GameList(
                  games: state.games,
                  onTap: (id) async {
                    await context.push('/game-detail/$id');
                    if (!mounted) return;
                    await _controller.loadGames();
                    if (mounted) setState(() {});
                  },
                  onToggleFavorite: (id) async {
                    await _controller.toggleFavorite(id);
                    if (mounted) setState(() {});
                  },
                  onRemove: (id, name) async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      barrierColor: Colors.black.withValues(alpha: 0.75),
                      builder: (_) => _RemoveGameDialog(gameName: name),
                    );
                    if (confirmed != true) return;
                    if (!mounted) return;
                    await _controller.removeGame(id);
                    if (mounted) setState(() {});
                  },
                ),
              const SizedBox(height: 16),
              ApexFeatureCard(
                badge: 'FAV',
                title: 'Jogos favoritos',
                subtitle: 'Acesso rápido aos jogos que você mais usa.',
                accentColor: AppColors.cyberBlue,
                delay: 100.ms,
              ),
              const SizedBox(height: 12),
              ApexFeatureCard(
                badge: 'GFX',
                title: 'Perfis locais',
                subtitle:
                    'Preferências visuais serão salvas por jogo nas próximas etapas.',
                accentColor: AppColors.energyOrange,
                delay: 200.ms,
              ),
              const SizedBox(height: 32),
              _BibliotecaCTA(
                onPressed: _openAddGameDialog,
              ),
              const SizedBox(height: 10),
              _AppPickerButton(
                onPressed: _openPickerSheet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _BibliotecaHeader extends StatelessWidget {
  const _BibliotecaHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biblioteca',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: -0.08, end: 0, duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Organize seus jogos em um só lugar.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textGray,
              ),
        ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
      ],
    );
  }
}

// ─── Empty card ───────────────────────────────────────────────────────────────

class _BibliotecaEmptyCard extends StatelessWidget {
  const _BibliotecaEmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cyberBlue.withValues(alpha: 0.12),
            AppColors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cyberBlue.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ApexBadge(label: 'BIB', color: AppColors.cyberBlue),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.cyberBlue.withValues(alpha: 0.45),
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Sua biblioteca está sendo preparada',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Em breve você poderá adicionar seus jogos e iniciar sessões pelo Apex Booster +.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGray,
                  fontSize: 13,
                ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.04, end: 0, duration: 400.ms);
  }
}

// ─── Game list ────────────────────────────────────────────────────────────────

class _GameList extends StatelessWidget {
  final List<ApexGame> games;
  final void Function(String id) onTap;
  final void Function(String id) onToggleFavorite;
  final void Function(String id, String name) onRemove;

  const _GameList({
    required this.games,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${games.length} ${games.length == 1 ? 'jogo' : 'jogos'} na sessão',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textGray,
                fontSize: 12,
              ),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 10),
        ...games.asMap().entries.map((entry) {
          final index = entry.key;
          final game = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _GameCard(
              game: game,
              delay: (index * 60).ms,
              onTap: () => onTap(game.id),
              onToggleFavorite: () => onToggleFavorite(game.id),
              onRemove: () => onRemove(game.id, game.name),
            ),
          );
        }),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  final ApexGame game;
  final Duration delay;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onRemove;

  const _GameCard({
    required this.game,
    required this.delay,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.cyberBlue.withValues(alpha: 0.10),
            AppColors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: game.isFavorite
              ? AppColors.apexGreen.withValues(alpha: 0.35)
              : AppColors.cyberBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  const ApexBadge(label: 'GAME', color: AppColors.cyberBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      game.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onToggleFavorite,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                game.isFavorite
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: game.isFavorite
                    ? AppColors.apexGreen
                    : AppColors.textGray.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textGray.withValues(alpha: 0.5),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 350.ms)
        .slideX(begin: 0.04, end: 0, delay: delay, duration: 300.ms);
  }
}

// ─── Add game dialog ──────────────────────────────────────────────────────────

class _AddGameDialog extends StatefulWidget {
  final String initialName;
  final String initialPackageName;

  const _AddGameDialog({
    this.initialName = '',
    this.initialPackageName = '',
  });

  @override
  State<_AddGameDialog> createState() => _AddGameDialogState();
}

class _AddGameDialogState extends State<_AddGameDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _pkgController;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _pkgController = TextEditingController(text: widget.initialPackageName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pkgController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Nome obrigatório');
      return;
    }
    final pkg = _pkgController.text.trim();
    Navigator.of(context).pop((name, pkg.isEmpty ? null : pkg));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111318),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.cyberBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      title: const Text(
        'Adicionar jogo',
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DialogField(
            controller: _nameController,
            label: 'Nome do jogo',
            autofocus: widget.initialName.isEmpty,
            errorText: _nameError,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 12),
          _DialogField(
            controller: _pkgController,
            label: 'Package name (opcional)',
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textGray),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cyberBlue,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          child: const Text(
            'Adicionar',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _DialogField({
    required this.controller,
    required this.label,
    this.autofocus = false,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: const TextStyle(color: AppColors.white),
      cursorColor: AppColors.cyberBlue,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 14),
        errorText: errorText,
        errorStyle:
            const TextStyle(color: AppColors.energyOrange, fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: AppColors.cyberBlue.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.cyberBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.energyOrange),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.energyOrange, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.white.withValues(alpha: 0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ─── Remove game dialog ───────────────────────────────────────────────────────

class _RemoveGameDialog extends StatelessWidget {
  final String gameName;

  const _RemoveGameDialog({required this.gameName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111318),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.cyberBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      title: const Text(
        'Remover jogo',
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      content: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 14,
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'Remover '),
            TextSpan(
              text: gameName,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: ' da biblioteca?'),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textGray),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.energyOrange,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 0,
          ),
          child: const Text(
            'Remover',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// ─── CTAs ─────────────────────────────────────────────────────────────────────

class _BibliotecaCTA extends StatelessWidget {
  final VoidCallback onPressed;

  const _BibliotecaCTA({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyberBlue,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Text(
          'ADICIONAR JOGO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }
}

class _AppPickerButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AppPickerButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.apps_rounded, size: 16),
        label: const Text(
          'ESCOLHER APP INSTALADO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cyberBlue,
          side: BorderSide(color: AppColors.cyberBlue.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }
}
