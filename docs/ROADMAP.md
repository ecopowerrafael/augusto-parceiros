# Roadmap

1. Fundação e site comercial — concluída.
1.1. Preparação do ambiente online de homologação — concluída.
1.4. Identidade visual oficial e encerramento da homologação inicial — concluída.
2. Autenticação segura e PWA instalável — implementação 0.2.1 em homologação.

   Entregue: perfis ADMINISTRATOR/PARTNER/CLIENT, cadastros, aprovação de parceiro, login/logout, sessões, CSRF, rate limit, bcrypt, auditoria, reset SMTP, migrations e painéis iniciais.
   Pendente: importar o banco pelo phpMyAdmin, configurar SMTP/admin, executar testes HTTP com contas fictícias e validação visual manual.
   Conexão MySQL comprovada em ambiente real usando `127.0.0.1`; banco inicialmente vazio.
   Ajustes 0.2.1: políticas de senha por perfil, colaboradores, mostrar/ocultar senha e status traduzidos.
3. Painel administrativo e configurações comerciais — Fase 3.1 implementada; Fase 3.2 em homologação autenticada / versão 0.3.0 publicada.
   Construtor no-code, composição de cobranças, regras declarativas e simulador implementados. Migrations 001, 002 e 003 confirmadas no MySQL remoto; pendente apenas a execução dos cenários pelo proprietário e a criação do segundo serviço demonstrativo pela interface.
3.3. Fluxo de cadastro e aprovação de parceiros — correção 0.3.1 preparada.
   Integração dos CTAs comerciais com o cadastro real, acompanhamento seguro de pendentes, busca/filtros administrativos e transições de status com auditoria. Pendente validar o fluxo completo online com contas fictícias.
3.4. Usabilidade, cadastro e mensagens — correção 0.3.2 publicada.
   Documento CPF/CNPJ automático, remoção de nome de acesso, máscaras reutilizáveis e tradução centralizada de erros; sem alteração de schema.
3.5. Reestruturação administrativa e comissionamento — versão 0.3.3 integrada na `main`; Migration 004 instalada e validada.
3.6. Design system, painéis profissionais e homologação do simulador — versão 0.3.5. Shell autenticado, navegação por perfil, correção de cidade/UF, comissão condicional, simulador sem persistência e Migration 005 instalada/validada.
3.7. Correção do simulador no-code — versão 0.3.6. Normalização de combustível, placas e cilindradas, fixture do cenário comercial, erros específicos e Migration 006 incremental aguardando importação manual. Não iniciar a Fase 4.
3.7.1. Correção da configuração real do simulador — versão 0.3.7. Campos derivados de placa reconhecidos pelo validador, conversão visual de cilindrada no blur, detalhes de erro no simulador e teste de integração equivalente às migrations 001–006. Sem nova migration.
3.7.2. Correção da normalização de combustíveis — versão 0.3.8. Compatibilidade completa entre valores internos persistidos, aliases do frontend e respostas futuras da API. Sem alteração de banco.
3.9. Regras declarativas, simulador comercial e PDF profissional — versão `0.4.2` publicada na `main`; Migration 007 instalada e verificada na Hostinger; homologação funcional online pendente.
3.9.1. Hotfix do editor HTTP 503 — versão `0.4.3` publicada na `main` pelo commit `27c8b190938aa7f7b687a2c53282e28178aef3e2`; homologação online pendente.
3.9.2. Hotfix 0.4.4 de diagnóstico do erro interno após as consultas do editor; normalização JSON e regressão ampliada implementadas. Homologação online pendente.
3.9.3. Hotfix 0.4.5 corrige a validação de campos declarativos legados da Migration 007; 127 testes aprovados. Homologação online pendente.
3.10. Fluxo condicional, análise manual e PDF — implementação local da versão `0.4.6` na branch `feature/fase-3-10-fluxo-resultado-pdf`; sem nova migration identificada até o momento. Aguardando revisão e homologação funcional do proprietário antes da `main`.
4. Integração Simples API, após validação contratual e técnica.
5. Motor de regras de cadastro de motor.
6. Orçamentos em PDF e conversão em solicitação.
7. Solicitações, checklist e anexos.
8. Documentação digital privada e links seguros.
9. Acompanhamento por linha do tempo.
10. Financeiro, relatórios e expansão.

Fases posteriores dependem de validação das regras operacionais e não devem ser inferidas como aprovação pelo Detran.
- Fase 3.5: reestruturação administrativa e preparação de comissionamento integradas na `main`; Migration 004 confirmada pelo proprietário. Pendentes propagação online e homologação autenticada.
## Fase 3.8 — resultado visual, PDF e compartilhamento

Concluída e incorporada à Fase 3.9 na versão `0.4.2`. A Migration 007 foi instalada manualmente no phpMyAdmin; a homologação funcional online permanece pendente.
