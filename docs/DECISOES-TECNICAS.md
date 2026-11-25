# Decisões técnicas

## 2026-11-25 — um deploy Node.js

Escolhido React/TypeScript/Vite servido por Express no mesmo domínio. Reduz complexidade e encaixa no recurso Web Apps Node.js da Hostinger, com MySQL futuro.

## 2026-11-25 — sem backend de negócio na Fase 1

Não simular armazenamento, autenticação ou integração externa. O formulário abre WhatsApp com dados digitados, tornando explícito o limite real do produto.

## 2026-11-25 — logo oficial preservada

A logo existente foi usada sem redesenho. A interface usa vermelho como cor comercial de ação e mantém o azul da marca como assinatura da logo.
# Fase 2 — decisões adicionais

- `mysql2` foi adotado no lugar do Prisma para a primeira migration: a hospedagem compartilhada não exige geração de client/binários e o schema SQL versionado mantém o deploy simples. A camada `server/database.js` centraliza pool e transações.
- Sessões opacas persistidas foram escolhidas em vez de JWT para permitir revogação, expiração e controle operacional imediato.
- SMTP é opcional na inicialização, mas obrigatório para envio real de recuperação de senha; sem configuração a solicitação não expõe token e permanece documentada como indisponível.
- O painel administrativo usa consultas reais do MySQL e ações transacionais de aprovação/suspensão. Nenhum indicador é preenchido com valores fictícios.
- A primeira instalação do banco será manual pelo phpMyAdmin, após diagnóstico real confirmar `127.0.0.1`, para não depender de SSH/terminal da Hostinger. `schema_migrations` é registrado pelo SQL somente depois que as oito tabelas da Fase 2 existem.
