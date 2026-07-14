# Data Safety — Respostas Preliminares

**Versão:** preliminar pré-submissão
**Revisão obrigatória antes de Billing (BILL-U1):** sim

---

## Perguntas principais

| Pergunta Play Console | Resposta recomendada | Justificativa |
|---|---|---|
| O app coleta dados dos usuários? | **Sim** (dados ficam no dispositivo) | O app lê apps instalados, salva biblioteca, histórico e preferências localmente |
| O app compartilha dados com terceiros? | **Não** | Sem backend, sem SDK de ads/analytics/atribuição |
| O app usa criptografia? | **Sim** — criptografia em trânsito padrão do Android | TLS do sistema quando houver qualquer conexão |
| O app permite exclusão de dados? | **Sim** | "Limpar histórico" nas Configurações remove sessões; remoção do app limpa `shared_preferences` |

---

## Dados declarados como coletados (ficam no dispositivo)

| Tipo de dado | Coletado? | Compartilhado? | Processamento |
|---|---|---|---|
| Apps instalados (packageName, label, ícone) | Sim | Não | Apenas para exibir biblioteca local |
| Histórico de sessões (jogo, data, métricas locais) | Sim | Não | Armazenado localmente em `shared_preferences` |
| Preferências (idioma, onboarding, GFX, foco) | Sim | Não | Armazenado localmente |
| RAM disponível/total do dispositivo | Sim (snapshot) | Não | Exibição local, não persistido além da sessão |
| Latência Apex (medição própria do app) | Sim (snapshot) | Não | Exibição local |
| Dados de localização | Não | — | — |
| E-mail, nome, telefone | Não | — | — |
| Dados financeiros | Não (Billing não implementado) | — | Será revisado quando Billing entrar |
| Fotos / vídeos (Apex Studio) | Sim — seleção voluntária pelo usuário | Não | Processado localmente em memória; nunca enviado a servidores |
| Identidade do dispositivo (IMEI, etc.) | Não | — | — |

---

## Observações críticas

Quando o Billing (BILL-U1) for implementado, o Data Safety precisa ser atualizado para
declarar dados de compras e transações. Não subir Billing sem revisitar e atualizar
este documento e o formulário correspondente na Play Console.

Quando o recurso de captura flutuante / gravação nativa (fase futura) for implementado,
o Data Safety precisará ser revisado para cobrir dados de captura de tela e gravação de
vídeo da sessão gamer.
