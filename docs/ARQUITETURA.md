# Arquitetura

## Estado atual — Fase 2.1 / preparação Fase 3

Monorepo simples, um único deploy Node.js. O build do Vite gera o frontend estático e o Express serve `dist` no mesmo domínio, com fallback para SPA. A API REST da Fase 2 está no mesmo processo e usa MySQL via `mysql2`.

O módulo `server/config.js` centraliza `NODE_ENV`, `APP_ENV`, `ALLOW_INDEXING`, `APP_DEBUG`, porta e versão. `server/auth.js` concentra contratos Zod, hash de senha, sessão, CSRF, rate limit e auditoria. Rotas autenticadas exigem banco; o site público continua inicializando sem `DATABASE_URL`.

## Metodologia de ambientes

O computador local é usado para edição, lint, testes unitários e build. A Hostinger Node.js Web App é o ambiente de teste funcional real, recebendo a branch `main`. O ciclo é: implementar → validar localmente → commit → push → deploy Hostinger → testar por HTTP → corrigir → registrar. A inspeção visual é manual quando a automação do navegador não estiver disponível.

## Direção futura

Migrations SQL versionadas foram escolhidas para reduzir dependência de binários no ambiente compartilhado. Prisma não é necessário para o schema inicial. A Fase 3 prepara tabelas de serviços, preços e regras em SQL manual, sem consultar essas tabelas na aplicação até a confirmação de importação. A aplicação seguirá como um único deploy Express/Vite e o backend continuará sendo a autoridade para permissões, escopo de parceiro e estado das configurações.

## Limites da infraestrutura

Hostinger Web Apps suporta Node 18/20/22/24, React/Vite/Express, variáveis de ambiente, deploy via GitHub e MySQL. A hospedagem compartilhada encerra requisições em 120 segundos e não oferece workers permanentes ou WebSockets de entrada; tarefas assíncronas futuras devem usar cron ou serem reavaliadas para VPS.
