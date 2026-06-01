import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/device_metrics.dart';
import 'package:apex_booster_plus/domain/entities/gfx_profile.dart';
import 'package:apex_booster_plus/presentation/screens/home/tabs/preparar_tab.dart';

DeviceMetrics makeMetrics({
  bool isLowMemory = false,
  LatencyStatus latencyStatus = LatencyStatus.success,
  int? latencyMs = 50,
}) =>
    DeviceMetrics(
      availableMemoryBytes: isLowMemory ? 200 * 1024 * 1024 : 2000 * 1024 * 1024,
      totalMemoryBytes: 8 * 1024 * 1024 * 1024,
      isLowMemory: isLowMemory,
      latencyMs: latencyMs,
      latencyStatus: latencyStatus,
    );

void main() {
  group('buildGfxRecommendations — perfil nulo', () {
    test('retorna lista vazia quando profile é null', () {
      final result = buildGfxRecommendations(null, null, null);
      expect(result, isEmpty);
    });

    test('retorna lista vazia com metrics reais mas sem perfil', () {
      final result = buildGfxRecommendations(null, makeMetrics(), false);
      expect(result, isEmpty);
    });
  });

  group('buildGfxRecommendations — sem crash com nulls', () {
    test('metrics null não causa exceção', () {
      expect(
        () => buildGfxRecommendations(GfxProfile.performance, null, null),
        returnsNormally,
      );
    });

    test('focusGranted null não causa exceção', () {
      expect(
        () => buildGfxRecommendations(GfxProfile.economy, makeMetrics(), null),
        returnsNormally,
      );
    });

    test('todos os campos null com perfil válido não causam exceção', () {
      for (final profile in GfxProfile.values) {
        expect(
          () => buildGfxRecommendations(profile, null, null),
          returnsNormally,
        );
      }
    });
  });

  group('buildGfxRecommendations — limite de 3 itens', () {
    test('Desempenho com baixa memória e foco negado retorna 3 itens', () {
      final result = buildGfxRecommendations(
        GfxProfile.performance,
        makeMetrics(isLowMemory: true),
        false,
      );
      expect(result.length, lessThanOrEqualTo(3));
    });

    test('Qualidade com latência ruim e foco negado retorna no máximo 3 itens', () {
      final result = buildGfxRecommendations(
        GfxProfile.quality,
        makeMetrics(latencyStatus: LatencyStatus.timeout),
        false,
      );
      expect(result.length, lessThanOrEqualTo(3));
    });

    test('Economia com baixa memória e foco negado retorna no máximo 3 itens', () {
      final result = buildGfxRecommendations(
        GfxProfile.economy,
        makeMetrics(isLowMemory: true),
        false,
      );
      expect(result.length, lessThanOrEqualTo(3));
    });

    test('Equilibrado com baixa memória e foco negado retorna no máximo 3 itens', () {
      final result = buildGfxRecommendations(
        GfxProfile.balanced,
        makeMetrics(isLowMemory: true),
        false,
      );
      expect(result.length, lessThanOrEqualTo(3));
    });

    test('nenhum perfil retorna mais de 3 itens em qualquer condição', () {
      for (final profile in GfxProfile.values) {
        final result = buildGfxRecommendations(
          profile,
          makeMetrics(isLowMemory: true, latencyStatus: LatencyStatus.error),
          false,
        );
        expect(result.length, lessThanOrEqualTo(3),
            reason: 'Perfil ${profile.label} retornou ${result.length} itens');
      }
    });
  });

  group('buildGfxRecommendations — Desempenho', () {
    test('inclui recomendação base mesmo com metrics e focus null', () {
      final result = buildGfxRecommendations(GfxProfile.performance, null, null);
      expect(result, isNotEmpty);
      expect(result.any((r) => r.contains('segundo plano')), isTrue);
    });

    test('inclui dica de Modo Foco quando focusGranted é false', () {
      final result = buildGfxRecommendations(GfxProfile.performance, null, false);
      expect(result.any((r) => r.contains('Modo Foco')), isTrue);
    });

    test('não inclui dica de Modo Foco quando focusGranted é true', () {
      final result = buildGfxRecommendations(GfxProfile.performance, null, true);
      expect(result.any((r) => r.contains('Modo Foco')), isFalse);
    });

    test('não inclui dica de Modo Foco quando focusGranted é null', () {
      final result = buildGfxRecommendations(GfxProfile.performance, null, null);
      expect(result.any((r) => r.contains('Modo Foco')), isFalse);
    });

    test('inclui alerta de RAM quando isLowMemory é true', () {
      final result = buildGfxRecommendations(
        GfxProfile.performance,
        makeMetrics(isLowMemory: true),
        null,
      );
      expect(result.any((r) => r.contains('RAM') || r.contains('apps pesados')), isTrue);
    });

    test('inclui Wi-Fi quando memória normal', () {
      final result = buildGfxRecommendations(
        GfxProfile.performance,
        makeMetrics(isLowMemory: false),
        null,
      );
      expect(result.any((r) => r.contains('Wi-Fi')), isTrue);
    });

    test('inclui todos os alertas críticos: memória baixa + foco negado', () {
      final result = buildGfxRecommendations(
        GfxProfile.performance,
        makeMetrics(isLowMemory: true),
        false,
      );
      expect(result.any((r) => r.contains('segundo plano')), isTrue);
      expect(result.any((r) => r.contains('Modo Foco')), isTrue);
      expect(result.any((r) => r.contains('RAM') || r.contains('apps pesados')), isTrue);
    });
  });

  group('buildGfxRecommendations — Qualidade', () {
    test('inclui recomendação de carga mesmo com metrics null', () {
      final result = buildGfxRecommendations(GfxProfile.quality, null, null);
      expect(result.any((r) => r.contains('carregado') || r.contains('carga')), isTrue);
    });

    test('inclui dica de conexão quando latência indicar falha', () {
      final result = buildGfxRecommendations(
        GfxProfile.quality,
        makeMetrics(latencyStatus: LatencyStatus.timeout),
        null,
      );
      expect(result.any((r) => r.toLowerCase().contains('conexão')), isTrue);
    });

    test('inclui dica de conexão quando latência indicar erro de rede', () {
      final result = buildGfxRecommendations(
        GfxProfile.quality,
        makeMetrics(latencyStatus: LatencyStatus.noNetwork),
        null,
      );
      expect(result.any((r) => r.toLowerCase().contains('conexão')), isTrue);
    });

    test('inclui Modo Foco quando focusGranted é false', () {
      final result = buildGfxRecommendations(GfxProfile.quality, null, false);
      expect(result.any((r) => r.contains('Modo Foco')), isTrue);
    });

    test('não inclui Modo Foco quando focusGranted é true', () {
      final result = buildGfxRecommendations(GfxProfile.quality, null, true);
      expect(result.any((r) => r.contains('Modo Foco')), isFalse);
    });
  });

  group('buildGfxRecommendations — Economia', () {
    test('inclui recomendação de brilho sempre', () {
      final result = buildGfxRecommendations(GfxProfile.economy, null, null);
      expect(result.any((r) => r.contains('brilho')), isTrue);
    });

    test('inclui alerta de apps em segundo plano quando isLowMemory é true', () {
      final result = buildGfxRecommendations(
        GfxProfile.economy,
        makeMetrics(isLowMemory: true),
        null,
      );
      expect(result.any((r) => r.contains('segundo plano')), isTrue);
    });

    test('inclui sessões curtas quando memória normal', () {
      final result = buildGfxRecommendations(
        GfxProfile.economy,
        makeMetrics(isLowMemory: false),
        null,
      );
      expect(result.any((r) => r.contains('curtas') || r.contains('carga')), isTrue);
    });

    test('inclui Modo Foco quando focusGranted é false', () {
      final result = buildGfxRecommendations(GfxProfile.economy, null, false);
      expect(result.any((r) => r.contains('Modo Foco')), isTrue);
    });

    test('não inclui Modo Foco quando focusGranted é true', () {
      final result = buildGfxRecommendations(GfxProfile.economy, null, true);
      expect(result.any((r) => r.contains('Modo Foco')), isFalse);
    });

    test('isLowMemory false e focusGranted true não inclui alertas de memória nem foco', () {
      final result = buildGfxRecommendations(
        GfxProfile.economy,
        makeMetrics(isLowMemory: false),
        true,
      );
      expect(result.any((r) => r.contains('segundo plano')), isFalse);
      expect(result.any((r) => r.contains('Modo Foco')), isFalse);
    });
  });

  group('buildGfxRecommendations — Equilibrado', () {
    test('inclui recomendação de conexão sempre', () {
      final result = buildGfxRecommendations(GfxProfile.balanced, null, null);
      expect(result.any((r) => r.contains('conexão')), isTrue);
    });

    test('inclui fechar apps quando isLowMemory é true', () {
      final result = buildGfxRecommendations(
        GfxProfile.balanced,
        makeMetrics(isLowMemory: true),
        null,
      );
      expect(result.any((r) => r.contains('apps')), isTrue);
    });

    test('inclui Modo Foco quando focusGranted é false', () {
      final result = buildGfxRecommendations(GfxProfile.balanced, null, false);
      expect(result.any((r) => r.contains('Modo Foco')), isTrue);
    });

    test('não inclui Modo Foco quando focusGranted é true', () {
      final result = buildGfxRecommendations(GfxProfile.balanced, null, true);
      expect(result.any((r) => r.contains('Modo Foco')), isFalse);
    });
  });

  group('buildGfxRecommendations — linguagem proibida', () {
    const prohibited = [
      'fps',
      'gpu',
      'resolução',
      'textura',
      'boost gráfico',
      'desempenho garantido',
      'otimização garantida',
      'gráficos melhorados',
    ];

    for (final profile in GfxProfile.values) {
      test('${profile.label} — sem linguagem proibida com memória baixa e foco negado', () {
        final result = buildGfxRecommendations(
          profile,
          makeMetrics(isLowMemory: true, latencyStatus: LatencyStatus.error),
          false,
        );
        for (final rec in result) {
          final lower = rec.toLowerCase();
          for (final word in prohibited) {
            expect(lower, isNot(contains(word)),
                reason: 'Recomendação do perfil ${profile.label} contém "$word": $rec');
          }
        }
      });
    }
  });
}
