# SOCIAL-U2A — Apex Floating Button + Mini-Overlay
**Data:** 2026-06-11  
**Fase:** SOCIAL-U2A  
**Status:** Spec aprovado — aguardando implementação  
**Fase seguinte:** SOCIAL-U2B (MediaProjection + ForegroundService + captura real de tela)  
**Aparelho de validação principal:** Samsung S24 Ultra · One UI 8.5 · Android 16 (API 36) — apenas dispositivo físico de teste; a implementação deve funcionar em Android geral.

---

## 1. Objetivo

Implementar o **Apex Floating Button** como ponto de acesso rápido ao Apex Studio durante uma sessão gamer. O botão flutua sobre outros apps (após opt-in), exibe um mini-overlay com duas ações ao ser tocado, e integra diretamente com o Apex Studio para composição de cards sociais.

**O que SOCIAL-U2A entrega:**
- Botão flutuante discreto, ativado somente por escolha do usuário.
- Fluxo de consentimento antes de pedir `SYSTEM_ALERT_WINDOW`.
- Mini-overlay com "Adicionar print ou vídeo" e "Voltar ao Apex Studio".
- Integração: mídia selecionada vai direto para o Apex Studio com pré-carga.
- Toggle de desativação em Configurações.

**O que SOCIAL-U2A NÃO entrega (reservado para SOCIAL-U2B):**
- Captura real de tela de outros apps (requer `MediaProjection` + `ForegroundService`).
- Gravação de vídeo curto (`MediaRecorder`).
- `ForegroundService` próprio.

> **Regra soberana:** nenhuma captura automática. Nenhum compartilhamento automático. O botão flutuante é um atalho de expressão gamer, não um gravador silencioso.

---

## 2. Arquitetura

### 2.1 Diagrama de componentes

```
┌──────────────── Main App Flutter Engine ──────────────────────┐
│                                                                │
│  configuracoes_tab.dart                                        │
│    └─ _FloatingCaptureCard                                     │
│         ├─ toggle on  → CaptureConsentSheet                   │
│         │    └─ "Ativar" → requestPermission()                 │
│         │         → granted → FloatingCaptureService.show()   │
│         │         → denied  → snackbar + fallback hint        │
│         └─ toggle off → FloatingCaptureService.disable()      │
│                                                                │
│  FloatingCaptureService (singleton)                            │
│    - isEnabled() / enable() / disable()                        │
│    - isPermissionGranted() / requestPermission()               │
│    - handleMessage(data) → galeria ou studio                   │
│    - SharedPreferences key: 'capture_float_enabled'            │
│                                                                │
│  ApexStudioScreen                                              │
│    - novo parâmetro: initialMediaPath (via GoRouter extra)     │
│    - se fornecido: pré-carrega mídia no initState              │
│                                                                │
│  app_router.dart                                               │
│    /share-studio/:gameId aceita GoRouterState.extra: String?   │
└────────────────────────────────────────────────────┬──────────┘
                FlutterOverlayWindow.shareData        │
                FlutterOverlayWindow.overlayListener  │
                                                      ▼
┌──────────────── Overlay Flutter Engine ───────────────────────┐
│  Entry point: overlayMain() em lib/main.dart                   │
│                                                                │
│  ApexFloatingButton                                            │
│    estado collapsed: bolt circle, 60×60, verde Apex, direita  │
│    estado expanded: dark card com duas ações:                  │
│      ◾ "Adicionar print ou vídeo"  → envia 'open_gallery'     │
│      ◾ "Voltar ao Apex Studio"     → envia 'open_studio'      │
│    draggable: enableDrag: true                                 │
│    collapse automático: 5s sem interação                       │
└───────────────────────────────────────────────────────────────┘
```

### 2.2 Fluxo de mensagens

| Mensagem (overlay → main) | Ação no main app |
|---|---|
| `'open_gallery'` | Main app é trazido ao primeiro plano → exibe sheet de seleção (imagem **ou** vídeo, reutilizando `_showMediaTypeSheet` do Studio) → resultado → navega `/share-studio/:lastGameId` com `extra: path` |
| `'open_studio'` | Main app é trazido ao primeiro plano → navega `/share-studio/:lastGameId` sem extra (Studio abre sem mídia pré-carregada) |

`lastGameId` é o último jogo com sessão no histórico. Se não houver, usa `'default'` e Studio abre normalmente.

---

## 3. Permissões

| Permissão | Entrada no Manifest | Runtime | Quando pedir | Fallback |
|---|---|---|---|---|
| `SYSTEM_ALERT_WINDOW` | `<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>` | `FlutterOverlayWindow.requestPermission()` | Somente após o usuário tocar "Ativar" no consent sheet | Toggle volta para OFF; Studio e galeria continuam funcionando |

**Não necessárias nesta fase:** `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PROJECTION`, `RECORD_AUDIO`, `READ_MEDIA_IMAGES`.

### 3.1 Variações de permissão por fabricante

`SYSTEM_ALERT_WINDOW` tem comportamento diferente por fabricante e versão de Android. O código **não deve assumir** que `requestPermission()` sempre abre a tela padrão do Android.

| Fabricante / Camada | Comportamento conhecido | Impacto no app |
|---|---|---|
| Android puro (AOSP / Pixel) | Settings → Apps → Aparecer na tela → tela padrão `ACTION_MANAGE_OVERLAY_PERMISSION` | Fluxo canônico; sem divergência |
| Samsung One UI 6+ | Encaminha para configuração própria; path pode mudar entre versões da One UI | Testar no S24 Ultra (Android 16, API 36); path pode diferir em One UI mais antigo |
| Xiaomi / HyperOS (MIUI) | Permissão de "janela flutuante" separada; pode exigir passo adicional no Security Center | Alta variação; não confiável via intent padrão |
| OPPO / Realme / ColorOS | "Exibir sobre outros apps" dentro de "Gerenciamento de perms"; intent nem sempre funciona | Fallback obrigatório para Settings genérico |
| Huawei (sem GMS / EMUI 12+) | Permissão equivalente em posição não padronizada; pode bloquear silenciosamente | Tratar negação silenciosa como "não suportado" |
| Android 10–12 (API 29–32) | `canDrawOverlays()` é a checagem correta; `requestPermission()` via plugin deve funcionar | Testar em API mínima suportada |
| Android 13 (API 33) | Sem mudança estrutural para `SYSTEM_ALERT_WINDOW` | Fluxo padrão |
| Android 14+ (API 34+) | `foregroundServiceType="specialUse"` exigido para o service interno do plugin; já declarado no Manifest | Já coberto; não requer ação adicional |
| Android 16 (API 36) | Validação primária (S24 Ultra) | Confirmar fluxo completo no aparelho físico |

**Regra de implementação:** toda checagem de permissão deve usar `FlutterOverlayWindow.isPermissionGranted()` (ou equivalente) em vez de assumir que `requestPermission()` sempre concede. Se o resultado for incerto após o retorno, re-checar com `canDrawOverlays()` via `MethodChannel` se necessário.

**Não necessárias nesta fase:** `FOREGROUND_SERVICE` próprio, `FOREGROUND_SERVICE_MEDIA_PROJECTION`, `RECORD_AUDIO`, `READ_MEDIA_IMAGES`.

---

## 4. Risco Play Store

| Item | Risco | Mitigação |
|---|---|---|
| `SYSTEM_ALERT_WINDOW` | Médio | Opt-in; gaming utility é caso legítimo e aprovado; disclosure na política de privacidade e no manifest |
| Service interno do plugin | Baixo | Automergado pelo Gradle; sem comportamento oculto |
| Rejeição por abuso de overlay | Baixo | Sem anúncios, sem dark patterns, toggle de desativação, copy honesta em todas as línguas |

A permissão `SYSTEM_ALERT_WINDOW` exige disclosure explícita na Política de Privacidade do projeto. A seção `docs/claude/security.md` e os textos de consentimento no app devem refletir isso.

---

## 5. Arquivos

### Novos

| Arquivo | Responsabilidade |
|---|---|
| `lib/presentation/services/floating_capture_service.dart` | Singleton: ciclo de vida do overlay, estado persistido, handler de mensagens recebidas do overlay engine |
| `lib/presentation/widgets/social/capture_consent_sheet.dart` | Bottom sheet opt-in: copy honesta + solicitação de permissão + fallback |
| `lib/presentation/widgets/social/apex_floating_button.dart` | Widget da overlay engine (renderizado pelo `overlayMain()`) |

### Modificados

| Arquivo | Mudança |
|---|---|
| `android/app/src/main/AndroidManifest.xml` | +`SYSTEM_ALERT_WINDOW` |
| `pubspec.yaml` | +`flutter_overlay_window` |
| `lib/main.dart` | +`overlayMain()` entry point anotado com `@pragma('vm:entry-point')` |
| `lib/core/i18n/app_strings.dart` | +17 strings em PT-BR/EN/ES |
| `lib/core/routing/app_router.dart` | Route `/share-studio/:gameId` aceita `state.extra as String?` |
| `lib/presentation/screens/share_studio/share_studio_screen.dart` | Constructor aceita `initialMediaPath`; `initState` pré-carrega se fornecido |
| `lib/domain/interfaces/apex_capture_source.dart` | +enum `CaptureMethod { gallery, mediaProjection }` (stub U2B) |
| `lib/presentation/screens/home/tabs/configuracoes_tab.dart` | +`_FloatingCaptureCard` (toggle + perm check, padrão `_FocusModeCard`) |
| `docs/claude/security.md` | +seção SYSTEM_ALERT_WINDOW: justificativa, disclosure, fallback |

---

## 6. Copy — AppStrings PT-BR / EN / ES

Toda copy em `AppStrings` nas três línguas. Nenhuma copy promete FPS, ping, RAM, CPU, GPU ou boost real.

### 6.1 Card de Configurações

| Key | PT-BR | EN | ES |
|---|---|---|---|
| `captureFloatBadge` | `SOCIAL` | `SOCIAL` | `SOCIAL` |
| `captureFloatCardTitle` | `Botão Flutuante` | `Floating Button` | `Botón Flotante` |
| `captureFloatCardSubtitle` | `Acesse rapidamente suas mídias durante a sessão gamer` | `Quickly access your media during gaming sessions` | `Accede rápidamente a tus medios durante la sesión gamer` |
| `captureFloatCardEnabled` | `Ativo` | `Active` | `Activo` |
| `captureFloatCardDisabled` | `Inativo` | `Inactive` | `Inactivo` |
| `captureFloatCardPermRequired` | `Permissão de sobreposição necessária` | `Overlay permission required` | `Permiso de superposición necesario` |
| `captureFloatCardOpenSettings` | `Abrir configurações` | `Open settings` | `Abrir configuración` |

### 6.2 Consent Sheet

| Key | PT-BR | EN | ES |
|---|---|---|---|
| `captureConsentTitle` | `Captura Flutuante Apex` | `Apex Floating Capture` | `Captura Flotante Apex` |
| `captureConsentBody` | `Use o botão flutuante para acessar rapidamente suas mídias durante a sessão gamer. Você escolhe o print ou vídeo que deseja usar no Apex Studio. Nada é capturado ou compartilhado automaticamente.` | `Use the floating button to quickly access your media during gaming sessions. You choose the screenshot or video to use in Apex Studio. Nothing is captured or shared automatically.` | `Usa el botón flotante para acceder rápidamente a tus medios durante la sesión gamer. Tú eliges la captura o el video que quieres usar en Apex Studio. Nada se captura ni comparte automáticamente.` |
| `captureConsentPermNote` | `Este recurso precisa de permissão para exibir sobre outros apps.` | `This feature needs permission to display over other apps.` | `Esta función necesita permiso para mostrarse sobre otras apps.` |
| `captureConsentActivate` | `Ativar` | `Activate` | `Activar` |
| `captureConsentPermDenied` | `Permissão necessária. Ative em Configurações › Apps › Aparência na tela.` | `Permission required. Enable it in Settings › Apps › Appear on screen.` | `Permiso necesario. Actívalo en Configuración › Apps › Aparecer en pantalla.` |

### 6.3 Mini-overlay

| Key | PT-BR | EN | ES |
|---|---|---|---|
| `captureOverlayOpenGallery` | `Adicionar print ou vídeo` | `Add screenshot or video` | `Agregar captura o video` |
| `captureOverlayOpenStudio` | `Voltar ao Apex Studio` | `Back to Apex Studio` | `Volver a Apex Studio` |

---

## 7. Fluxo completo do usuário

```
Configurações
  → "_FloatingCaptureCard" toggle (off)
  → usuário toca toggle
  → CaptureConsentSheet aparece:
      title:   "Captura Flutuante Apex"
      body:    [copy honesta conforme 6.2]
      permNote: [aviso de overlay]
      botões:  [Cancelar]  [Ativar]
  → "Ativar"
  → FlutterOverlayWindow.requestPermission()
  → sistema Android: "Permitir que Apex Booster+ apareça sobre outros apps?"
      granted → FloatingCaptureService.enable() → overlay aparece
      denied  → snackbar com captureConsentPermDenied; toggle volta OFF

Durante o jogo:
  → bolt verde 60×60 flutuando, canto direito, draggable
  → toca bolt → mini-overlay expande:
      ◾ "Adicionar print ou vídeo"  (ícone image_outlined)
      ◾ "Voltar ao Apex Studio"     (ícone bolt_rounded)
  → 5s sem toque → colapsa automaticamente

"Adicionar print ou vídeo":
  → envia 'open_gallery' ao main app
  → overlay recolhe → main app trazido ao primeiro plano
  → main app exibe sheet: "Imagem" ou "Vídeo" (mesmo `_showMediaTypeSheet`)
  → usuário escolhe e seleciona arquivo
  → se path ≠ null → navega /share-studio/:lastGameId (extra: path)
  → Studio abre com mídia pré-carregada
  → usuário compõe → Privacy Guard → compartilha

"Voltar ao Apex Studio":
  → envia 'open_studio' ao main app
  → main app: navega /share-studio/:lastGameId sem extra
  → Studio abre normalmente (picker disponível)

Desativar:
  → Configurações → toggle OFF
  → FloatingCaptureService.disable()
  → FlutterOverlayWindow.closeOverlay()
  → SharedPreferences['capture_float_enabled'] = false
```

---

## 8. Comportamentos de erro e fallback

### 8.1 Fallback primário — Apex Studio + Galeria

Quando o overlay **não estiver disponível por qualquer motivo**, o app não para. O usuário ainda acessa o Apex Studio pela navegação normal e abre a galeria de dentro do Studio. O botão flutuante é uma conveniência, não um bloqueio de fluxo.

```
Overlay indisponível → qualquer motivo
  → FloatingCaptureService.isAvailable() == false
  → _FloatingCaptureCard: toggle oculto ou desabilitado + aviso informativo
  → Apex Studio acessível via navegação normal (Home → Biblioteca → Jogo → Studio)
  → Seleção de mídia disponível dentro do Studio (ImagePicker)
  → Toda a composição e exportação funcionam normalmente
```

### 8.2 Tabela de cenários

| Cenário | Comportamento |
|---|---|
| `SYSTEM_ALERT_WINDOW` negado pelo usuário | Snackbar com `captureConsentPermDenied`; toggle volta para OFF; Studio e galeria acessíveis normalmente |
| `SYSTEM_ALERT_WINDOW` negado permanentemente | Card exibe "Abrir configurações" (padrão `_FocusModeCard`); toggle desabilitado |
| Fabricante bloqueia overlay silenciosamente (ex: Huawei) | `isPermissionGranted()` retorna false após request; tratar como negação permanente; fallback para Studio |
| Fabricante com intent não padronizado (MIUI, ColorOS) | Se `requestPermission()` lançar exceção ou não abrir configuração correta, capturar erro, mostrar aviso com instrução manual + link para configurações genérico |
| Plugin não inicializa (dispositivo incompatível, API muito antiga) | `FloatingCaptureService.isSupported()` retorna false; card oculta toggle e exibe aviso; nenhum erro visual |
| Overlay em API < mínima suportada pelo plugin | Tratar como `isSupported() == false`; fallback silencioso para Studio |
| ImagePicker retorna null (cancelamento) | Overlay recolhe; nenhuma navegação ocorre |
| `lastGameId` não disponível | Navega `/share-studio/default`; Studio carrega sem jogo vinculado |
| Exception inesperada no `overlayMain()` | Capturar em try/catch; overlay não aparece; não travar app principal |
| Overlay inicializado mas não visível (clipping por fabricante) | Dentro do escopo de SOCIAL-U2B; nesta fase apenas logar |

### 8.3 Contrato defensivo do FloatingCaptureService

O serviço deve expor o seguinte contrato mínimo para que `_FloatingCaptureCard` tome decisões sem depender de plataforma específica:

```dart
// Retorna false se o plugin não carregou, se a API é muito antiga,
// ou se o fabricante não suporta overlay de forma detectável.
bool isSupported();

// Retorna true somente se canDrawOverlays() == true confirmado.
Future<bool> isPermissionGranted();

// Solicita permissão; retorna o estado pós-request.
// Captura exceções de fabricantes com UX não padronizada.
Future<bool> requestPermission();

// Liga overlay somente se isSupported() && isPermissionGranted().
Future<void> enable();

// Desliga overlay e persiste estado; nunca lança exceção.
Future<void> disable();
```

Nenhum método do serviço deve propagar exceção não tratada para a UI. Erros internos → `disable()` + log.

---

## 9. Compatibilidade Android — Regras de implementação

> **Regra soberana:** o Apex Booster+ é um app Android geral. O Samsung S24 Ultra com One UI 8.5 e Android 16 (API 36) é apenas o aparelho físico de validação principal. Nenhuma decisão de código deve ser hardcoded para esse dispositivo.

### 9.1 Escopo de compatibilidade

| Dimensão | Escopo alvo |
|---|---|
| API mínima | Definido pelo `minSdkVersion` do projeto (não assumir API 34) |
| API de validação | API 36 (Android 16, Samsung S24 Ultra) |
| Fabricantes testados | Samsung One UI; outros por análise defensiva |
| Tamanhos de tela | Qualquer; botão flutuante draggable não deve fixar posição por resolução |
| Orientação | Portrait e landscape; overlay deve se reposicionar defensivamente |

### 9.2 Regras de código

1. **Não hardcode versão de Android.** Use `Build.VERSION.SDK_INT >= X` somente quando necessário para workarounds específicos; não bloqueie features por versão sem necessidade.
2. **Não hardcode fabricante.** Não use `Build.MANUFACTURER == "samsung"` para bifurcar comportamento crítico; use detecção de capacidade (`canDrawOverlays`, `isSupported`).
3. **Não assuma posição fixa de overlay.** O botão arrasta; a posição inicial deve ser calculada em dp, não em pixels absolutos de um display específico.
4. **Não assuma UX de permissão padrão.** Envolver `requestPermission()` em try/catch; checar `isPermissionGranted()` após retorno.
5. **Fallback obrigatório.** Se `isSupported() == false` ou permissão não puder ser obtida: card informativo + Studio funciona via navegação normal.
6. **Sem tela vermelha.** Qualquer exceção do overlay engine não deve propagar para o engine principal.

### 9.3 Checklist de validação multi-ambiente

| Ambiente | O que verificar |
|---|---|
| Samsung S24 Ultra (Android 16, One UI 8.5) | Fluxo completo; consentimento; overlay visível; drag; collapse automático; desativar |
| Emulador AOSP API 29 (mínima) | `isSupported()` retorna valor coerente; fallback funciona; sem crash |
| Emulador AOSP API 33 | Fluxo de permissão; overlay aparece; mensagem chega ao main app |
| Emulador AOSP API 35 | Fluxo idêntico ao API 34; `FOREGROUND_SERVICE_SPECIAL_USE` já declarado |
| Dispositivo sem overlay (fabricante restritivo simulado) | `isSupported() == false` → card informativo → Studio acessível normalmente |

---

## 10. Testes (TDD — escrita de testes antes do código)

| Arquivo | Testes |
|---|---|
| `test/presentation/services/floating_capture_service_test.dart` | `isEnabled` retorna false por padrão; `enable()` persiste true; `disable()` persiste false e fecha overlay |
| `test/presentation/screens/share_studio/share_studio_screen_test.dart` | +1: com `initialMediaPath` apontando para imagem (extensão `.png`), botão Exportar fica habilitado (não null) |

---

## 11. Regras do produto — confirmação explícita

| Regra | Status |
|---|---|
| Nenhuma captura automática de tela | ✅ Confirmado |
| Nenhum compartilhamento automático | ✅ Confirmado |
| SYSTEM_ALERT_WINDOW somente após opt-in | ✅ Confirmado |
| Overlay desligável pelo usuário | ✅ Toggle em Configurações |
| Captura real (MediaProjection) reservada para SOCIAL-U2B | ✅ Fora de escopo nesta fase |
| Nenhuma promessa de FPS, ping, RAM, CPU, GPU ou boost | ✅ Copy verificada |
| Privacy Guard antes de exportar | ✅ Já implementado em SOCIAL-U1 |
| Toda copy em PT-BR, EN e ES | ✅ Seção 6 completa |
| Código defensivo para Android geral (sem hardcode Samsung/API 34) | ✅ Seções 3.1, 8 e 9 |
| Fallback obrigatório para Apex Studio + galeria se overlay indisponível | ✅ Seção 8.1 |

---

## 12. Atualização de documentação de privacidade

`docs/claude/security.md` receberá nova seção:

**SYSTEM_ALERT_WINDOW — Botão Flutuante Apex**
- Finalidade: exibir botão de acesso rápido sobre outros apps durante sessão gamer.
- Solicitação: somente após consentimento explícito do usuário.
- Uso: exclusivo para o botão flutuante social; não usado para coleta, anúncios ou rastreamento.
- Desativação: usuário pode desligar a qualquer momento em Configurações.
- Disclosure: deve constar na Política de Privacidade publicada antes do release.

---

*Spec de SOCIAL-U2A escrito em 2026-06-11. Pronto para revisão e transição para plano de implementação.*
