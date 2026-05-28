import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/data/datasources/installed_apps_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.allappsengineer.apex_booster_plus/apps');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // Um único teste de integração cobre os três cenários de isGame num só call.
  // Isso evita o problema do _appsCache estático que persiste entre test() blocks.
  test(
    'getInstalledApps: propaga isGame true, false e ausente corretamente',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getInstalledApps') {
          return [
            {
              'appName': 'Jogo Classificado',
              'packageName': 'com.pkg.jogo',
              'isGame': true,
            },
            {
              'appName': 'App Nao Classificado',
              'packageName': 'com.pkg.app',
              'isGame': false,
            },
            {
              'appName': 'App Legado',
              'packageName': 'com.pkg.legado',
              // sem campo isGame — backward compat
            },
          ];
        }
        return null;
      });

      final apps = await InstalledAppsDatasource().getInstalledApps();

      expect(apps, hasLength(3));

      final jogo = apps.firstWhere((a) => a.packageName == 'com.pkg.jogo');
      final app = apps.firstWhere((a) => a.packageName == 'com.pkg.app');
      final legado = apps.firstWhere((a) => a.packageName == 'com.pkg.legado');

      expect(jogo.isGame, isTrue);
      expect(app.isGame, isFalse);
      expect(legado.isGame, isFalse);

      // Campos existentes preservados
      expect(jogo.appName, 'Jogo Classificado');
      expect(app.appName, 'App Nao Classificado');
      expect(legado.appName, 'App Legado');
    },
  );
}
