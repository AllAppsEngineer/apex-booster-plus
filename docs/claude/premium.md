# Camada Premium Memorável — APEX BOOSTER+

> Arquivo auxiliar de `CLAUDE.md`. Não revoga nem substitui regras do arquivo principal.  
> Regra comercial preservada: **free install + one-time unlock**.

A camada premium deve fazer o app parecer referência no segmento, não apenas um utilitário correto. Implementar como acréscimo incremental e controlado. Não recomeçar o app, não redesenhar telas congeladas sem aprovação e não transformar placebo visual em promessa técnica.

---

## Componentes obrigatórios

| Componente | Obrigação operacional | Proibição explícita |
|---|---|---|
| Apex Visual System | Criar Apex Core, Apex Ring, Apex Pulse, Apex Grid e Status Chips reutilizáveis | Não usar para sugerir CPU/GPU/FPS real. |
| Apex Ritual Cinematográfico | Refinar Boost Apex como ritual curto, bonito e honesto | Não bloquear abertura do jogo nem prometer boost real. |
| Apex Result Card | Criar fechamento visual com dados seguros e CTA Abrir Jogo | Não exibir FPS/ping inventados ou dados sensíveis. |
| Honest Booster Mode | Explicar o que o app faz e não faz | Não esconder limitações técnicas. |
| Session Profiles | Reposicionar GFX/foco/visual como perfis de sessão | Não afirmar alteração de engine, resolução ou arquivos do jogo. |
| Widget e Quick Actions | Reduzir atrito e aumentar recorrência | Não exibir "FPS boost ativo", "ping reduzido" ou "RAM limpa". |
| Badges e Resumo Semanal | Enriquecer histórico local | Não criar gamificação abusiva ou notificação insistente. |
| Temas Contextuais | Valor visual premium | Não dizer que tema melhora performance. |

---

## Fases operacionais

| Fase | Nome | Objetivo | Dependência | Evidência mínima |
|---|---|---|---|---|
| PREMIUM-U1 | Apex Visual System | Criar tokens/componentes Apex Core, Ring, Pulse, Grid e Status Chips | Design atual | Screenshots Home/Preparar/Resultado e teste de overflow. |
| PREMIUM-U2 | Apex Ritual Cinematográfico | Refinar Boost Apex em fluxo curto com etapas reais/simbólicas | PREMIUM-U1 | Vídeo ou sequência de screenshots + validação de copy. |
| PREMIUM-U3 | Apex Result Card | Criar card pós-preparo com jogo, perfil, tempo, status e CTA | PREMIUM-U2 | Screenshot de card e teste de abertura do jogo. |
| TRUST-U1 | Honest Booster Mode | Criar explicação clara sobre FPS, ping, RAM, unlock e limites técnicos | Strings/i18n | PT-BR/EN/ES validados. |
| PROFILE-U1 | Session Profiles | Expandir GFX para perfis Balanced, Focus, Visual, Battery Mindful e Custom | Persistência local | Teste de salvar/carregar por jogo. |
| RETENTION-U1 | Badges locais | Criar badges de uso, recorrência e variedade | Histórico | Teste de persistência local. |
| RETENTION-U2 | Resumo Semanal Local | Criar card "Sua semana gamer" | RETENTION-U1 | Dados locais coerentes e copy segura. |
| CONVENIENCE-U1 | Quick Actions | Atalhos do ícone do app | Navegação estável | Teste em aparelho/emulador Android. |
| CONVENIENCE-U2 | Widget Premium | Widget de favorito/última sessão | Favoritos estáveis | Screenshot do widget e teste de atualização. |
| SHARE-U1 | Share Card Seguro | Compartilhamento opcional do Result Card | PREMIUM-U3 | Arquivo/imagem gerado sem dados sensíveis. |
| THEME-U1 | Temas Contextuais | Tema visual por jogo/perfil | PREMIUM-U1 | Screenshots comparativos e validação de contraste. |
| ACCESS-U1 | Modo Baixa Distração | Reduzir animações, brilho, haptics e duração | Motion System | Toggle funcional e validação visual. |

---

## Contrato de copy — funcionalidades premium

Toda copy nova em `AppStrings` para PT-BR, EN e ES. Sem strings hardcoded. Linguagem de preparação e experiência; nunca linguagem de ganho técnico não comprovado.

| Contexto | Copy aprovada PT-BR | Copy proibida |
|---|---|---|
| Ritual | "Sessão pronta para abrir." | "FPS aumentado." |
| Perfil | "Perfil da sessão carregado." | "Configuração interna do jogo aplicada." |
| Result Card | "Preparado em 6s." | "Jogo otimizado em 6s." |
| Widget | "Preparar favorito." | "Ativar turbo real." |
| Honest Mode | "Não prometemos aumento real de FPS." | "Boost garantido em todos os jogos." |
| Badge | "5 sessões esta semana." | "Performance melhorada 5 vezes." |
| Tema | "Tema visual aplicado ao Apex." | "Gráficos do jogo melhorados." |
| Checklist | "Conexão verificada." | "Ping reduzido." |

---

## Session Profiles — compatibilidade com GFX Profile

Session Profiles são camada semântica acima das preferências locais existentes. Reutilizam GFX Profile, Modo Foco e preferências visuais, mas não declaram alterações reais no jogo.

| Session Profile | Composição permitida | Observação |
|---|---|---|
| Balanced | Ritual normal, tema padrão, checklist básico e GFX Equilibrado quando aplicável | Perfil padrão e seguro. |
| Focus | Modo Foco, animação reduzida, CTA direto e chips de foco | Respeitar opt-in do usuário. |
| Visual | Apex Core completo, tema premium e Result Card destacado | Valor premium visual. |
| Battery Mindful | Motion reduzido, brilho menor e ritual curto | Não prometer economia real sem medição. |
| Custom | Preferências de tema, duração, haptic, favoritos e checklist | Pode exigir persistência mais estruturada. |

Se a implementação exigir Hive, BLoC, DI, Firebase, Billing ou nova permissão: abrir fase específica e pedir aprovação.

---

## Widget e Quick Actions — limitações Android

| Recurso | Permitido | Bloqueado |
|---|---|---|
| Widget de favorito | Mostrar jogo favorito, botão preparar e última sessão | Mostrar FPS/ping/boost real. |
| Widget médio | Mostrar 2 a 4 favoritos | Coletar dados externos sem necessidade. |
| Widget de resultado | Mostrar última sessão local | Expor informações sensíveis. |
| Quick Action favorito | Abrir fluxo de preparação | Pular disclaimers obrigatórios quando necessários. |
| Quick Action histórico | Abrir Histórico | Alterar fluxo central sem teste. |

Não adicionar plugin nativo sem justificar impacto no build, privacidade e testes.

---

## Badges, Streaks e Resumo Semanal

| Item | Regra |
|---|---|
| Badges | Locais, discretos e baseados em eventos reais do app. |
| Streaks | Informativos, não punitivos. |
| Resumo semanal | Somente histórico local e linguagem neutra. |
| Histórico enriquecido | Não pode inventar melhoria de performance. |
| Privacidade | Não sincronizar com servidor sem nova decisão de arquitetura e política. |

---

## Share Card Seguro

| Elemento | Status |
|---|---|
| Nome do jogo | Permitido. |
| Ícone/arte visual do app | Permitido. |
| Badge local | Permitido. |
| Tempo de preparação real | Permitido. |
| FPS, ping, CPU, GPU, RAM como melhoria | Proibido. |
| Modelo do dispositivo | Proibido por padrão. |
| Lista de apps instalados | Proibido. |
| Identificadores do usuário/dispositivo | Proibido. |

---

## Honest Booster Mode — respostas recomendadas no app

| Pergunta do usuário | Resposta dentro do app |
|---|---|
| "O app aumenta FPS?" | "O Apex Booster+ não promete aumento real de FPS. Ele prepara sua sessão com organização, perfis, foco e experiência visual." |
| "O app reduz ping?" | "Ping depende da rede, servidor e operadora. O Apex Booster+ evita prometer controle sobre isso." |
| "O que o unlock libera?" | "Temas, ritual premium, perfis avançados, histórico completo, badges, widget e cards." |
| "Por que usar antes de jogar?" | "Para entrar com seus jogos organizados, perfil carregado e uma rotina visual de foco." |

---

## Apex Ritual Cinematográfico — etapas

| Etapa | Nome | Tipo de valor | Texto seguro |
|---|---|---|---|
| 1 | Game Lock | Seleção real do jogo | "Jogo selecionado." |
| 2 | Profile Load | Perfil local | "Perfil da sessão carregado." |
| 3 | Focus Prep | Ajuste/opção real quando disponível | "Preferências de foco prontas." |
| 4 | Visual Sync | Feedback simbólico | "Apex visual ativo." |
| 5 | Ready State | Conclusão | "Sessão pronta para abrir." |

---

## Matriz free install vs one-time unlock

| Camada | Free install | One-time unlock |
|---|---|---|
| Biblioteca | Uso essencial e abertura de jogos | Conveniência avançada, favoritos refinados e atalhos. |
| Preparação | Ritual básico e honesto | Apex Ritual completo e variações visuais premium. |
| Perfis | Perfil/GFX básico | Session Profiles avançados e Custom. |
| Resultado | Resultado simples | Apex Result Card premium e Share Card seguro. |
| Histórico | Histórico essencial | Badges, streaks e resumo semanal local. |
| Visual | Tema padrão | Temas contextuais e skins visuais. |
| Conveniência | Navegação pelo app | Widget e Quick Actions. |
| Confiança | Honest Booster Mode | Também disponível; confiança não é paywall. |

---

## Temas contextuais

| Tema | Personalidade | Uso recomendado |
|---|---|---|
| Neon Green | Clássico gamer | Padrão Apex. |
| Cyber Blue | Tecnologia e precisão | Jogos competitivos. |
| Inferno Orange | Energia e ação | Shooters e corrida. |
| Purple Void | Estética futurista | RPGs e jogos sci-fi. |
| Minimal Pro | Discreto e limpo | Usuários que preferem menos glow. |

Copy: o tema muda a experiência visual do Apex Booster+, nunca o desempenho técnico do jogo.

---

## Apex Focus Checklist

| Item | Tipo | Automação possível |
|---|---|---|
| Bateria suficiente | Real | Leitura de nível de bateria. |
| Volume pronto | Real/parcial | Verificação ou lembrete. |
| Conexão adequada | Real/parcial | Indicar Wi-Fi/dados sem prometer ping. |
| Modo foco | Real se opt-in | Atalho para configuração. |
| Notificações | Real se permissão existir | Orientar usuário. |
| Perfil da sessão | Local | Carregar preferências. |

---

## Lacunas competitivas que motivam esta camada

Os concorrentes são fortes em promessas simples, mas pouco exploram: narrativa de preparação, recompensa visual pós-sessão, honestidade explícita, badges locais, perfis de sessão com linguagem segura e monetização transparente.

| Área | Lacuna dos concorrentes | Oportunidade Apex |
|---|---|---|
| Booster visual | Pouca identidade proprietária | Apex Core, Ring e Pulse. |
| Resultado final | Normalmente inexistente | Apex Result Card. |
| Retenção | Poucos motivos emocionais | Badges, streaks e resumo semanal. |
| Transparência | Claims agressivos | Honest Booster Mode. |
| Monetização | Ads, assinaturas confusas | free install + one-time unlock claro. |

> **Tese final:** o Apex Booster+ não é "game booster" — é o **ritual premium de entrada em jogo no Android**.
