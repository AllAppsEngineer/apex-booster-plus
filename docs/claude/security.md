# Segurança — APEX BOOSTER+ (OWASP LLM Top 10)

> Arquivo auxiliar de `CLAUDE.md`. Não revoga nem substitui regras do arquivo principal.

Toda API interna, serviço, integração futura, fluxo de Billing, restore purchase, unlock, métricas, score, sessão, telemetria local ou lógica sensível deve ser projetada contra manipulação, abuso, injeção e vazamento de dados, seguindo controles inspirados no OWASP LLM Top 10. Aplicar com recursos gratuitos do próprio projeto: sem dependência paga sem aprovação.

---

## S1. Prevenção contra Prompt Injection e Injeção de Dados

- Tratar todas as entradas de usuário como dados não confiáveis.
- Separar dados textuais, nomes de jogos, `packageName`, histórico, métricas, logs e preferências de qualquer instrução de execução.
- Validar tipo, tamanho e formato de entradas sensíveis com regras explícitas.
- Nunca confiar em lógica crítica executada só no cliente quando houver backend, Billing, unlock, restore purchase, score ou validação remota.
- Nenhum texto vindo do usuário, app instalado, nome de jogo, resposta externa ou campo persistido pode alterar regras internas do produto.
- Nomes de jogos, labels, mensagens de erro e dados persistidos são conteúdo, nunca comando.
- Integrações futuras com IA: prompts e dados separados por estrutura clara; saídas consideradas não confiáveis até validação.

---

## S2. Prevenção contra Insecure Output Handling

- Sanitizar e normalizar toda saída antes de renderização, persistência, logs, relatórios ou integrações.
- Não inserir conteúdo externo diretamente em UI, banco local, logs ou APIs futuras sem validação.
- Se houver backend/BD/painel no futuro, encodar outputs para reduzir risco de SQL/NoSQL injection, XSS, log injection ou corrupção.
- Mensagens geradas por IA (caso existam): tratar como conteúdo não confiável até validação.
- Textos de UI via `AppStrings` quando forem copy do produto; validados/normalizados quando de origem externa.
- Logs úteis para depuração, nunca canal de vazamento de dados sensíveis.

---

## S3. Prevenção contra Sensitive Data Disclosure

- Não expor dados sensíveis, identificadores privados, tokens, chaves, recibos de compra, logs brutos ou informações pessoais em telas, logs, commits ou relatórios.
- Mascarar dados sensíveis antes de trafegar, registrar ou usar em contexto de IA.
- **Nunca commitar:** secrets, keystore, `key.properties`, `google-services.json`, chaves privadas, tokens de API ou credenciais.
- Política de privacidade deve refletir exatamente os dados usados pelo app.
- Recibos de compra, status de unlock, IDs de transação, identificadores de dispositivo e dados de diagnóstico não devem aparecer integralmente em UI, prints públicos, logs de produção ou documentação compartilhável.
- Antes de Firebase, Billing, backend ou Play Console: revisar se dados trafegados estão cobertos pela política de privacidade.

---

## S4. Blindagem de APIs, Billing, Métricas e Unlock

Regras preventivas para fases futuras. Aplicar apenas quando houver backend, API remota, Billing, restore, unlock, score, telemetria ou sincronização externa.

| Controle | Obrigação |
|---|---|
| HMAC | Requisições que enviem/validem pontuação, unlock, recibo, sessão ou métrica sensível devem usar HMAC ou equivalente gerado em ambiente confiável. Nunca hardcoded no cliente. |
| Validação de estado | Progresso, sessão, compra, restore, unlock e status premium devem respeitar sequência cronológica válida. Não aceitar estado alto sem registros anteriores coerentes. |
| Rate limiting | Limitar chamadas sensíveis por usuário, dispositivo, compra, IP ou identificador equivalente quando houver backend. |
| Replay protection | Usar timestamp, nonce ou equivalente em APIs futuras sensíveis. |
| Server-side validation | Compras, restore, unlock e estados comerciais não devem depender exclusivamente de flags locais em release comercial. |
| Logs seguros | Nunca registrar recibos completos, tokens, secrets, HMAC, payloads sensíveis ou dados privados em logs de produção. |
| Client-side flags | Permitidas para desenvolvimento/protótipo/cache local; não são verdade comercial em release com Billing real. |
| Fallback de unlock | Qualquer fallback local de desenvolvimento deve ser explicitamente bloqueado ou removido no build de release. |

---

## S5. Segurança Gratuita Obrigatória no Fluxo de Desenvolvimento

Sem dependências pagas, todo código que toque dados sensíveis, Billing, unlock, métricas, sessões, logs, IA, backend ou validação de estado deve aplicar, quando fizer sentido:

- validação de entrada por tipo, tamanho e formato;
- normalização de strings antes de persistir ou comparar;
- whitelists para valores esperados;
- tratamento seguro de erro sem expor stack trace ao usuário;
- logs mínimos e mascarados;
- testes unitários para entradas inválidas, vazias, longas, malformadas e inesperadas;
- revisão de `git diff` antes de commit;
- verificação de que nenhum secret foi incluído no repositório;
- execução de `flutter analyze`, `flutter test` e checker de strings quando houver copy.

---

## S6. Autoauditoria Obrigatória antes de Entregar Código

Antes de entregar qualquer trecho que toque APIs, Billing, unlock, restore, métricas, score, sessões, logs, IA, backend ou dados sensíveis, listar:

1. Quais regras desta seção foram aplicadas.
2. Quais riscos foram considerados.
3. Quais dados foram tratados como não confiáveis.
4. Quais validações foram adicionadas.
5. Quais pontos continuam fora de escopo ou dependem de fase futura.

---

## Permissões e privacidade — regras operacionais

| Recurso | Regra |
|---|---|
| Apps instalados | Usar escopo justificado e fallback. |
| Modo Foco / DND | Opt-in, reversível e não bloqueante. |
| Internet | Apenas com função real e política correspondente. |
| Firebase | Sem Analytics; só Crashlytics/Remote Config se aprovado. |
| Ads/Analytics/Atribuição | Proibidos no MVP. |
| Billing | Apenas com fase aprovada e Play Console pronto. |

Antes da loja: publicar Política de Privacidade em URL pública real e ativar link funcional no app.

---

## S10. SYSTEM_ALERT_WINDOW — Botão Flutuante Apex (SOCIAL-U2A)

- **Finalidade:** exibir botão de acesso rápido sobre outros apps durante sessão gamer.
- **Solicitação:** apenas após consentimento explícito do usuário em Configurações (`CaptureConsentSheet`). Nunca solicitada automaticamente.
- **Uso exclusivo:** botão flutuante social. Não utilizado para coleta de dados, anúncios, rastreamento ou qualquer outra finalidade.
- **Desativação:** toggle em Configurações → `FloatingCaptureService.disable()` + `FlutterOverlayWindow.closeOverlay()`.
- **Captura automática:** proibida. O botão é um atalho para a galeria do usuário ou para o Apex Studio.
- **Compartilhamento automático:** proibido. Toda publicação exige ação explícita do usuário no Apex Studio.
- **Disclosure obrigatória:** deve constar na Política de Privacidade publicada antes do release (seção sobre permissões especiais / overlay).
- **Fase seguinte (SOCIAL-U2B):** se MediaProjection for implementada, exigirá `FOREGROUND_SERVICE`, disclosure adicional e fase própria aprovada separadamente.
