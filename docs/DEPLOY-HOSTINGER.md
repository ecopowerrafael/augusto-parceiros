# Deploy na Hostinger

## Fase 3.12

O código está na versão `0.4.8`, publicada na `main` no commit `3373ee5845ca0a25a6091c4f4fa715ec50281cb7`. A Migration 008 e, posteriormente, a Migration 009 foram importadas e verificadas manualmente pelo proprietário; não devem ser reexecutadas. A Migration 009 foi confirmada com cinco campos atualizados, registro único em `schema_migrations` e `migration_009_count = 1`. Rollback: `rollback-before-0-4-8-20261126` (`03d263d738df59e5e683464344b4d3de7caf4528`). O health check local não resolveu `docmotor.online`; a homologação funcional permanece pendente dos testes reais do proprietário.

Baseado na documentação oficial consultada em 25/11/2026: Hostinger Web Apps Node.js suporta planos Business/Unlimited e Cloud; presets React, Vite e Express; Node 18, 20, 22 e 24; deploy via GitHub; variáveis de ambiente no painel; e MySQL com `127.0.0.1`.

### Migration 010 — importação manual pendente

O erro `#1146 vehicle_modifications não existe` foi localizado no precheck antigo, não na criação da tabela: o arquivo consultava o catálogo antes da atualização. Depois, foram corrigidos o contexto de `PREPARE`/`EXECUTE` para phpMyAdmin, a consulta `SELECT id` ambígua na carga de opções e a ausência de aliases `name`/`description` na tabela derivada da carga de regras técnicas (`#1054`). Os três artefatos foram regenerados após a última correção. A ordem obrigatória permanece precheck somente leitura → update → verify. Não executar SQL remoto nem repetir a importação sem confirmar o estado parcial pelo precheck. A execução real em MariaDB não foi validada neste ambiente, pois não há cliente/servidor MariaDB descartável disponível.

O precheck inicial foi aprovado pelo proprietário em 27/11/2026, mas as tentativas seguintes deixaram execução parcial confirmada: cinco tabelas novas presentes, catálogo com 27 registros, uma versão do serviço, `quantity_expression` presente, `migration_010_already_registered = 0` e 5/7 campos específicos presentes. Antes da retomada, executar novamente o precheck atualizado; depois importar o arquivo corrigido e executar o verify. O agente não executa SQL remoto.

A primeira importação falhou posteriormente com `#1052` na subconsulta da carga de opções; o alias foi corrigido para `sv.id`. Como o erro ocorreu depois de DDL e seeds iniciais, executar novamente o precheck antes de uma retomada. A retomada só deve usar o SQL regenerado após o commit da correção.

O precheck de recuperação confirmou cinco tabelas novas, catálogo com 27 registros, uma versão do serviço, `quantity_expression` presente, migration ainda não registrada e 5/7 campos específicos presentes. Esse é o cenário parcial esperado após a falha; a retomada pode usar o SQL completo corrigido, sem excluir estruturas ou registrar a migration manualmente.

Após a correção dos aliases, uma nova tentativa encontrou `#4025` em `technical_rules.conditions`. A regra afetada foi `5A000000-0000-4000-8000-000000000006` (`Checklist compatível`), cujo JSON tinha fechamento incompleto no `all` externo após o `any` aninhado. Os três SQLs foram regenerados; o verify agora também informa a quantidade de regras esperadas cujo `conditions` passa em `JSON_VALID`.

Validação funcional posterior informada pelo proprietário: Migration 010 registrada com sucesso, verify com 53 consultas e estrutura completa (17 campos, 6 cobranças, 7 regras, 27 modificações e 54 vínculos de categoria). Não reimportar a Migration 010. A auditoria local também corrigiu o simulador para aplicar os escopos de categoria/UF persistidos no catálogo; esta alteração é de código e não exige nova migration.

## Configuração desta aplicação

1. Conectar o repositório GitHub na opção Node.js Web App.
2. Selecionar branch `main`, preset Vite/React para build ou Express para runtime conforme o fluxo exibido.
3. Node 20 (compatível com o desenvolvimento atual).
4. Build command: `npm run build`.
5. Entry file para runtime: `server/index.js`.
6. Adicionar variáveis pelo painel, nunca no repositório.
7. Validar o domínio, HTTPS e o caminho de fallback SPA.

8. Manter `NPM_CONFIG_INCLUDE=dev` no ambiente de build para garantir que ferramentas de compilação presentes em `devDependencies` estejam disponíveis durante o deploy.

## Variáveis de homologação

Configure diretamente no painel da Hostinger, sem versionar valores:

```text
NODE_ENV=production
APP_ENV=staging
ALLOW_INDEXING=false
APP_DEBUG=false
NPM_CONFIG_INCLUDE=dev
PORT=(fornecida pela Hostinger, quando aplicável)
DATABASE_URL=(MySQL da Hostinger; necessária para a Fase 2)
DB_POOL_SIZE=5
SMTP_HOST=...
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=...
SMTP_PASSWORD=...
SMTP_FROM=...
```

Não preencher senhas neste repositório ou nesta documentação. A instalação inicial da Fase 2 deve ser feita pelo phpMyAdmin conforme `database/README.md`, sem executar `node scripts/migrate.mjs` ou `node scripts/provision-admin.mjs` nesta etapa.

## Publicação da versão 0.4.6

- A branch `feature/fase-3-10-fluxo-resultado-pdf` foi integrada na `main` pelo merge `aa20697`; a atualização documental foi registrada em `c6a81e4`.
- A tag `rollback-before-0-4-6-20261126` aponta para o commit anterior da `main` (`3448cba`).
- A versão esperada após o deploy é `0.4.6`; o manifest PWA também está em `0.4.6`.
- Não há Migration 008, migrations automáticas no startup, SQL remoto ou reimportação da Migration 007 nesta publicação.
- A confirmação de deploy exige `/api/health` com `environment: staging`, `allowIndexing: false` e versão `0.4.6`; o push no GitHub isoladamente não comprova a propagação da Hostinger.
- A tentativa HTTP local de 26/11/2026 não resolveu `docmotor.online`; a homologação funcional permanece pendente de rede/DNS funcional e conferência manual do proprietário.

## Fase 3.11 — Migration 008 verificada

- A versão `0.4.7` está na branch `feature/fase-3-11-homologacao-simulador` e sua publicação foi autorizada.
- A causa da falha de motocicleta foi confirmada na configuração persistida de `engine.identification_mode`; os arquivos `008_motorcycle_visibility_consistency_precheck.sql`, `008_motorcycle_visibility_consistency.sql` e `008_motorcycle_visibility_consistency_verify.sql` foram gerados pelo comando oficial e importados/verificados manualmente pelo proprietário.
- Não executar novamente a Migration 008, não executar migrations anteriores, não usar `node scripts/migrate.mjs` e não executar SQL pelo backend. Evidências: `migration_007_registered=1`, `migration_008_count=1`, três updates concluídos, uma linha inserida e `motorcycle_mode_not_required=1`.
- A Migration 008 não altera preços, regras comerciais, usuários ou configurações de atendimento; apenas torna a aplicabilidade declarativa da identificação do motor consistente.
- A branch foi integrada na `main` pelo merge `365980a`; rollback local/remoto registrado na tag `rollback-before-0-4-7-20261126` apontando para `1b420c4`. Confirmar a propagação pelo `/api/health`; o push não é evidência suficiente de deploy.

## Fase 3 — implantação em duas etapas

O proprietário confirmou a importação da Migration 002 e das 23 tabelas no banco correto. Não reimportar a 002. Para esta missão, usar somente: (1) `database/updates/003_complete_engine_service_seed_precheck.sql`; (2) `database/updates/003_complete_engine_service_seed.sql`; (3) `database/updates/003_complete_engine_service_seed_verify.sql`. Só depois da confirmação da 003 o código do painel que depende dessas configurações poderá ser publicado na `main`.

A versão `0.3.0` foi publicada na `main` pelo commit `4f22ceb` (documentação final em `020b443`) e propagou na Hostinger. A validação HTTP confirmou `/api/health`, `/api/runtime-config`, `/api/services/catalog`, manifest, robots, headers, assets e `401` nas rotas administrativas sem sessão. Não importar migrations novamente.

Os arquivos manuais devem ser gerados localmente por `node scripts/generate-hostinger-sql.mjs u891593158_doc database/updates`. Eles iniciam com `USE \`u891593158_doc\`;` e `SELECT DATABASE()`, qualificam tabelas da aplicação e não dependem de SSH ou CLI MySQL. A 002 já foi aplicada; para a configuração complementar, usar somente a sequência da 003: precheck, `003_complete_engine_service_seed.sql`, depois verify. Não importar novamente a 002.

Não executar migrations no startup, não usar SSH como requisito e não importar o SQL Fase 3 em produção sem conferência do banco selecionado. Em caso de falha parcial, preservar o erro do phpMyAdmin e interromper a sequência.

## Checklist de testes online

### Hotfix 0.4.4 — diagnóstico do editor

- Não importar migrations nem executar SQL remoto.
- Após o deploy, abrir o construtor de serviços com uma sessão administrativa fictícia e registrar o `X-Request-ID`.
- Se ainda falhar, consultar os logs privados e localizar o primeiro evento ausente entre `editor.queries_completed`, `editor.*_mapped`, `editor.validation_completed`, `editor.response_built` e `editor.response_serialized`.
- O evento `editor_processing_failed` contém a etapa, `errorName`, mensagem original, código e stack; não deve ser exposto ao cliente.
- A homologação só será considerada concluída após carregar o construtor, simular e gerar o PDF comercial na Hostinger.

### Hotfix 0.4.5 — validação declarativa

- Não importar migrations nem executar SQL remoto; a correção é exclusivamente de código.
- Confirmar no `/api/health` a versão `0.4.5` após a propagação.
- Abrir o editor do serviço de cadastro de motor; o campo `motorcycle.compatibility_declaration` deve carregar sem `TypeError`.
- Depois, executar os cenários do simulador e gerar o PDF comercial com dados fictícios. A homologação permanece pendente até o proprietário confirmar esses três fluxos.

## Fase 3.4 — cadastro e mensagens

A versão `0.3.3` foi integrada na `main`. A Migration 004 foi importada manualmente no banco `u891593158_doc` e verificada pelo proprietário em MariaDB `11.8.9-MariaDB-log`. Não executar migrations no startup nem repetir a importação.

Após o deploy, confirmar por HTTP `version=0.3.3`, `APP_ENV=staging` e `allowIndexing=false`. A publicação do commit não é evidência de propagação da Web App.

Tentativa pós-publicação do commit `44ca973` nesta sessão: `Invoke-WebRequest` não resolveu `docmotor.online` em nenhuma das rotas testadas. Resultado registrado como propagação pendente, não como falha confirmada da Hostinger.

Em falha na aprovação administrativa, registrar o `X-Request-ID` devolvido pela API e consultar os logs privados da aplicação; o log estruturado informa código/estado SQL sem credenciais ou PII.

Na última tentativa automatizada local, `Invoke-WebRequest` não resolveu `docmotor.online`; essa limitação não é evidência de indisponibilidade da Hostinger. A conferência deve ser repetida de uma rede com DNS funcional.

Confirmar também que erros como `DOCUMENT_TYPE_MISMATCH`, `INVALID_DOCUMENT`, `REGISTRATION_CONFLICT`, `INVALID_CREDENTIALS`, `AUTHENTICATION_REQUIRED` e `INTERNAL_ERROR` aparecem em português claro na interface, sem expor os códigos.

## Fase 3.3 — correção do fluxo de parceiros

A versão `0.3.1` não exige migration. As migrations 001, 002 e 003 permanecem instaladas e não devem ser reexecutadas. Os commits `b99ed33` e `1d1bdeb` foram integrados na `main` e propagaram na Hostinger; `/api/health` retornou `version=0.3.1` e o bundle final `index-qbH4Hyei.js` foi entregue.

Validação funcional mínima, com contas fictícias e sessão autorizada:

- `/cadastro-parceiro` persiste empresa, responsável, vínculo `OWNER` e status `PENDING`.
- `/area-do-parceiro` leva anônimos ao login, pendentes ao `/aguardando-aprovacao` e ativos ao `/parceiro`.
- `/api/partner/status` retorna somente os dados da própria empresa e é inacessível sem sessão de parceiro.
- O administrador pesquisa/filtra parceiros e aprova, recusa, suspende ou reativa com confirmação e motivo quando aplicável.
- A alteração de status é refletida no usuário vinculado e registrada em auditoria.

Não considerar o push no GitHub como deploy concluído sem confirmar a versão no `/api/health`.

- [ ] Deploy da branch `main` concluído na Hostinger.
- [ ] `GET /api/health` retorna `status: ok`, `environment: staging` e a versão esperada.
- [ ] Header `X-Robots-Tag` contém `noindex, nofollow`.
- [ ] `/robots.txt` retorna `Disallow: /`.
- [ ] Página inicial carrega com banner de homologação.
- [ ] Fallback SPA funciona em uma rota amigável.
- [ ] Logo e imagens carregam sem 404.
- [ ] Links de WhatsApp abrem a mensagem correta, sem envio automático.
- [ ] Não há erros no console nem overflow em 360px e desktop.
- [ ] Nenhum dado real de cliente foi utilizado.

## Evidência técnica desta homologação

Os endpoints podem ser validados por `curl.exe` ou `Invoke-WebRequest`; não dependem de navegador automatizado. A conferência visual permanece manual quando o controle do navegador não estiver disponível.

Se o domínio continuar entregando `robots.txt` antigo, MIME `text/plain` no manifest ou não mostrar os novos headers após um push em `main`, verificar o histórico de deployments/auto-deploy no painel Hostinger e executar um redeploy manual. Não considerar o commit publicado como deploy concluído sem essa evidência HTTP.

## Limitações relevantes

Requests têm timeout de 120 s; não há WebSockets de entrada nem workers sempre ativos. Cron jobs existem, rodam em UTC e têm limite de 30 minutos. Uploads privados e documentos pessoais não devem ficar em `public` nem no cache offline. Limites específicos de upload e recursos variam por plano e precisam ser conferidos no painel contratado antes da Fase 8.

Se o código publicado estiver em `0.2.1`, mas um login com payload válido retornar `INTERNAL_ERROR`, verificar o histórico de deploy: o commit pode estar no GitHub sem ter sido aplicado pela Web App. Após o redeploy, consultar o diagnóstico de conexão; a instalação da estrutura deve seguir o procedimento manual pelo phpMyAdmin. Falhas de banco devem aparecer como `503 DATABASE_NOT_READY`.

## Migration 011 — Fase 3.14

A Migration 011 é incremental e necessária porque a regra persistida de `OTHER_STATE` para `LOWERED_SUSPENSION` não existia na Migration 010, além de atualizar os rótulos dos checklists. Não executar SQL remoto a partir do Codex. Depois da revisão e autorização, importar no phpMyAdmin, nesta ordem: `database/updates/011_suspension_form_usability_precheck.sql`, `database/updates/011_suspension_form_usability.sql` e `database/updates/011_suspension_form_usability_verify.sql`. O precheck é somente leitura; o verify deve retornar a regra `MANUAL_REVIEW` de prioridade 1 e uma única linha em `schema_migrations`.

## Diagnóstico temporário de conexão MySQL

Na inicialização do `server/index.js`, a aplicação executa o diagnóstico privado usando o mesmo pool de `server/database.js`. Os resultados aparecem nos logs da aplicação Node.js da Hostinger: painel da Web App → logs/runtime logs da aplicação → reiniciar/redeploy → procurar por `[database-diagnostic]`.

O diagnóstico executa somente `SELECT 1 AS connected`, `SELECT DATABASE() AS database_name` e `SHOW TABLES`. Não cria tabelas, não executa migrations e não cria administrador. A senha, a URL completa e o conteúdo de `DATABASE_URL` nunca são registrados.

Status possíveis: `DATABASE_CONFIG_MISSING`, `DATABASE_CONFIG_INVALID`, `ECONNREFUSED`, `ETIMEDOUT`, `ENOTFOUND`, `ER_ACCESS_DENIED_ERROR`, `ER_BAD_DB_ERROR`, `DATABASE_CONNECTED`, `DATABASE_CONNECTED_EMPTY_SCHEMA` e `DATABASE_CONNECTED_SCHEMA_EXISTS`. Para schema vazio ou existente, o log inclui apenas o banco selecionado, o resultado de conectividade e a quantidade de tabelas.
# Migration 007 instalada e Fase 3.9 publicada

O proprietário confirmou a instalação e verificação da Migration 007 no banco `u891593158_doc`. Não reimportar a migration, não executar SQL remoto e não iniciar a Fase 4. A Fase 3.9 foi publicada na `main` pelo commit `fa90ef0539bce813a613151d90ab6fd0684fe02b`; rollback: `rollback-before-fase-3-9-20261126`. A homologação funcional online ainda depende de evidência HTTP e testes manuais do proprietário.

## Hotfix 0.4.3

O hotfix do editor deve ser publicado somente após `lint`, `typecheck`, testes, build e sintaxe Node.js. A publicação não exige nova migration. Após o deploy, validar no painel administrativo o carregamento do editor, a simulação e a geração do PDF; registrar falhas SQL pelos logs privados usando o `X-Request-ID` retornado pela aplicação.

Para o estado parcial confirmado, não excluir as colunas `manual_whatsapp`, `manual_team_name` ou `manual_message_template`; a Migration 007 usa `ADD COLUMN IF NOT EXISTS` e `ON DUPLICATE KEY UPDATE` para permitir a recuperação segura.

# Fase 3.14 — procedimento de homologação

A versão `0.4.10` permanece em branch de desenvolvimento até autorização expressa. A Migration 010 já está instalada no banco remoto; não executar SQL, não reimportar migrations e não criar Migration 011 para correções que sejam apenas de renderização. Após autorização futura, publicar a branch, aguardar o deploy da Hostinger e validar manualmente os dois simuladores, sem consumir a Simples API.

