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

Não preencher senhas neste repositório ou nesta documentação. Após configurar o painel, executar `node scripts/migrate.mjs` e `node scripts/provision-admin.mjs` em ambiente controlado.

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

Se o código publicado estiver em `0.2.0`, mas um login com payload válido retornar `INTERNAL_ERROR`, verificar o histórico de deploy: o commit pode estar no GitHub sem ter sido aplicado pela Web App. Após o redeploy, executar a migration e repetir o teste; falhas de banco devem aparecer como `503 DATABASE_NOT_READY`.
