import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/installed_app.dart';

void main() {
  // --- fromMap: isGame parsing ---

  group('InstalledApp.fromMap — isGame', () {
    test('isGame true quando mapa tem isGame: true', () {
      final app = InstalledApp.fromMap({
        'appName': 'Free Fire',
        'packageName': 'com.garena.game.kalahari',
        'isGame': true,
      });
      expect(app.isGame, isTrue);
    });

    test('isGame false quando mapa tem isGame: false', () {
      final app = InstalledApp.fromMap({
        'appName': 'Waze',
        'packageName': 'com.waze',
        'isGame': false,
      });
      expect(app.isGame, isFalse);
    });

    test('isGame false quando campo isGame está ausente (backward compat)', () {
      final app = InstalledApp.fromMap({
        'appName': 'App Legado',
        'packageName': 'com.legado.app',
      });
      expect(app.isGame, isFalse);
    });

    test('isGame false quando isGame é null', () {
      final app = InstalledApp.fromMap({
        'appName': 'App',
        'packageName': 'com.pkg',
        'isGame': null,
      });
      expect(app.isGame, isFalse);
    });

    test('isGame false para valor inesperado int (não bool)', () {
      final app = InstalledApp.fromMap({
        'appName': 'App',
        'packageName': 'com.pkg',
        'isGame': 1,
      });
      expect(app.isGame, isFalse);
    });

    test('isGame false para valor inesperado String', () {
      final app = InstalledApp.fromMap({
        'appName': 'App',
        'packageName': 'com.pkg',
        'isGame': 'true',
      });
      expect(app.isGame, isFalse);
    });
  });

  // --- fromMap: campos existentes preservados ---

  group('InstalledApp.fromMap — campos existentes', () {
    test('preserva appName e packageName com isGame true', () {
      final app = InstalledApp.fromMap({
        'appName': 'PUBG Mobile',
        'packageName': 'com.tencent.ig',
        'isGame': true,
      });
      expect(app.appName, 'PUBG Mobile');
      expect(app.packageName, 'com.tencent.ig');
    });

    test('preserva appName e packageName sem campo isGame', () {
      final app = InstalledApp.fromMap({
        'appName': 'Spotify',
        'packageName': 'com.spotify.music',
      });
      expect(app.appName, 'Spotify');
      expect(app.packageName, 'com.spotify.music');
      expect(app.isGame, isFalse);
    });
  });

  // --- construtor: valor padrão de isGame ---

  group('InstalledApp construtor — isGame default', () {
    test('isGame é false por padrão', () {
      const app = InstalledApp(appName: 'X', packageName: 'com.x');
      expect(app.isGame, isFalse);
    });

    test('isGame pode ser true explicitamente', () {
      const app = InstalledApp(appName: 'X', packageName: 'com.x', isGame: true);
      expect(app.isGame, isTrue);
    });
  });
}
