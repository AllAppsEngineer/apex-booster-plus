import '../entities/apex_game.dart';
import '../entities/apex_scan_result.dart';

class ApexScanService {
  ApexScanResult scan({
    required ApexGame game,
    required bool isLaunchable,
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

  ScanScore _score(ApexGame game, bool isLaunchable) {
    final hasPackage =
        game.packageName != null && game.packageName!.isNotEmpty;
    return (hasPackage && isLaunchable)
        ? ScanScore.pronto
        : ScanScore.incompleto;
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

  ScanCheck _acesso(ApexGame game, bool isLaunchable) {
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
    final hasPerfil = game.localProfileName != null;
    return ScanCheck(
      id: 'perfil',
      label: 'Perfil GFX',
      status: hasPerfil ? ScanCheckStatus.ok : ScanCheckStatus.info,
      message: hasPerfil
          ? 'Perfil ${game.localProfileName} configurado'
          : 'Perfil padrão será usado',
    );
  }

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
