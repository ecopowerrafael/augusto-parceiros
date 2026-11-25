# Banco de dados

## Fase 2 — schema inicial

MySQL da Hostinger é conectado por `DATABASE_URL`. `migrations/001_initial.sql` cria usuários, parceiros, membros, clientes, sessões, tokens de reset, rate limits e auditoria, com chaves estrangeiras, índices e unicidade de e-mail/documento.

Execute `node scripts/migrate.mjs` somente com `DATABASE_URL` configurada. Cada migration é registrada em `schema_migrations` e aplicada em transação. Não há migration destrutiva nesta fase. Sessões armazenam apenas hashes dos tokens.

Para a instalação atual na Hostinger, o procedimento oficial é manual pelo phpMyAdmin: importar `database/install.sql`, executar `database/verify.sql`, criar o primeiro administrador com uma cópia preenchida de `database/create-admin.sql` e verificar novamente. A conexão real foi comprovada com `DATABASE_URL` apontando para `127.0.0.1`; o banco estava vazio no diagnóstico. Não executar migrations pelo terminal durante esse procedimento.

Entidades futuras: veículo, serviço, regra de viabilidade, tabela de preço, orçamento, solicitação, documento, link de upload e evento de timeline.

Toda entidade de negócio deve carregar o escopo de tenant quando aplicável. Alterações de schema exigem migration, análise de dados existentes, índice/constraint, plano de rollback e deploy progressivo.
