# Doc Motor — Documentação Veicular

Plataforma comercial e operacional da Doc Motor. A Fase 1 entrega o site comercial; a Fase 2 adiciona autenticação, perfis, permissões e persistência MySQL. Simples API, regras de viabilidade, orçamentos e financeiro permanecem fora do escopo atual.

## Stack

React + TypeScript + Vite, servido em produção por Express; MySQL via mysql2, Zod, bcryptjs, Nodemailer e Lucide. A escolha é compatível com o fluxo Node.js Web App da Hostinger.

## Desenvolvimento

```bash
npm install
npm run dev
```

Verificações: `npm run lint`, `npm run typecheck`, `npm run test` e `npm run build`.

## Homologação

O ambiente principal de homologação é a Hostinger Node.js Web App, com deploy da branch `main`. Na homologação, use `NODE_ENV=production`, `APP_ENV=staging`, `ALLOW_INDEXING=false` e `APP_DEBUG=false`. O endpoint público de saúde é `GET /api/health`; ele retorna somente status, ambiente e versão.

O formulário da Fase 1 não grava dados. Não utilize dados reais de clientes durante a homologação.

## Estrutura

- `src/App.tsx`: experiência comercial e interações locais.
- `src/styles.css`: identidade visual e responsividade.
- `public/assets`: logo oficial e imagens editoriais locais.
- `server/index.js`: servidor Express para servir `dist` em produção.
- `server/app.js` e `server/auth.js`: API de autenticação, autorização, sessões, auditoria e painéis iniciais.
- `migrations/001_initial.sql`: schema inicial da Fase 2.
- `scripts/migrate.mjs` e `scripts/provision-admin.mjs`: operações explícitas de infraestrutura.
- `docs/`: decisões, regras, roadmap, segurança e status persistente.

## Preparação da Fase 3

A Fase 3 está autorizada somente para preparar o catálogo de serviços, disponibilidade, preços e regras técnicas. O código da aplicação ainda não consulta essas tabelas. Para um banco Fase 2 existente, execute no phpMyAdmin, nesta ordem: `database/updates/002_services_pricing_rules_precheck.sql`, `database/updates/002_services_pricing_rules.sql` e `database/updates/002_services_pricing_rules_verify.sql`. Após a confirmação do proprietário, será implementado o painel administrativo e a publicação dependerá dessas tabelas.

O arquivo `database/install.sql` já contém o schema Fase 2 + Fase 3 para bancos novos. Não executar `DROP`, migrations automáticas ou operações remotas pelo projeto.

## Deploy

Leia [`docs/DEPLOY-HOSTINGER.md`](docs/DEPLOY-HOSTINGER.md). Em produção, configure `npm run build` como build command, `dist` como output quando aplicável e `server/index.js` como entry file Node/Express.

## Fase 2

Em ambientes com terminal, `node scripts/migrate.mjs` e `node scripts/provision-admin.mjs` executam a instalação/provisionamento. Na Hostinger desta fase, use o procedimento manual pelo phpMyAdmin documentado em `database/README.md`. O cadastro de parceiro inicia pendente de aprovação.

Para a instalação atual da Hostinger, siga `database/README.md`: importe os SQLs pelo phpMyAdmin e não execute os scripts de terminal.

## Escopo da Fase 1

Inclui home comercial, navegação por âncoras, FAQ, formulário de parceria que monta mensagem e abre o WhatsApp, CTAs por serviço, SEO técnico básico, sitemap, robots, manifest PWA e página de área do parceiro ainda não implementada (sem autenticação falsa).
