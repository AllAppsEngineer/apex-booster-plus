# SOCIAL-U8 — Aba "Social" na navegação inferior — Design Spec

**Data:** 2026-07-13
**Fase:** Consolidação de acesso social (nav)
**Abordagem aprovada:** B — Nova aba "Social" consolidada, mantendo o CTA "Criar card" também no Detalhe do Jogo

---

## Escopo

Adicionar uma 6ª aba "Social" na `BottomNavigationBar` do `HomeScreen`, entre "Preparar" e "Histórico" (ou ao final — decidir na etapa de plano com base no teste visual), reunindo em um único lugar:

1. **Modo Captura da Sessão** (Print/Vídeo, hoje `_FloatingCaptureCard` dentro de `configuracoes_tab.dart`)
2. **Criar Card** (fluxo já existente `ApexStudioScreen`, hoje acessível só via Detalhe do Jogo)

Configurações continua existindo como aba própria (sem remoção), só perde a seção de captura, que é extraída para um widget compartilhado. O CTA "Criar card" no Detalhe do Jogo é mantido (acesso duplicado, contextual ao jogo já selecionado).

**Fora de escopo (não mexer):** captura/gravação em si, `MediaProjection`, código nativo Kotlin, permissões, Apex Scan, Billing, Firebase, package/signing, publicação na loja.

---

## Problema técnico central

`ApexStudioScreen` (rota `/share-studio/:gameId`) exige `gameId` obrigatório — foi desenhada para ser empilhada a partir de um jogo já selecionado (Detalhe do Jogo), com `AppBar` e `bottomNavigationBar` próprios. Não existe hoje uma versão "Apex Studio sem jogo". A nova aba precisa de uma **tela de landing nova** (`SocialTab` ou `ApexStudioTab`) que:

- Renderiza o card de Modo Captura (extraído de Configurações) no topo.
- Abaixo, oferece um seletor de jogo (reaproveitando a lista de jogos já existente na Biblioteca/Preparar) para então navegar via `context.push('/share-studio/$gameId')` — reaproveitando a rota e a tela existentes sem alterá-las.

Nenhuma mudança é necessária em `app_router.dart` nem em `ApexStudioScreen` — a rota e o construtor continuam iguais.

---

## 1. HomeScreen — nova aba

`lib/presentation/screens/home/home_screen.dart`:

- `IndexedStack` passa de 5 para 6 filhos; array `_tabVisited` passa de 5 para 6 posições.
- Novo `BottomNavigationBarItem` (ícone sugerido: `Icons.camera_alt_outlined` / `Icons.camera_alt`, ou `Icons.auto_awesome_outlined` — decidir na etapa visual; label curto para caber em `type: fixed` com 6 itens).
- Novo label i18n: `navSocial` (pt-BR/en/es) em `lib/core/i18n/app_strings.dart`.
- Risco de layout: 6 itens em `BottomNavigationBar(type: fixed)`, `selectedFontSize`/`unselectedFontSize` fixos em 11, sem tokens de breakpoint no projeto. Testar labels curtos (ex.: "Social") e validar em tela pequena além do S24 Ultra.

---

## 2. Nova tela — Social Tab (landing)

Novo arquivo: `lib/presentation/screens/home/tabs/social_tab.dart` (nome de classe a decidir no plano, ex. `SocialTab`).

Conteúdo, em duas seções visualmente separadas (consistente com a regra de separação MÉTRICAS/PLACEBO do produto, aqui aplicada a CAPTURA/CRIAÇÃO):

- **Seção "Modo Captura da Sessão"** — o card extraído (ver item 3).
- **Seção "Criar Card"** — seletor de jogo (lista simples, reaproveitando dados já carregados de biblioteca/histórico) + CTA que navega para `/share-studio/:gameId` do jogo escolhido.

---

## 3. Extração do Modo Captura

Hoje: `_FloatingCaptureCard` é widget privado dentro de `lib/presentation/screens/home/tabs/configuracoes_tab.dart` (opt-in, escolha print/vídeo, duração, arm/disarm via `ScreenCaptureService`, toggle via `FloatingCaptureService`).

Mudança: extrair para um widget público reutilizável, ex. `lib/presentation/widgets/social/floating_capture_card.dart` (nome a decidir no plano), preservando toda a lógica interna (opt-in dialog, `_pickCaptureMode`, `_pickVideoDuration`, `_syncState`) sem alterações de comportamento. `configuracoes_tab.dart` remove a seção e passa a não renderizá-la; `social_tab.dart` passa a renderizá-la.

**Restrição:** nenhuma mudança de comportamento da captura em si — é puramente mover código de UI de um arquivo para outro.

---

## 4. Detalhe do Jogo — sem mudança

`game_detail_screen.dart` mantém `_CreateCardButton` exatamente como está, preservando o atalho contextual já validado.

---

## Arquivos alterados (estimativa)

| Arquivo | Mudança |
|---|---|
| `lib/presentation/screens/home/home_screen.dart` | 6º item de nav, `IndexedStack`, `_tabVisited` |
| `lib/core/i18n/app_strings.dart` | novo label `navSocial` (pt/en/es) + strings da tela nova |
| `lib/presentation/screens/home/tabs/social_tab.dart` (novo) | landing com Modo Captura + seletor de jogo/Criar Card |
| `lib/presentation/widgets/social/floating_capture_card.dart` (novo, extraído) | widget de Modo Captura movido de Configurações |
| `lib/presentation/screens/home/tabs/configuracoes_tab.dart` | remove `_FloatingCaptureCard` inline, passa a importar o widget extraído em nenhum lugar (seção removida) |
| `lib/presentation/screens/game_detail/game_detail_screen.dart` | nenhuma mudança |
| `lib/core/routing/app_router.dart` | nenhuma mudança |
| `lib/presentation/screens/share_studio/share_studio_screen.dart` | nenhuma mudança |

---

## Validação

1. `flutter analyze`
2. `flutter test`
3. `dart run tool/check_hardcoded_strings.dart`
4. `git status --short` / `git diff --stat`
5. Teste visual no S24 Ultra: 6 abas, labels legíveis, Modo Captura funcionando igual dentro da nova aba, Criar Card acessível tanto pela nova aba quanto pelo Detalhe do Jogo
6. Teste visual em um perfil de tela menor (emulador com tela ~360dp de largura) para validar que os 6 itens não cortam labels nem apertam demais os toques

---

## Restrições honradas

- Configurações não é removida.
- CTA "Criar card" no Detalhe do Jogo não é removido (acesso duplicado é intencional).
- Nenhuma mudança em captura/gravação, `MediaProjection`, Kotlin, permissões, Apex Scan, Billing, Firebase, package/signing ou publicação.
- Nenhuma nova rota — reaproveita `/share-studio/:gameId` como está.
- Nenhuma dependência nova.
