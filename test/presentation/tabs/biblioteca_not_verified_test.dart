import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/installed_app.dart';
import 'package:apex_booster_plus/presentation/screens/home/tabs/biblioteca_tab.dart';

void main() {
  const gameApp = InstalledApp(
    appName: 'Free Fire',
    packageName: 'com.garena.game.kalahari',
    isGame: true,
  );
  const nonGameApp = InstalledApp(
    appName: 'Waze',
    packageName: 'com.waze',
    isGame: false,
  );
  const legacyApp = InstalledApp(
    appName: 'App Legado',
    packageName: 'com.legado',
  );

  group('buildNotVerifiedSet', () {
    test('retorna vazio quando lista está vazia', () {
      expect(buildNotVerifiedSet([]), isEmpty);
    });

    test('retorna vazio quando todos os apps são jogos verificados', () {
      expect(buildNotVerifiedSet([gameApp]), isEmpty);
    });

    test('inclui packageName de app com isGame false', () {
      final result = buildNotVerifiedSet([nonGameApp]);
      expect(result, contains('com.waze'));
    });

    test('inclui app legado (isGame false por padrão)', () {
      final result = buildNotVerifiedSet([legacyApp]);
      expect(result, contains('com.legado'));
    });

    test('exclui jogo verificado e inclui app não verificado', () {
      final result = buildNotVerifiedSet([gameApp, nonGameApp]);
      expect(result, isNot(contains('com.garena.game.kalahari')));
      expect(result, contains('com.waze'));
    });

    test('processa lista mista corretamente', () {
      final result = buildNotVerifiedSet([gameApp, nonGameApp, legacyApp]);
      expect(result, hasLength(2));
      expect(result, containsAll(['com.waze', 'com.legado']));
      expect(result, isNot(contains('com.garena.game.kalahari')));
    });
  });
}
