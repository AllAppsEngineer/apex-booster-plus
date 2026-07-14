# Especificações de Assets Gráficos — Play Store

---

## Ícone — 512×512

| Atributo | Valor |
|---|---|
| Dimensão | 512×512 pixels exatos |
| Formato | PNG 32 bits com canal alfa |
| Fundo | Com fundo — não usar fundo transparente |
| Cor de fundo recomendada | `#050505` ou `#080808` (background profundo Apex) |
| Elemento central | Logo/símbolo Apex com verde `#22C55E` ou azul `#3B82F6` |
| Zona segura | 10% em cada borda (51px) — nenhum elemento cortado nessa margem |
| Estilo | Dark premium, gamer, sem texto |
| Adaptive icon | O `ic_launcher` Flutter gera as camadas; este 512×512 é o arquivo estático separado para a Play Console |
| Nome de arquivo | `icon/ic_launcher_play_store.png` |

### O que evitar

- Texto legível dentro do ícone
- Bordas arredondadas manuais (Android aplica o adaptive icon shape automaticamente)
- PNG com artifacts de compressão JPEG
- Ícone genérico de raio, trovão ou joystick sem identidade Apex
- Fundo branco ou transparente

---

## Feature Graphic — 1024×500

| Atributo | Valor |
|---|---|
| Dimensão | 1024×500 pixels exatos |
| Formato | JPEG ou PNG 24 bits (sem canal alfa) |
| Zona segura | Manter conteúdo fora dos 5% das bordas (~51px laterais, ~25px vertical) |
| Nome de arquivo | `feature_graphic/feature_graphic_1024x500.jpg` |

### Composição recomendada

```
[fundo #050505 com partículas neon verdes/azuis suaves]
[centro-esquerda] Logo Apex Booster + (símbolo + nome)
[centro-direita ou abaixo] "Prepare. Scan. Play." em branco #FFFFFF
[sem bordas arredondadas no arquivo — a loja aplica]
```

### Texto na feature graphic

- Máximo 2 linhas de texto
- Fonte grande, contraste alto sobre fundo escuro
- Usar tagline em inglês como língua franca: **"Prepare. Scan. Play."**
- Tamanho de fonte mínimo recomendado: 48pt equivalente

### Contexto de uso na Play Store

Exibida no topo da ficha quando o app está em destaque ou em resultados de busca.
Deve funcionar sozinha, sem o ícone ao lado.

### O que evitar

- Screenshots dentro da feature graphic (redundante com a galeria)
- Texto muito pequeno (ilegível em mobile)
- Bordas brancas ou fundo branco
- QR codes ou URLs
- Elementos cortados pela zona de segurança
- Texto em idioma diferente do inglês (para máxima compatibilidade)

---

## Tokens visuais de referência

| Token | Valor |
|---|---|
| Background profundo | `#050505` / `#080808` |
| Verde Apex | `#22C55E` |
| Azul Cyber | `#3B82F6` |
| Laranja energia/alerta | `#F97316` |
| Texto principal | `#FFFFFF` |
| Texto secundário | `#A1A1AA` |
