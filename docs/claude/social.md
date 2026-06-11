# Apex Social Capture & Share Layer — APEX BOOSTER+

> Arquivo auxiliar de `CLAUDE.md`. Não revoga nem substitui regras do arquivo principal.  
> Regra comercial preservada: **free install + one-time unlock**.

A camada **Apex Social Capture & Share Layer** é uma ferramenta de **expressão gamer, evolução pessoal e compartilhamento social**. Não é um boost de performance. Implementar como extensão incremental do produto, nunca como substituição de telas e fluxos existentes.

> **Regra soberana:** o APEX BOOSTER+ pode ajudar o usuário a registrar e compartilhar sua jornada gamer, mas **nunca pode capturar, gravar, publicar, expor ou inferir dados sem ação explícita e consentimento claro do usuário**.

---

## Regras operacionais da camada social

| Regra | Obrigação |
|---|---|
| Incrementalidade | Implementar por fases pequenas, com testes visuais e funcionais. |
| Consentimento | Solicitar permissão apenas quando o usuário ativar recurso que realmente precisa dela. |
| Controle do usuário | Permitir cancelar, revisar, editar, excluir e exportar manualmente. |
| Não automação social | Nunca postar automaticamente em TikTok, Instagram, YouTube, WhatsApp ou qualquer rede. |
| Segurança | Não capturar notificações, conversas, identificadores, lista de apps ou dados sensíveis por padrão. |
| Honestidade | Não transformar captura social em claim de desempenho. |
| Performance | Não inserir overlay pesado ou animações que prejudiquem gameplay. |
| Fallback | Permitir uso via importação de galeria caso overlay/gravação não sejam viáveis. |

---

## Fases obrigatórias de implementação social

A ordem abaixo deve ser respeitada, salvo aprovação humana explícita. A captura com overlay vem depois do Share Studio porque o editor social entrega valor com menor risco técnico.

| Fase | Nome | Objetivo | Evidência mínima |
|---|---|---|---|
| SOCIAL-U1 | Apex Share Studio | Criar editor de card com tema, legenda, badge e exportação local | Screenshots dos layouts 9:16 e 1:1. |
| SOCIAL-U2 | Apex Evolution Card | Criar cards com sessões, jogos favoritos, badges e streaks locais | Dados locais coerentes e copy validada. |
| SOCIAL-U3 | Importação da galeria | Permitir selecionar screenshot/clipe escolhido pelo usuário | Teste de seleção, cancelamento e exportação. |
| SOCIAL-U4 | Social Export Presets | Gerar 9:16, 1:1 e 16:9 | Verificação de cortes, margens e legibilidade. |
| SOCIAL-U5 | Privacy Guard | Criar telas de consentimento e revisão | Textos PT-BR, EN e ES. |
| SOCIAL-U6 | Apex Floating Capture Button | Implementar botão flutuante opt-in, móvel e desativável | Teste em Android e prova de não interferência. |
| SOCIAL-U7 | Short Clip Capture | Implementar captura curta assistida, se viável | Teste de permissão, cancelamento, arquivo e exportação. |

---

## Apex Floating Capture Button — regras específicas

Só pode ser implementado com **opt-in explícito**. Tratar como recurso sensível — pode envolver sobreposição sobre outros apps e captura de tela. Não adicionar plugin, permissão ou código nativo sem justificar impacto, riscos e testes.

| Área | Regra operacional |
|---|---|
| Ativação | O botão só aparece após o usuário ativar manualmente o recurso. |
| Permissão | Solicitar permissão de overlay apenas no momento necessário e com explicação clara. |
| Desativação | O usuário deve conseguir ocultar, minimizar ou desligar o botão. |
| Movimento | O botão deve ser reposicionável para não atrapalhar controles do jogo. |
| Copy | Usar "Capturar momento", "Marcar clipe" ou "Abrir Share Studio". |
| Proibição | Nunca usar "ativar boost", "vantagem", "turbo real", "FPS" ou "ping". |
| Performance | O overlay deve ser leve e compatível com Modo Baixa Distração. |
| Loja | Validar permissões e descrições antes de release. |

---

## Apex Share Studio — regras específicas

O Share Studio é o núcleo da camada social. Funciona mesmo sem overlay, usando dados locais e mídia escolhida pelo usuário.

| Item | Regra operacional |
|---|---|
| Entrada de mídia | Usar screenshot/clipe importado ou card gerado pelo Apex. |
| Dados permitidos | Sessões, jogos favoritos, badges, streaks, perfil usado e tempo de preparação real. |
| Dados proibidos | FPS, ping, CPU, GPU, RAM como melhoria, rank não autorizado, conversas, notificações e identificadores. |
| Publicação | Usar compartilhamento nativo; o usuário escolhe destino e confirma postagem fora do Apex. |
| Rascunhos | Salvar localmente se implementado, sem sincronização automática. |
| Watermark | Opcional ou claramente configurável conforme estratégia comercial. |
| Templates | Não usar assets protegidos de jogos sem permissão. |

---

## Copy permitida e proibida — camada social

Toda copy em `AppStrings` em PT-BR, EN e ES. Linguagem de expressão, jornada, captura e compartilhamento; nunca desempenho técnico falso.

| Contexto | Copy permitida PT-BR | Copy proibida |
|---|---|---|
| Botão flutuante | "Capturar momento" | "Ativar vantagem no jogo" |
| Botão flutuante | "Marcar clipe" | "Turbo real ativado" |
| Share Studio | "Criar card para TikTok/Reels" | "Mostrar FPS aumentado" |
| Evolução | "Sua jornada no Apex" | "Sua performance no jogo melhorou" |
| Exportação | "Exportar para compartilhar" | "Postar automaticamente no TikTok" |
| Watermark | "Prepared with Apex Booster+" | "Boost real aplicado" |
| Screenshot | "Selecionar captura" | "Capturar tudo em segundo plano" |
| Clipe curto | "Gravar clipe curto" | "Gravar suas partidas automaticamente" |
| Privacidade | "Você revisa antes de compartilhar" | "Compartilharemos por você" |
| Badge | "5 sessões preparadas esta semana" | "5 partidas otimizadas com ganho real" |
| Perfil | "Perfil da sessão usado" | "Configuração interna do jogo alterada" |
| TikTok/Reels | "Formato vertical pronto para exportar" | "Publique sem revisar" |

---

## Matriz de permissões — camada social

Nenhum recurso social solicita permissão antes de existir uma razão clara e uma ação do usuário.

| Recurso | Permissão possível | Quando pedir | Bloqueio obrigatório |
|---|---|---|---|
| Importar imagem/clipe | Acesso seletivo à mídia ou picker do sistema | Quando usuário escolher importar | Não varrer galeria inteira. |
| Floating Button | Sobreposição sobre outros apps | Quando usuário ativar botão flutuante | Não ativar por padrão. |
| Captura de tela | Consentimento de captura/sistema | Quando usuário iniciar captura | Não capturar silenciosamente. |
| Microfone | Gravação de áudio | Somente se houver narração opt-in | Não gravar áudio por padrão. |
| Notificações | Preferencialmente nenhuma | Evitar no MVP social | Não usar notificação como pressão de streak. |
| Compartilhamento | Share sheet nativa | Quando usuário tocar em exportar | Não postar automaticamente. |

---

## Critérios de rejeição automática — camada social

| Critério de rejeição | Motivo |
|---|---|
| Captura sem consentimento | Viola privacidade e confiança. |
| Postagem automática | Retira controle do usuário. |
| Uso de FPS/ping inventados em card social | Viola honestidade técnica. |
| Coleta de conversas/notificações/lista de apps | Exposição sensível desnecessária. |
| Overlay obrigatório | Pode prejudicar gameplay e políticas de loja. |
| Plugin nativo sem justificativa | Aumenta risco de build e manutenção. |
| Watermark enganosa | Pode sugerir boost real inexistente. |
| Gamificação agressiva | Pode gerar pressão indevida. |

---

## Matriz free install vs one-time unlock — camada social

| Função social | Free install | One-time unlock |
|---|---|---|
| Card básico | Permitido | Mais templates, temas e estilos. |
| Evolution Card | Básico | Badges, streaks, resumo semanal e variações visuais. |
| Exportação 9:16 | Básica | Presets avançados e controle de watermark. |
| Share Studio | Essencial | Molduras premium e rascunhos locais. |
| Floating Capture Button | Limitado ou prévia | Completo, personalizável e integrado ao Share Studio. |
| Privacy Guard | Sempre disponível | Sempre disponível; privacidade não é paywall. |

---

## Regra final da camada social

A camada social deve aumentar desejo de download, compartilhamento orgânico e valor percebido sem violar a verdade do produto. O APEX BOOSTER+ pode ajudar o usuário a preparar sua sessão, registrar momentos e compartilhar sua evolução gamer; ele não pode prometer vantagem competitiva, alteração de desempenho, automação invisível ou captura sem consentimento.
