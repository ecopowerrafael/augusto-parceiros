# Arquitetura

## Estado atual

Monorepo simples, um único deploy Node.js. O build do Vite gera o frontend estático e o Express serve `dist` no mesmo domínio, com fallback para SPA. Não há persistência nem API de negócio na Fase 1.

## Direção futura

Adicionar API REST no mesmo processo Express, com camadas consistentes de validação (Zod), autorização no servidor, serviços de domínio, Prisma/MySQL e armazenamento privado de documentos. O banco alvo é MySQL por compatibilidade com Hostinger compartilhada.

## Limites da infraestrutura

Hostinger Web Apps suporta Node 18/20/22/24, React/Vite/Express, variáveis de ambiente, deploy via GitHub e MySQL. A hospedagem compartilhada encerra requisições em 120 segundos e não oferece workers permanentes ou WebSockets de entrada; tarefas assíncronas futuras devem usar cron ou serem reavaliadas para VPS.
