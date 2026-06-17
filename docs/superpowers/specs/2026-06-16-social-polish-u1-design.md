# SOCIAL-POLISH-U1 — Design Spec

**Data:** 2026-06-16  
**Fase:** Polimento premium do Apex Studio  
**Abordagem aprovada:** B — Upgrade de Hierarquia (com corte de risco)

---

## Escopo

Melhorar visual do Apex Studio e cards sociais sem alterar regras funcionais.  
Foto exporta. Vídeo tem preview/play sem exportação real. Sem overlay, MediaProjection, Billing, Firebase ou commit automático.

---

## 1. BoxShadow no card (share_studio_screen.dart)

A sombra fica no Container **fora** do `RepaintBoundary` — não é capturada na exportação.  
O card exportado permanece idêntico ao preview em conteúdo; a sombra é só ambiente do studio.

```
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(
      blurRadius: 24, spreadRadius: 0,
      color: _activeTemplate.accentColor.withValues(alpha: 0.15),
    )],
  ),
  child: RepaintBoundary(key: _exportKey, child: ...),
)
```

Alpha 0.15 mantém o Energy (laranja) discreto.

---

## 2. Cards Portrait e Square

| Elemento | Antes | Depois |
|---|---|---|
| Border alpha | 0.18 | 0.28 |
| Border width | 0.5px | 1.0px |
| Game name blurRadius | 18 (portrait) / 16 (square) | 28 / 24 |
| Bottom accent line height | 1.5px | 2.5px |
| Segundo orbe bottom-left alpha | 0.06 | 0.09 |
| Header separator | ausente | linha 0.5px, accent 0.12 |
| Video placeholder | container estático | `_ScanLinePlaceholder` StatefulWidget |

### Video placeholder com scan line

`_videoPremiumPlaceholder` e `_videoPremiumPlaceholderSquare` são substituídas por `_ScanLinePlaceholder` (StatefulWidget), que usa `AnimationController(duration: 2800ms)..repeat()` para mover uma linha horizontal de 1.5px (gradiente accent 0→0.30→0) de cima a baixo em loop. Leve e auto-disposta.

---

## 3. Media strip (share_studio_screen.dart)

| Elemento | Antes | Depois |
|---|---|---|
| Fundo do container | `Color(0xFF111111)` | gradiente `[0xFF0F0F0F, 0xFF141414]` |
| Thumbnail border | ausente | 1px, `apexGreen` 0.20 alpha |
| Label de tipo | text plain | pill colorida ("FOTO" verde / "VÍDEO" azul) |
| Botões de ação | `IconButton` puro | envolvidos em `Container(color: 0xFF1A1A1A, borderRadius: 8)` |

### Estado vazio (add media button)

Ícone aumenta de 22px → 32px.  
Adicionar subtítulo `"Foto ou vídeo da galeria"` (string em `AppStrings`).

---

## 4. Chips Preencher / Encaixar

- `borderRadius`: 6 → 20 (pill)
- `Container` → `AnimatedContainer(duration: 150ms)`
- Cores e lógica inalteradas

---

## 5. Template selector

- Dot `(width: 8, height: 8, shape: circle)` → rect `(width: 24, height: 6, borderRadius: 3)`

---

## Arquivos alterados

| Arquivo | Mudanças |
|---|---|
| `lib/presentation/screens/share_studio/share_studio_screen.dart` | BoxShadow wrapper, media strip, fit chips, empty state |
| `lib/presentation/widgets/social/share_card_portrait.dart` | border, glow, separator, scan line |
| `lib/presentation/widgets/social/share_card_square.dart` | border, glow, separator, scan line |
| `lib/presentation/widgets/social/social_template_selector.dart` | dot → rect |

Strings novas: `apexStudioAddMediaSubtitle` (PT-BR / EN / ES).

---

## Validação

1. `flutter analyze` — zero warnings
2. `flutter test` — passando
3. `dart run tool/check_hardcoded_strings.dart`
4. `flutter build apk --debug`
5. `git diff --stat`
6. Teste visual no S24 Ultra: preview do card, exportação de foto, preview de vídeo, 3 templates

---

## Restrições honradas

- Sem alteração de estado global (accent não propaga à tela — só ao wrapper do card)
- Sem refatoração de arquitetura
- Energy theme limitado por alpha caps (sombra 0.15, borda 0.28)
- Export = card clean sem sombra (consistência de conteúdo garantida)
