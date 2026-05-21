import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';
import 'package:apex_booster_plus/data/repositories/in_memory_game_library_repository.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/presentation/controllers/game_library_controller.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_background.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_badge.dart';
import 'package:apex_booster_plus/presentation/widgets/apex_feature_card.dart';

class BibliotecaTab extends StatefulWidget {
  const BibliotecaTab({super.key});

  @override
  State<BibliotecaTab> createState() => _BibliotecaTabState();
}

class _BibliotecaTabState extends State<BibliotecaTab> {
  final _controller = GameLibraryController(InMemoryGameLibraryRepository());

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    await _controller.loadGames();
    if (mounted) setState(() {});
  }

  Future<void> _openAddGameDialog(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => const _AddGameDialog(),
    );

    if (name == null || name.isEmpty) return;
    if (!mounted) return;

    final now = DateTime.now();
    final game = ApexGame(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: now,
      updatedAt: now,
    );
    await _controller.addGame(game);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                _GameList(games: state.games),
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
                onPressed: () => _openAddGameDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _GameList extends StatelessWidget {
  final List<dynamic> games;

  const _GameList({required this.games});

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
            child: _GameListItem(
              name: game.name as String,
              delay: (index * 60).ms,
            ),
          );
        }),
      ],
    );
  }
}

class _GameListItem extends StatelessWidget {
  final String name;
  final Duration delay;

  const _GameListItem({required this.name, required this.delay});

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
          color: AppColors.cyberBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const ApexBadge(label: 'JOGO', color: AppColors.cyberBlue),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.gamepad_outlined,
            color: AppColors.cyberBlue.withValues(alpha: 0.5),
            size: 18,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay, duration: 350.ms)
        .slideX(begin: 0.04, end: 0, delay: delay, duration: 300.ms);
  }
}

class _AddGameDialog extends StatefulWidget {
  const _AddGameDialog();

  @override
  State<_AddGameDialog> createState() => _AddGameDialogState();
}

class _AddGameDialogState extends State<_AddGameDialog> {
  final _nameController = TextEditingController();
  String? _fieldError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
          TextField(
            controller: _nameController,
            autofocus: true,
            style: const TextStyle(color: AppColors.white),
            cursorColor: AppColors.cyberBlue,
            decoration: InputDecoration(
              hintText: 'Nome do jogo',
              hintStyle: const TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
              ),
              errorText: _fieldError,
              errorStyle: const TextStyle(
                color: AppColors.energyOrange,
                fontSize: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.cyberBlue.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.cyberBlue,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.energyOrange,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.energyOrange,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: AppColors.white.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            onChanged: (_) {
              if (_fieldError != null) {
                setState(() => _fieldError = null);
              }
            },
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
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              setState(() => _fieldError = 'Nome obrigatório');
              return;
            }
            Navigator.of(context).pop(name);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cyberBlue,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            elevation: 0,
          ),
          child: const Text(
            'Adicionar',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

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
