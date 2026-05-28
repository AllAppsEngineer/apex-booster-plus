import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/installed_app.dart';
import 'package:apex_booster_plus/presentation/widgets/app_picker_sheet.dart';

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

  final allApps = [gameApp, nonGameApp, legacyApp];

  // --- filtro desligado ---

  group('applyPickerFilter — filtro desligado', () {
    test('retorna todos os apps quando query vazia e filtro desligado', () {
      final result = applyPickerFilter(allApps, '', false);
      expect(result, hasLength(3));
    });

    test('filtra por nome quando filtro desligado', () {
      final result = applyPickerFilter(allApps, 'free', false);
      expect(result, hasLength(1));
      expect(result.first.packageName, 'com.garena.game.kalahari');
    });

    test('filtra por packageName quando filtro desligado', () {
      final result = applyPickerFilter(allApps, 'com.waze', false);
      expect(result, hasLength(1));
      expect(result.first.appName, 'Waze');
    });

    test('retorna lista vazia quando nenhum app corresponde à busca', () {
      final result = applyPickerFilter(allApps, 'xyzabc', false);
      expect(result, isEmpty);
    });
  });

  // --- filtro ligado ---

  group('applyPickerFilter — filtro ligado', () {
    test('retorna apenas isGame == true quando filtro ligado e query vazia', () {
      final result = applyPickerFilter(allApps, '', true);
      expect(result, hasLength(1));
      expect(result.first.packageName, 'com.garena.game.kalahari');
    });

    test('filtro ligado exclui apps com isGame == false', () {
      final result = applyPickerFilter(allApps, '', true);
      expect(result.any((a) => a.packageName == 'com.waze'), isFalse);
      expect(result.any((a) => a.packageName == 'com.legado'), isFalse);
    });
  });

  // --- busca textual + filtro ligado (cumulativo) ---

  group('applyPickerFilter — busca textual + filtro ligado', () {
    test('retorna apenas isGame==true que corresponde à query', () {
      final result = applyPickerFilter(allApps, 'fire', true);
      expect(result, hasLength(1));
      expect(result.first.appName, 'Free Fire');
    });

    test('retorna vazio quando query corresponde mas app nao é jogo', () {
      final result = applyPickerFilter(allApps, 'waze', true);
      expect(result, isEmpty);
    });
  });

  // --- lista vazia com filtro ---

  group('applyPickerFilter — lista vazia', () {
    test('lista vazia com filtro desligado retorna vazio sem erro', () {
      final result = applyPickerFilter([], '', false);
      expect(result, isEmpty);
    });

    test('lista vazia com filtro ligado retorna vazio sem erro', () {
      final result = applyPickerFilter([], '', true);
      expect(result, isEmpty);
    });

    test('lista vazia com filtro ligado e query ativa retorna vazio sem erro', () {
      final result = applyPickerFilter([], 'fire', true);
      expect(result, isEmpty);
    });
  });
}
