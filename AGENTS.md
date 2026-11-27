# Doc Motor — instruções para futuras sessões

Antes de implementar qualquer funcionalidade, leia `docs/STATUS-DO-PROJETO.md`, `docs/ARQUITETURA.md`, `docs/REGRAS-DE-NEGOCIO.md`, `docs/DECISOES-TECNICAS.md` e o `README.md`. O `AGENTS.md` fornecido na missão original define os princípios obrigatórios de engenharia e segurança; ele deve ser preservado como referência de trabalho.

## Regras locais

- Trabalhe por fases; as migrations 001, 002, 003 e 004 foram confirmadas no banco remoto. A Fase 3.6 usa o design system documentado em `docs/DESIGN-SYSTEM.md`. Não iniciar a Fase 4 sem nova autorização explícita.
- O backend é a autoridade para autenticação, autorização, tenant, limites e regras de negócio.
- Não versionar `.env`, credenciais, tokens ou documentos pessoais.
- Ao mudar schema, atualizar `docs/BANCO-DE-DADOS.md` e planejar migration/rollback.
- Para cada migration futura, validar estaticamente a correspondência entre colunas e valores de todos os `INSERT`s e, quando possível, executar em MariaDB descartável; nunca declarar validação SQL com base apenas em testes JavaScript.
- Toda migration futura deve ter validação estática da correspondência entre colunas e valores em cada `INSERT`, além de validação SQL real quando houver MariaDB disponível; testes de aplicação não substituem execução SQL.
- A Migration 008 da Fase 3.11 está apenas preparada localmente; não executar SQL remoto, não reimportar a 007 e aguardar confirmação explícita do proprietário antes de qualquer importação manual.
- Nenhuma migration é considerada pronta sem `precheck`, SQL, `verify` e execução do gerador `npm run generate:hostinger-sql -- u891593158_doc database/updates`; preservar `information_schema` fora da qualificação do banco da aplicação.
- Antes de aprovar qualquer migration, executar `node scripts/validate-migration-inserts.mjs migrations/<arquivo>.sql` e registrar a validação de correspondência entre colunas e valores de todos os `INSERT`s.
- O mesmo validador deve ser ampliado ou executado junto das verificações de balanceamento e argumentos pares de `JSON_OBJECT`; todo literal SQL iniciado por `{` ou `[` deve ser parseado como JSON, e condições devem ser confrontadas com o schema/avaliador declarativo antes da entrega. Validação JavaScript isolada não comprova `JSON_VALID` no MariaDB.
- Para a Migration 007, executar também `node scripts/validate-migration-config.mjs migrations/007_engine_rules_and_documents.sql` para validar a condição persistida da cobrança com o avaliador real.
- Para a Fase 3.14, as Migrations 001–010 já são histórico do banco remoto. A Migration 011 (`011_suspension_form_usability.sql`) foi preparada localmente e aguarda autorização/importação manual; não executar SQL remoto nem reimportar 010.
- O validador de migrations também confirma que, quando presente, o registro em `schema_migrations` é o último comando executável; não registrar uma migration antes de seus seeds e verificações finais.
- Prechecks e verifies de migrations devem consultar primeiro `information_schema`; para tabelas/colunas opcionais, usar SQL preparado somente após confirmar a existência. Nunca colocar uma referência direta a uma estrutura criada pela própria migration antes do `CREATE` correspondente.
- Em SQL preparado gerado para a Hostinger, qualificar também as tabelas dentro das strings com o banco alvo explícito; `USE` não deve ser a única dependência do contexto da sessão do phpMyAdmin.
- A validação estática de ordem não substitui MariaDB: quando não houver servidor descartável disponível, declarar explicitamente que a sintaxe/execução SQL real não foi comprovada.
- O catálogo de modificações e a configuração de suspensão devem permanecer no-code: listas, preços, exigências e condições pertencem ao MySQL/configuração declarativa; não hardcodar opções comerciais no frontend ou no avaliador.
- Ao mudar autenticação ou autorização, atualizar `docs/AUTENTICACAO-E-PERMISSOES.md` e revisar a matriz de acesso.
- Ao concluir uma missão, atualize `CHANGELOG.md` e `docs/STATUS-DO-PROJETO.md`.
- Toda funcionalidade já implementada deve estar conectada aos respectivos botões, menus e fluxos de navegação; não manter CTAs provisórios apontando para recursos existentes apenas no backend.
- Todas as interfaces devem usar português brasileiro, traduzir códigos técnicos antes de exibi-los, usar mensagens contextualizadas, aplicar máscaras reutilizáveis em campos com formato conhecido, evitar dados redundantes e validar sempre no frontend e no backend.
- Execute `npm run lint`, `npm run typecheck`, `npm run build` e os testes relevantes antes de entregar.
- Não afirmar que algo foi testado sem executar a verificação.
- Painéis autenticados devem usar o shell SaaS compartilhado, navegação por perfil, textos em português e estados futuros explicitamente desabilitados; não criar telas paralelas com layout próprio sem justificativa.
- O ambiente de homologação oficial é a Hostinger; depois de publicar na `main`, registrar se o teste online foi realmente executado.
- Fluxo permanente: implementar localmente → lint/typecheck/test/build → commit → publicar na `main` → validar na Hostinger por HTTP → corrigir e registrar evidências.
- A conferência visual fica sob responsabilidade humana quando o controle automatizado do navegador não estiver disponível; registrar como pendente, sem inventar resultado.
- Nunca adicionar senha de banco, chave de API ou dado de cliente ao código, logs, documentação ou commits.
- Para autenticação, use sessões opacas persistidas no MySQL, cookies HttpOnly/Secure/SameSite, CSRF e rate limit persistido; não use tokens de autenticação em localStorage.
- A recuperação de senha depende de SMTP configurado no ambiente; nunca retornar o token de recuperação na API.
- A instalação inicial do MySQL desta fase é manual pelo phpMyAdmin usando `database/install.sql`; não executar migrations, provisionamento ou operações remotas sem autorização explícita da missão.
- A Migration 013 (`suspension_documentation_fields`) foi suspensa e não pertence ao fluxo ativo de instalação ou geração SQL. Seus artefatos históricos não devem ser importados. Novas perguntas e alterações visuais de formulários devem ser implementadas em componentes React específicos; migrations só são necessárias quando houver alteração real de schema ou dados persistentes.
- Toda migration nova deve ser auditada pela ordem de criação e uso de tabelas/colunas, ter precheck somente de leitura seguro antes das estruturas existirem e verify diagnóstico para execução parcial. A validação estática não substitui MariaDB real quando este estiver disponível.
- Nos arquivos novos de precheck e verify destinados ao phpMyAdmin, usar SELECTs estáticos, tabelas qualificadas e contagens exatas; não usar PREPARE, EXECUTE, DEALLOCATE PREPARE ou procedures temporárias para emitir resultados tabulares. Se uma tabela-base obrigatória não existir, informar a dependência e interromper antes da consulta de conteúdo.
- Os simuladores devem reutilizar os componentes compartilhados de campos, condições, opções, grupos repetíveis e resultados; não criar renderizadores divergentes para a mesma configuração declarativa.
- Na arquitetura híbrida, o serviço de motor utiliza `MotorForm` e o endpoint `MOTOR_V1`; suspensão e demais serviços ainda reutilizam `DeclarativeSimulationPage` até suas próprias migrações. `ServiceResultView` e o gerador de PDF permanecem compartilhados. Não criar outro construtor universal.
- O item genérico de simulador não deve aparecer no menu operacional. A rota legada pode permanecer compatível por redirecionamento ou retorno ao contexto de configuração.
- Campos técnicos só podem aparecer ou ser obrigatórios por condições declarativas persistidas; não espalhar regras comerciais rígidas no frontend.
- Para a Migration 007, a publicação fica suspensa até confirmação manual do proprietário no phpMyAdmin; não executar SQL remoto pelo agente.
- Na Fase 3.5, a migration `004_partner_commissions.sql` também é manual: executar precheck, importar, verificar e aguardar confirmação do proprietário antes de integrar dependências de schema na `main`.
- Aprovação administrativa deve ser atômica, sincronizar empresa e usuários vinculados, registrar auditoria e, em falha SQL, registrar apenas request ID/código SQL sem PII ou credenciais.
- A Migration 002 já está instalada no banco remoto e não deve ser reimportada; a Migration 003 também foi confirmada. Não executar novamente esses SQLs. Qualquer alteração estrutural futura exige nova migration e confirmação explícita antes da publicação.
- A Hostinger usa importação manual pelo phpMyAdmin; não depender de SSH, CLI MySQL ou execução de migrations no terminal remoto. Migrations canônicas permanecem portáveis e nunca recebem o nome do banco.
- Toda alteração de banco deve entregar três SQLs manuais: pré-verificação somente leitura, atualização incremental e verificação posterior, além de manter `database/install.sql` atualizado.
- A Migration 005 (`application_settings`) foi importada e verificada pelo proprietário; não reexecutar o SQL remoto. A homologação funcional do módulo continua sendo feita somente pelo ambiente online.
- A Migration 006 (`simulator_input_normalization`) foi importada e validada pelo proprietário no banco remoto; não reexecutar o SQL remoto.
- O simulador no-code normaliza placas, combustíveis e cilindradas no backend; a interface melhora a entrada, mas nunca substitui o avaliador.
- Na Fase 3.8, resultados do simulador devem ser apresentados por `ServiceResultView`; não exibir JSON bruto como resultado principal. PDFs de simulação devem declarar `SIMULAÇÃO — SEM VALIDADE COMERCIAL` e usar somente valores validados pelo backend.
- A Fase 3.7.1 mantém `vehicle_target.plate_pattern` e `vehicle_donor.plate_pattern` como campos derivados internos reconhecidos pelo validador; não persistir esses valores como entradas editáveis nem criar migration para eles.
- SQLs manuais da Hostinger devem iniciar com `USE \`u891593158_doc\`;` e `SELECT DATABASE() AS selected_database;`, qualificar tabelas da aplicação com `\`u891593158_doc\`.`, filtrar `information_schema` por `table_schema = 'u891593158_doc'` e ser gerados por `scripts/generate-hostinger-sql.mjs`. O gerador valida o identificador, não inclui credenciais e não executa SQL remoto.
- Não alterar migrations já aplicadas. Como 001 e 002 estão instaladas, alterações estruturais futuras começam na migration 003; não repetir seeds antigos, não usar DROP/TRUNCATE, não desabilitar foreign keys e não prometer rollback transacional completo para DDL.

## Comandos

```bash
npm install
npm run dev
npm run lint
npm run typecheck
npm run test
npm run build
```
