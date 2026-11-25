# Banco de dados

## Fase 2 — schema inicial

MySQL da Hostinger é conectado por `DATABASE_URL`. `migrations/001_initial.sql` cria usuários, parceiros, membros, clientes, sessões, tokens de reset, rate limits e auditoria, com chaves estrangeiras, índices e unicidade de e-mail/documento.

Execute `node scripts/migrate.mjs` somente com `DATABASE_URL` configurada. Cada migration é registrada em `schema_migrations` e aplicada em transação. Não há migration destrutiva nesta fase. Sessões armazenam apenas hashes dos tokens.

Para a instalação atual na Hostinger, o procedimento oficial é manual pelo phpMyAdmin: importar `database/install.sql`, executar `database/verify.sql`, criar o primeiro administrador com uma cópia preenchida de `database/create-admin.sql` e verificar novamente. A conexão real foi comprovada com `DATABASE_URL` apontando para `127.0.0.1`; o banco estava vazio no diagnóstico. Não executar migrations pelo terminal durante esse procedimento.

## Fase 3 — preparação manual

Foi criada a migration `migrations/002_services_pricing_rules.sql` e sua cópia para importação `database/updates/002_services_pricing_rules.sql`. Ela cria catálogo de serviços, categorias, UFs, disponibilidade, relações, tabelas de preços, componentes e regras técnicas versionáveis. Não cria preços reais e deixa as regras preliminares em `DRAFT`.

Para um banco Fase 2 já instalado, executar na ordem: `database/updates/002_services_pricing_rules_precheck.sql`, `database/updates/002_services_pricing_rules.sql`, `database/updates/002_services_pricing_rules_verify.sql`. O `database/install.sql` contém o conjunto completo para instalações novas. Nenhum arquivo executa `DROP`, migration automática ou operação remota.

As FKs dependem de `users`, `partner_companies` e `schema_migrations` existentes. A migration registra `002_services_pricing_rules.sql` apenas quando as onze tabelas novas estiverem presentes. Em falha parcial, interromper, salvar o erro do phpMyAdmin, verificar as tabelas com o precheck e corrigir/reexecutar somente após análise; não registrar manualmente a migration.

O painel e as rotas administrativas serão implementados somente após confirmação da importação, para evitar que o deploy consulte tabelas ainda inexistentes.

Toda entidade de negócio deve carregar o escopo de tenant quando aplicável. Alterações de schema exigem migration, análise de dados existentes, índice/constraint, plano de rollback e deploy progressivo.
