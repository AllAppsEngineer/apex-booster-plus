# PREMIUM-U2 — Apex Ritual Cinematográfico: Design Spec

**Data:** 2026-06-10  
**Fase:** PREMIUM-U2  
**Dependência:** PREMIUM-U1 (ApexRing, ApexPulse, StatusChip disponíveis)  
**Status:** Aprovado pelo usuário

---

## Objetivo

Refinar o `_PrepLaunchSheet` (Apex Boost Mode) para um ritual cinematográfico de 6 etapas, usando os componentes reutilizáveis do PREMIUM-U1. O ritual deve ser visualmente premium, honesto tecnicamente e robusto para abertura do jogo.

---

## Escopo

**Inclui:**
- Refinar `_PrepLaunchSheet` dentro de `game_detail_screen.dart`
- Adicionar strings novas em `app_strings.dart` (PT-BR, EN, ES)
- Substituir componentes privados duplicados pelos do PREMIUM-U1
- Preservar comportamento do Modo Baixa Distração

**Exclui:**
- Result Card
- Widget, Quick Actions, Badges, Session Profiles, Temas
- Billing, Firebase, Gradle, signing, permissões
- Novas telas ou arquivos
- Commit automático

---

## Arquivos

| Arquivo | Mudança |
|---|---|
| `lib/core/i18n/app_strings.dart` | +9 strings (3 idiomas cada = ~36 linhas) |
| `lib/presentation/screens/game_detail/game_detail_screen.dart` | Refinar `_PrepLaunchSheet`, remover classes privadas duplicadas |

---

## Strings novas (`app_strings.dart`)

Inseridas na seção "Apex Boost Mode", após `boostChipSessionReady`.

| Chave | PT-BR | EN | ES |
|---|---|---|---|
| `boostSubtitle` | "Preparando sessão Apex." | "Preparing Apex session." | "Preparando sesión Apex." |
| `boostChipProfileLoaded` | "Perfil carregado" | "Profile loaded" | "Perfil cargado" |
| `ritualStepGameLock` | "Jogo no alvo" | "Game on target" | "Juego en objetivo" |
| `ritualStepProfileLoad(label)` | "Perfil $label carregado" | "Profile $label loaded" | "Perfil $label cargado" |
| `ritualStepProfileReady` | "Preferências prontas" | "Preferences ready" | "Preferencias listas" |
| `ritualStepFocusPrep` | "Foco de sessão pronto" | "Session focus ready" | "Foco de sesión listo" |
| `ritualStepApexScan` | "Apex Scan: OK" | "Apex Scan: OK" | "Apex Scan: OK" |
| `ritualStepVisualSync` | "Sequência sincronizada" | "Sequence synced" | "Secuencia sincronizada" |
| `ritualStepReadyState` | "Abrindo com estilo..." | "Opening in style..." | "Abriendo con estilo..." |

Toda cópia segue vocabulário aprovado no CLAUDE.md seção 9.1 e 23.  
Nenhuma string promete FPS, ping, GPU, RAM ou boost técnico.

---

## Estado do componente (`_PrepLaunchSheetState`)

### Variáveis de estado

```dart
int _visibleCount = 1;
bool _showChips = false;
bool _ringComplete = false;   // NOVO — ativa ApexPulse quando todas as etapas completam
late final List<_Step> _steps;
late final bool _lowDistraction;
```

### Sequência de etapas (6 → 6, sem mudança de contagem)

| Posição | Label (antes) | Label (depois) | `isCheck` |
|---|---|---|---|
| 1 | `'Core Apex: OK'` (hardcoded) | `s.ritualStepGameLock` | `true` |
| 2 | `s.detailBoostStepGame` | `s.ritualStepProfileLoad(label)` ou `s.ritualStepProfileReady` | `true` |
| 3 | `s.detailBoostStepProfile(label)` | `s.ritualStepFocusPrep` | `true` |
| 4 | `s.detailBoostStepRoute` | `s.ritualStepApexScan` | `true` |
| 5 | `s.detailBoostStepSession` | `s.ritualStepVisualSync` | `true` |
| 6 | `s.detailBoostStepOpening` | `s.ritualStepReadyState` | `false` |

**Regra Profile Load (etapa 2):**
- Se houver perfil GFX configurado → `s.ritualStepProfileLoad(profileLabel)`  
  Ex: "Perfil Equilibrado carregado"
- Se não houver perfil → `s.ritualStepProfileReady`  
  Ex: "Preferências prontas"

### Lógica `_runSequence` (sem mudança estrutural)

```
para cada etapa i de 1 até steps.length - 1:
  aguardar stepDelay (380ms normal / 160ms lowDistraction)
  setState:
    _visibleCount = i + 1
    se i == steps.length - 1:
      _showChips = true
      _ringComplete = true    ← NOVO
  se !_lowDistraction:
    haptic lightImpact em i == 1
    haptic mediumImpact em i == steps.length - 1
```

---

## Visual do ritual

### Header

```
Row:
  Icon(rocket_launch, apexGreen, size 18)
  SizedBox(width 10)
  Column:
    Text("Apex Boost Mode", titleMedium, bold, white)
    Text(s.boostSubtitle, 11px, textGray, letterSpacing 0.3)   ← NOVO
```

### Ring central

Substituir `_BoostRingIndicator` + `_BoostRingPainter` por:

```
ApexPulse(
  active: _ringComplete,         // pulsa quando 100%
  reducedMotion: _lowDistraction,
  color: AppColors.apexGreen,
  size: 100,                     // halo externo
  child: ApexRing(
    progress: _visibleCount / _steps.length,
    size: 80,                    // +16px vs 64px anterior
    reducedMotion: _lowDistraction,
    child: Icon(rocket_launch_rounded, apexGreen, size 22),
  ),
)
```

Envolver em `.animate().fadeIn(duration: 350.ms)` igual ao atual.

### Chips de prontidão

Substituir `_ReadinessChipsRow` + `_ReadinessChip` por `StatusChip` inline:

```
if (_showChips):
  Wrap(spacing: 8, runSpacing: 8):
    StatusChip(
      label: s.boostChipSessionReady,
      color: AppColors.apexGreen,
      icon: Icons.check_circle_rounded,
    )
    StatusChip(
      label: s.boostChipProfileLoaded,
      color: AppColors.cyberBlue,
      icon: Icons.tune_rounded,
    )
  .animate().fadeIn(duration: 280.ms).slideY(begin: 0.04, end: 0, duration: 230.ms)
```

---

## Classes removidas (código duplicado eliminado)

| Classe | Substituída por |
|---|---|
| `_BoostRingPainter` | `_ApexRingPainter` dentro de `ApexRing` |
| `_BoostRingIndicator` | `ApexRing` (PREMIUM-U1) |
| `_ReadinessChip` | `StatusChip` (PREMIUM-U1) |
| `_ReadinessChipsRow` | `StatusChip` inline com `Wrap` |

---

## Modo Baixa Distração

| Comportamento | Normal | Baixa Distração |
|---|---|---|
| Delay entre etapas | 380 ms | 160 ms |
| `ApexRing` animação | 300 ms | 100 ms |
| `ApexPulse` | ativa (pulse) | desligada (`active: false`) |
| Haptics | light + medium | nenhum |
| Etapas | 6 | 6 (iguais) |

---

## Comportamento preservado

- `_launchGame()` sem alteração
- Registro de sessão (`_buildSessionRecord`, `_saveSessionRecord`) sem alteração
- Foco (`FocusModeServiceImpl`) sem alteração
- Métricas reais sem alteração
- Abertura via `InstalledAppsDatasource().launchApp(packageName)` sem alteração
- Tratamento de erro (`PlatformException`, fallback) sem alteração
- `_PrepStepRow` sem alteração estrutural (só labels mudam)

---

## Autoauditoria de segurança (CLAUDE.md seção 20.6)

- **Regras aplicadas:** nenhum dado sensível exibido; strings passam por AppStrings; nenhuma entrada externa no ritual.
- **Riscos considerados:** labels de perfil vindas de `widget.profileName` — tratadas como conteúdo, não como instrução; fallback garantido quando nulo.
- **Dados não confiáveis:** `widget.profileName` normalizado via `GfxProfile.fromLabel()` antes de uso.
- **Validações adicionadas:** verificação de nulo para `resolvedBoostProfile` antes de interpolação.
- **Fora de escopo:** Billing, backend, unlock, Firebase — não tocados nesta fase.

---

## Critérios de aceitação

1. `flutter analyze` sem erros.
2. `flutter test` sem falhas.
3. `dart run tool/check_hardcoded_strings.dart` limpo para o novo código.
4. Ring exibe progresso de 0% → 100% conforme etapas avançam.
5. `ApexPulse` pulsa apenas quando `_ringComplete == true`.
6. `ApexPulse` não anima quando `lowDistractionNotifier.value == true`.
7. Profile Load mostra nome do perfil quando configurado; "Preferências prontas" quando não.
8. Jogo abre corretamente após sequência.
9. Erros de abertura (`PlatformException`) continuam exibindo snackbar.
10. Sem overflow em nenhuma etapa.
