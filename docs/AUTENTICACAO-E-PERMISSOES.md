# Autenticação e permissões

## Sessão

O login cria um token aleatório opaco, grava somente seu SHA-256 na tabela `sessions` e envia o valor em cookie `HttpOnly`. Em produção o cookie usa `Secure`, `SameSite=Lax`, `Path=/` e expiração de oito horas. Logout e alteração de senha revogam sessões conforme a operação.

O token CSRF é separado do cookie de sessão. Ele é entregue apenas após autenticação/cadastro e deve ser enviado no header `X-CSRF-Token` em mutações autenticadas. A origem também é conferida.

## Matriz inicial

| Área | Administrador | Parceiro | Cliente |
|---|---:|---:|---:|
| Site público e autenticação | Sim | Sim | Sim |
| Indicadores administrativos | Sim | Não | Não |
| Aprovar/suspender parceiros | Sim | Não | Não |
| Listar usuários/parceiros | Sim | Apenas membros da própria empresa | Não |
| Dados da própria empresa | Não aplicável | Sim | Não |
| Dados da própria conta | Sim | Sim | Sim |
| Veículos, orçamentos, documentos e financeiro | Futuro | Futuro | Futuro |

As rotas privadas usam `requireAuth`, `requireRole` e, para parceiros, consultas vinculadas a `company_members`. A interface não é considerada mecanismo de segurança.

## Status

Parceiros são criados como `PENDING`, com empresa, responsável e vínculo `OWNER` persistidos em uma transação. O próprio parceiro pendente pode consultar somente o status da sua empresa em `/api/partner/status`; não acessa rotas operacionais. A aprovação administrativa altera a empresa e os usuários vinculados para `ACTIVE`; suspensão altera o acesso para `SUSPENDED`; recusa desabilita o usuário e preserva a justificativa. A mudança é transacional e registrada em `audit_logs`.

Os links comerciais `/cadastro-parceiro` e `/area-do-parceiro` usam o cadastro e a sessão existentes. A área encaminha usuários não autenticados ao login, parceiros pendentes ao acompanhamento e parceiros ativos ao painel. A autoridade dessas decisões permanece no backend.

## Recuperação

O reset depende de SMTP configurado. O token é aleatório, armazenado como hash, expira em 30 minutos e é marcado como usado na mesma transação da troca de senha. A resposta de solicitação é genérica para evitar enumeração de contas.

## Homologação

Os testes que dependem de MySQL, SMTP e contas reais de homologação devem ser executados na Hostinger após configurar as variáveis descritas em `docs/DEPLOY-HOSTINGER.md`. Não usar dados reais de clientes.
