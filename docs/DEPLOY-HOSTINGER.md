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

## Limitações relevantes

Requests têm timeout de 120 s; não há WebSockets de entrada nem workers sempre ativos. Cron jobs existem, rodam em UTC e têm limite de 30 minutos. Uploads privados e documentos pessoais não devem ficar em `public` nem no cache offline. Limites específicos de upload e recursos variam por plano e precisam ser conferidos no painel contratado antes da Fase 8.
