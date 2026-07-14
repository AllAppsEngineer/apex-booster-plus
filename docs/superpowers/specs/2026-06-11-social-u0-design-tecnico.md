# SOCIAL-U0 — Apex Social Capture & Share Layer: Design Técnico

**Data:** 2026-06-11  
**Fase:** SOCIAL-U0 (apenas documentação — nenhum código Dart alterado)  
**Dependências:** PREMIUM-U2 concluído, CLAUDE.md modularizado, docs/claude/social.md oficial  
**Status:** Design aprovado — aguarda execução de SOCIAL-U1

---

## Objetivo

Definir arquitetura completa, mapa de arquivos, modelos de dados, strings e restrições da **Apex Social Capture & Share Layer** antes de qualquer implementação. Este documento orienta todas as fases SOCIAL-U1 a SOCIAL-U7 e garante coerência entre entidades, serviços e experiência do usuário.

---

## Posicionamento do produto

A camada social é uma ferramenta de **expressão gamer, evolução pessoal e compartilhamento social**. Não é boost de performance. Não afirma FPS, ping, CPU, GPU ou vantagem competitiva real.

> Regra soberana: o APEX BOOSTER+ pode ajudar o usuário a registrar e compartilhar sua jornada gamer, mas nunca pode capturar, gravar, publicar, expor ou inferir dados sem ação explícita e consentimento claro do usuário.

---

## Fases e componentes

| Fase | Componente | Objetivo | Prioridade |
|---|---|---|---|
| SOCIAL-U1 | Apex Share Studio | Editor de card com tema, legenda, badge e exportação local | Alta |
| SOCIAL-U2 | Apex Evolution Card | Cards com sessões, jogos favoritos, badges e streaks locais | Alta |
| SOCIAL-U3 | Importação da galeria | Seleção de screenshot/clipe pelo usuário | Média |
| SOCIAL-U4 | Social Export Presets | Formatos 9:16, 1:1 e 16:9 com qualidade controlada | Média |
| SOCIAL-U5 | Privacy Guard completo | Telas de consentimento persistente e revisão por sessão | Média |
| SOCIAL-U6 | Apex Floating Capture Button | Botão flutuante opt-in, reposicionável, leve | Baixa |
| SOCIAL-U7 | Short Clip Capture | Captura assistida de clipe curto (se viável na loja) | Baixa |

> SOCIAL-U1 é a única fase executável sem novas permissões. Todas as fases seguintes devem ser aprovadas individualmente.

---

## Mapa completo de arquivos — camada social

### Domain — entidades

| Arquivo | Responsabilidade |
|---|---|
| `lib/domain/entities/social_card.dart` | Modelo de card: jogo, sessão, badge, legenda, template, preset |
| `lib/domain/entities/share_preset.dart` | Enum `SharePreset` + extensão com `aspectRatio` e `label` |
| `lib/domain/entities/social_template.dart` | Modelo de template visual + catálogo `kSocialTemplates` |

### Domain — serviços abstratos

| Arquivo | Responsabilidade |
|---|---|
| `lib/domain/services/social_card_service.dart` | Constrói `SocialCard` a partir de `ApexGame` + `SessionRecord` |
| `lib/domain/services/privacy_consent_service.dart` | Gerencia estado de consentimento social (opt-ins) |

> `SocialExportService` é omitido em SOCIAL-U1 por YAGNI — a lógica de exportação vive diretamente no `ShareStudioScreen` com `GlobalKey + RepaintBoundary`. Extrair para serviço em SOCIAL-U4 se necessário.

### Data — implementações

| Arquivo | Responsabilidade |
|---|---|
| `lib/data/services/social_card_service_impl.dart` | Impl de `SocialCardService` com dados locais existentes |
| `lib/data/services/privacy_consent_service_impl.dart` | Persiste consentimentos em `shared_preferences` |

### Presentation — telas

| Arquivo | Responsabilidade | Fase |
|---|---|---|
| `lib/presentation/screens/share_studio/share_studio_screen.dart` | Editor de card: template, legenda, preset, preview, exportação | SOCIAL-U1 |
| `lib/presentation/screens/evolution_card/evolution_card_screen.dart` | Card de evolução: sessões, jogo favorito, streaks | SOCIAL-U2 |
| `lib/presentation/screens/privacy_guard/privacy_guard_screen.dart` | Tela de consentimento persistente e revisão | SOCIAL-U5 |

### Presentation — widgets

| Arquivo | Responsabilidade | Fase |
|---|---|---|
| `lib/presentation/widgets/social/share_card_portrait.dart` | Render de card 9:16 (TikTok/Reels) | SOCIAL-U1 |
| `lib/presentation/widgets/social/share_card_square.dart` | Render de card 1:1 (feed geral) | SOCIAL-U1 |
| `lib/presentation/widgets/social/privacy_guard_sheet.dart` | Bottom sheet de revisão antes de exportar | SOCIAL-U1 |
| `lib/presentation/widgets/social/share_card_landscape.dart` | Render de card 16:9 (YouTube/community) | SOCIAL-U4 |
| `lib/presentation/widgets/social/social_template_selector.dart` | Seletor horizontal de templates no editor | SOCIAL-U1 |
| `lib/presentation/widgets/social/floating_capture_button.dart` | Botão flutuante opt-in reposicionável | SOCIAL-U6 |

### Routing e strings

| Arquivo | Mudança | Fase |
|---|---|---|
| `lib/core/routing/app_router.dart` | +`/share-studio/:gameId` e `/evolution-card` | SOCIAL-U1/U2 |
| `lib/core/i18n/app_strings.dart` | +seção Social: Share Studio, Privacy Guard, Evolution Card, Floating Button | SOCIAL-U1 |

### Arquivos modificados em telas existentes

| Arquivo | Mudança | Fase |
|---|---|---|
| `lib/presentation/screens/game_detail/game_detail_screen.dart` | +botão "Criar card" como CTA secundário | SOCIAL-U1 |
| `lib/presentation/screens/configuracoes/configuracoes_tab.dart` | +toggle opt-in do Floating Capture Button | SOCIAL-U6 |

---

## Modelo de dados — `SocialCard`

```dart
class SocialCard {
  final String id;
  final String gameId;
  final String gameName;
  final String? gameIconPath;       // caminho local do ícone do app
  final String? sessionId;          // null = card manual sem sessão associada
  final DateTime createdAt;
  final String caption;             // legenda editada pelo usuário (max 120 chars)
  final String templateId;          // referência a SocialTemplate.id
  final SharePreset preset;
  final List<String> badgeKeys;     // ex: ['5_sessions', 'streak_3']
  final bool includeWatermark;
  final String? importedMediaPath;  // apenas SOCIAL-U3+
}
```

**Regras de negócio:**
- `caption` max 120 caracteres — validado na UI, não é erro fatal se ultrapassar.
- `badgeKeys` são somente chaves locais — nunca FPS/ping/boost.
- `importedMediaPath` fica `null` em SOCIAL-U1 e U2.
- `includeWatermark` = `true` por padrão; configurável apenas com one-time unlock (lock inativo até BILL-U1).

---

## Modelo de dados — `SharePreset`

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

---

## Modelo de dados — `SocialTemplate`

```dart
class SocialTemplate {
  final String id;
  final String namePtBr;
  final String nameEn;
  final String nameEs;
  final Color backgroundColor;
  final Color accentColor;
  final bool isFree;
}

const kSocialTemplates = [
  SocialTemplate(
    id: 'default',
    namePtBr: 'Apex Dark',
    nameEn: 'Apex Dark',
    nameEs: 'Apex Dark',
    backgroundColor: Color(0xFF080808),
    accentColor: Color(0xFF22C55E),   // Verde Apex
    isFree: true,
  ),
  SocialTemplate(
    id: 'cyber',
    namePtBr: 'Cyber Blue',
    nameEn: 'Cyber Blue',
    nameEs: 'Cyber Blue',
    backgroundColor: Color(0xFF050515),
    accentColor: Color(0xFF3B82F6),   // Azul Cyber
    isFree: true,
  ),
  SocialTemplate(
    id: 'energy',
    namePtBr: 'Energy',
    nameEn: 'Energy',
    nameEs: 'Energy',
    backgroundColor: Color(0xFF0A0505),
    accentColor: Color(0xFFF97316),   // Laranja energia
    isFree: false, // one-time unlock — lock inativo até BILL-U1
  ),
];
```

---

## Fluxo de exportação — sem permissão extra (Android 10+)

```
ShareStudioScreen
  → usuário edita card (template + legenda + preset + badge)
  → toca "Exportar"
  → PrivacyGuardSheet confirma: "Você revisa. Apex nunca posta por você."
  → [Continuar] → RepaintBoundary.toImage(pixelRatio: 3.0)
  → bytes gravados em getTemporaryDirectory()
  → share_plus.Share.shareXFiles([XFile(path)], text: caption)
  → Android share sheet nativa → usuário escolhe destino
```

**Implementação de captura no ShareStudioScreen:**

```dart
final GlobalKey _exportKey = GlobalKey();

Future<void> _exportCard(SocialCard card) async {
  final boundary = _exportKey.currentContext
      ?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return;

  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return;

  final bytes = byteData.buffer.asUint8List();
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/apex_card_${card.id}.png');
  await file.writeAsBytes(bytes);

  await Share.shareXFiles([XFile(file.path)], text: card.caption);
}
```

O widget de preview fica envolto em `RepaintBoundary(key: _exportKey, child: ...)`.

---

## Estratégia de permissões por fase

| Fase | Ação que requer permissão | Permissão Android | Quando solicitar |
|---|---|---|---|
| SOCIAL-U1 | Exportar card como imagem | Nenhuma (temp dir + share sheet) | — |
| SOCIAL-U3 | Selecionar imagem da galeria | `READ_MEDIA_IMAGES` (Android 13+) | No momento da seleção, via picker do sistema |
| SOCIAL-U6 | Mostrar botão durante jogos | `SYSTEM_ALERT_WINDOW` | Apenas quando o usuário ativar opt-in |
| SOCIAL-U7 | Gravar tela | `MediaProjection` / `RECORD_AUDIO` opt-in | Apenas no início da gravação opt-in |

> SOCIAL-U1 não exige nenhuma nova permissão no `AndroidManifest.xml`.

---

## Dependências novas — avaliação completa

| Pacote | Versão sugerida | Necessidade | Risco | Fase |
|---|---|---|---|---|
| `share_plus` | `^10.1.4` | Exportar imagem via share sheet nativa | Baixo — padrão Flutter, sem permissão extra | SOCIAL-U1 |
| `path_provider` | `^2.1.5` | Diretório temporário para arquivo de imagem | Mínimo — amplamente usado | SOCIAL-U1 |
| `image_picker` | `^1.1.2` | Selecionar imagem da galeria pelo sistema | Baixo com picker do sistema | SOCIAL-U3 (separado) |
| `permission_handler` | `^11.3.0` | Gerenciar permissão SYSTEM_ALERT_WINDOW | Médio — impacto de build | SOCIAL-U6 (separado) |

> `share_plus` e `path_provider` são as únicas adições para SOCIAL-U1. Ambas devem ser aprovadas explicitamente antes de modificar `pubspec.yaml`.

---

## Strings sociais obrigatórias — mapa completo

Todas as chaves abaixo devem existir em PT-BR, EN e ES no `app_strings.dart`. Nenhuma string pode prometer FPS, ping, GPU, CPU ou boost técnico real.

### Share Studio

| Chave | PT-BR | EN | ES |
|---|---|---|---|
| `socialStudioTitle` | "Share Studio" | "Share Studio" | "Share Studio" |
| `socialStudioSubtitle` | "Crie seu card gamer" | "Create your gamer card" | "Crea tu tarjeta gamer" |
| `socialStudioCaption` | "Legenda" | "Caption" | "Leyenda" |
| `socialStudioCaptionHint` | "Escreva sobre sua sessão..." | "Write about your session..." | "Escribe sobre tu sesión..." |
| `socialStudioTemplate` | "Tema" | "Theme" | "Tema" |
| `socialStudioExport` | "Exportar" | "Export" | "Exportar" |
| `socialStudioPreview` | "Prévia" | "Preview" | "Vista previa" |
| `socialStudioWatermark` | "Prepared with Apex Booster+" | "Prepared with Apex Booster+" | "Prepared with Apex Booster+" |
| `socialStudioBadgeSection` | "Badges" | "Badges" | "Insignias" |
| `socialStudioNoBadge` | "Sem badge" | "No badge" | "Sin insignia" |
| `socialStudioCreateCard` | "Criar card" | "Create card" | "Crear tarjeta" |

### Presets

| Chave | PT-BR | EN | ES |
|---|---|---|---|
| `socialPresetPortrait` | "9:16 · TikTok / Reels" | "9:16 · TikTok / Reels" | "9:16 · TikTok / Reels" |
| `socialPresetSquare` | "1:1 · Feed" | "1:1 · Feed" | "1:1 · Feed" |
| `socialPresetLandscape` | "16:9 · YouTube" | "16:9 · YouTube" | "16:9 · YouTube" |

### Privacy Guard

| Chave | PT-BR | EN | ES |
|---|---|---|---|
| `privacyGuardTitle` | "Revisar antes de compartilhar" | "Review before sharing" | "Revisar antes de compartir" |
| `privacyGuardBody` | "Você revisa e escolhe onde compartilhar." | "You review and choose where to share." | "Revisas y eliges dónde compartir." |
| `privacyGuardNoAutoPost` | "O Apex nunca posta por você." | "Apex never posts for you." | "Apex nunca publica por ti." |
| `privacyGuardConfirm` | "Exportar" | "Export" | "Exportar" |
| `privacyGuardCancel` | "Cancelar" | "Cancel" | "Cancelar" |

### Evolution Card

| Chave | PT-BR | EN | ES |
|---|---|---|---|
| `evolutionCardTitle` | "Sua jornada no Apex" | "Your Apex Journey" | "Tu camino en Apex" |
| `evolutionCardSessions` | "sessões preparadas" | "sessions prepared" | "sesiones preparadas" |
| `evolutionCardFavorite` | "Jogo favorito" | "Favorite game" | "Juego favorito" |
| `evolutionCardStreak` | "sequência atual" | "current streak" | "racha actual" |
| `evolutionCardShare` | "Compartilhar evolução" | "Share evolution" | "Compartir evolución" |

### Floating Capture Button

| Chave | PT-BR | EN | ES |
|---|---|---|---|
| `floatingCaptureEnable` | "Ativar botão de captura" | "Enable capture button" | "Activar botón de captura" |
| `floatingCaptureTitle` | "Capturar momento" | "Capture moment" | "Capturar momento" |
| `floatingCaptureClip` | "Marcar clipe" | "Mark clip" | "Marcar clip" |
| `floatingCaptureDisable` | "Desativar botão" | "Disable button" | "Desactivar botón" |
| `floatingCaptureOptInTitle` | "Botão flutuante de captura" | "Floating capture button" | "Botón flotante de captura" |
| `floatingCaptureOptInBody` | "Este botão aparece sobre outros apps quando ativado. Você pode desativar a qualquer momento." | "This button appears over other apps when enabled. You can disable it at any time." | "Este botón aparece sobre otras apps cuando está activado. Puedes desactivarlo en cualquier momento." |
| `floatingCapturePermission` | "Para mostrar o botão durante jogos, é preciso permissão de sobreposição." | "To show the button during games, overlay permission is required." | "Para mostrar el botón durante juegos, se requiere permiso de superposición." |

---

## Estratégia free install vs. one-time unlock

> Billing não implementado até BILL-U1. Em SOCIAL-U1, o lock é visual/inativo — templates `isFree: false` aparecem com chip "Premium" mas são acessíveis. O bloqueio real só ativa quando BILL-U1 for aprovado.

| Função social | Free install | One-time unlock |
|---|---|---|
| Card básico (templates `isFree: true`) | ✓ | — |
| Preset 9:16 e 1:1 | ✓ | — |
| Preset 16:9 | Lock visual inativo | ✓ quando BILL-U1 |
| Template `isFree: false` (Energy) | Prévia com chip "Premium" | ✓ completo |
| Evolution Card básico | ✓ | — |
| Evolution Card com streaks e badges | Lock visual inativo | ✓ quando BILL-U1 |
| Watermark configurável | — | ✓ quando BILL-U1 |
| Floating Capture Button | Opt-in limitado | Completo |
| Privacy Guard | ✓ sempre | ✓ sempre |

---

## Separação de dados reais vs. placebo nos cards sociais

| Dado | Natureza | Permitido em card social? |
|---|---|---|
| Nome do jogo | Real | ✓ |
| Data da sessão | Real | ✓ |
| Tempo de preparação (SessionRecord) | Real | ✓ |
| GFX Profile usado | Preferência local | ✓ com contexto "perfil local" |
| Número de sessões (contador local) | Real | ✓ |
| Badge de sequência (streak local) | Simbólico local | ✓ com contexto claro |
| Latência Apex (medição própria) | Medição real local | ✓ com label explícito |
| FPS suposto | Falso | ✗ sempre |
| Ping reduzido | Falso | ✗ sempre |
| RAM limpa | Falso | ✗ sempre |
| "Boost aplicado" | Falso | ✗ sempre |
| Rank não autorizado | Falso | ✗ sempre |

---

## Critérios de rejeição automática — camada social

| Critério | Motivo |
|---|---|
| Captura sem ação do usuário | Viola privacidade e confiança |
| Postagem automática em qualquer rede | Retira controle do usuário |
| FPS/ping/boost inventados no card | Viola honestidade técnica |
| Coleta de notificações, conversas ou lista de apps | Exposição sensível desnecessária |
| Overlay ativo por padrão (sem opt-in) | Viola regra SOCIAL-U6 |
| Plugin nativo sem aprovação explícita | Aumenta risco de build e loja |
| Watermark com "boost real" ou "FPS" | Sugestão técnica falsa |
| Commit automático | Regra inviolável CLAUDE.md §5.12 |

---

## Critérios de aceitação da fase SOCIAL-U0

- [x] Spec criado em `docs/superpowers/specs/2026-06-11-social-u0-design-tecnico.md`
- [x] Plano SOCIAL-U1 criado em `docs/superpowers/plans/2026-06-11-social-u1-share-studio.md`
- [ ] Nenhum arquivo Dart foi alterado nesta fase
- [ ] Working tree limpo após entrega (somente docs novos)
- [ ] Nenhum commit automático realizado
