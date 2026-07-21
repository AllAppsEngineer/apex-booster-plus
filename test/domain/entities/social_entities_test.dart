import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/social_card.dart';
import 'package:apex_booster_plus/domain/entities/share_preset.dart';

void main() {
  group('SocialCard', () {
    test('creates with required fields and defaults', () {
      final card = SocialCard(
        id: 'test-1',
        gameId: 'game-1',
        gameName: 'Free Fire',
        createdAt: DateTime(2026, 6, 11),
      );
      expect(card.id, 'test-1');
      expect(card.gameName, 'Free Fire');
      expect(card.caption, '');
      expect(card.templateId, 'default');
      expect(card.preset, SharePreset.portrait);
      expect(card.includeWatermark, true);
      expect(card.badgeKeys, isEmpty);
      expect(card.importedMediaPath, isNull);
    });

    test('copyWith updates caption without changing other fields', () {
      final original = SocialCard(
        id: 'test-1',
        gameId: 'game-1',
        gameName: 'Free Fire',
        createdAt: DateTime(2026, 6, 11),
      );
      final updated = original.copyWith(caption: 'Sessão épica!');
      expect(updated.caption, 'Sessão épica!');
      expect(updated.id, original.id);
      expect(updated.gameName, original.gameName);
      expect(updated.preset, original.preset);
    });

    test('copyWith updates preset independently', () {
      final card = SocialCard(
        id: 'test-2',
        gameId: 'game-1',
        gameName: 'Free Fire',
        createdAt: DateTime(2026, 6, 11),
      );
      final updated = card.copyWith(preset: SharePreset.square);
      expect(updated.preset, SharePreset.square);
      expect(updated.id, card.id);
    });

    test('copyWith updates templateId independently', () {
      final card = SocialCard(
        id: 'test-3',
        gameId: 'game-1',
        gameName: 'Free Fire',
        createdAt: DateTime(2026, 6, 11),
      );
      final updated = card.copyWith(templateId: 'cyber');
      expect(updated.templateId, 'cyber');
    });
  });

  group('SharePreset', () {
    test('portrait aspectRatio is 9/16', () {
      expect(SharePreset.portrait.aspectRatio, closeTo(9 / 16, 0.001));
    });
    test('square aspectRatio is 1.0', () {
      expect(SharePreset.square.aspectRatio, 1.0);
    });
    test('landscape aspectRatio is 16/9', () {
      expect(SharePreset.landscape.aspectRatio, closeTo(16 / 9, 0.001));
    });
    test('portrait label is 9:16', () {
      expect(SharePreset.portrait.label, '9:16');
    });
    test('square label is 1:1', () {
      expect(SharePreset.square.label, '1:1');
    });
    test('landscape label is 16:9', () {
      expect(SharePreset.landscape.label, '16:9');
    });
  });
}
