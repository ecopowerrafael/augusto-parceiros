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
3.4. Usabilidade, cadastro e mensagens — correção 0.3.2 preparada.
   Documento CPF/CNPJ automático, remoção de nome de acesso, máscaras reutilizáveis e tradução centralizada de erros; sem alteração de schema.
4. Integração Simples API, após validação contratual e técnica.
5. Motor de regras de cadastro de motor.
6. Orçamentos em PDF e conversão em solicitação.
7. Solicitações, checklist e anexos.
8. Documentação digital privada e links seguros.
9. Acompanhamento por linha do tempo.
10. Financeiro, relatórios e expansão.

Fases posteriores dependem de validação das regras operacionais e não devem ser inferidas como aprovação pelo Detran.
