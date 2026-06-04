# Política de Privacidade — Apex Booster+

**Última atualização:** a definir antes da publicação na Play Store.

---

## 1. Identificação do Responsável

**Nome do app:** Apex Booster+  
**Desenvolvedor / Responsável:** AllAppsEngineer  
**Contato oficial:** a definir antes da publicação *(placeholder — substituir por e-mail real antes de publicar)*.

---

## 2. Dados Armazenados Localmente

O Apex Booster+ **não possui servidor próprio** e **não envia dados pessoais para servidores externos**.

Todos os dados são armazenados exclusivamente no dispositivo do usuário, via `SharedPreferences` do Android:

| Dado | Finalidade |
|---|---|
| Biblioteca de jogos adicionados | Exibir e gerenciar a lista de jogos do usuário |
| `packageName` dos jogos | Identificar e abrir o app correspondente |
| Perfil GFX local por jogo | Salvar preferência visual escolhida pelo usuário |
| Histórico de sessões | Exibir sessões anteriores e métricas locais |
| Idioma selecionado | Manter a preferência de idioma entre sessões |
| Flag de onboarding concluído | Evitar exibir o tutorial na reabertura do app |

Esses dados **não são sincronizados, vendidos ou compartilhados** com terceiros.

---

## 3. Leituras Locais do Dispositivo

O app realiza as seguintes leituras **locais** para fins informativos:

- **RAM disponível e total:** leitura da memória do dispositivo para exibir snapshot da sessão.
- **Latência básica de rede (Apex Ping):** teste de conectividade próprio do app para avaliar a qualidade da conexão no momento da sessão. **Não representa nem promete o ping real de servidores de jogos externos.**
- **Estado do Modo Foco / Não Perturbe (DND):** verificado apenas quando o usuário concede a permissão `ACCESS_NOTIFICATION_POLICY`. Não ativado automaticamente.

Essas leituras **não são enviadas para nenhum servidor**.

---

## 4. Uso de Internet

O app utiliza a permissão `INTERNET` exclusivamente para o **teste básico de latência/conectividade** mencionado acima (Apex Ping). Nenhuma outra comunicação de rede é realizada.

O app **não coleta, transmite nem armazena** dados em servidores externos.

---

## 5. Apps Instalados

Para permitir que o usuário selecione jogos da sua biblioteca de apps instalados, o Apex Booster+ pode listar apps iniciáveis disponíveis no dispositivo (via `intent` `MAIN/LAUNCHER`).

- **Sem `QUERY_ALL_PACKAGES`:** o app não solicita acesso irrestrito à lista de apps.
- **Sem envio externo:** a lista de apps instalados **nunca é enviada para servidores**.
- **Controle do usuário:** o usuário decide quais apps adicionar à biblioteca. O app não faz varredura automática nem exporta dados.

---

## 6. Dados NÃO Coletados

O Apex Booster+ **não coleta** nenhum dos seguintes dados:

- Nome, e-mail ou qualquer identificador pessoal.
- Localização precisa ou aproximada.
- Contatos, fotos, vídeos ou arquivos pessoais.
- Mensagens, chamadas ou dados de comunicação.
- Informações financeiras ou de pagamento nesta versão.
- Dados de uso detalhado de apps (sem `PACKAGE_USAGE_STATS`).
- Dados biométricos.
- Identificadores de publicidade.

---

## 7. Compartilhamento de Dados

O Apex Booster+ **não vende, não aluga e não compartilha dados pessoais** com anunciantes, parceiros ou terceiros.

Não há:
- SDK de anúncios.
- SDK de analytics de terceiros (ex: Firebase Analytics, Mixpanel, Amplitude).
- Rastreamento de comportamento para fins publicitários.

---

## 8. Permissões Utilizadas

| Permissão | Finalidade |
|---|---|
| `INTERNET` | Teste básico de latência (Apex Ping) |
| `ACCESS_NOTIFICATION_POLICY` | Modo Foco Gamer (Não Perturbe) — somente quando o usuário concede |

Nenhuma permissão sensível adicional é solicitada nesta versão.

---

## 9. Limites e Avisos Importantes

- O Apex Booster+ **não altera jogos de terceiros automaticamente**.
- O app **não promete melhoria real de FPS, GPU, resolução, ping ou desempenho** de jogos externos.
- As métricas exibidas (RAM, latência Apex) são **locais e informativas** — não representam alteração automática do dispositivo ou dos jogos.
- O Modo Foco Gamer ativa o Não Perturbe do Android somente quando o usuário concede a permissão explicitamente.

---

## 10. Segurança dos Dados

Como todos os dados são armazenados localmente no dispositivo via `SharedPreferences`, a segurança depende das proteções nativas do Android (sandbox de app, criptografia do sistema de arquivos quando habilitada pelo dispositivo).

O app não transmite dados, portanto não há risco de interceptação de rede.

---

## 11. Crianças

O Apex Booster+ **não é direcionado a crianças menores de 13 anos** e não coleta conscientemente dados de menores.

---

## 12. Alterações nesta Política

Esta política pode ser atualizada antes ou após a publicação na Play Store. A data de "Última atualização" no topo do documento refletirá a versão vigente.

---

## 13. Contato

Para dúvidas, solicitações de exclusão de dados (aplicável a dados locais no dispositivo) ou qualquer questão relacionada à privacidade:

**E-mail de contato:** *(a definir antes da publicação — placeholder)*

---

*Esta política foi elaborada para o Apex Booster+ — desenvolvido por AllAppsEngineer.*
