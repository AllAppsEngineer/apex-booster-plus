# SOCIAL-U1 — Apex Share Studio: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Apex Share Studio — a card editor that lets the user create a gamer card with template, caption, and badge, then export it via the native share sheet (no new Android permissions required).

**Architecture:** Domain entities (`SocialCard`, `SharePreset`, `SocialTemplate`) sit in `lib/domain/entities/`. Three new presentation-layer widgets (`ShareCardPortrait`, `ShareCardSquare`, `SocialTemplateSelector`) render the card. `ShareStudioScreen` orchestrates editing and export via `RepaintBoundary.toImage()` → temp file → `share_plus`. A `PrivacyGuardSheet` (bottom sheet) shows before every export. Entry point: `_CreateCardButton` added to `GameDetailScreen`.

**Tech Stack:** Flutter/Dart, `share_plus ^10.1.4`, `path_provider ^2.1.5`, existing `go_router`, `AppStrings` (PT-BR / EN / ES), `languageNotifier`, `AppColors`.

**Design spec:** `docs/superpowers/specs/2026-06-11-social-u0-design-tecnico.md`

**Constraints:**
- No new Android permissions — export uses temp dir + share sheet.
- BibliotecaTab must not be touched.
- No automatic sharing — user always reaches the share sheet.
- No FPS/ping/GPU/CPU copy anywhere in this code.
- No automatic commits.

---

### Task 1: Add dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add share_plus and path_provider to pubspec.yaml**

In the `dependencies:` block, after `shared_preferences: ^2.3.0`, add:

```yaml
  share_plus: ^10.1.4
  path_provider: ^2.1.5
```

- [ ] **Step 2: Fetch packages**

```bash
flutter pub get
```

Expected: `Resolving dependencies... Got dependencies!` with no errors.

- [ ] **Step 3: Verify no analysis errors introduced**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat(social): add share_plus and path_provider for SOCIAL-U1"
```

---

### Task 2: Domain entities — SocialCard, SharePreset, SocialTemplate

**Files:**
- Create: `lib/domain/entities/social_card.dart`
- Create: `lib/domain/entities/share_preset.dart`
- Create: `lib/domain/entities/social_template.dart`
- Create: `test/domain/entities/social_entities_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/domain/entities/social_entities_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:apex_booster_plus/domain/entities/social_card.dart';
import 'package:apex_booster_plus/domain/entities/share_preset.dart';
import 'package:apex_booster_plus/domain/entities/social_template.dart';

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

  group('kSocialTemplates', () {
    test('contains at least 2 templates', () {
      expect(kSocialTemplates.length, greaterThanOrEqualTo(2));
    });
    test('first template id is default', () {
      expect(kSocialTemplates.first.id, 'default');
    });
    test('default template is free', () {
      expect(kSocialTemplates.first.isFree, true);
    });
    test('all templates have non-empty ids', () {
      for (final t in kSocialTemplates) {
        expect(t.id, isNotEmpty);
      }
    });
    test('template ids are unique', () {
      final ids = kSocialTemplates.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
    });
    test('SocialTemplate backgroundColor is opaque', () {
      for (final t in kSocialTemplates) {
        expect(t.backgroundColor.alpha, 255);
      }
    });
  });
}
```

- [ ] **Step 2: Run test — verify it fails**

```bash
flutter test test/domain/entities/social_entities_test.dart
```

Expected: compilation errors (types not yet defined).

- [ ] **Step 3: Create lib/domain/entities/share_preset.dart**

```dart
enum SharePreset { portrait, square, landscape }

extension SharePresetDimensions on SharePreset {
  double get aspectRatio => switch (this) {
    SharePreset.portrait  => 9 / 16,
    SharePreset.square    => 1.0,
    SharePreset.landscape => 16 / 9,
  };

  String get label => switch (this) {
    SharePreset.portrait  => '9:16',
    SharePreset.square    => '1:1',
    SharePreset.landscape => '16:9',
  };
}
```

- [ ] **Step 4: Create lib/domain/entities/social_template.dart**

```dart
import 'package:flutter/material.dart';

class SocialTemplate {
  final String id;
  final String namePtBr;
  final String nameEn;
  final String nameEs;
  final Color backgroundColor;
  final Color accentColor;
  final bool isFree;

  const SocialTemplate({
    required this.id,
    required this.namePtBr,
    required this.nameEn,
    required this.nameEs,
    required this.backgroundColor,
    required this.accentColor,
    this.isFree = true,
  });
}

const kSocialTemplates = [
  SocialTemplate(
    id: 'default',
    namePtBr: 'Apex Dark',
    nameEn: 'Apex Dark',
    nameEs: 'Apex Dark',
    backgroundColor: Color(0xFF080808),
    accentColor: Color(0xFF22C55E),
    isFree: true,
  ),
  SocialTemplate(
    id: 'cyber',
    namePtBr: 'Cyber Blue',
    nameEn: 'Cyber Blue',
    nameEs: 'Cyber Blue',
    backgroundColor: Color(0xFF050515),
    accentColor: Color(0xFF3B82F6),
    isFree: true,
  ),
  SocialTemplate(
    id: 'energy',
    namePtBr: 'Energy',
    nameEn: 'Energy',
    nameEs: 'Energy',
    backgroundColor: Color(0xFF0A0505),
    accentColor: Color(0xFFF97316),
    isFree: false,
  ),
];
```

- [ ] **Step 5: Create lib/domain/entities/social_card.dart**

```dart
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
```

- [ ] **Step 6: Run test — verify it passes**

```bash
flutter test test/domain/entities/social_entities_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 7: Run full analysis**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 8: Commit**

```bash
git add lib/domain/entities/social_card.dart lib/domain/entities/share_preset.dart lib/domain/entities/social_template.dart test/domain/entities/social_entities_test.dart
git commit -m "feat(social): add SocialCard, SharePreset and SocialTemplate entities"
```

---

### Task 3: AppStrings — social section

**Files:**
- Modify: `lib/core/i18n/app_strings.dart` (append before final `}`)
- Test: `test/core/i18n/app_strings_social_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/i18n/app_strings_social_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/i18n/app_strings.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';

void main() {
  final langs = AppLanguage.values;

  group('AppStrings — social section', () {
    for (final lang in langs) {
      group('lang=$lang', () {
        late AppStrings s;
        setUp(() => s = AppStrings(lang));

        test('socialStudioTitle is non-empty', () => expect(s.socialStudioTitle, isNotEmpty));
        test('socialStudioSubtitle is non-empty', () => expect(s.socialStudioSubtitle, isNotEmpty));
        test('socialStudioCaptionHint is non-empty', () => expect(s.socialStudioCaptionHint, isNotEmpty));
        test('socialStudioExport is non-empty', () => expect(s.socialStudioExport, isNotEmpty));
        test('socialStudioWatermark is non-empty', () => expect(s.socialStudioWatermark, isNotEmpty));
        test('socialStudioCreateCard is non-empty', () => expect(s.socialStudioCreateCard, isNotEmpty));
        test('socialPresetPortrait is non-empty', () => expect(s.socialPresetPortrait, isNotEmpty));
        test('socialPresetSquare is non-empty', () => expect(s.socialPresetSquare, isNotEmpty));
        test('socialPresetLandscape is non-empty', () => expect(s.socialPresetLandscape, isNotEmpty));
        test('privacyGuardTitle is non-empty', () => expect(s.privacyGuardTitle, isNotEmpty));
        test('privacyGuardBody is non-empty', () => expect(s.privacyGuardBody, isNotEmpty));
        test('privacyGuardNoAutoPost is non-empty', () => expect(s.privacyGuardNoAutoPost, isNotEmpty));
        test('privacyGuardConfirm is non-empty', () => expect(s.privacyGuardConfirm, isNotEmpty));
        test('privacyGuardCancel is non-empty', () => expect(s.privacyGuardCancel, isNotEmpty));

        test('socialStudioWatermark does not contain FPS', () {
          expect(s.socialStudioWatermark.toLowerCase(), isNot(contains('fps')));
        });
        test('socialStudioWatermark does not contain boost', () {
          expect(s.socialStudioWatermark.toLowerCase(), isNot(contains('boost real')));
        });
      });
    }
  });
}
```

- [ ] **Step 2: Run test — verify it fails**

```bash
flutter test test/core/i18n/app_strings_social_test.dart
```

Expected: compilation errors (`socialStudioTitle` not found on `AppStrings`).

- [ ] **Step 3: Add social strings to AppStrings**

In `lib/core/i18n/app_strings.dart`, insert the following block immediately before the final `}` (currently at line 2154):

```dart
  // ─── Social — Share Studio (SOCIAL-U1) ──────────────────────────────────────

  String get socialStudioTitle => 'Share Studio';

  String get socialStudioSubtitle => switch (lang) {
    AppLanguage.ptBr => 'Crie seu card gamer',
    AppLanguage.en   => 'Create your gamer card',
    AppLanguage.es   => 'Crea tu tarjeta gamer',
  };

  String get socialStudioCaption => switch (lang) {
    AppLanguage.ptBr => 'Legenda',
    AppLanguage.en   => 'Caption',
    AppLanguage.es   => 'Leyenda',
  };

  String get socialStudioCaptionHint => switch (lang) {
    AppLanguage.ptBr => 'Escreva sobre sua sessão...',
    AppLanguage.en   => 'Write about your session...',
    AppLanguage.es   => 'Escribe sobre tu sesión...',
  };

  String get socialStudioTemplate => switch (lang) {
    AppLanguage.ptBr => 'Tema',
    AppLanguage.en   => 'Theme',
    AppLanguage.es   => 'Tema',
  };

  String get socialStudioExport => switch (lang) {
    AppLanguage.ptBr => 'Exportar',
    AppLanguage.en   => 'Export',
    AppLanguage.es   => 'Exportar',
  };

  String get socialStudioPreview => switch (lang) {
    AppLanguage.ptBr => 'Prévia',
    AppLanguage.en   => 'Preview',
    AppLanguage.es   => 'Vista previa',
  };

  String get socialStudioWatermark => 'Prepared with Apex Booster+';

  String get socialStudioBadgeSection => switch (lang) {
    AppLanguage.ptBr => 'Badges',
    AppLanguage.en   => 'Badges',
    AppLanguage.es   => 'Insignias',
  };

  String get socialStudioNoBadge => switch (lang) {
    AppLanguage.ptBr => 'Sem badge',
    AppLanguage.en   => 'No badge',
    AppLanguage.es   => 'Sin insignia',
  };

  String get socialStudioCreateCard => switch (lang) {
    AppLanguage.ptBr => 'Criar card',
    AppLanguage.en   => 'Create card',
    AppLanguage.es   => 'Crear tarjeta',
  };

  // ─── Social — Export Presets ─────────────────────────────────────────────────

  String get socialPresetPortrait => switch (lang) {
    AppLanguage.ptBr => '9:16 · TikTok / Reels',
    AppLanguage.en   => '9:16 · TikTok / Reels',
    AppLanguage.es   => '9:16 · TikTok / Reels',
  };

  String get socialPresetSquare => switch (lang) {
    AppLanguage.ptBr => '1:1 · Feed',
    AppLanguage.en   => '1:1 · Feed',
    AppLanguage.es   => '1:1 · Feed',
  };

  String get socialPresetLandscape => switch (lang) {
    AppLanguage.ptBr => '16:9 · YouTube',
    AppLanguage.en   => '16:9 · YouTube',
    AppLanguage.es   => '16:9 · YouTube',
  };

  // ─── Social — Privacy Guard ──────────────────────────────────────────────────

  String get privacyGuardTitle => switch (lang) {
    AppLanguage.ptBr => 'Revisar antes de compartilhar',
    AppLanguage.en   => 'Review before sharing',
    AppLanguage.es   => 'Revisar antes de compartir',
  };

  String get privacyGuardBody => switch (lang) {
    AppLanguage.ptBr => 'Você revisa e escolhe onde compartilhar.',
    AppLanguage.en   => 'You review and choose where to share.',
    AppLanguage.es   => 'Revisas y eliges dónde compartir.',
  };

  String get privacyGuardNoAutoPost => switch (lang) {
    AppLanguage.ptBr => 'O Apex nunca posta por você.',
    AppLanguage.en   => 'Apex never posts for you.',
    AppLanguage.es   => 'Apex nunca publica por ti.',
  };

  String get privacyGuardConfirm => switch (lang) {
    AppLanguage.ptBr => 'Exportar',
    AppLanguage.en   => 'Export',
    AppLanguage.es   => 'Exportar',
  };

  String get privacyGuardCancel => switch (lang) {
    AppLanguage.ptBr => 'Cancelar',
    AppLanguage.en   => 'Cancel',
    AppLanguage.es   => 'Cancelar',
  };

  // ─── Social — Evolution Card (SOCIAL-U2) ────────────────────────────────────

  String get evolutionCardTitle => switch (lang) {
    AppLanguage.ptBr => 'Sua jornada no Apex',
    AppLanguage.en   => 'Your Apex Journey',
    AppLanguage.es   => 'Tu camino en Apex',
  };

  String get evolutionCardSessions => switch (lang) {
    AppLanguage.ptBr => 'sessões preparadas',
    AppLanguage.en   => 'sessions prepared',
    AppLanguage.es   => 'sesiones preparadas',
  };

  String get evolutionCardFavorite => switch (lang) {
    AppLanguage.ptBr => 'Jogo favorito',
    AppLanguage.en   => 'Favorite game',
    AppLanguage.es   => 'Juego favorito',
  };

  String get evolutionCardStreak => switch (lang) {
    AppLanguage.ptBr => 'sequência atual',
    AppLanguage.en   => 'current streak',
    AppLanguage.es   => 'racha actual',
  };

  String get evolutionCardShare => switch (lang) {
    AppLanguage.ptBr => 'Compartilhar evolução',
    AppLanguage.en   => 'Share evolution',
    AppLanguage.es   => 'Compartir evolución',
  };

  // ─── Social — Floating Capture Button (SOCIAL-U6) ───────────────────────────

  String get floatingCaptureEnable => switch (lang) {
    AppLanguage.ptBr => 'Ativar botão de captura',
    AppLanguage.en   => 'Enable capture button',
    AppLanguage.es   => 'Activar botón de captura',
  };

  String get floatingCaptureTitle => switch (lang) {
    AppLanguage.ptBr => 'Capturar momento',
    AppLanguage.en   => 'Capture moment',
    AppLanguage.es   => 'Capturar momento',
  };

  String get floatingCaptureClip => switch (lang) {
    AppLanguage.ptBr => 'Marcar clipe',
    AppLanguage.en   => 'Mark clip',
    AppLanguage.es   => 'Marcar clip',
  };

  String get floatingCaptureDisable => switch (lang) {
    AppLanguage.ptBr => 'Desativar botão',
    AppLanguage.en   => 'Disable button',
    AppLanguage.es   => 'Desactivar botón',
  };

  String get floatingCaptureOptInTitle => switch (lang) {
    AppLanguage.ptBr => 'Botão flutuante de captura',
    AppLanguage.en   => 'Floating capture button',
    AppLanguage.es   => 'Botón flotante de captura',
  };

  String get floatingCaptureOptInBody => switch (lang) {
    AppLanguage.ptBr =>
      'Este botão aparece sobre outros apps quando ativado. '
      'Você pode desativar a qualquer momento.',
    AppLanguage.en =>
      'This button appears over other apps when enabled. '
      'You can disable it at any time.',
    AppLanguage.es =>
      'Este botón aparece sobre otras apps cuando está activado. '
      'Puedes desactivarlo en cualquier momento.',
  };

  String get floatingCapturePermission => switch (lang) {
    AppLanguage.ptBr =>
      'Para mostrar o botão durante jogos, é preciso permissão de sobreposição.',
    AppLanguage.en =>
      'To show the button during games, overlay permission is required.',
    AppLanguage.es =>
      'Para mostrar el botón durante juegos, se requiere permiso de superposición.',
  };
```

- [ ] **Step 4: Run test — verify it passes**

```bash
flutter test test/core/i18n/app_strings_social_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Run full suite**

```bash
flutter analyze && flutter test
```

Expected: `No issues found!` and all tests pass.

- [ ] **Step 6: Run hardcoded strings checker (if present)**

```bash
dart run tool/check_hardcoded_strings.dart
```

- [ ] **Step 7: Commit**

```bash
git add lib/core/i18n/app_strings.dart test/core/i18n/app_strings_social_test.dart
git commit -m "feat(social): add social strings section to AppStrings (Share Studio, Privacy Guard, Evolution Card, Floating Button)"
```

---

### Task 4: ShareCardPortrait widget (9:16)

**Files:**
- Create: `lib/presentation/widgets/social/share_card_portrait.dart`
- Create: `test/presentation/widgets/social/share_card_portrait_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/widgets/social/share_card_portrait_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/social_card.dart';
import 'package:apex_booster_plus/domain/entities/share_preset.dart';
import 'package:apex_booster_plus/domain/entities/social_template.dart';
import 'package:apex_booster_plus/presentation/widgets/social/share_card_portrait.dart';

void main() {
  final template = kSocialTemplates.first;

  testWidgets('ShareCardPortrait renders game name', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Free Fire',
      createdAt: DateTime(2026, 6, 11),
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 270,
        height: 480,
        child: ShareCardPortrait(card: card, template: template),
      ),
    ));
    expect(find.text('Free Fire'), findsOneWidget);
  });

  testWidgets('ShareCardPortrait shows watermark by default', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Free Fire',
      createdAt: DateTime(2026, 6, 11),
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 270,
        height: 480,
        child: ShareCardPortrait(card: card, template: template),
      ),
    ));
    expect(find.text('Prepared with Apex Booster+'), findsOneWidget);
  });

  testWidgets('ShareCardPortrait hides watermark when includeWatermark=false', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Free Fire',
      createdAt: DateTime(2026, 6, 11),
      includeWatermark: false,
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 270,
        height: 480,
        child: ShareCardPortrait(card: card, template: template),
      ),
    ));
    expect(find.text('Prepared with Apex Booster+'), findsNothing);
  });

  testWidgets('ShareCardPortrait shows caption when non-empty', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Free Fire',
      createdAt: DateTime(2026, 6, 11),
      caption: 'Sessão preparada!',
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 270,
        height: 480,
        child: ShareCardPortrait(card: card, template: template),
      ),
    ));
    expect(find.text('Sessão preparada!'), findsOneWidget);
  });

  testWidgets('ShareCardPortrait does not overflow', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Um Jogo Com Nome Muito Longo Mesmo Para Testar Overflow De Layout',
      createdAt: DateTime(2026, 6, 11),
      caption: 'Uma legenda também bem longa para garantir que o layout não quebre.',
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 270,
        height: 480,
        child: ShareCardPortrait(card: card, template: template),
      ),
    ));
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run test — verify it fails**

```bash
flutter test test/presentation/widgets/social/share_card_portrait_test.dart
```

Expected: compilation error (`ShareCardPortrait` not found).

- [ ] **Step 3: Create lib/presentation/widgets/social/share_card_portrait.dart**

```dart
import 'package:flutter/material.dart';
import '../../../domain/entities/social_card.dart';
import '../../../domain/entities/share_preset.dart';
import '../../../domain/entities/social_template.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/i18n/app_language.dart';

class ShareCardPortrait extends StatelessWidget {
  final SocialCard card;
  final SocialTemplate template;
  final AppLanguage lang;

  const ShareCardPortrait({
    super.key,
    required this.card,
    required this.template,
    this.lang = AppLanguage.ptBr,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(lang);
    return AspectRatio(
      aspectRatio: SharePreset.portrait.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: template.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: template.accentColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  'APEX BOOSTER+',
                  style: TextStyle(
                    color: template.accentColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              card.gameName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (card.caption.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                card.caption,
                style: const TextStyle(
                  color: Color(0xFFA1A1AA),
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            if (card.includeWatermark)
              Text(
                s.socialStudioWatermark,
                style: TextStyle(
                  color: template.accentColor.withValues(alpha: 0.6),
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test — verify it passes**

```bash
flutter test test/presentation/widgets/social/share_card_portrait_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/social/share_card_portrait.dart test/presentation/widgets/social/share_card_portrait_test.dart
git commit -m "feat(social): add ShareCardPortrait widget (9:16)"
```

---

### Task 5: ShareCardSquare widget (1:1)

**Files:**
- Create: `lib/presentation/widgets/social/share_card_square.dart`
- Create: `test/presentation/widgets/social/share_card_square_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/widgets/social/share_card_square_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/social_card.dart';
import 'package:apex_booster_plus/domain/entities/share_preset.dart';
import 'package:apex_booster_plus/domain/entities/social_template.dart';
import 'package:apex_booster_plus/presentation/widgets/social/share_card_square.dart';

void main() {
  final template = kSocialTemplates.first;

  testWidgets('ShareCardSquare renders game name', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Call of Duty',
      createdAt: DateTime(2026, 6, 11),
      preset: SharePreset.square,
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 300,
        height: 300,
        child: ShareCardSquare(card: card, template: template),
      ),
    ));
    expect(find.text('Call of Duty'), findsOneWidget);
  });

  testWidgets('ShareCardSquare shows watermark', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Call of Duty',
      createdAt: DateTime(2026, 6, 11),
      preset: SharePreset.square,
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 300,
        height: 300,
        child: ShareCardSquare(card: card, template: template),
      ),
    ));
    expect(find.text('Prepared with Apex Booster+'), findsOneWidget);
  });

  testWidgets('ShareCardSquare does not overflow with long name', (tester) async {
    final card = SocialCard(
      id: 'test',
      gameId: 'g1',
      gameName: 'Um Nome De Jogo Muito Longo Para Testar O Layout Do Card',
      createdAt: DateTime(2026, 6, 11),
      caption: 'Legenda também comprida para garantir robustez visual.',
      preset: SharePreset.square,
    );
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: 300,
        height: 300,
        child: ShareCardSquare(card: card, template: template),
      ),
    ));
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run test — verify it fails**

```bash
flutter test test/presentation/widgets/social/share_card_square_test.dart
```

Expected: compilation error (`ShareCardSquare` not found).

- [ ] **Step 3: Create lib/presentation/widgets/social/share_card_square.dart**

```dart
import 'package:flutter/material.dart';
import '../../../domain/entities/social_card.dart';
import '../../../domain/entities/share_preset.dart';
import '../../../domain/entities/social_template.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/i18n/app_language.dart';

class ShareCardSquare extends StatelessWidget {
  final SocialCard card;
  final SocialTemplate template;
  final AppLanguage lang;

  const ShareCardSquare({
    super.key,
    required this.card,
    required this.template,
    this.lang = AppLanguage.ptBr,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(lang);
    return AspectRatio(
      aspectRatio: SharePreset.square.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: template.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: template.accentColor, size: 12),
                const SizedBox(width: 4),
                Text(
                  'APEX BOOSTER+',
                  style: TextStyle(
                    color: template.accentColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              card.gameName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (card.caption.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                card.caption,
                style: const TextStyle(
                  color: Color(0xFFA1A1AA),
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            if (card.includeWatermark)
              Text(
                s.socialStudioWatermark,
                style: TextStyle(
                  color: template.accentColor.withValues(alpha: 0.6),
                  fontSize: 8,
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test — verify it passes**

```bash
flutter test test/presentation/widgets/social/share_card_square_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/social/share_card_square.dart test/presentation/widgets/social/share_card_square_test.dart
git commit -m "feat(social): add ShareCardSquare widget (1:1)"
```

---

### Task 6: SocialTemplateSelector widget

**Files:**
- Create: `lib/presentation/widgets/social/social_template_selector.dart`
- Create: `test/presentation/widgets/social/social_template_selector_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/widgets/social/social_template_selector_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/domain/entities/social_template.dart';
import 'package:apex_booster_plus/presentation/widgets/social/social_template_selector.dart';

void main() {
  testWidgets('SocialTemplateSelector shows template names', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SocialTemplateSelector(
        templates: kSocialTemplates,
        selectedId: 'default',
        onSelected: (_) {},
        lang: AppLanguage.ptBr,
      ),
    ));
    expect(find.text('Apex Dark'), findsOneWidget);
    expect(find.text('Cyber Blue'), findsOneWidget);
  });

  testWidgets('SocialTemplateSelector calls onSelected when tapped', (tester) async {
    SocialTemplate? selected;
    await tester.pumpWidget(MaterialApp(
      home: SocialTemplateSelector(
        templates: kSocialTemplates,
        selectedId: 'default',
        onSelected: (t) => selected = t,
        lang: AppLanguage.ptBr,
      ),
    ));
    await tester.tap(find.text('Cyber Blue'));
    expect(selected?.id, 'cyber');
  });

  testWidgets('SocialTemplateSelector shows Premium chip for non-free template', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SocialTemplateSelector(
        templates: kSocialTemplates,
        selectedId: 'default',
        onSelected: (_) {},
        lang: AppLanguage.ptBr,
      ),
    ));
    expect(find.text('Premium'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test — verify it fails**

```bash
flutter test test/presentation/widgets/social/social_template_selector_test.dart
```

Expected: compilation error (`SocialTemplateSelector` not found).

- [ ] **Step 3: Create lib/presentation/widgets/social/social_template_selector.dart**

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_language.dart';
import '../../../domain/entities/social_template.dart';

class SocialTemplateSelector extends StatelessWidget {
  final List<SocialTemplate> templates;
  final String selectedId;
  final ValueChanged<SocialTemplate> onSelected;
  final AppLanguage lang;

  const SocialTemplateSelector({
    super.key,
    required this.templates,
    required this.selectedId,
    required this.onSelected,
    required this.lang,
  });

  String _nameFor(SocialTemplate t) => switch (lang) {
    AppLanguage.ptBr => t.namePtBr,
    AppLanguage.en   => t.nameEn,
    AppLanguage.es   => t.nameEs,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final t = templates[i];
          final isSelected = t.id == selectedId;
          return GestureDetector(
            onTap: () => onSelected(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? t.accentColor.withValues(alpha: 0.12)
                    : const Color(0xFF111111),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? t.accentColor : const Color(0xFF2A2A2A),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: t.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _nameFor(t),
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : AppColors.textGray,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (!t.isFree) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.energyOrange.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'Premium',
                        style: TextStyle(
                          color: AppColors.energyOrange,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Run test — verify it passes**

```bash
flutter test test/presentation/widgets/social/social_template_selector_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/social/social_template_selector.dart test/presentation/widgets/social/social_template_selector_test.dart
git commit -m "feat(social): add SocialTemplateSelector widget"
```

---

### Task 7: PrivacyGuardSheet

**Files:**
- Create: `lib/presentation/widgets/social/privacy_guard_sheet.dart`
- Create: `test/presentation/widgets/social/privacy_guard_sheet_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/widgets/social/privacy_guard_sheet_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/presentation/widgets/social/privacy_guard_sheet.dart';

void main() {
  testWidgets('PrivacyGuardSheet shows title and body', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => TextButton(
          onPressed: () => showPrivacyGuardSheet(ctx, AppLanguage.ptBr),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Revisar antes de compartilhar'), findsOneWidget);
    expect(find.text('Você revisa e escolhe onde compartilhar.'), findsOneWidget);
    expect(find.text('O Apex nunca posta por você.'), findsOneWidget);
  });

  testWidgets('PrivacyGuardSheet Cancel button returns false', (tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => TextButton(
          onPressed: () async {
            result = await showPrivacyGuardSheet(ctx, AppLanguage.ptBr);
          },
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(result, false);
  });

  testWidgets('PrivacyGuardSheet Confirm button returns true', (tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => TextButton(
          onPressed: () async {
            result = await showPrivacyGuardSheet(ctx, AppLanguage.ptBr);
          },
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exportar').last);
    await tester.pumpAndSettle();

    expect(result, true);
  });
}
```

- [ ] **Step 2: Run test — verify it fails**

```bash
flutter test test/presentation/widgets/social/privacy_guard_sheet_test.dart
```

Expected: compilation error (`showPrivacyGuardSheet` not found).

- [ ] **Step 3: Create lib/presentation/widgets/social/privacy_guard_sheet.dart**

```dart
import 'package:flutter/material.dart';
import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';

Future<bool> showPrivacyGuardSheet(
  BuildContext context,
  AppLanguage lang,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: const Color(0xFF111111),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _PrivacyGuardContent(lang: lang),
  );
  return result ?? false;
}

class _PrivacyGuardContent extends StatelessWidget {
  final AppLanguage lang;
  const _PrivacyGuardContent({required this.lang});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(lang);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.privacyGuardTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            s.privacyGuardBody,
            style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            s.privacyGuardNoAutoPost,
            style: const TextStyle(
              color: Color(0xFF22C55E),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFA1A1AA),
                    side: const BorderSide(color: Color(0xFF2A2A2A)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(s.privacyGuardCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    s.privacyGuardConfirm,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test — verify it passes**

```bash
flutter test test/presentation/widgets/social/privacy_guard_sheet_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/social/privacy_guard_sheet.dart test/presentation/widgets/social/privacy_guard_sheet_test.dart
git commit -m "feat(social): add PrivacyGuardSheet bottom sheet"
```

---

### Task 8: ShareStudioScreen

**Files:**
- Create: `lib/presentation/screens/share_studio/share_studio_screen.dart`
- Create: `test/presentation/screens/share_studio/share_studio_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/presentation/screens/share_studio/share_studio_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apex_booster_plus/core/i18n/app_language.dart';
import 'package:apex_booster_plus/presentation/screens/share_studio/share_studio_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ShareStudioScreen shows title', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ShareStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Share Studio'), findsOneWidget);
  });

  testWidgets('ShareStudioScreen shows export button', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ShareStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Exportar'), findsOneWidget);
  });

  testWidgets('ShareStudioScreen shows caption hint', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ShareStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Escreva sobre sua sessão...'), findsOneWidget);
  });

  testWidgets('ShareStudioScreen shows preset chips', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ShareStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('9:16'), findsOneWidget);
    expect(find.text('1:1'), findsOneWidget);
  });

  testWidgets('ShareStudioScreen shows template selector', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ShareStudioScreen(gameId: 'test-game'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Apex Dark'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test — verify it fails**

```bash
flutter test test/presentation/screens/share_studio/share_studio_screen_test.dart
```

Expected: compilation error (`ShareStudioScreen` not found).

- [ ] **Step 3: Create lib/presentation/screens/share_studio/share_studio_screen.dart**

```dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../data/repositories/shared_preferences_game_library_repository.dart';
import '../../../domain/entities/share_preset.dart';
import '../../../domain/entities/social_card.dart';
import '../../../domain/entities/social_template.dart';
import '../../../domain/repositories/game_library_repository.dart';
import '../../widgets/social/privacy_guard_sheet.dart';
import '../../widgets/social/share_card_portrait.dart';
import '../../widgets/social/share_card_square.dart';
import '../../widgets/social/social_template_selector.dart';

class ShareStudioScreen extends StatefulWidget {
  final String gameId;
  const ShareStudioScreen({super.key, required this.gameId});

  @override
  State<ShareStudioScreen> createState() => _ShareStudioScreenState();
}

class _ShareStudioScreenState extends State<ShareStudioScreen> {
  final _exportKey = GlobalKey();
  final _captionController = TextEditingController();
  late SocialCard _card;
  String _selectedTemplateId = 'default';
  bool _exporting = false;
  bool _loaded = false;
  AppLanguage _lang = AppLanguage.ptBr;

  final GameLibraryRepository _library =
      SharedPreferencesGameLibraryRepository();

  @override
  void initState() {
    super.initState();
    _lang = languageNotifier.value;
    _loadGame();
  }

  Future<void> _loadGame() async {
    final games = await _library.getGames();
    final game = games.where((g) => g.id == widget.gameId).firstOrNull;
    if (!mounted) return;
    setState(() {
      _card = SocialCard(
        id: '${widget.gameId}_${DateTime.now().millisecondsSinceEpoch}',
        gameId: widget.gameId,
        gameName: game?.name ?? widget.gameId,
        templateId: _selectedTemplateId,
        createdAt: DateTime.now(),
      );
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  SocialTemplate get _activeTemplate =>
      kSocialTemplates.firstWhere((t) => t.id == _selectedTemplateId);

  void _onTemplateSelected(SocialTemplate t) {
    setState(() {
      _selectedTemplateId = t.id;
      _card = _card.copyWith(templateId: t.id);
    });
  }

  void _onPresetChanged(SharePreset p) =>
      setState(() => _card = _card.copyWith(preset: p));

  Future<void> _export() async {
    final confirmed = await showPrivacyGuardSheet(context, _lang);
    if (!confirmed || !mounted) return;

    setState(() => _exporting = true);
    try {
      final boundary = _exportKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/apex_card_${_card.id}.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)], text: _card.caption);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(_lang);
    if (!_loaded) {
      return Scaffold(
        backgroundColor: const Color(0xFF050505),
        appBar: _buildAppBar(s),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: _buildAppBar(s),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: RepaintBoundary(
                  key: _exportKey,
                  child: _card.preset == SharePreset.portrait
                      ? ShareCardPortrait(
                          card: _card,
                          template: _activeTemplate,
                          lang: _lang,
                        )
                      : ShareCardSquare(
                          card: _card,
                          template: _activeTemplate,
                          lang: _lang,
                        ),
                ),
              ),
            ),
          ),
          SocialTemplateSelector(
            templates: kSocialTemplates,
            selectedId: _selectedTemplateId,
            onSelected: _onTemplateSelected,
            lang: _lang,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: SharePreset.values
                  .where((p) => p != SharePreset.landscape)
                  .map((p) => Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(p.label),
                            selected: _card.preset == p,
                            onSelected: (_) => _onPresetChanged(p),
                            selectedColor: AppColors.apexGreen
                                .withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: _card.preset == p
                                  ? AppColors.apexGreen
                                  : AppColors.textGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: const Color(0xFF111111),
                            side: BorderSide(
                              color: _card.preset == p
                                  ? AppColors.apexGreen
                                      .withValues(alpha: 0.4)
                                  : const Color(0xFF2A2A2A),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _captionController,
              onChanged: (v) =>
                  setState(() => _card = _card.copyWith(caption: v)),
              maxLength: 120,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: s.socialStudioCaptionHint,
                hintStyle: const TextStyle(
                    color: Color(0xFF555555), fontSize: 14),
                counterStyle: const TextStyle(
                    color: Color(0xFF555555), fontSize: 11),
                filled: true,
                fillColor: const Color(0xFF111111),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFF2A2A2A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFF2A2A2A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFF22C55E)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _exporting ? null : _export,
                icon: _exporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.share_rounded, size: 18),
                label: Text(
                  s.socialStudioExport,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.apexGreen,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(AppStrings s) => AppBar(
        backgroundColor: const Color(0xFF050505),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          s.socialStudioTitle,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17),
        ),
        centerTitle: true,
        elevation: 0,
      );
}
```

- [ ] **Step 4: Run test — verify it passes**

```bash
flutter test test/presentation/screens/share_studio/share_studio_screen_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Run full suite**

```bash
flutter analyze && flutter test
```

Expected: no issues, all tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/screens/share_studio/share_studio_screen.dart test/presentation/screens/share_studio/share_studio_screen_test.dart
git commit -m "feat(social): add ShareStudioScreen with card editor and export flow"
```

---

### Task 9: Route + entry point in GameDetailScreen

**Files:**
- Modify: `lib/core/routing/app_router.dart`
- Modify: `lib/presentation/screens/game_detail/game_detail_screen.dart`
- Test: `test/core/routing/app_router_social_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/routing/app_router_social_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:apex_booster_plus/core/routing/app_router.dart';

void main() {
  test('appRouter contains /share-studio/:gameId route', () {
    final routes = appRouter.configuration.routes;
    bool found = false;
    void visit(List<RouteBase> list) {
      for (final r in list) {
        if (r is GoRoute && r.path == '/share-studio/:gameId') {
          found = true;
        }
        visit(r.routes);
      }
    }
    visit(routes);
    expect(found, true);
  });
}
```

- [ ] **Step 2: Run test — verify it fails**

```bash
flutter test test/core/routing/app_router_social_test.dart
```

Expected: FAIL — route not found.

- [ ] **Step 3: Add route to app_router.dart**

In `lib/core/routing/app_router.dart`, add the import and route:

After the existing imports, add:
```dart
import '../../presentation/screens/share_studio/share_studio_screen.dart';
```

Inside the `routes: [...]` list, after the `/honest-booster-mode` route, add:
```dart
    GoRoute(
      path: '/share-studio/:gameId',
      builder: (context, state) => ShareStudioScreen(
        gameId: state.pathParameters['gameId'] ?? '',
      ),
    ),
```

- [ ] **Step 4: Run test — verify it passes**

```bash
flutter test test/core/routing/app_router_social_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Add _CreateCardButton to GameDetailScreen**

In `lib/presentation/screens/game_detail/game_detail_screen.dart`, find the block at line ~352:

```dart
              if (!_loading && _game != null)
                _LaunchGameButton(
                  hasPackage: _game!.packageName?.isNotEmpty == true,
                  onTap: _launchGame,
                ),
```

Change it to:

```dart
              if (!_loading && _game != null)
                _LaunchGameButton(
                  hasPackage: _game!.packageName?.isNotEmpty == true,
                  onTap: _launchGame,
                ),
              if (!_loading && _game != null)
                _CreateCardButton(gameId: widget.gameId),
```

Then add the `_CreateCardButton` class at the end of the file (before the `// ─── Prep launch sheet` comment at line ~1164), right after the closing `}` of `_LaunchGameButton`:

```dart
// ─── Create card button (Share Studio entry point) ───────────────────────────

class _CreateCardButton extends StatelessWidget {
  final String gameId;
  const _CreateCardButton({required this.gameId});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => context.push('/share-studio/$gameId'),
          icon: const Icon(Icons.share_outlined, size: 17),
          label: Text(s.socialStudioCreateCard),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.apexGreen,
            side: BorderSide(
                color: AppColors.apexGreen.withValues(alpha: 0.35)),
            padding: const EdgeInsets.symmetric(vertical: 11),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Run full suite**

```bash
flutter analyze && flutter test
```

Expected: `No issues found!` and all tests pass.

- [ ] **Step 7: Run hardcoded strings checker**

```bash
dart run tool/check_hardcoded_strings.dart
```

- [ ] **Step 8: Manual visual check — run on device or emulator**

```bash
flutter run
```

Navigate: GameDetail → tap "Criar card" → ShareStudioScreen opens → change template → change preset → type caption → tap "Exportar" → PrivacyGuardSheet appears → tap "Exportar" → share sheet opens.

Verify: no overflow, no `FPS`/`ping`/`boost real` text anywhere, watermark visible.

- [ ] **Step 9: Commit**

```bash
git add lib/core/routing/app_router.dart lib/presentation/screens/game_detail/game_detail_screen.dart test/core/routing/app_router_social_test.dart
git commit -m "feat(social): add Share Studio route and entry point in GameDetailScreen"
```

---

## Self-review checklist

**Spec coverage:**

| Requirement (from SOCIAL-U0 spec) | Covered by task |
|---|---|
| SocialCard entity with copyWith | Task 2 |
| SharePreset with aspect ratios | Task 2 |
| SocialTemplate with kSocialTemplates catalog | Task 2 |
| Social strings PT-BR / EN / ES | Task 3 |
| ShareCardPortrait (9:16) | Task 4 |
| ShareCardSquare (1:1) | Task 5 |
| SocialTemplateSelector with Premium chip | Task 6 |
| PrivacyGuardSheet before every export | Task 7 |
| ShareStudioScreen editor | Task 8 |
| Export via RepaintBoundary + share_plus | Task 8 |
| Route /share-studio/:gameId | Task 9 |
| Entry point from GameDetailScreen | Task 9 |
| No FPS/ping/boost copy | Enforced by AppStrings test (Task 3) |
| No new Android permissions | share_plus + temp dir needs none |

**Not in SOCIAL-U1 (deferred):**
- Landscape 16:9 preset → SOCIAL-U4
- Evolution Card → SOCIAL-U2
- Gallery import → SOCIAL-U3
- Full Privacy Guard persistence → SOCIAL-U5
- Floating Capture Button → SOCIAL-U6
- Short Clip Capture → SOCIAL-U7

**Next plan:** `docs/superpowers/plans/SOCIAL-U2-evolution-card.md` (to be written before SOCIAL-U2 execution).
