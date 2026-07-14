# Política de Privacidade — Apex Booster+

**Última atualização:** a definir antes da publicação na Play Store.

---

## 1. Identificação do Responsável

**Nome do app:** Apex Booster+  
**Desenvolvedor / Responsável:** AllAppsEngineer  
**Contato oficial:** digitaldefense.ai@gmail.com

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

A mídia selecionada pelo usuário no Apex Studio (imagem ou vídeo) **não é salva nas preferências locais** — é usada apenas em memória durante a sessão, para compor o card social, e descartada quando o usuário fecha a tela.

Esses dados **não são sincronizados, vendidos ou compartilhados** com terceiros.

---

## 3. Leituras Locais do Dispositivo

O app realiza as seguintes leituras **locais** para fins informativos:

- **RAM disponível e total:** leitura da memória do dispositivo para exibir snapshot da sessão.
- **Latência básica de rede (Apex Ping):** teste de conectividade próprio do app para avaliar a qualidade da conexão no momento da sessão. **Não representa nem promete o ping real de servidores de jogos externos.**
- **Estado do Modo Foco / Não Perturbe (DND):** verificado apenas quando o usuário concede a permissão `ACCESS_NOTIFICATION_POLICY`. Não ativado automaticamente.
- **Acesso a mídia via Apex Studio:** quando o usuário abre o Apex Studio e seleciona voluntariamente uma imagem ou vídeo da galeria do sistema, o arquivo é lido localmente para composição do card. A operação ocorre somente mediante ação explícita do usuário pelo seletor de mídia nativo do Android. A mídia **nunca é enviada para servidores externos**.

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

## 6. Apex Studio e Compartilhamento Social

O **Apex Studio** é o recurso de criação de cards sociais do app. Ele permite que o usuário:

- Selecione voluntariamente uma imagem ou vídeo da galeria do dispositivo para usar como fundo do card;
- Pré-visualize vídeos selecionados diretamente no app;
- Gere um card visual com dados de preparação gamer (sessão, jogo, perfil GFX, etc.);
- Exporte o card gerado como imagem e compartilhe manualmente via o sistema de compartilhamento nativo do Android.

### Pontos importantes sobre privacidade no Apex Studio

| Item | Esclarecimento |
|---|---|
| Acesso à mídia | Somente quando o usuário abre o seletor de galeria e escolhe um arquivo |
| Processamento | Local, apenas em memória durante a sessão |
| Transmissão | Nenhuma — a mídia não é enviada para servidores |
| Compartilhamento | Sempre iniciado manualmente pelo usuário — o app nunca posta ou publica automaticamente |
| Exportação de imagem | Disponível — gera um card JPG/PNG compartilhável |
| Exportação de vídeo | **Recurso futuro** — atualmente vídeos podem ser pré-visualizados, mas a exportação do card com vídeo embutido ainda não está disponível |
| Captura de tela flutuante / gravação nativa | **Recurso futuro planejado** — não implementado na versão atual |

---

## 7. Dados NÃO Coletados

O Apex Booster+ **não coleta** nenhum dos seguintes dados:

- Nome, e-mail ou qualquer identificador pessoal.
- Localização precisa ou aproximada.
- Contatos ou arquivos pessoais não solicitados.
- Fotos ou vídeos sem ação explícita do usuário (o Apex Studio só acessa a mídia que o próprio usuário seleciona voluntariamente pelo seletor nativo do Android).
- Mensagens, chamadas ou dados de comunicação.
- Informações financeiras ou de pagamento nesta versão.
- Dados de uso detalhado de apps (sem `PACKAGE_USAGE_STATS`).
- Dados biométricos.
- Identificadores de publicidade.

---

## 8. Compartilhamento de Dados

O Apex Booster+ **não vende, não aluga e não compartilha dados pessoais** com anunciantes, parceiros ou terceiros.

Não há:
- SDK de anúncios.
- SDK de analytics de terceiros (ex: Firebase Analytics, Mixpanel, Amplitude).
- Rastreamento de comportamento para fins publicitários.
- Postagem ou publicação automática em redes sociais.

---

## 9. Permissões Utilizadas

| Permissão | Finalidade |
|---|---|
| `INTERNET` | Teste básico de latência (Apex Ping) |
| `ACCESS_NOTIFICATION_POLICY` | Modo Foco Gamer (Não Perturbe) — somente quando o usuário concede |

**Acesso à galeria / mídia:** o Apex Studio utiliza o seletor de mídia nativo do Android (`image_picker`). No Android 13 ou superior, esse seletor é integrado ao sistema e não requer declaração de permissão adicional. Em versões anteriores do Android, o comportamento segue as políticas da plataforma. O app **não solicita acesso permanente à galeria**.

Nenhuma outra permissão sensível é solicitada nesta versão.

---

## 10. Limites e Avisos Importantes

- O Apex Booster+ **não altera jogos de terceiros automaticamente**.
- O app **não promete melhoria real de FPS, GPU, resolução, ping ou desempenho** de jogos externos.
- As métricas exibidas (RAM, latência Apex) são **locais e informativas** — não representam alteração automática do dispositivo ou dos jogos.
- O Modo Foco Gamer ativa o Não Perturbe do Android somente quando o usuário concede a permissão explicitamente.
- O Apex Studio **não exporta vídeo** nesta versão — a exportação de vídeo está planejada para fase futura.
- Recursos de captura de tela flutuante e gravação nativa estão **planejados para versões futuras** e não estão disponíveis na versão atual.

---

## 11. Segurança dos Dados

Como todos os dados são armazenados localmente no dispositivo via `SharedPreferences`, a segurança depende das proteções nativas do Android (sandbox de app, criptografia do sistema de arquivos quando habilitada pelo dispositivo).

O app não transmite dados, portanto não há risco de interceptação de rede.

---

## 12. Crianças

O Apex Booster+ **não é direcionado a crianças menores de 13 anos** e não coleta conscientemente dados de menores.

---

## 13. Alterações nesta Política

Esta política pode ser atualizada antes ou após a publicação na Play Store. A data de "Última atualização" no topo do documento refletirá a versão vigente.

---

## 14. Contato

Para dúvidas, solicitações de exclusão de dados (aplicável a dados locais no dispositivo) ou qualquer questão relacionada à privacidade:

**E-mail de contato:** digitaldefense.ai@gmail.com

---

*Esta política foi elaborada para o Apex Booster+ — desenvolvido por AllAppsEngineer.*
