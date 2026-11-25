# Doc Motor — Documentação Veicular

Landing page comercial da Doc Motor, construída para apresentar serviços de regularização veicular e captar clientes/parceiros via WhatsApp. A Fase 1 não possui autenticação, banco de dados ou integração real com a Simples API.

## Stack

React + TypeScript + Vite, servido em produção por Express; CSS responsivo sem dependência de framework visual; Lucide para ícones; PWA manifest preparado. A escolha é compatível com o fluxo Node.js Web App da Hostinger.

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
- `docs/`: decisões, regras, roadmap, segurança e status persistente.

## Deploy

Leia [`docs/DEPLOY-HOSTINGER.md`](docs/DEPLOY-HOSTINGER.md). Em produção, configure `npm run build` como build command, `dist` como output quando aplicável e `server/index.js` como entry file Node/Express.

## Escopo da Fase 1

Inclui home comercial, navegação por âncoras, FAQ, formulário de parceria que monta mensagem e abre o WhatsApp, CTAs por serviço, SEO técnico básico, sitemap, robots, manifest PWA e página de área do parceiro ainda não implementada (sem autenticação falsa).
