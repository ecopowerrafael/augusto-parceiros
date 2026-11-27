# Decisões técnicas

## 2026-11-25 — um deploy Node.js

Escolhido React/TypeScript/Vite servido por Express no mesmo domínio. Reduz complexidade e encaixa no recurso Web Apps Node.js da Hostinger, com MySQL futuro.

## 2026-11-25 — sem backend de negócio na Fase 1

Não simular armazenamento, autenticação ou integração externa. O formulário abre WhatsApp com dados digitados, tornando explícito o limite real do produto.

## 2026-11-25 — logo oficial preservada

A logo existente foi usada sem redesenho. A interface usa vermelho como cor comercial de ação e mantém o azul da marca como assinatura da logo.
# Fase 2 — decisões adicionais

- `mysql2` foi adotado no lugar do Prisma para a primeira migration: a hospedagem compartilhada não exige geração de client/binários e o schema SQL versionado mantém o deploy simples. A camada `server/database.js` centraliza pool e transações.
- Sessões opacas persistidas foram escolhidas em vez de JWT para permitir revogação, expiração e controle operacional imediato.
- SMTP é opcional na inicialização, mas obrigatório para envio real de recuperação de senha; sem configuração a solicitação não expõe token e permanece documentada como indisponível.
- O painel administrativo usa consultas reais do MySQL e ações transacionais de aprovação/suspensão. Nenhum indicador é preenchido com valores fictícios.
- A primeira instalação do banco será manual pelo phpMyAdmin, após diagnóstico real confirmar `127.0.0.1`, para não depender de SSH/terminal da Hostinger. `schema_migrations` é registrado pelo SQL somente depois que as oito tabelas da Fase 2 existem.

## 2026-11-25 — configuração no-code por versão

Serviços são separados de `service_versions`, e formulários, cobranças, regras, documentos e mensagens apontam para a versão. Isso permite editar um rascunho sem mutar a configuração publicada e prepara snapshots futuros de orçamento.

O avaliador usa uma DSL declarativa limitada, validada no backend. Operadores, ações e tipos de campo são listas fechadas; `eval`, SQL, scripts e URLs arbitrárias são proibidos. O frontend apenas edita configurações e exibe o simulador; não é autoridade para totais, permissões ou viabilidade.

## SQL portável e importação manual

As migrations canônicas não fixam o schema MySQL. Para a Hostinger, `scripts/generate-hostinger-sql.mjs` gera arquivos específicos com `USE`, `SELECT DATABASE()`, referências qualificadas e filtros explícitos de `information_schema`. Essa separação evita que o nome do banco vaze para o pool ou para o código da aplicação e evita correções textuais manuais que possam corromper JSON ou literais SQL.
# ADR — aprovação e comissionamento da Fase 3.5

- Manter a aprovação no backend e em transação única; o frontend não decide permissões nem status de usuários.
- Usar request IDs e códigos MySQL em logs estruturados, sem registrar payload sensível.
- Preparar comissões por modelo semântico e centavos, com `NONE` como padrão até homologação e sem dependência de nomes de serviços.
- Bloquear a integração em `main` até a importação manual e verificação da migration 004.

## 2026-11-26 — aplicabilidade declarativa da identificação do motor

A obrigatoriedade de `engine.identification_mode` deve ser controlada por `visibility_condition` e `required_condition` persistidas, aplicáveis somente a automóveis, caminhões e ônibus. Motocicletas seguem o fluxo de declaração de compatibilidade e não recebem campos técnicos do motor de origem. A correção foi preparada na Migration 008 porque o defeito estava no estado persistido do construtor, não em uma regra comercial fixa do código.

## 2026-11-26 — logo incorporado ao bundle do PDF

O logo oficial é lido pelo Vite durante o build e incorporado ao bundle como bytes base64; o gerador `pdf-lib` embute esses bytes no documento antes de finalizar o PDF. Assim, a geração não depende de URL, cache ou disponibilidade de rede no momento do download.

## 2026-11-26 — catálogo de modificações e quantidade declarativa

Modificações adicionais são entidades persistidas em catálogo próprio, com status, exigências, referências e cobrança vinculada. O serviço de suspensão apenas seleciona essas entidades por campo repetível no-code; não reproduz a lista nem valores no React. A cobrança por quantidade usa `quantity_expression` e o operador fechado `COUNT_FILLED`, calculado no backend.

## 2026-11-27 — páginas operacionais reutilizam o motor declarativo

A operação não terá um formulário fixo por serviço. `DeclarativeSimulationPage` recebe o código persistido do serviço e reaproveita o renderer, avaliador, resultado e PDF já existentes. Isso evita divergência entre simulador administrativo e páginas futuras. Não foi criada Migration 013 porque a Fase 3.15 não comprovou alteração necessária no schema.
