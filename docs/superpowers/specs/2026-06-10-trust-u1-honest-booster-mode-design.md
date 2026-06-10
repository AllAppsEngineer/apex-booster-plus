# TRUST-U1 — Honest Booster Mode: Design Spec

**Data:** 2026-06-10  
**Fase:** TRUST-U1  
**Status:** Aprovado pelo usuário  
**Produto:** APEX BOOSTER+  
**Regra soberana:** honestidade técnica acima de tudo — nenhuma copy desta tela promete FPS, ping, RAM ou CPU real.

---

## 1. Objetivo

Implementar uma área de confiança chamada **Honest Booster Mode / Modo Booster Honesto** que explica claramente o que o Apex Booster+ faz e não faz. A tela responde às 6 perguntas mais prováveis de um usuário cético, usando linguagem confiante, premium e honesta.

---

## 2. Escopo desta fase

### Inclui
- Novo card `_HonestBoosterCard` em `ConfiguracoesTab` (entre Language e About)
- Nova tela `HonestBoosterModeScreen` com FAQ de 6 itens
- Nova rota `/honest-booster-mode` em `app_router.dart`
- Novas chaves `AppStrings` nos três idiomas (PT-BR, EN, ES), prefixo `honestBooster`

### Não inclui (fora de escopo)
- BibliotecaTab (congelada)
- Widget, Quick Actions, Badges, Session Profiles, Result Card, Ritual
- Gradle, signing, permissões, Billing, Firebase, package name
- Splash, onboarding, bottom navigation

---

## 3. Arquitetura

### 3.1 Arquivos alterados/criados

| Arquivo | Ação |
|---|---|
| `lib/core/i18n/app_strings.dart` | Adicionar bloco `// TRUST-U1` com ~20 chaves novas |
| `lib/core/routing/app_router.dart` | Adicionar rota `/honest-booster-mode` |
| `lib/presentation/screens/configuracoes/honest_booster_mode_screen.dart` | Criar (arquivo novo) |
| `lib/presentation/screens/home/tabs/configuracoes_tab.dart` | Adicionar `_HonestBoosterCard` e inseri-lo na coluna |

### 3.2 Rota

```dart
GoRoute(
  path: '/honest-booster-mode',
  builder: (_, __) => const HonestBoosterModeScreen(),
),
```

Navegação a partir do card via `context.push('/honest-booster-mode')`.

---

## 4. `_HonestBoosterCard` — ConfiguracoesTab

Card novo inserido **entre `_LanguageCard` e `_AboutCard`** na coluna da tela de configurações.

### Estrutura visual
- Badge chip: `s.honestBoosterCardBadge` → `"CONFIANÇA"` / `"TRUST"` / `"CONFIANZA"`
- Título: `s.honestBoosterCardTitle` → `"Modo Booster Honesto"` / `"Honest Booster Mode"` / `"Modo Booster Honesto"`
- Subtítulo: `s.honestBoosterCardSubtitle` → `"O que o Apex faz — e o que ele não promete."` / `"What Apex does — and what it doesn't promise."` / `"Lo que Apex hace — y lo que no promete."`
- Row de ação: `s.honestBoosterCardAction` → `"Ver detalhes"` / `"See details"` / `"Ver detalles"` + ícone `Icons.arrow_forward_ios_rounded`
- Tap no row → `context.push('/honest-booster-mode')`

### Comportamento
- Sem estado local; é apenas navegação
- Reaproveita o padrão visual dos demais cards da tela (Container com gradiente grafite, badge chip, divider, row de ação)

---

## 5. `HonestBoosterModeScreen` — Tela dedicada

### AppBar
- Botão back (`context.pop()` ou `context.canPop()`)
- Título: `s.honestBoosterScreenTitle`
- Dark, sem elevation visível

### Corpo — scrollável
- Parágrafo introdutório (`s.honestBoosterIntro`)
- 6 blocos FAQ:
  - Pergunta: texto em destaque, cor `#22C55E` (verde Apex), peso `FontWeight.bold`
  - Resposta: texto secundário `#A1A1AA`
  - Separador sutil entre blocos
- Padding interno consistente com demais telas do app
- Sem animações pesadas, sem elementos placebo — tela de confiança é direta e limpa

---

## 6. AppStrings — chaves novas (bloco TRUST-U1)

### 6.1 Card em ConfiguracoesTab

| Chave | PT-BR | EN | ES |
|---|---|---|---|
| `honestBoosterCardBadge` | `CONFIANÇA` | `TRUST` | `CONFIANZA` |
| `honestBoosterCardTitle` | `Modo Booster Honesto` | `Honest Booster Mode` | `Modo Booster Honesto` |
| `honestBoosterCardSubtitle` | `O que o Apex faz — e o que ele não promete.` | `What Apex does — and what it doesn't promise.` | `Lo que Apex hace — y lo que no promete.` |
| `honestBoosterCardAction` | `Ver detalhes` | `See details` | `Ver detalles` |

### 6.2 Tela HonestBoosterModeScreen

| Chave | PT-BR | EN | ES |
|---|---|---|---|
| `honestBoosterScreenTitle` | `Modo Booster Honesto` | `Honest Booster Mode` | `Modo Booster Honesto` |
| `honestBoosterIntro` | `O Apex Booster+ é uma ferramenta de preparação gamer. Aqui está o que ele faz — e o que ele não promete.` | `Apex Booster+ is a gaming preparation tool. Here's what it does — and what it doesn't promise.` | `Apex Booster+ es una herramienta de preparación gamer. Esto es lo que hace — y lo que no promete.` |

### 6.3 FAQ — Perguntas

| Chave | PT-BR | EN | ES |
|---|---|---|---|
| `honestBoosterQ1` | `O app aumenta FPS?` | `Does the app boost FPS?` | `¿La app aumenta los FPS?` |
| `honestBoosterQ2` | `O app reduz ping?` | `Does the app reduce ping?` | `¿La app reduce el ping?` |
| `honestBoosterQ3` | `O app limpa RAM?` | `Does the app clean RAM?` | `¿La app limpia la RAM?` |
| `honestBoosterQ4` | `O que o app realmente faz?` | `What does the app actually do?` | `¿Qué hace realmente la app?` |
| `honestBoosterQ5` | `O que o unlock libera?` | `What does the unlock include?` | `¿Qué incluye el desbloqueo?` |
| `honestBoosterQ6` | `Por que usar antes de jogar?` | `Why use it before playing?` | `¿Por qué usarla antes de jugar?` |

### 6.4 FAQ — Respostas

| Chave | PT-BR | EN | ES |
|---|---|---|---|
| `honestBoosterA1` | `O Apex Booster+ não promete aumento real de FPS. Ele prepara sua sessão com organização, perfis, foco, leitura local e experiência visual.` | `Apex Booster+ doesn't promise a real FPS boost. It prepares your session with organization, profiles, focus, local readings, and visual experience.` | `Apex Booster+ no promete un aumento real de FPS. Prepara tu sesión con organización, perfiles, enfoque, lecturas locales y experiencia visual.` |
| `honestBoosterA2` | `Ping depende de rede, rota, servidor e operadora. O app pode exibir Latência Apex própria, mas não promete reduzir ping de jogos terceiros.` | `Ping depends on network, routing, server, and carrier. The app can display its own Apex Latency reading, but doesn't promise to reduce ping in third-party games.` | `El ping depende de la red, la ruta, el servidor y el operador. La app puede mostrar su propia Latencia Apex, pero no promete reducir el ping en juegos de terceros.` |
| `honestBoosterA3` | `O app pode exibir snapshot de memória quando disponível, mas não promete limpeza automática de RAM.` | `The app can display a memory snapshot when available, but doesn't promise automatic RAM cleanup.` | `La app puede mostrar un snapshot de memoria cuando está disponible, pero no promete limpieza automática de RAM.` |
| `honestBoosterA4` | `O Apex Booster+ organiza seus jogos, salva preferências locais, exibe dados locais, cria um ritual visual de preparação e abre o jogo selecionado.` | `Apex Booster+ organizes your games, saves local preferences, displays local data, creates a visual preparation ritual, and launches your selected game.` | `Apex Booster+ organiza tus juegos, guarda preferencias locales, muestra datos locales, crea un ritual visual de preparación y abre el juego seleccionado.` |
| `honestBoosterA5` | `O unlock libera a experiência premium: temas, ritual completo, perfis avançados, histórico enriquecido, badges, widget, Quick Actions e cards, conforme forem implementados.` | `The unlock includes the full premium experience: themes, complete ritual, advanced profiles, enriched history, badges, widget, Quick Actions, and cards — as they become available.` | `El desbloqueo incluye la experiencia premium completa: temas, ritual completo, perfiles avanzados, historial enriquecido, insignias, widget, Quick Actions y tarjetas — según se implementen.` |
| `honestBoosterA6` | `Para entrar com biblioteca organizada, perfil carregado, checklist de foco e preparação visual.` | `To enter with an organized library, loaded profile, focus checklist, and visual preparation.` | `Para entrar con biblioteca organizada, perfil cargado, checklist de enfoque y preparación visual.` |

---

## 7. Testes e validação

```bash
flutter analyze
flutter test
dart run tool/check_hardcoded_strings.dart
git diff --stat
git status --short
```

Validação visual obrigatória no S24 Ultra:
1. Abrir Configurações → confirmar novo card entre Idioma e Sobre
2. Tocar em "Ver detalhes" → confirmar navegação para tela Honest Booster Mode
3. Rolar o FAQ completo — confirmar sem overflow
4. Trocar idioma para EN → voltar a Configurações → abrir tela → confirmar EN
5. Trocar idioma para ES → confirmar ES
6. Voltar com botão back → confirmar retorno a Configurações

---

## 8. Critério de rejeição

- Qualquer string hardcoded fora de `AppStrings`
- Copy que promete FPS, ping, RAM ou CPU real
- Overflow na tela em qualquer idioma
- Navegação quebrada (push sem rota registrada)
- Card sem badge/subtítulo correto
- `flutter analyze` com warnings novos
