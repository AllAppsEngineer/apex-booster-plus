import 'share_preset.dart';

class SocialCard {
  final String id;
  final String gameId;
  final String gameName;
  final String? gameIconPath;
  final String? sessionId;
  final DateTime createdAt;
  final String caption;
  final String templateId;
  final SharePreset preset;
  final List<String> badgeKeys;
  final bool includeWatermark;
  final String? importedMediaPath;

  const SocialCard({
    required this.id,
    required this.gameId,
    required this.gameName,
    this.gameIconPath,
    this.sessionId,
    required this.createdAt,
    this.caption = '',
    this.templateId = 'default',
    this.preset = SharePreset.portrait,
    this.badgeKeys = const [],
    this.includeWatermark = true,
    this.importedMediaPath,
  });

  SocialCard copyWith({
    String? id,
    String? gameId,
    String? gameName,
    String? gameIconPath,
    String? sessionId,
    DateTime? createdAt,
    String? caption,
    String? templateId,
    SharePreset? preset,
    List<String>? badgeKeys,
    bool? includeWatermark,
    String? importedMediaPath,
  }) {
    return SocialCard(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      gameName: gameName ?? this.gameName,
      gameIconPath: gameIconPath ?? this.gameIconPath,
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
      caption: caption ?? this.caption,
      templateId: templateId ?? this.templateId,
      preset: preset ?? this.preset,
      badgeKeys: badgeKeys ?? this.badgeKeys,
      includeWatermark: includeWatermark ?? this.includeWatermark,
      importedMediaPath: importedMediaPath ?? this.importedMediaPath,
    );
  }
}
