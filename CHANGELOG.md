# Changelog

## [0.4.2] — Auditoria da Fase 3.9 — 2026-11-26

- Adicionada edição administrativa dos contatos da análise manual, sem número fixo no frontend.
- Resultado manual não exibe orçamento, valores ou PDF; quando configurado, encaminha os dados reais preenchidos ao WhatsApp administrativo.
- PDF A4 reorganizado com logotipo oficial, identificação, responsável, data, dados técnicos, serviços, total, documentos e contato.
- Seleção visual do estado limitada a São Paulo e Outros estados; o backend continua como autoridade.
- Validações locais executadas: lint, typecheck, 120 testes e build.
- Gerados três PDFs demonstrativos com o mesmo gerador da aplicação e prévias PNG conferidas visualmente; publicação continua aguardando aprovação visual.

## [0.4.2] — Recuperação da Migration 007 após erro #1582 — 2026-11-26

- Substituída a condição aninhada da cobrança `MODIFICATION_REQUEST` por JSON serializado validado, eliminando a chamada `JSON_OBJECT` que falhava no MariaDB da Hostinger.
- Reauditadas as expressões JSON e mantido o avaliador declarativo como referência semântica.
- A Migration 007 continua idempotente para o estado parcial informado; nenhuma migration anterior foi alterada.

## [0.4.1] — Correção definitiva da Migration 007 — 2026-11-26

- Corrigida a linha `motorcycle.compatibility_declaration`, que tinha 13 valores para 14 colunas.
- Reauditados todos os `INSERT`s da Migration 007; 20 linhas tiveram correspondência de colunas e valores validada por script estático.
- Corrigidos UUIDs de documentos e mensagens e reforçada a condição de registro em `schema_migrations` somente após a estrutura completa existir.
- Preparada recuperação idempotente para o estado parcial real da Hostinger, preservando as três colunas de contato já criadas.
- Confirmada a limitação: MariaDB descartável não está disponível neste ambiente; não houve execução SQL remota.

## [0.4.0] — Fase 3.9 — Correção de regras e pacote SQL Hostinger — 2026-11-26

- Preparada a Migration 007 incremental, sem operações destrutivas, para regras comerciais autorizadas, documentos, mensagens e contato de análise manual.
- Corrigida a geração dos artefatos Hostinger com `USE`, referências qualificadas ao banco e preservação de `information_schema`.
- O orçamento automático agora exclui ITL/CSV e cobra no máximo uma solicitação de modificação quando aplicável.
- Adicionados testes locais para limites de 10%, dados ausentes, deduplicação e validação de configuração.
- Publicação na `main` permanece suspensa até a importação manual e confirmação do proprietário no phpMyAdmin.

## [0.3.5] — Fase 3.6 — Auditoria do simulador NO-CODE — 2026-11-25

- Confirmada a Migration 005 instalada pelo proprietário no banco remoto.
- Adicionado contrato Zod para o payload do simulador, tratamento específico de falhas e garantia de zero chamadas externas.
- Adicionados 13 cenários de homologação executável para o avaliador declarativo, com placas, potência, cilindrada, combustível, nota fiscal, motocicleta e preenchimento manual.

## [0.3.4] — Fase 3.6 — Design system e homologação do simulador — 2026-11-25

- Criado shell SaaS responsivo para áreas autenticadas, com navegação específica de administrador e parceiro, topbar, títulos objetivos e conta separada.
- Corrigido o carregamento de cidade/UF no painel do parceiro pela consulta oficial do backend.
- Tornada a configuração global de comissão condicional ao modelo, com valor fixo exibido em reais e conversão para centavos no envio.
- Itens operacionais futuros permanecem explicitamente indisponíveis; não foram criadas operações simuladas nem integração real com a Simples API.
- Adicionado simulador de comissão sem persistência financeira, usando o avaliador backend e exibindo total, base elegível, honorários e comissão.
- O simulador permite selecionar um parceiro ativo e calcula a regra efetiva global, personalizada ou desativada.
- Preparada Migration 005 para configurações gerais comerciais persistidas, com precheck, atualização e verify manuais.
- Migration 005 confirmada pelo proprietário no phpMyAdmin, com `application_settings` criada, registro inicial e migration registrada.
- Adicionado roteiro executável com 13 cenários do simulador NO-CODE, incluindo placas, potência, cilindrada, combustível, nota fiscal, motocicleta e entrada manual sem API externa.

## [0.3.3] — Fase 3.5 — Administração e comissionamento — 2026-11-25

- Branch `feature/fase-3-5-admin-comissoes` integrada na `main` após validação local completa.
- Reestruturada a área administrativa com rotas independentes para visão geral, parceiros, clientes, serviços, comissões, chaves API e configurações.
- Corrigido o fluxo transacional de aprovação de parceiros com request ID e diagnóstico SQL seguro.
- Preparados comissão global, override individual, herança global, modelos em centavos e classificação semântica de honorários.
- Migration 004 importada e validada manualmente pelo proprietário no banco de homologação; comissões permanecem desativadas por padrão.

## [0.3.2] — Fase 3.4 — Usabilidade, cadastro e mensagens — 2026-11-25

- Corrigido o fluxo que deixava `PJ` fixo e causava `DOCUMENT_TYPE_MISMATCH` ao informar CPF.
- Adicionada máscara automática CPF/CNPJ, inferência PF/PJ, normalização no backend e suporte à validação de CNPJ alfanumérico.
- Removido o campo redundante de nome de acesso do cadastro de parceiros.
- Centralizadas mensagens amigáveis para erros da API e adicionadas máscaras reutilizáveis de documento, telefone e CEP.

## [0.3.1] — Fase 3.3 — Fluxo de parceiros — 2026-11-25

- Conectados os CTAs comerciais de parceiro ao cadastro real e à área autenticada.
- Adicionado acompanhamento seguro do status do próprio parceiro pendente.
- Ampliada a gestão administrativa com pesquisa, filtros por status/segmento/UF, indicadores por status e confirmações de mutação.
- Preservadas as migrations existentes, o construtor no-code e a integração exclusiva por WhatsApp para atendimento geral.

## [0.3.0] — Fase 3 — Construtor no-code — 2026-11-25

- Revisado o schema Fase 3 para versões de serviço, formulários dinâmicos, fontes simuladas, catálogo de cobranças, ações, documentos e mensagens.
- Implementado editor administrativo genérico e simulador baseado nas configurações persistidas.
- Implementado avaliador declarativo sem `eval`, com deduplicação de cobranças, limites, análise manual e bloqueios.
- Adicionados testes dos cenários financeiros A–J, placas, 10%, dados ausentes, ciclos e referências inválidas.
- Completa a auditoria das mutações do builder, incluindo campos, opções, vínculos de cobrança, ações, regras e documentos.
- Adicionada aba de configuração geral/versionamento e exposição no builder para disponibilidade, publicação e arquivamento de versões.
- Preparada Migration 003 incremental para completar cálculo de potência, padrão de placa, UFs, adaptadores externos, CSV sem valor e regras preliminares pendentes.
- Padronizados SQLs manuais Hostinger com gerador local, `USE`, `SELECT DATABASE()`, schema explícito e referências qualificadas.
- Publicada a versão `0.3.0` na `main` e validada por HTTP na Hostinger; testes autenticados do builder permanecem sob responsabilidade do proprietário.
- Ampliada a interface do builder para opções, campos calculados, condições de visibilidade, cobranças condicionais, mapeamentos e ações de regras.
- Adicionado roteiro persistente em `docs/HOMOLOGACAO-FASE-3.2.md` com 12 cenários do motor, checklist do segundo serviço no-code e limites da validação.
- Alinhada a documentação de fase: 3.1 implementada, 3.2 em homologação autenticada e migrations 001–003 confirmadas, sem reimportação.

## [0.3.0-prep] — Preparação anterior de serviços, preços e regras técnicas — 2026-11-25

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
## 0.3.3 — Fase 3.5

- Reestruturada a área administrativa com navegação independente para visão geral, parceiros, clientes e configuração de serviços.
- Corrigida a transição de status de parceiros com atualização atômica de empresa e usuários vinculados, request ID e logs estruturados sem PII.
- Preparada a migration 004 de comissionamento genérico, inicialmente com modelo `NONE` e sem valores comerciais ativos.
- A migration 004 ainda depende de importação manual no phpMyAdmin antes da integração em `main`.

# 0.3.6 - Fase 3.7

- Corrigida a normalização declarativa do simulador para combustível, placas e cilindradas.
- Adicionados testes do cenário do proprietário, equivalência Álcool/Etanol e placas antigas/Mercosul.
- Migration 006 importada e validada pelo proprietário no banco da Hostinger; nenhum SQL remoto foi executado pelo projeto.
- A versão permanece `0.3.6`, pois o estado atual da branch já havia avançado de `0.3.5`; não foi realizado downgrade de versão.

# 0.3.7 - Fase 3.7.1

- Corrigido o HTTP 422 causado por referências a `vehicle_target.plate_pattern` e `vehicle_donor.plate_pattern`, agora tratados como campos derivados internos.
- Corrigida a conversão visual de cilindradas no blur e a apresentação de detalhes seguros de configuração no simulador.
- Adicionado teste de integração do contrato equivalente à configuração persistida pelas migrations 001–006; nenhuma Migration 007 foi criada.

# 0.3.8 - Correção de combustíveis do simulador

- Aceito o valor interno `ALCOHOL`, que estava ausente no mapa backend e causava `INVALID_FUEL` para a opção Álcool.
- Padronizados aliases de Álcool/Etanol, Gasolina, Diesel e Flex no frontend e backend, com normalização idempotente.
- Adicionados testes de integração para os quatro valores internos, aliases, alteração efetiva e valor inválido.

# 0.3.9

- Adicionada apresentação visual reutilizável do resultado do simulador.
- Adicionados PDF A4 real, visualização, download, impressão e compartilhamento com fallback responsável para WhatsApp.
- Corrigido o filtro de regras por categoria do veículo e descartadas ações vazias de `LEFT JOIN`.
- Modo manual agora remove a placa e o padrão derivados do motor de origem.
- Documentação permanente em `docs/GERACAO-DE-DOCUMENTOS.md`.

