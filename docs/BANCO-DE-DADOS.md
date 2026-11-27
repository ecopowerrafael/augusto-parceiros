# Banco de dados

## Migration 010 — catálogo de modificações e suspensão

A Migration 010 cria o catálogo reutilizável `vehicle_modifications`, suas relações de categorias/UFs, documentos e mensagens, além de `quantity_expression` para cobranças declarativas. Também renomeia o serviço existente `LOWERED_SUSPENSION` sem duplicá-lo e inicializa sua primeira versão DRAFT, campos, opções, regras e cobranças.

Importação manual: `database/updates/010_suspension_modification_catalog_precheck.sql`, depois `010_suspension_modification_catalog.sql`, depois `010_suspension_modification_catalog_verify.sql`. Não executar remotamente nem reexecutar migrations 001–009. A migration registra-se somente quando as tabelas, catálogo, serviço e campos esperados existirem.

O precheck e o verify foram preparados para banco sem Migration 010 e para execução parcial: primeiro consultam `information_schema.tables`/`information_schema.columns`; consultas de dados a tabelas opcionais são montadas e executadas somente após confirmar a existência. As consultas preparadas dos artefatos Hostinger qualificam explicitamente `u891593158_doc`, pois o phpMyAdmin pode preparar o comando com `information_schema` como contexto corrente. Para evitar o erro de renderização `Undefined index: statement/parser`, `EXECUTE` não devolve result set: grava em variáveis com `SELECT ... INTO`, seguido de `SELECT` normal. A consulta antiga que acessava `vehicle_modifications` antes do `CREATE TABLE` foi removida. Se o precheck mostrar tabela ausente, não há evidência de que a atualização tenha sido aplicada; não reimporte até confirmar o estado real.

Precheck inicial confirmado pelo proprietário em 27/11/2026: banco `u891593158_doc`, MariaDB `11.8.9-MariaDB-log`, seis dependências-base presentes, Migration 010 não registrada, cinco tabelas novas ausentes, coluna `quantity_expression` ausente, serviço de suspensão sem versão e três itens-base de cobrança presentes. Após as falhas de importação, o precheck de recuperação confirmou execução parcial; a próxima etapa é executar novamente o precheck atualizado, importar o update corrigido e depois executar o verify.

Após as tentativas de importação, o proprietário reportou `#1052` na carga de opções e, posteriormente, `#1054 Coluna 'r.name' desconhecida` na carga de regras técnicas. O primeiro erro foi causado por `SELECT id` ambíguo em uma subconsulta; o segundo, pela ausência dos aliases `name` e `description` na primeira linha da tabela derivada `r`, embora esses nomes fossem usados pelo `SELECT` externo. Ambos foram corrigidos na Migration 010 canônica e nos artefatos gerados. Como DDL e seeds anteriores podem ter permanecido após cada falha, o estado parcial deve ser reavaliado pelo precheck antes de repetir a importação.

O precheck de recuperação confirmou execução parcial: as cinco tabelas novas, a coluna `quantity_expression`, os 27 itens do catálogo e uma versão do serviço já existem; a migration ainda não está registrada e somente 5 dos 7 campos específicos do checklist foram encontrados. Como os comandos são idempotentes e não destrutivos, retomar com o SQL completo corrigido e executar o verify imediatamente depois; não inserir manualmente o registro em `schema_migrations`.

## Fase 2 — schema inicial

MySQL da Hostinger é conectado por `DATABASE_URL`. `migrations/001_initial.sql` cria usuários, parceiros, membros, clientes, sessões, tokens de reset, rate limits e auditoria, com chaves estrangeiras, índices e unicidade de e-mail/documento.

Execute `node scripts/migrate.mjs` somente com `DATABASE_URL` configurada. Cada migration é registrada em `schema_migrations` e aplicada em transação. Não há migration destrutiva nesta fase. Sessões armazenam apenas hashes dos tokens.

Para a instalação atual na Hostinger, o procedimento oficial é manual pelo phpMyAdmin: importar `database/install.sql`, executar `database/verify.sql`, criar o primeiro administrador com uma cópia preenchida de `database/create-admin.sql` e verificar novamente. A conexão real foi comprovada com `DATABASE_URL` apontando para `127.0.0.1`; o banco estava vazio no diagnóstico. Não executar migrations pelo terminal durante esse procedimento.

## Fase 3 — modelo no-code e preparação manual

Foi revisada a migration `migrations/002_services_pricing_rules.sql` e sua cópia para importação `database/updates/002_services_pricing_rules.sql`. Além das estruturas iniciais, ela cria versões de serviços, seções/campos/opções, fontes e consultas externas, catálogo central de itens de cobrança, composição por versão, ações de regras, exigências documentais e mensagens. O serviço de cadastro de motor é configurado pelos mesmos registros genéricos usados pelo editor e permanece `DRAFT`.

`service_prices` legado permanece por compatibilidade da preparação anterior, mas não é fonte definitiva de preço. A composição operacional deve usar `billing_items` + `service_billing_items`, permitindo múltiplos itens, condições, quantidade, visibilidade e valores ausentes. Não há preço publicado; os valores informados pelo proprietário estão em itens `DRAFT` e descritos como configuração comercial, não como taxa oficial.

Para um banco Fase 2 já instalado, executar na ordem: `database/updates/002_services_pricing_rules_precheck.sql`, `database/updates/002_services_pricing_rules.sql`, `database/updates/002_services_pricing_rules_verify.sql`. O `database/install.sql` contém o conjunto completo para instalações novas. Nenhum arquivo executa `DROP`, migration automática ou operação remota.

As FKs dependem de `users`, `partner_companies` e `schema_migrations` existentes. A migration registra `002_services_pricing_rules.sql` somente quando as 23 tabelas novas estiverem presentes. Em falha parcial, interromper, salvar o erro do phpMyAdmin, verificar as tabelas com o precheck e corrigir/reexecutar somente após análise; não registrar manualmente a migration.

As rotas `/api/admin/services`, `/api/admin/service-versions/*`, `/api/admin/billing-items`, `/api/admin/rules` e `/api/admin/service-versions/:id/simulate` dependem das tabelas novas. O painel administrativo e essas rotas só devem ser publicados na `main` após confirmação da importação manual.

Toda entidade de negócio deve carregar o escopo de tenant quando aplicável. Alterações de schema exigem migration, análise de dados existentes, índice/constraint, plano de rollback e deploy progressivo.

## SQL manual da Hostinger

O banco `u891593158_doc` é selecionado explicitamente somente nos artefatos manuais de importação. Eles começam com `USE \`u891593158_doc\`;` e `SELECT DATABASE()`, qualificam as tabelas da aplicação e usam `table_schema = 'u891593158_doc'` nas consultas de `information_schema`. As migrations canônicas continuam sem nome de banco.

O gerador local é `scripts/generate-hostinger-sql.mjs`. Ele produz pré-verificação, atualização e verificação posterior; a atualização deve ser executada somente depois da leitura da pré-verificação. DDL pode realizar commit implícito no MySQL, portanto não é prometido rollback transacional completo. Em falha parcial, preservar o erro, fazer backup/verificação e criar uma nova migration incremental; não repetir uma migration aplicada.

O gerador preserva aspas SQL escapadas em comandos `PREPARE` e só qualifica identificadores fora de strings. O validador `scripts/validate-migration-inserts.mjs` verifica colunas/valores, `JSON_OBJECT`, ordem de criação/uso de tabelas e registro final em `schema_migrations`; isso é validação estática e não substitui MariaDB.
# Fase 3.5 — comissões

`004_partner_commissions.sql` cria `commission_settings` e `partner_commission_overrides`. O registro inicial é `NONE`, sem valores comerciais. A importação é manual e deve ser verificada antes de ativar as telas dependentes.

# Fase 3.6 — configurações gerais

`005_application_settings.sql` cria a tabela singleton `application_settings`, com dados comerciais editáveis pelo administrador, timezone e auditoria do último responsável. A Migration 005 foi importada e verificada pelo proprietário no banco `u891593158_doc`, MariaDB `11.8.9-MariaDB-log`: `required_base_tables_present=2`, registro anterior `0`, tabela anterior `0`, registro posterior `1`, tabela posterior `1`, `company_name=Doc Motor` e `timezone=America/Sao_Paulo`. Não executar novamente essa migration.

O módulo `/api/admin/settings` lê e atualiza somente os campos comerciais permitidos, exige administrador e CSRF, valida nome, UF e e-mail e registra `APPLICATION_SETTINGS_UPDATED` na auditoria. Configurações de infraestrutura e segredos continuam somente leitura.
## Migration 006 — normalização do simulador

A Migration 006 (`migrations/006_simulator_input_normalization.sql`) é incremental e não destrutiva. Ela transforma os campos persistidos de combustível em `SINGLE_SELECT`, registra quatro opções padronizadas e marca as cilindradas com unidade `cm³`. Foi importada e validada pelo proprietário no banco `u891593158_doc`, MariaDB `11.8.9-MariaDB-log`: registro anterior `0`, registro posterior `1`, dois campos de combustível convertidos, dois campos de cilindrada atualizados, oito opções inseridas e campos de placa preservados como `VEHICLE_PLATE`.

Use, nesta ordem, `database/updates/006_simulator_input_normalization_precheck.sql`, `006_simulator_input_normalization.sql` e `006_simulator_input_normalization_verify.sql`. Não execute migrations anteriores novamente.
# Migration 007 — regras e documentos comerciais

A comunicação com o MySQL remoto foi comprovada anteriormente usando `127.0.0.1`. A Migration 007 é incremental e deve ser aplicada manualmente pelo phpMyAdmin somente após o `007_engine_rules_and_documents_precheck.sql`. Em seguida, importar `007_engine_rules_and_documents.sql` e executar `007_engine_rules_and_documents_verify.sql`. Nenhum desses arquivos contém `DROP`, `TRUNCATE` ou credenciais. A migration não deve ser marcada como aplicada se os campos, regras, cobrança única de modificação, exclusão de ITL/CSV e quatro documentos não estiverem presentes.

