# Deploy na Hostinger

Baseado na documentação oficial consultada em 25/11/2026: Hostinger Web Apps Node.js suporta planos Business/Unlimited e Cloud; presets React, Vite e Express; Node 18, 20, 22 e 24; deploy via GitHub; variáveis de ambiente no painel; e MySQL com `127.0.0.1`.

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

## Fase 3 — implantação em duas etapas

O proprietário confirmou a importação da Migration 002 e das 23 tabelas no banco correto. Não reimportar a 002. Para esta missão, usar somente: (1) `database/updates/003_complete_engine_service_seed_precheck.sql`; (2) `database/updates/003_complete_engine_service_seed.sql`; (3) `database/updates/003_complete_engine_service_seed_verify.sql`. Só depois da confirmação da 003 o código do painel que depende dessas configurações poderá ser publicado na `main`.

A versão `0.3.0` foi publicada na `main` pelo commit `4f22ceb` (documentação final em `020b443`) e propagou na Hostinger. A validação HTTP confirmou `/api/health`, `/api/runtime-config`, `/api/services/catalog`, manifest, robots, headers, assets e `401` nas rotas administrativas sem sessão. Não importar migrations novamente.

Os arquivos manuais devem ser gerados localmente por `node scripts/generate-hostinger-sql.mjs u891593158_doc database/updates`. Eles iniciam com `USE \`u891593158_doc\`;` e `SELECT DATABASE()`, qualificam tabelas da aplicação e não dependem de SSH ou CLI MySQL. A 002 já foi aplicada; para a configuração complementar, usar somente a sequência da 003: precheck, `003_complete_engine_service_seed.sql`, depois verify. Não importar novamente a 002.

Não executar migrations no startup, não usar SSH como requisito e não importar o SQL Fase 3 em produção sem conferência do banco selecionado. Em caso de falha parcial, preservar o erro do phpMyAdmin e interromper a sequência.

## Checklist de testes online

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

## Diagnóstico temporário de conexão MySQL

Na inicialização do `server/index.js`, a aplicação executa o diagnóstico privado usando o mesmo pool de `server/database.js`. Os resultados aparecem nos logs da aplicação Node.js da Hostinger: painel da Web App → logs/runtime logs da aplicação → reiniciar/redeploy → procurar por `[database-diagnostic]`.

O diagnóstico executa somente `SELECT 1 AS connected`, `SELECT DATABASE() AS database_name` e `SHOW TABLES`. Não cria tabelas, não executa migrations e não cria administrador. A senha, a URL completa e o conteúdo de `DATABASE_URL` nunca são registrados.

Status possíveis: `DATABASE_CONFIG_MISSING`, `DATABASE_CONFIG_INVALID`, `ECONNREFUSED`, `ETIMEDOUT`, `ENOTFOUND`, `ER_ACCESS_DENIED_ERROR`, `ER_BAD_DB_ERROR`, `DATABASE_CONNECTED`, `DATABASE_CONNECTED_EMPTY_SCHEMA` e `DATABASE_CONNECTED_SCHEMA_EXISTS`. Para schema vazio ou existente, o log inclui apenas o banco selecionado, o resultado de conectividade e a quantidade de tabelas.
