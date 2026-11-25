# Status do projeto

## Fase atual

Fase 3.5 — reestruturação administrativa e preparação de comissionamento — versão `0.3.3` integrada na `main`; propagação online e homologação autenticada ainda pendentes.

## Fase 3.5 — estado da publicação

- Migration 004 instalada e validada pelo proprietário no banco `u891593158_doc`, MariaDB `11.8.9-MariaDB-log`.
- `commission_settings` e `partner_commission_overrides` existem; configuração inicial permanece `NONE`, sem valores comerciais ativos.
- Commit da `main` antes da integração, usado como rollback: `c98aa17f4bd1c82d13bd333876c30778d9a2c67e`.
- Branch integrada: `feature/fase-3-5-admin-comissoes`; versão no código: `0.3.3`.
- Propagação na Hostinger: pendente de confirmação HTTP; homologação autenticada da aprovação: pendente.
- Após a publicação da `main` em `44ca97339c1f4dd24caded242cb4631de92865e7`, a validação com `Invoke-WebRequest` foi tentada para todas as rotas previstas, mas o ambiente local continuou sem resolver `docmotor.online`; propagação permanece não confirmada.

## Implementado

- Landing page comercial responsiva com hero, serviços, parceria, público, processo, FAQ e contato.
- Logo oficial fornecida preservada; imagens automotivas locais geradas para o projeto.
- CTAs e formulário de parceria com mensagens específicas para WhatsApp.
- SEO técnico básico, URLs descritas no sitemap, robots e manifest PWA.
- Servidor Express preparado para servir o build no mesmo domínio.
- Documentação persistente inicial.
- Configuração centralizada de ambiente (`server/config.js`).
- Endpoint `/api/health` com resposta não sensível.
- Banner de homologação quando `APP_ENV=staging`.
- `X-Robots-Tag`, meta robots e robots.txt condicionais à indexação.
- Validação HTTP real do domínio `https://docmotor.online/` executada.
- Correção preparada para colisão de `robots.txt` estático e MIME do manifest.
- Headers básicos de segurança adicionados.
- Identidade visual oficial retangular e quadrada integrada.
- Componente reutilizável `BrandLogo` criado.
- Ícones técnicos PWA/favicons gerados a partir do ícone oficial.
- Versão da aplicação atualizada para `0.2.1`.
- Proprietário aprovou visualmente a página comercial publicada.
- API de autenticação com cadastro de cliente e parceiro, login, logout, alteração/reset de senha e sessão persistente.
- Perfis ADMINISTRATOR, PARTNER e CLIENT com autorização no servidor e painéis iniciais.
- Painel administrativo com indicadores reais, filtros e ações de aprovação, recusa e suspensão.
- Painel parceiro com dados da empresa e usuários vinculados; painel cliente com dados da própria conta.
- Matriz de autenticação e permissões em `docs/AUTENTICACAO-E-PERMISSOES.md`.
- Migration MySQL, rate limit persistido, auditoria e script seguro de provisionamento do administrador.

## Pendente

- Criar/usar uma conta fictícia de parceiro e validar cadastro, status pendente, aprovação, recusa, suspensão e reativação com o administrador.
- Validar cadastro de parceiro com CPF e CNPJ pela máscara dinâmica e confirmar a versão `0.3.2` online.
- Conferência visual manual do menu, cadastro e painéis em mobile e desktop.
- Configurar SMTP para validar recuperação de senha real.
- Conferência visual manual das novas telas.
- Domínio/canonical definitivo.
- Não iniciar a Fase 4 nem consumir créditos da Simples API.

## Problemas conhecidos/limitações

- A conferência autenticada do construtor no-code e a criação do segundo serviço demonstrativo continuam pendentes da missão anterior.
- Recuperação de senha exige SMTP configurado; sem SMTP, não é possível concluir o envio real.
- Links institucionais de política/termos são âncoras temporárias até conteúdo jurídico aprovado.
- O formulário comercial geral continua encaminhando atendimento para o WhatsApp; o cadastro de parceiro usa `/cadastro-parceiro` e persiste no MySQL.
- O navegador local não foi usado para homologação visual; essa conferência permanece manual.

## Testes realizados

- `vitest run`: 1 teste passou (link do WhatsApp usa o número comercial e codifica a mensagem).
- `eslint .`: passou.
- `tsc -b --pretty false`: passou.
- `vite build`: passou e gerou `dist`.
- Inicialização do Express em `NODE_ENV=production`, `APP_ENV=staging`, `ALLOW_INDEXING=false`, `APP_DEBUG=false`: passou, com log na porta de teste.
- Inspeção de assets: os arquivos da logo, hero, serviços e parceria existem em `public/assets` e foram incluídos em `dist/assets`.
- Navegador automatizado: não utilizado conforme orientação; conferência visual manual pendente.
- Homologação online inicial: HTTPS, HTML, health, runtime-config, fallback e assets aprovados.
- Homologação online inicial: robots.txt e MIME do manifest foram corrigidos e revalidados após o redeploy.
- Fase 1.4: validação visual aprovada pelo proprietário e validação técnica online concluída por HTTP.
- Revalidação online: versão `0.1.1`, health/runtime-config, robots, manifest, headers e todos os assets oficiais retornaram respostas esperadas.
- `npm run typecheck`: passou após a implementação da Fase 2.
- `npm test -- --run`: passou com os testes existentes e validações de CPF/CNPJ/contratos de autenticação.
- `npm run build`: passou e gerou o build de produção.
- `npm run lint`: passou após a atualização final do backend; validação MySQL online ainda não executada.
- Navegador automatizado: não utilizado conforme orientação; telas da Fase 2 aguardam conferência visual manual.
- Reauditoria local: lint, typecheck, 5 testes, build e diff-check aprovados após as correções do painel.
- Auditoria das mutações do builder revisada: operações administrativas do catálogo agora registram eventos em `audit_logs`.
- Builder ampliado com configuração geral, disponibilidade e transição de status da versão, sempre validada pelo backend.
- Verificações desta preparação: lint, typecheck, build, sintaxe Node, revisão estática do SQL (9 tabelas, zero comandos destrutivos) e 12 testes com worker único aprovados. A execução padrão do Vitest sofreu OOM do ambiente; o resultado com worker único foi concluído.
- Homologação HTTP online em 25/11/2026: `/api/health`, `/api/runtime-config`, `/robots.txt`, `/manifest.webmanifest`, fallback `/login`/`/cadastro-parceiro`/`/admin` e headers responderam conforme esperado; versão online `0.2.0`, staging e noindex confirmados.
- Após o push da `main` em `4f22ceb`, a validação externa continuou retornando `/api/health` e `/api/runtime-config` na versão `0.2.1`; `/api/admin/*` ainda respondeu o fallback HTML, evidenciando que o novo deploy não havia propagado. Assets públicos e headers permaneceram acessíveis.
- Após a propagação, validação HTTP da `0.3.0`: `/api/health` e `/api/runtime-config` retornaram versão `0.3.0`, `/api/services/catalog` retornou os serviços persistidos no MySQL, `/api/admin/services` retornou `401 AUTHENTICATION_REQUIRED`, manifest/robots/headers/fallback React responderam corretamente e os dois assets referenciados pelo HTML retornaram `200`.
- Interface do builder revisada antes da homologação autenticada: opções, cálculo, visibilidade condicional, cobranças condicionais, mapeamentos e ações agora podem ser cadastrados pela tela.
- Após o commit `5a9ca29`, a Hostinger propagou o bundle `index-BAMHVL_a.js`; a versão online permanece `0.3.0` e `/api/admin/services` continua protegido com `401` sem sessão.
- Roteiro persistente de homologação autenticada criado em `docs/HOMOLOGACAO-FASE-3.2.md`, incluindo os 12 cenários do motor e o aceite do segundo serviço no-code.
- Revalidação local após o roteiro: 35 testes aprovados com worker único, `npm run lint`, `npm run typecheck` e `npm run build` aprovados; nenhum arquivo versionado foi alterado pelo build.
- Revalidação HTTP externa em 25/11/2026: `/api/health` retornou `200` com `version=0.3.0`, runtime confirmou `staging`/`allowIndexing=false`, catálogo público retornou dados persistidos, `/api/admin/services` respondeu `401`, e `robots.txt`/manifest responderam `200` com headers de segurança.
- Auditoria da Fase 3.3 confirmou os links provisórios no `src/App.tsx`, a infraestrutura de autenticação/admin existente e a ausência de endpoint de acompanhamento próprio para parceiros pendentes.
- Publicação Fase 3.3: commit `b99ed33` integrado na `main`; em 25/11/2026 `/api/health` retornou `0.3.1`, o HTML referenciou `index-Bpu536if.js`, e `/api/partner/status` e `/api/admin/partners` retornaram `401 AUTHENTICATION_REQUIRED` sem sessão.
- Correção final de detalhes completos publicada no commit `1d1bdeb`; após a propagação, o HTML referenciou `index-qbH4Hyei.js`, health/runtime permaneceram em `0.3.1` e as rotas privadas continuaram retornando `401` sem sessão.
- Fase 3.4: causa de `DOCUMENT_TYPE_MISMATCH` identificada no seletor `PJ` fixo do frontend; adicionados tipo automático, normalização, máscaras CPF/CNPJ, remoção de nome de acesso, máscaras de telefone/CEP e tradução centralizada de erros. Verificação local: 48 testes, lint, typecheck e build aprovados.
- Propagação Fase 3.4 validada em 25/11/2026: `/api/health` e `/api/runtime-config` retornaram `0.3.2`/staging, o HTML referenciou `index-C4zVfBod.js`, manifest respondeu `200`, e `/api/partner/status`/`/api/admin/partners` permaneceram protegidos com `401` sem sessão. Após o teste adicional de CPF, a suíte local totaliza 49 testes.
- Correção da máscara de telefone publicada no commit `f205692`; após nova propagação, o health permaneceu em `0.3.2` e o bundle entregue passou a ser `index-BBl7mpMI.js`.
- Homologação HTTP online: `/api/admin/summary` sem sessão retornou `401`; após correção do hash bcrypt dummy, tentativa de login fictícia retorna `503 DATABASE_NOT_READY`. O backend está acessível e diagnostica explicitamente que a conexão/schema MySQL ainda não está pronto.
- Diagnóstico temporário de conexão MySQL executado na Hostinger: `DATABASE_CONNECTED`, `connected=1`, banco `u891593158_doc` e `DATABASE_CONNECTED_EMPTY_SCHEMA` com `table_count=0`.
- Políticas de senha por perfil: cliente com mínimo de 6 caracteres, parceiro/colaborador com mínimo de 8 e administrador com mínimo de 12 e complexidade.
- Alteração e redefinição de senha validam o perfil real no backend; login de usuários existentes não é afetado.
- SQL administrativo temporário é gerado localmente por `scripts/generate-admin-sql.ps1`, fora do repositório.
- Schema Fase 3 preparado sem preços reais: catálogo de serviços, categorias, UFs, disponibilidade, relações, tabelas de preço, componentes e regras técnicas preliminares em `DRAFT`.
- Pacote manual Fase 3 criado em `database/updates/002_services_pricing_rules_precheck.sql`, `database/updates/002_services_pricing_rules.sql` e `database/updates/002_services_pricing_rules_verify.sql`.
- Construtor administrativo genérico implementado com versões, seções, campos, opções, catálogo de cobranças, regras, documentos e simulador.
- Avaliador declarativo backend implementado sem execução arbitrária de código; fontes externas permanecem simuladas e a Simples API não foi integrada.
- Confirmação do proprietário: Migration 002 instalada no banco `u891593158_doc`, com 23 tabelas, 27 UFs, 6 categorias, 6 serviços, 6 itens de cobrança, 13 campos, 8 regras DRAFT, 1 versão, 2 documentos e 4 ações; zero relacionamentos inválidos.
- Migration 003 confirmada pelo proprietário: 12 tabelas esperadas, 7 colunas compatíveis, 27 UFs, 2 consultas, 8 mapeamentos, cálculo persistido, CSV sem valor e 11 regras técnicas.
- SQLs manuais agora são gerados com seleção explícita e referências qualificadas pelo `scripts/generate-hostinger-sql.mjs`.
- Pré-merge da Fase 3.5: lint, typecheck, 55 testes, build, sintaxe Node.js, validação SQL e `git diff --check` aprovados.
- Instalação real da Migration 004 confirmada pelo proprietário: precheck sem registro prévio, duas tabelas criadas, registro `004_partner_commissions.sql`, configuração `NONE` e zero overrides inválidos.

## Próxima missão

Confirmar a propagação da versão `0.3.3` no Hostinger e executar `docs/HOMOLOGACAO-APROVACAO-PARCEIRO.md` com dados fictícios. Não iniciar a Fase 4/Simples API real, orçamento definitivo, documentação digital ou financeiro.
