import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/apex_game.dart';
import 'package:apex_booster_plus/domain/entities/apex_scan_result.dart';
import 'package:apex_booster_plus/domain/services/apex_scan_service.dart';

void main() {
  late ApexScanService service;

  final baseTime = DateTime(2026, 1, 1, 12, 0, 0);
  final laterTime = DateTime(2026, 1, 1, 12, 0, 5);

  ApexGame makeGame({
    String? packageName,
    bool isFavorite = false,
    String? localProfileName,
    DateTime? updatedAt,
  }) {
    return ApexGame(
      id: 'g1',
      name: 'Test Game',
      packageName: packageName,
      isFavorite: isFavorite,
      localProfileName: localProfileName,
      createdAt: baseTime,
      updatedAt: updatedAt ?? baseTime,
    );
  }

  setUp(() {
    service = ApexScanService();
  });

  // --- Score ---

  group('score', () {
    test('incompleto when packageName is null', () {
      final result = service.scan(game: makeGame(), isLaunchable: false);
      expect(result.score, ScanScore.incompleto);
    });

    test('incompleto when packageName present but not launchable', () {
      final result = service.scan(
        game: makeGame(packageName: 'com.example.game'),
        isLaunchable: false,
      );
      expect(result.score, ScanScore.incompleto);
    });

    test('pronto when packageName present and launchable', () {
      final result = service.scan(
        game: makeGame(packageName: 'com.example.game'),
        isLaunchable: true,
      );
      expect(result.score, ScanScore.pronto);
    });

    test('pronto regardless of GFX profile', () {
      final result = service.scan(
        game: makeGame(packageName: 'com.example.game', localProfileName: null),
        isLaunchable: true,
      );
      expect(result.score, ScanScore.pronto);
    });

    test('pronto regardless of isFavorite', () {
      final result = service.scan(
        game: makeGame(
            packageName: 'com.example.game', isFavorite: false),
        isLaunchable: true,
      );
      expect(result.score, ScanScore.pronto);
    });
  });

  // --- Always 5 checks ---

  test('result always contains exactly 5 checks', () {
    final result = service.scan(game: makeGame(), isLaunchable: false);
    expect(result.checks.length, 5);
  });

  test('check ids are correct and in order', () {
    final result = service.scan(game: makeGame(), isLaunchable: false);
    expect(result.checks.map((c) => c.id).toList(),
        ['vinculo', 'acesso', 'perfil', 'prioridade', 'consistencia']);
  });

  // --- Check: vinculo ---

  group('check vinculo', () {
    test('ok when packageName is present', () {
      final result = service.scan(
        game: makeGame(packageName: 'com.example.game'),
        isLaunchable: true,
      );
      final check = result.checks.firstWhere((c) => c.id == 'vinculo');
      expect(check.status, ScanCheckStatus.ok);
      expect(check.message, 'App vinculado ao cadastro');
    });

    test('warn when packageName is null', () {
      final result = service.scan(game: makeGame(), isLaunchable: false);
      final check = result.checks.firstWhere((c) => c.id == 'vinculo');
      expect(check.status, ScanCheckStatus.warn);
      expect(check.message, 'Sem packageName — vínculo não confirmado');
    });
  });

  // --- Check: acesso ---

  group('check acesso', () {
    test('ok when packageName present and launchable', () {
      final result = service.scan(
        game: makeGame(packageName: 'com.example.game'),
        isLaunchable: true,
      );
      final check = result.checks.firstWhere((c) => c.id == 'acesso');
      expect(check.status, ScanCheckStatus.ok);
      expect(check.message, 'App instalado e acessível');
    });

    test('fail when packageName present but not launchable', () {
      final result = service.scan(
        game: makeGame(packageName: 'com.example.game'),
        isLaunchable: false,
      );
      final check = result.checks.firstWhere((c) => c.id == 'acesso');
      expect(check.status, ScanCheckStatus.fail);
      expect(check.message, 'App não encontrado nos instalados');
    });

    test('warn when packageName is null', () {
      final result = service.scan(game: makeGame(), isLaunchable: false);
      final check = result.checks.firstWhere((c) => c.id == 'acesso');
      expect(check.status, ScanCheckStatus.warn);
      expect(check.message, 'Acesso não verificado — sem packageName');
    });
  });

  // --- Check: perfil ---

  group('check perfil', () {
    test('Equilibrado retorna mensagem semantica e status ok', () {
      final result = service.scan(
        game: makeGame(
            packageName: 'com.example.game',
            localProfileName: 'Equilibrado'),
        isLaunchable: true,
      );
      final check = result.checks.firstWhere((c) => c.id == 'perfil');
      expect(check.status, ScanCheckStatus.ok);
      expect(check.message, 'Equilibrado — balanço entre visual e fluidez');
    });

    test('Desempenho retorna mensagem semantica e status ok', () {
      final result = service.scan(
        game: makeGame(
            packageName: 'com.example.game',
            localProfileName: 'Desempenho'),
        isLaunchable: true,
      );
      final check = result.checks.firstWhere((c) => c.id == 'perfil');
      expect(check.status, ScanCheckStatus.ok);
      expect(check.message, 'Desempenho — priorizando fluidez local');
    });

    test('Qualidade retorna mensagem semantica e status ok', () {
      final result = service.scan(
        game: makeGame(
            packageName: 'com.example.game',
            localProfileName: 'Qualidade'),
        isLaunchable: true,
      );
      final check = result.checks.firstWhere((c) => c.id == 'perfil');
      expect(check.status, ScanCheckStatus.ok);
      expect(check.message, 'Qualidade — priorizando visual local');
    });

    test('Economia retorna mensagem semantica e status ok', () {
      final result = service.scan(
        game: makeGame(
            packageName: 'com.example.game',
            localProfileName: 'Economia'),
        isLaunchable: true,
      );
      final check = result.checks.firstWhere((c) => c.id == 'perfil');
      expect(check.status, ScanCheckStatus.ok);
      expect(check.message, 'Economia — priorizando autonomia da bateria');
    });

    test('null retorna fallback padrao com status info', () {
      final result = service.scan(
        game: makeGame(packageName: 'com.example.game'),
        isLaunchable: true,
      );
      final check = result.checks.firstWhere((c) => c.id == 'perfil');
      expect(check.status, ScanCheckStatus.info);
      expect(check.message, 'Perfil padrão será usado');
    });

    test('perfil invalido retorna fallback padrao com status info', () {
      final result = service.scan(
        game: makeGame(
            packageName: 'com.example.game',
            localProfileName: 'ProfileDesconhecido'),
        isLaunchable: true,
      );
      final check = result.checks.firstWhere((c) => c.id == 'perfil');
      expect(check.status, ScanCheckStatus.info);
      expect(check.message, 'Perfil padrão será usado');
    });

    test('perfil nao afeta score pronto', () {
      final result = service.scan(
        game: makeGame(packageName: 'com.example.game', localProfileName: null),
        isLaunchable: true,
      );
      expect(result.score, ScanScore.pronto);
    });

    test('perfil invalido nao afeta score', () {
      final result = service.scan(
        game: makeGame(
            packageName: 'com.example.game',
            localProfileName: 'ProfileDesconhecido'),
        isLaunchable: true,
      );
      expect(result.score, ScanScore.pronto);
    });
  });

  // --- Check: prioridade ---

  group('check prioridade', () {
    test('ok when isFavorite is true', () {
      final result = service.scan(
        game: makeGame(isFavorite: true),
        isLaunchable: false,
      );
      final check = result.checks.firstWhere((c) => c.id == 'prioridade');
      expect(check.status, ScanCheckStatus.ok);
      expect(check.message, 'Marcado como prioritário');
    });

    test('info when isFavorite is false', () {
      final result = service.scan(game: makeGame(), isLaunchable: false);
      final check = result.checks.firstWhere((c) => c.id == 'prioridade');
      expect(check.status, ScanCheckStatus.info);
      expect(check.message, 'Jogo padrão na biblioteca');
    });

    test('prioridade does not affect score', () {
      final withFav = service.scan(
        game: makeGame(
            packageName: 'com.example.game', isFavorite: true),
        isLaunchable: false,
      );
      final withoutFav = service.scan(
        game: makeGame(
            packageName: 'com.example.game', isFavorite: false),
        isLaunchable: false,
      );
      expect(withFav.score, ScanScore.incompleto);
      expect(withoutFav.score, ScanScore.incompleto);
    });
  });

  // --- Check: consistencia ---

  group('check consistencia', () {
    test('ok when updatedAt is more than 1 second after createdAt', () {
      final result = service.scan(
        game: makeGame(updatedAt: laterTime),
        isLaunchable: false,
      );
      final check = result.checks.firstWhere((c) => c.id == 'consistencia');
      expect(check.status, ScanCheckStatus.ok);
      expect(check.message, 'Cadastro consistente');
    });

    test('info when updatedAt equals createdAt', () {
      final result = service.scan(game: makeGame(), isLaunchable: false);
      final check = result.checks.firstWhere((c) => c.id == 'consistencia');
      expect(check.status, ScanCheckStatus.info);
      expect(check.message, 'Configuração inicial');
    });
  });

  // --- Mensagens sem conteúdo proibido ---

  test('no check message contains FPS, RAM, GPU or Ping', () {
    final result = service.scan(
      game: makeGame(
        packageName: 'com.example.game',
        isFavorite: true,
        localProfileName: 'Qualidade',
        updatedAt: laterTime,
      ),
      isLaunchable: true,
    );
    for (final check in result.checks) {
      final msg = check.message.toLowerCase();
      expect(msg, isNot(contains('fps')));
      expect(msg, isNot(contains('ram')));
      expect(msg, isNot(contains('gpu')));
      expect(msg, isNot(contains('ping')));
      expect(msg, isNot(contains('otimiz')));
      expect(msg, isNot(contains('performance')));
    }
  });
}
