# Changelog

## [0.3.1] — Fase 3.1 — Construtor no-code — 2026-11-25

- Revisado o schema Fase 3 para versões de serviço, formulários dinâmicos, fontes simuladas, catálogo de cobranças, ações, documentos e mensagens.
- Implementado editor administrativo genérico e simulador baseado nas configurações persistidas.
- Implementado avaliador declarativo sem `eval`, com deduplicação de cobranças, limites, análise manual e bloqueios.
- Adicionados testes dos cenários financeiros A–J, placas, 10%, dados ausentes, ciclos e referências inválidas.
- Mantida a entrega somente na branch de desenvolvimento; nenhum SQL remoto executado e nenhuma alteração publicada na `main`.

## [0.3.0-prep] — Preparação de serviços, preços e regras técnicas — 2026-11-25

- Preparado schema SQL para serviços, categorias, UFs, disponibilidade, relações, preços e regras técnicas.
- Criados precheck, atualização manual e verificação pós-importação.
- Regras preliminares entram inativas (`DRAFT`) e nenhum preço real é semeado.
- Código da aplicação ainda não consulta as novas tabelas; aguarda confirmação do phpMyAdmin.

## [0.2.1] — Ajustes de autenticação e provisionamento administrativo

- Ajustadas as políticas de senha por perfil: cliente (6), parceiro (8) e administrador (12 com complexidade).
- Aplicadas validações de senha em cadastro, alteração e redefinição sem afetar o login de usuários existentes.
- Adicionado mostrar/ocultar senha, autocomplete e mensagens simples nos formulários.
- Traduzidos status nos painéis, removida duplicidade de logo e ampliado o layout desktop.
- Provisionamento administrativo mantido sem credenciais padrão ou endpoint público.

## [0.2.0] — Fase 2 — 2026-11-25

- Adicionada persistência MySQL com migrations para usuários, parceiros, clientes, sessões, rate limit e auditoria.
- Adicionados perfis, cadastros, login, logout, alteração e recuperação de senha via SMTP configurável.
- Adicionados CSRF, cookies HttpOnly/Secure, bcrypt e scripts de migration/provisionamento.
- Preservado o site comercial; sem Simples API, motor de regras, orçamentos ou financeiro.
- Painel administrativo inicial com indicadores reais e ações de aprovação, recusa e suspensão de parceiros.
- Gestão inicial de usuários, auditoria protegida e matriz documentada de permissões.
- Adicionados artefatos de instalação manual pelo phpMyAdmin: `database/install.sql`, `database/create-admin.sql`, `database/verify.sql` e documentação operacional.

## [0.1.1] — Fase 1.4 — 2026-11-25

- Substituída a marca de apresentação pelo logotipo retangular oficial.
- Criado componente reutilizável `BrandLogo` para futuras telas autenticadas.
- Gerados favicons, Apple Touch Icon e ícones PWA a partir do ícone oficial quadrado.
- Atualizadas referências do manifest, HTML e documentação de identidade visual.
- Versão centralizada atualizada para `0.1.1`.

## [0.1.0] — Fase 1.1 — 2026-11-25

- Adicionada configuração centralizada de ambientes e variáveis de homologação.
- Adicionados `/api/health` e `/api/runtime-config` sem dados sensíveis.
- Adicionados banner de staging e proteção condicional contra indexação.
- Atualizada documentação do fluxo Hostinger → GitHub → testes online.

## [0.1.0] — Fase 1 — 2026-11-25

- Criada fundação React + TypeScript + Vite + Express.
- Criada landing page comercial responsiva da Doc Motor.
- Integrada logo fornecida e imagens automotivas locais geradas para o projeto.
- Implementados serviços, FAQ, fluxo de parceria e CTAs de WhatsApp.
- Adicionados manifest PWA, robots.txt, sitemap.xml e metadados SEO.
- Registrada arquitetura compatível com Hostinger Web Apps Node.js.
