import '../entities/apex_game.dart';
import '../entities/apex_scan_result.dart';
import '../entities/gfx_profile.dart';

class ApexScanService {
  /// [isLaunchable] null = local-only mode (no getInstalledApps call);
  /// true/false = verified via platform channel.
  ApexScanResult scan({
    required ApexGame game,
    bool? isLaunchable,
  }) {
    return ApexScanResult(
      checks: [
        _vinculo(game),
        _acesso(game, isLaunchable),
        _perfil(game),
        _prioridade(game),
        _consistencia(game),
      ],
      score: _score(game, isLaunchable),
    );
  }

  ScanScore _score(ApexGame game, bool? isLaunchable) {
    final hasPackage =
        game.packageName != null && game.packageName!.isNotEmpty;
    if (!hasPackage) return ScanScore.incompleto;
    if (isLaunchable == true) return ScanScore.pronto;
    if (isLaunchable == false) return ScanScore.incompleto;
    return ScanScore.naoVerificado;
  }

  ScanCheck _vinculo(ApexGame game) {
    final hasPackage =
        game.packageName != null && game.packageName!.isNotEmpty;
    return ScanCheck(
      id: 'vinculo',
      label: 'Vínculo de app',
      status: hasPackage ? ScanCheckStatus.ok : ScanCheckStatus.warn,
      message: hasPackage
          ? 'App vinculado ao cadastro'
          : 'Sem packageName — vínculo não confirmado',
    );
  }

  ScanCheck _acesso(ApexGame game, bool? isLaunchable) {
    final hasPackage =
        game.packageName != null && game.packageName!.isNotEmpty;
    if (!hasPackage) {
      return const ScanCheck(
        id: 'acesso',
        label: 'Acesso',
        status: ScanCheckStatus.warn,
        message: 'Acesso não verificado — sem packageName',
      );
    }
    if (isLaunchable == null) {
      return ScanCheck(
        id: 'acesso',
        label: 'Acesso',
        status: ScanCheckStatus.info,
        message: 'App vinculado: ${game.packageName} registrado',
      );
    }
    return ScanCheck(
      id: 'acesso',
      label: 'Acesso',
      status: isLaunchable ? ScanCheckStatus.ok : ScanCheckStatus.fail,
      message: isLaunchable
          ? 'App instalado e acessível'
          : 'App não encontrado nos instalados',
    );
  }

  ScanCheck _perfil(ApexGame game) {
    final profile = GfxProfile.fromLabel(game.localProfileName);
    return ScanCheck(
      id: 'perfil',
      label: 'Perfil GFX',
      status: profile != null ? ScanCheckStatus.ok : ScanCheckStatus.info,
      message: profile != null ? _perfilMessage(profile) : 'Perfil padrão será usado',
    );
  }

  static String _perfilMessage(GfxProfile profile) => switch (profile) {
        GfxProfile.balanced => 'Equilibrado — balanço entre visual e fluidez',
        GfxProfile.performance => 'Desempenho — priorizando fluidez local',
        GfxProfile.quality => 'Qualidade — priorizando visual local',
        GfxProfile.economy => 'Economia — priorizando autonomia da bateria',
      };

  ScanCheck _prioridade(ApexGame game) {
    return ScanCheck(
      id: 'prioridade',
      label: 'Prioridade',
      status: game.isFavorite ? ScanCheckStatus.ok : ScanCheckStatus.info,
      message: game.isFavorite
          ? 'Marcado como prioritário'
          : 'Jogo padrão na biblioteca',
    );
  }

  ScanCheck _consistencia(ApexGame game) {
    final customized =
        game.updatedAt.difference(game.createdAt).inSeconds > 1;
    return ScanCheck(
      id: 'consistencia',
      label: 'Consistência',
      status: customized ? ScanCheckStatus.ok : ScanCheckStatus.info,
      message: customized ? 'Cadastro consistente' : 'Configuração inicial',
    );
  }
}
