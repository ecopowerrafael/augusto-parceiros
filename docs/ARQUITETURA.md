# Arquitetura

## Estado atual — Fase 3.2

Monorepo simples, um único deploy Node.js. O build do Vite gera o frontend estático e o Express serve `dist` no mesmo domínio, com fallback para SPA. A API REST da Fase 2 está no mesmo processo e usa MySQL via `mysql2`.

O módulo `server/config.js` centraliza `NODE_ENV`, `APP_ENV`, `ALLOW_INDEXING`, `APP_DEBUG`, porta e versão. `server/auth.js` concentra contratos Zod, hash de senha, sessão, CSRF, rate limit e auditoria. Rotas autenticadas exigem banco; o site público continua inicializando sem `DATABASE_URL`.

## Metodologia de ambientes

O computador local é usado para edição, lint, testes unitários e build. A Hostinger Node.js Web App é o ambiente de teste funcional real, recebendo a branch `main`. O ciclo é: implementar → validar localmente → commit → push → deploy Hostinger → testar por HTTP → corrigir → registrar. A inspeção visual é manual quando a automação do navegador não estiver disponível.

## Direção futura

Migrations SQL versionadas foram escolhidas para reduzir dependência de binários no ambiente compartilhado. Prisma não é necessário. O modelo no-code separa `services` de `service_versions`; formulário, cobranças, regras, documentos e mensagens apontam para a versão. O avaliador em `server/service-config.js` aceita somente operadores e ações enumerados, não usa `eval`, SQL do usuário ou scripts configuráveis. Na Fase 3.7, normalizadores reutilizáveis convertem combustível, placas e cilindradas antes do cálculo; o frontend não é autoridade para totais ou viabilidade.

`server/services.js` concentra a API administrativa com autorização de administrador, CSRF, validação Zod, transações e auditoria. A interface `ServiceBuilder` é genérica: os campos do simulador são renderizados pelas linhas do banco, não por componentes de cadastro de motor. Fontes externas são apenas registros de adaptadores permitidos; a Simples API real continua fora da fase.

Versões são rascunhos até publicação posterior. O serviço inicial de cadastro de motor é semeado como `DRAFT`, com campos e cobranças informados pelo proprietário. A duplicação de serviço copia a configuração da versão para um novo serviço e cria nova versão rascunho.

## Limites da infraestrutura

Hostinger Web Apps suporta Node 18/20/22/24, React/Vite/Express, variáveis de ambiente, deploy via GitHub e MySQL. A hospedagem compartilhada encerra requisições em 120 segundos e não oferece workers permanentes ou WebSockets de entrada; tarefas assíncronas futuras devem usar cron ou serem reavaliadas para VPS.
# Fase 3.5

A área administrativa usa rotas independentes sobre o mesmo shell autenticado. A aprovação de parceiro é uma transação única que bloqueia a empresa, sincroniza os usuários membros e registra auditoria. Falhas retornam request ID e são observáveis somente nos logs privados.
