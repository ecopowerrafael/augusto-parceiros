# Arquitetura

## Estado atual

Monorepo simples, um único deploy Node.js. O build do Vite gera o frontend estático e o Express serve `dist` no mesmo domínio, com fallback para SPA. Não há persistência nem API de negócio na Fase 1.

O módulo `server/config.js` centraliza `NODE_ENV`, `APP_ENV`, `ALLOW_INDEXING`, `APP_DEBUG`, porta e versão. A aplicação comercial não depende de MySQL ou Simples API para inicializar. O endpoint `/api/health` não testa conectividade com banco; a estrutura de diagnóstico fica reservada para a Fase 2 e não expõe detalhes sensíveis.

## Direção futura

Adicionar API REST no mesmo processo Express, com camadas consistentes de validação (Zod), autorização no servidor, serviços de domínio, Prisma/MySQL e armazenamento privado de documentos. O banco alvo é MySQL por compatibilidade com Hostinger compartilhada.

## Limites da infraestrutura

Hostinger Web Apps suporta Node 18/20/22/24, React/Vite/Express, variáveis de ambiente, deploy via GitHub e MySQL. A hospedagem compartilhada encerra requisições em 120 segundos e não oferece workers permanentes ou WebSockets de entrada; tarefas assíncronas futuras devem usar cron ou serem reavaliadas para VPS.
