# Doc Motor — Documentação Veicular

Plataforma comercial e operacional da Doc Motor. A Fase 1 entrega o site comercial; a Fase 2 adiciona autenticação, perfis, permissões e persistência MySQL. A Fase 3 usa o construtor no-code, o catálogo central de modificações, páginas operacionais e o simulador administrativo. A versão 0.4.11 prepara a estrutura operacional; Simples API real, documentos de clientes e financeiro permanecem fora do escopo atual.

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
- `server/services.js` e `server/service-config.js`: catálogo administrativo, construtor no-code e avaliador declarativo sem `eval`.
- `migrations/001_initial.sql`: schema inicial da Fase 2.
- `scripts/migrate.mjs` e `scripts/provision-admin.mjs`: operações explícitas de infraestrutura.
- `docs/`: decisões, regras, roadmap, segurança e status persistente.
- `docs/HOMOLOGACAO-FASE-3.2.md`: roteiro dos 12 cenários do motor e homologação do segundo serviço no-code.
- `docs/HOMOLOGACAO-FASE-3.7.md`: roteiro da correção de normalização e importação manual da Migration 006.
- `docs/CATALOGO-MODIFICACOES.md`: catálogo reutilizável e limites de aplicabilidade.
- `docs/ESTRUTURA-OPERACIONAL.md`: separação entre configuração administrativa e operação.
- `docs/HOMOLOGACAO-FASE-3.15.md`: roteiro da estrutura operacional e da navegação.
- `docs/REGULARIZACAO-SUSPENSAO.md`: regras e fluxo declarativo do serviço de suspensão.
- `docs/HOMOLOGACAO-FASE-3.13.md`: roteiro e pendências de homologação.

## Fase 3 — construtor no-code e homologação

A branch contém o painel administrativo para configurar serviços, versões, seções, campos, fontes simuladas, cobranças, regras, documentos e o simulador. O backend valida todos os contratos e é a autoridade para o cálculo. O simulador possui apresentação visual e PDF de demonstração, sempre marcado como sem validade comercial. O fluxo comercial de parceiros usa `/cadastro-parceiro`; `/area-do-parceiro` direciona cada perfil conforme a sessão e o status real. Não há integração real com a Simples API, orçamento persistido ou armazenamento de documentos nesta fase.

Para um banco Fase 2 existente, as migrations 002 e 003 já confirmadas não devem ser reexecutadas. A Fase 3.3 não exige alteração de schema ou nova migration.

O arquivo `database/install.sql` já contém o schema Fase 2 + Fase 3 para bancos novos. Não executar `DROP`, migrations automáticas ou operações remotas pelo projeto.

## Deploy

Leia [`docs/DEPLOY-HOSTINGER.md`](docs/DEPLOY-HOSTINGER.md). Em produção, configure `npm run build` como build command, `dist` como output quando aplicável e `server/index.js` como entry file Node/Express.

## Fase 2

Em ambientes com terminal, `node scripts/migrate.mjs` e `node scripts/provision-admin.mjs` executam a instalação/provisionamento. Na Hostinger desta fase, use o procedimento manual pelo phpMyAdmin documentado em `database/README.md`. O cadastro de parceiro inicia pendente de aprovação.

Para a instalação atual da Hostinger, siga `database/README.md`: importe os SQLs pelo phpMyAdmin e não execute os scripts de terminal.

## Escopo da Fase 1

Inclui home comercial, navegação por âncoras, FAQ, atendimento geral por WhatsApp, CTAs por serviço, cadastro real de parceiros, SEO técnico básico, sitemap, robots, manifest PWA e área autenticada do parceiro com acompanhamento de status.
# Doc Motor

Plataforma de documentação veicular. A versão em desenvolvimento desta branch é `0.4.12`, Fase 3.16. O ambiente oficial de homologação é a Hostinger; a conferência visual continua manual e nenhuma homologação é declarada automaticamente.

Consulte `AGENTS.md`, `docs/STATUS-DO-PROJETO.md` e `docs/DEPLOY-HOSTINGER.md` antes de alterar o projeto.
