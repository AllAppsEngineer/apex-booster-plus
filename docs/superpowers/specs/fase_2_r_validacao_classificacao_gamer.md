# Fase 2-R — Validação e Classificação Gamer de Apps

**Data:** 2026-05-27  
**Status:** Design aprovado. Aguardando implementação.  
**Origem:** Descoberta da Fase 2-Q.4 — apps não-game (ex: Waze) podem ser adicionados à Biblioteca por terem `packageName` válido e launchable. Não é bug crítico; é lacuna de classificação/curadoria gamer.

---

## 1. Objetivo da Fase 2-R

Introduzir uma camada honesta de classificação gamer na Biblioteca do APEX BOOSTER+, reduzindo a adição acidental de apps não-game sem bloquear jogos reais que o Android não classifica formalmente como jogo.

**O que esta fase NÃO é:**
- Não é uma proteção técnica rígida.
- Não promete identificar 100% dos jogos.
- Não remove apps já salvos.
- Não bloqueia o launcher.
- Não usa servidor, Firebase ou Usage Stats.

**O que esta fase É:**
- Um sinal informativo honesto baseado em dados do próprio Android.
- Uma confirmação obrigatória antes de adicionar app não classificado.
- Um badge visual discreto na Biblioteca para apps não verificados.
- Um filtro opcional no picker para facilitar a curadoria do usuário.

---

## 2. Decisões Aprovadas

| Decisão | Valor |
|---|---|
| Abordagem | A — Signal + Confirmation Gate |
| Fonte de classificação | `ApplicationInfo.CATEGORY_GAME` (API 26+) + `FLAG_IS_GAME` (legado) |
| Nova permissão necessária | Nenhuma |
| Novo servidor/Firebase | Nenhum |
| Armazenamento de `isGame` | Não persiste — computado em runtime via `InstalledAppsDatasource` |
| Migração de `ApexGame` / SharedPreferences | Nenhuma |
| Comportamento para não classificado | Confirmação obrigatória, não bloqueio |
| Comportamento para classificado | Adição direta, sem dialog |
| Fallback manual | Preservado sem verificação de `isGame` |
| Apps já salvos | Recebem badge discreto, nunca são removidos |
| Launcher / ABRIR JOGO | Não alterado nesta fase |

**Texto aprovado para confirmação:**
```
Este app não foi identificado pelo Android como um jogo.
Você ainda pode adicioná-lo à sua biblioteca.
Adicionar mesmo assim?
```

Botões: **Adicionar mesmo assim** | **Cancelar**

---

## 3. Arquitetura Proposta

```
Android (Kotlin — getInstalledApps)
  └── lê ApplicationInfo.CATEGORY_GAME / FLAG_IS_GAME por app
        ↓
InstalledApp entity  (+  isGame: bool)
        ↓
InstalledAppsDatasource  (parseia isGame — cache de sessão existente)
        ↓
   ┌─────────────────────────────────────────────────────┐
   │  AppPickerSheet                                     │
   │    · badge "JOGO" nos classificados                 │
   │    · toggle "Apenas jogos verificados" (off padrão) │
   │    · confirmação ao selecionar não-classificado     │
   │                                                     │
   │  BibliotecaTab — add flow                           │
   │    · confirmação antes de salvar não-classificado   │
   │                                                     │
   │  BibliotecaTab — display (cards)                    │
   │    · badge retroativo em apps não verificados       │
   └─────────────────────────────────────────────────────┘
```

**Princípio central:** `isGame` nunca é armazenado em `ApexGame` nem em SharedPreferences. É lido do `InstalledAppsDatasource` em tempo de exibição e adição, usando o cache de sessão já existente. Isso garante:

- Zero migração de dados.
- Zero mudança no formato de SharedPreferences.
- Reflexo do estado real do dispositivo na sessão atual.
- Comportamento conservador: sem evidência (app desinstalado, sem `packageName`) → sem badge.

---

## 4. Impacto no `InstalledApp`

**Arquivo:** `lib/domain/entities/installed_app.dart`

**Campo adicionado:**
```dart
final bool isGame;
```

**Parsing no `fromMap`:**
```dart
isGame: (map['isGame'] as bool?) ?? false,
```

O default `?? false` garante backward compatibility caso o mapa Kotlin legado não inclua o campo — não acusa sem evidência.

**Sem mudança** no construtor `const InstalledApp(...)` além do novo campo.

---

## 5. Impacto em `getInstalledApps` / Kotlin

**Arquivo:** `android/app/src/main/kotlin/com/allappsengineer/apex_booster_plus/MainActivity.kt`

**Lógica a adicionar dentro do `case "getInstalledApps"`:**

```kotlin
val isGame = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
    info.category == ApplicationInfo.CATEGORY_GAME
} else {
    (info.flags and ApplicationInfo.FLAG_IS_GAME) != 0
}
```

**Map retornado:** adicionar `"isGame" to isGame` às chaves existentes (`appName`, `packageName`).

**Sem nova permissão.** `CATEGORY_GAME` e `FLAG_IS_GAME` são campos públicos de `ApplicationInfo`, acessados via `PackageManager` com as permissões já existentes (`<queries>` com `MAIN/LAUNCHER`).

**Nota de compatibilidade:**
- `CATEGORY_GAME` → API 26+ (Android 8.0 Oreo).
- `FLAG_IS_GAME` → legado, disponível em APIs anteriores, deprecated mas funcional.
- Samsung S24 Ultra roda API 34 — `CATEGORY_GAME` sempre disponível.

---

## 6. Impacto no `AppPickerSheet`

**Arquivo:** `lib/presentation/widgets/app_picker_sheet.dart`

### Badge "JOGO"
- Se `app.isGame == true`: exibe chip/badge verde com texto **"JOGO"** ao lado do nome do app no item da lista.
- Se `app.isGame == false`: sem badge. A ausência de badge é o sinal — não exibir "NÃO JOGO" nem marcação negativa.

### Toggle "Apenas jogos verificados"
- Estado interno: `bool _onlyGames = false` (padrão: off).
- Quando **on**: filtra lista para `app.isGame == true`.
- Quando **off**: exibe lista completa (comportamento atual).
- **Label obrigatória:** `"Apenas jogos verificados"` — não usar `"Apenas jogos"` para não induzir o usuário a acreditar que jogos sem categoria não são jogos reais.

### Confirmação ao selecionar app não classificado
- Usuário toca em item com `app.isGame == false`.
- Exibir `showDialog` com o texto aprovado (seção 2).
- **"Adicionar mesmo assim"** → retorna o app selecionado (comportamento atual preservado).
- **"Cancelar"** → fecha dialog, usuário permanece no picker.
- Usuário toca em item com `app.isGame == true` → sem dialog, fluxo atual direto.

### Implementação da confirmação: posição no fluxo
A confirmação dentro do AppPickerSheet ocorre **antes** de retornar o resultado para `BibliotecaTab`. Dessa forma, se o usuário cancelar, o picker permanece aberto. Se confirmar, o picker fecha e `BibliotecaTab` recebe o resultado normalmente — sem necessidade de um segundo dialog.

---

## 7. Impacto no Fluxo Adicionar por Nome / Manual

**Arquivo:** `lib/presentation/screens/home/tabs/biblioteca_tab.dart`

### Via sugestão de autocomplete (packageName resolvido)
Após resolver `resolvedPkg` via sugestão selecionada ou auto-link:

1. Buscar `InstalledApp` correspondente na lista em cache (`InstalledAppsDatasource`).
2. Se encontrado e `isGame == false` → exibir confirmação (`showDialog`) antes de salvar.
3. Se encontrado e `isGame == true`, ou não encontrado → adicionar normalmente.

### Via entrada manual (texto livre, sem sugestão aceita)
- Comportamento atual **preservado sem alteração**.
- Nenhuma verificação de `isGame` no caminho manual.
- Justificativa: o usuário que digita manualmente está exercendo override consciente. O fallback manual é a válvula de segurança para jogos não reconhecidos pelo Android.
- Bloqueio de `packageName` inválido (não launchable) e de duplicados continuam funcionando normalmente.

### Centralização da confirmação
A confirmação de `isGame` para o fluxo de adicionar por nome reside **exclusivamente em `biblioteca_tab.dart`**, após o retorno do BottomSheet. Isso garante um único ponto de decisão, independente do caminho de entrada (picker, autocomplete, auto-link).

---

## 8. Impacto na Biblioteca (`BibliotecaTab` — display)

**Arquivo:** `lib/presentation/screens/home/tabs/biblioteca_tab.dart`

### Badge retroativo nos cards
- Na inicialização da tab (ou ao recarregar), chamar `InstalledAppsDatasource().getInstalledApps()` — já acontece hoje para ícones; o cache de sessão garante que não há chamada nativa adicional.
- Para cada `ApexGame` com `packageName` não-null: buscar o `InstalledApp` correspondente.
- Se encontrado e `isGame == false` → exibir sinal discreto no card (ex: chip `"Não verificado"` ou ícone `⚠` em cinza suave).
- Se encontrado e `isGame == true` → sem sinal de aviso no card.
- Se `packageName == null`, app desinstalado ou não encontrado na lista → **sem badge** (conservador: não acusa sem evidência).

### O badge não bloqueia nenhuma ação
- Favoritar, remover, navegar para o detalhe e ABRIR JOGO: funcionam normalmente independente do badge.
- O badge é puramente informativo.

---

## 9. Comportamento para Apps Já Salvos

- Nenhum app existente é removido.
- Nenhuma propriedade de `ApexGame` é alterada retroativamente.
- O badge de "Não verificado" pode aparecer nos cards de apps já salvos se:
  - `packageName` estiver vinculado,
  - O app ainda estiver instalado,
  - E `isGame == false` no momento da sessão.
- Se o app foi desinstalado, o card continua exibindo o fallback atual (ícone genérico) sem badge de classificação.
- O usuário não é forçado a reconfirmar nem remover apps já salvos.

---

## 10. O Que Não Será Bloqueado

Esta fase **não bloqueia**:

- Adição de qualquer app via entrada manual (texto livre).
- Adição de app não classificado se o usuário confirmar o dialog.
- ABRIR JOGO em qualquer app da Biblioteca.
- Jogos reais que não declaram `CATEGORY_GAME` no manifesto (Free Fire, PUBG Mobile, Roblox etc.) — eles passam pela confirmação, mas não são impedidos.
- Apps já salvos — permanecem na Biblioteca sem alteração forçada.
- Qualquer funcionalidade existente: favoritar, remover, GFX Profile, Apex Scan, Modo Foco Gamer, Histórico.

---

## 11. Riscos

| Risco | Causa | Severidade | Mitigação |
|---|---|---|---|
| Alta taxa de confirmações para jogos reais | Free Fire, PUBG Mobile, Roblox etc. frequentemente não declaram `CATEGORY_GAME` | Médio (UX) | Copy honesta: "não foi identificado pelo Android". Confirmação de 1 toque. Não bloqueia. |
| Badge retroativo ausente para app desinstalado | `isGame` não verificável sem o app instalado | Baixo | Badge só aparece com evidência (app instalado + `isGame` no cache). Conservador por design. |
| Cache de sessão stale | App instalado durante a sessão não aparece no cache de `getInstalledApps` | Baixo | Comportamento atual — já existe hoje. Classificação é informativa, não crítica. |
| Dialog sobre BottomSheet no picker | `showDialog` com BottomSheet aberto pode gerar conflito de context em casos específicos | Baixo | Confirmação dentro do picker ocorre antes de retornar resultado. Picker fecha normalmente após confirmação. Testar no celular na Fase 2-R.3. |
| `CATEGORY_GAME` ausente em API < 26 | Campo não existe antes do Android 8.0 | Irrelevante para o público-alvo | Fallback para `FLAG_IS_GAME` via `Build.VERSION.SDK_INT >= Build.VERSION_CODES.O` no Kotlin. |
| Falso negativo: jogo real sem categoria | Jogo real que não declara categoria recebe confirmação desnecessária | Médio (UX) | Aceitável. A copy é honesta. O usuário confirma e segue. Não é erro. |

---

## 12. Critérios de Aceite

### Data layer
- [ ] `InstalledApp.isGame` parseia `true` corretamente.
- [ ] `InstalledApp.isGame` parseia `false` corretamente.
- [ ] `InstalledApp.isGame` default é `false` quando `null` no mapa.
- [ ] `getInstalledApps` retorna `isGame: true` para ao menos um app classificado no Samsung S24 Ultra.
- [ ] Cache de sessão propaga `isGame` corretamente.

### AppPickerSheet
- [ ] Badge "JOGO" visível apenas em apps com `isGame == true`.
- [ ] Apps com `isGame == false`: sem badge (ausência é o sinal).
- [ ] Toggle inicia **off** por padrão.
- [ ] Toggle **on**: lista filtrada somente para `isGame == true`.
- [ ] Toggle **off**: lista completa restaurada.
- [ ] Tocar em app não classificado: dialog com texto aprovado aparece.
- [ ] "Adicionar mesmo assim": prossegue normalmente.
- [ ] "Cancelar": picker permanece aberto.
- [ ] Tocar em app classificado: sem dialog, fluxo direto.

### Fluxo de adicionar
- [ ] App classificado como jogo: salva sem confirmação.
- [ ] App não classificado (via autocomplete/auto-link): confirmação obrigatória antes de salvar.
- [ ] Entrada manual sem sugestão aceita: sem verificação de `isGame`.
- [ ] Bloqueio de duplicados preservado.
- [ ] Bloqueio de packageName inválido preservado.

### Biblioteca (display)
- [ ] Cards de apps não classificados com `packageName` vinculado e instalado: badge/sinal discreto visível.
- [ ] Cards de apps classificados como jogo: sem sinal de aviso.
- [ ] Cards sem `packageName` ou com app desinstalado: sem badge.
- [ ] Nenhum app existente removido da Biblioteca.
- [ ] ABRIR JOGO não afetado.
- [ ] Favoritar, remover, GFX Profile, Apex Scan: não afetados.

### Geral
- [ ] `flutter analyze` passando.
- [ ] `flutter test` passando (baseline: 139 testes).
- [ ] Sem crash no Samsung S24 Ultra.
- [ ] Sem tela vermelha.
- [ ] Sem overflow visual.
- [ ] Sem nova permissão adicionada.
- [ ] `AndroidManifest.xml` não alterado.
- [ ] Nenhuma dependência nova adicionada.

---

## 13. Microfases Recomendadas

### 2-R.1 — Detecção Android + Entity (data layer puro)
**Escopo:**
- `MainActivity.kt`: adicionar `isGame` ao map de `getInstalledApps`.
- `InstalledApp`: campo `isGame: bool`.
- `InstalledAppsDatasource`: parsear `isGame`.
- Testes unitários do entity e do datasource (mock do MethodChannel).

**Sem UI nesta microfase.**  
`flutter analyze` + `flutter test` passando antes de avançar.

---

### 2-R.2 — AppPickerSheet: badge + toggle
**Escopo:**
- Badge "JOGO" nos apps classificados.
- Toggle "Apenas jogos verificados" (off por padrão).
- Sem confirmação ainda.

`flutter analyze` + `flutter test` + validação visual no celular antes de avançar.

---

### 2-R.3 — Confirmação obrigatória
**Escopo:**
- AppPickerSheet: dialog ao selecionar não-classificado.
- BibliotecaTab add flow: dialog antes de salvar não-classificado (via autocomplete/auto-link).
- Entrada manual preservada sem verificação.

`flutter analyze` + `flutter test` + validação no celular (fluxo com confirmação, fluxo cancelar, fluxo jogo classificado sem dialog) antes de avançar.

---

### 2-R.4 — Badge retroativo na Biblioteca
**Escopo:**
- Cards da BibliotecaTab: badge discreto para apps não classificados.
- Carregamento via `InstalledAppsDatasource` (cache de sessão).
- Apps sem packageName, desinstalados ou não encontrados: sem badge.

`flutter analyze` + `flutter test` + validação visual no celular antes de avançar.

---

### 2-R.5 — Revisão end-to-end + CLAUDE.md
**Escopo:**
- Teste completo de todos os cenários:
  - Picker → classificado → adicionar direto.
  - Picker → não classificado → confirmar → adicionar.
  - Picker → não classificado → cancelar → picker permanece.
  - Autocomplete → classificado → adicionar direto.
  - Autocomplete → não classificado → confirmar.
  - Manual → sem verificação.
  - Toggle on/off no picker.
  - Badge na Biblioteca: apps salvos não classificados.
  - ABRIR JOGO: funcionamento sem impacto.
- CLAUDE.md atualizado para refletir Fase 2-R concluída.
- Commit somente após aprovação humana.

---

*Design doc escrito em 2026-05-27. Fase 2-R aguarda aprovação para início da implementação (Fase 2-R.1).*
