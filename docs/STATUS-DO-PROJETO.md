# Status do projeto

## Fase 3.13 — implementação local em branch, Migration 010 pendente — 26/11/2026

- Branch de trabalho: `feature/fase-3-13-suspensao-modificacoes`; versão local `0.4.9`. A `main` não foi alterada e não houve SQL remoto.
- Corrigida a causa do `SERVICE_NOT_FOUND` no construtor: serviço existente sem versão agora recebe uma única versão DRAFT inicializada dentro de transação, preservando o versionamento.
- Implementado o catálogo central declarativo de modificações, endpoints administrativos protegidos e menu `Catálogo de modificações`. Cadastro de motor continua bloqueado como modificação adicional.
- Preparada a Migration 010, os artefatos Hostinger e o serviço de regularização de suspensão com campos, cobranças, regras, checklist condicional e grupo repetível. Os valores comerciais ficam no banco, não no frontend.
- Validação estática da Migration 010 aprovada: 30 linhas `INSERT`, correspondência de colunas/valores e `JSON_OBJECT` verificados pelo validador do projeto. MariaDB descartável não está disponível; execução SQL real e importação manual ainda não foram realizadas.
- Verificações locais executadas: `npm run lint`, `npm run typecheck`, `npm run test` (141 testes após os novos testes), `npm run build`, `node --check server/services.js` e `git diff --check` aprovados. O build mantém apenas o aviso existente de bundle acima de 500 kB.
- Pendências: revisão funcional/visual, importação e verificação da Migration 010 pelo proprietário, testes online na Hostinger e publicação posterior na `main` somente com autorização explícita. Não iniciar a Fase 4.
- Complemento posterior: adicionado o `Simulador declarativo` administrativo, com seleção real do catálogo ativo, grupo repetível e submissão ao mesmo endpoint backend do construtor. A conferência visual e a execução contra o banco online continuam pendentes.

## Fase 3.12 — publicada na main, homologação online pendente — 26/11/2026

- Branch de implementação: `feature/fase-3-12-ajustes-finais-simulador`; versão `0.4.8`; publicação na `main` no commit `3373ee5845ca0a25a6091c4f4fa715ec50281cb7`.
- A causa persistida identificada foi a visibilidade de potência, cilindrada e combustível do doador limitada ao modo MANUAL. A Migration 009 corrige isso para PLATE/MANUAL em automóveis, caminhões e ônibus, mantendo a placa doadora apenas em PLATE.
- A declaração de motocicleta recebeu texto configurável com alerta, exemplos e orientação de compatibilidade; a identificação do motor continua não aplicável a motocicletas conforme a Migration 008 já instalada.
- Não foram executados SQL remoto pelo agente, migrations anteriores não foram reimportadas e nenhuma chamada à Simples API foi realizada.
- Testes locais específicos: 4 regressões da Fase 3.12 aprovadas. Lint, typecheck, build, sintaxe Node e `git diff --check` aprovados; a suíte completa deve ser executada novamente após a correção final.
- Tag de rollback: `rollback-before-0-4-8-20261126`, apontando para `03d263d738df59e5e683464344b4d3de7caf4528`.
- Health check HTTP em `https://docmotor.online/` e `/api/health` foi tentado em 26/11/2026, mas o ambiente local não resolveu o domínio (`curl: (6) Could not resolve host`). Homologação funcional online e conferência humana continuam pendentes. Não iniciar a Fase 4.
- Revisão visual local dos três PDFs de exemplo: renderização aprovada sem sobreposição, com cabeçalho/rodapé presentes e uma página por arquivo. A validação visual online ainda depende do proprietário.

### Evidência de banco e publicação autorizada

- Migration 009 foi importada manualmente e verificada pelo proprietário no banco `u891593158_doc`, MariaDB `11.8.9-MariaDB-log`.
- Precheck: `migration_009_already_registered = 0`, `required_fields_present = 5` e `migration_008_registered = 1`.
- Execução: cinco campos atualizados, uma linha inserida em `schema_migrations`, sem erro SQL.
- Verify: `migration_009_count = 1` e cinco campos retornados.
- Não executar novamente a Migration 009 ou migrations anteriores. A branch foi autorizada para integração na `main` na versão `0.4.8`; a homologação funcional online continua pendente dos testes reais do proprietário.

## Fase 3.11 — Migration 008 verificada e publicação autorizada — 26/11/2026

- Branch: `feature/fase-3-11-homologacao-simulador`; versão `0.4.7`; commit aprovado `5d7160569d3e38f556e992a83fb6d13275e294a8`; integração publicada no merge `365980a`.
- Causa raiz confirmada: `engine.identification_mode` estava com `is_required = 1` e sem condição de visibilidade persistida, enquanto o frontend o ocultava para `MOTORCYCLE`.
- Migration 008 foi importada manualmente e verificada pelo proprietário no banco `u891593158_doc`, MariaDB `11.8.9-MariaDB-log`: precheck registrou `migration_007_registered = 1` e `migration_008_already_registered = 0`; três `UPDATE`s executados sem erro; uma linha inserida em `schema_migrations`; verify registrou `migration_008_count = 1` e `motorcycle_mode_not_required = 1`. Não executar novamente.
- A correção permanece no-code: a visibilidade e a obrigatoriedade são expressas por condições persistidas; o backend continua descartando valores ocultos antes de validar, calcular, cobrar, gerar PDF ou montar WhatsApp.
- O logo oficial agora é incorporado no bundle Vite e embutido no PDF sem depender de fetch durante a geração.
- Validações locais: 17 arquivos/135 testes, lint, typecheck, build, sintaxe Node, validadores estáticos das migrations 007/008 e `git diff --check` aprovados. A homologação visual em navegador real continua pendente.
- O PWA possui manifest versionado em `0.4.7`, mas não há service worker registrado no projeto; portanto não existe cache de service worker a invalidar nesta publicação.
- Rollback registrado na tag `rollback-before-0-4-7-20261126`, apontando para `1b420c4`.
- Próxima missão: confirmar o deploy na Hostinger e homologar visual/funcionalmente. Não iniciar a Fase 4.

## Fase 3.10 — publicada em homologação — 26/11/2026

- Integrada na `main` no commit `aa20697`, versão `0.4.6`; branch de implementação: `feature/fase-3-10-fluxo-resultado-pdf`.
- Frontend e backend respeitam visibilidade declarativa, limpam valores ocultos e tratam motocicletas, identificação manual e dados desconhecidos sem inferências.
- Modal acessível de análise manual, WhatsApp configurável sem chaves internas e PDF com incorporação do logo oficial foram implementados.
- Não foi identificada necessidade de Migration 008: a alteração é de avaliação, apresentação e geração de documento; Migration 007 instalada não foi modificada.
- Validações locais: lint, typecheck, 16 arquivos/133 testes, build de produção, sintaxe Node e `git diff --check` executados; MariaDB remoto, Hostinger e conferência visual humana online ainda pendentes.
- Rollback registrado na tag `rollback-before-0-4-6-20261126`, apontando para `3448cba`.
- Deploy Hostinger e homologação funcional online ainda aguardam execução real; não declarar concluída antes dos testes do proprietário. Próxima missão: homologar os 30 cenários da Fase 3.10. Não iniciar a Fase 4.

## Hotfix 0.4.5 — correção da validação declarativa — 26/11/2026

- Causa raiz confirmada pela Hostinger: `field.calculation.operands` estava indefinido para o campo `motorcycle.compatibility_declaration`, que é `CHECKBOX` e possui apenas `{ default: false }` no metadado legado da Migration 007.
- O trecho `fields.filter((field) => field.calculation).map((field) => field.calculation.operands.map(...))` assumia operandos em qualquer campo com `calculation` e provocava `TypeError` na etapa `editor.validation_completed`.
- Correção: somente campos `CALCULATED` entram no grafo; campos calculados sem operandos retornam erro declarativo específico; coleções obrigatórias ausentes também retornam erro, sem lançar `TypeError`.
- Teste de regressão do fluxo `loadEditor`/`validateConfiguration`, além de testes de configuração válida, rascunho incompleto e coleção ausente.
- Validações locais: 14 arquivos e 127 testes, lint, typecheck, build, sintaxe Node e `git diff --check` aprovados.
- Nenhum SQL remoto executado, nenhuma migration alterada/importada e nenhuma chamada à Simples API.
- Implementação publicada no commit `1add237`; integração na `main` concluída no merge `fa6cd1a`; rollback: `rollback-before-0-4-5-20261126`.

## Hotfix 0.4.4 — diagnóstico do erro interno no editor — 26/11/2026

- Branch de trabalho: `fix/fase-3-9-editor-internal-error`.
- Evidência real da Hostinger: as 11 consultas do editor concluíram; a exceção ocorreu no pós-processamento, após `editor.billing_items`.
- Implementado diagnóstico privado por etapa, request ID, `error.name`, mensagem original, código, stack e tipo do valor, sem credenciais, tokens, PII ou conteúdo integral de registros.
- O pós-processamento foi separado em etapas de seções, campos, opções, ações, regras, cobranças, documentos, mensagens, consultas externas, validação, construção e serialização da resposta.
- O parser JSON agora aceita o formato retornado pelo driver como string, objeto ou `NULL`; JSON inválido permanece erro explícito e diagnosticável.
- Testes locais: 14 arquivos e 124 testes aprovados; MariaDB remoto não foi acessado e a homologação online ainda não foi repetida.
- Não houve SQL remoto, nova migration, alteração de schema ou consumo da Simples API.

## Hotfix 0.4.3 — regressão HTTP 503 no editor — 26/11/2026

- Branch de trabalho: `fix/fase-3-9-editor-http-503`.
- Causa estrutural confirmada: o endpoint do editor executava uma função assíncrona diretamente no Express 4; rejeições SQL ficavam sem tratamento e podiam encerrar/reiniciar o processo, produzindo a página HTML `server busy` da Hostinger.
- Correção aplicada: wrapper assíncrono no endpoint, resposta JSON pelo middleware de erro e logs privados com request ID, operação, duração e código SQL.
- Mitigação de compatibilidade: regras e ações são carregadas por consultas separadas; removida a agregação `JSON_ARRAYAGG` combinada com `GROUP BY r.id`.
- Teste MariaDB real: não executado neste ambiente. Os testes do editor usam pool mockado e estão identificados como tal.
- Hotfix publicado na `main` no commit `27c8b190938aa7f7b687a2c53282e28178aef3e2`; rollback: `rollback-before-0.4.3-20261126` apontando para `45f72cc`.
- Homologação Hostinger: pendente de o proprietário abrir o construtor, simular e gerar o PDF online.

## Publicação da Fase 3.9 — 26/11/2026

- Ajustes locais preparados para contato configurável de análise manual, seleção visual restrita a São Paulo/Outros estados e PDF comercial A4 com logotipo oficial.
- `npm run lint`, `npm run typecheck`, `npm test` (120 testes) e `npm run build` executados com sucesso.
- A validação SQL continua estática: não há MariaDB descartável disponível e nenhum SQL foi executado remotamente.
- Foram gerados e visualmente inspecionados `docs/exemplos/pdf/exemplo-orcamento-automovel.pdf`, `exemplo-orcamento-motocicleta.pdf` e `exemplo-orcamento-parceiro.pdf`, todos A4 de uma página; prévias PNG estão em `docs/exemplos/pdf/preview/`.
- Migration 007 foi instalada e verificada pelo proprietário na Hostinger; não haverá nova importação nem SQL remoto.
- Layout dos PDFs demonstrativos foi aprovado visualmente pelo proprietário.
- Publicação na `main` concluída no commit `fa90ef0539bce813a613151d90ab6fd0684fe02b`; rollback registrado na tag `rollback-before-fase-3-9-20261126`.
- Homologação funcional online permanece pendente; o domínio não resolveu nesta sessão, portanto nenhum teste HTTP é considerado aprovado.

## Atualização da missão 3.9 — 26/11/2026

- Migration 007 foi corrigida localmente e os artefatos `database/updates/007_engine_rules_and_documents_{precheck,sql,verify}.sql` foram regenerados para o banco `u891593158_doc`.
- O gerador foi validado para inserir `USE \`u891593158_doc\`;`, qualificar tabelas da aplicação e não transformar `information_schema` em tabela do banco da aplicação.
- As regras ficam em `DRAFT`; ITL/CSV não entra em itens, totais, pendências ou comissão; a cobrança de modificação é única e categoria-aware.
- Nenhuma operação foi executada no MySQL remoto. A instalação foi realizada e confirmada pelo proprietário via phpMyAdmin.
- Limitação: a suíte local usa o avaliador e fixtures equivalentes; não há instância MariaDB local disponível nesta validação.

## Correção da Migration 007 — estado parcial Hostinger

- O proprietário confirmou que `application_settings` recebeu as três colunas de contato antes da falha, enquanto os dois novos campos ainda não existiam e `007_engine_rules_and_documents.sql` não foi registrada.
- Causa confirmada do erro `#1136`: a segunda linha do `INSERT INTO service_form_fields` tinha 13 valores para 14 colunas; foi adicionada a descrição ausente.
- A Migration 007 foi revisada para reexecução segura nesse estado parcial, sem remover colunas nem repetir registros.
- Validação estática: 20 linhas de `INSERT` conferidas; UUIDs, qualificação Hostinger e `information_schema` aprovados.
- MariaDB local descartável não está instalado/disponível; não foi possível executar os três cenários SQL reais. Os testes JavaScript não são apresentados como validação SQL.

## Recuperação após erro MariaDB #1582

- Causa corrigida: a condição da cobrança `MODIFICATION_REQUEST` deixou de depender de uma construção profundamente aninhada de `JSON_OBJECT`/`JSON_ARRAY` e passou a usar JSON serializado válido no `UPDATE`.
- O validador permanente agora verifica balanceamento, quantidade par de argumentos de `JSON_OBJECT` e correspondência de colunas/valores dos `INSERT`s.
- A validação atual confirma 20 linhas de `INSERT` e todas as chamadas `JSON_OBJECT` da Migration 007; ainda não é validação de execução MariaDB.

## Fase atual

Fase 3.9 — regras declarativas, simulador comercial e PDF profissional — versão `0.4.2`; Migration 007 instalada e verificada pelo proprietário; homologação funcional online pendente.

## Fase 3.5 — estado da publicação

- Migration 004 instalada e validada pelo proprietário no banco `u891593158_doc`, MariaDB `11.8.9-MariaDB-log`.
- `commission_settings` e `partner_commission_overrides` existem; configuração inicial permanece `NONE`, sem valores comerciais ativos.
- Commit da `main` antes da integração, usado como rollback: `c98aa17f4bd1c82d13bd333876c30778d9a2c67e`.
- Branch integrada: `feature/fase-3-5-admin-comissoes`; versão no código: `0.3.3`.
- Propagação na Hostinger: pendente de confirmação HTTP; homologação autenticada da aprovação: pendente.
- Após a publicação da `main` em `44ca97339c1f4dd24caded242cb4631de92865e7`, a validação com `Invoke-WebRequest` foi tentada para todas as rotas previstas, mas o ambiente local continuou sem resolver `docmotor.online`; propagação permanece não confirmada.

## Implementado

- Resultado do simulador apresentado por componente reutilizável, com situação semântica, dados analisados, cobranças, subtotal conhecido, documentos e diagnóstico técnico recolhido.
- PDF A4 real em texto selecionável com `pdf-lib`, download, visualização, impressão e compartilhamento por Web Share/fallback responsável para WhatsApp.
- Regras declarativas agora respeitam `vehicle_category_code` carregado da categoria persistida; ações vazias de `LEFT JOIN` são ignoradas.
- Modo manual remove placa e padrão do motor do estado e o backend descarta valores incompatíveis.
- Teste de geração real de PDF com assinatura `%PDF-`.

- Normalização reutilizável de placas antigas/Mercosul, combustíveis (Álcool/Etanol equivalentes) e cilindradas em litros/cm³ no simulador.
- Frontend do construtor com seletor de combustível, máscara de placa e orientação de cilindrada; backend permanece como autoridade.
- Erros específicos para placa, combustível e cilindrada inválidos, sem chamada externa ou consumo de créditos.
- Fixture corrigido e teste do cenário informado pelo proprietário: Automóvel, 75 CV, 2000 cm³, combustível equivalente, placa antiga no destino e total conhecido de R$ 975,80.
- Causa raiz documentada em `docs/HOMOLOGACAO-FASE-3.7.md`: respostas sem normalização central e rota que ocultava erros de avaliação atrás de mensagem genérica.
- Corrigida a causa real do HTTP 422: campos derivados de padrão de placa agora são reconhecidos pelo validador sem virar entradas persistidas/editáveis; teste de integração reproduz a configuração equivalente às migrations 001–006.
- Cilindradas são convertidas visualmente para cm³ no blur; erros `INVALID_SERVICE_CONFIGURATION` exibem código e detalhes seguros também no resultado próximo ao simulador.
- Corrigido o mapa de aliases que rejeitava o próprio valor persistido `ALCOHOL`; quatro valores internos e suas representações equivalentes agora são aceitos nos dois veículos.
- Teste de integração do endpoint-equivalente cobre o cenário `AAA1234`/`EEE1234`, 75 CV, 1000 cm³, Álcool, total R$ 975,80 e `externalCalls=0`.

- Shell SaaS responsivo para painéis autenticados, com navegação por perfil, topbar, largura integral, títulos objetivos e alteração de senha em Minha conta.
- Correção do endpoint `/api/partner/dashboard` para retornar cidade, UF e CEP da empresa persistida.
- Comissão global com campos condicionais por modelo e entrada de valor fixo em reais, convertida para centavos no backend.
- Override individual agora suporta herança global, configuração customizada e desativação sem nova migration.
- Documento permanente do design system em `docs/DESIGN-SYSTEM.md`.
- Endpoint protegido `/api/admin/commissions/simulate` com o mesmo avaliador de comissão usado pela regra operacional, sem criar registros financeiros.
- O simulador aceita parceiro ativo opcional e resolve a configuração efetiva no servidor, sem confiar no modelo escolhido no frontend.
- Módulo protegido `/api/admin/settings` para dados comerciais persistidos, com fallback explícito `SETTINGS_MIGRATION_REQUIRED` antes da importação da Migration 005.
- Pacote manual da Migration 005: `database/updates/005_application_settings_precheck.sql`, `005_application_settings.sql` e `005_application_settings_verify.sql`; `database/install.sql` atualizado para bancos novos.
- Migration 005 confirmada pelo proprietário: banco `u891593158_doc`, MariaDB `11.8.9-MariaDB-log`, duas tabelas-base presentes, tabela `application_settings` criada, migration registrada, registro inicial `Doc Motor`/`America/Sao_Paulo` e zero erros SQL.
- Roteiro local do simulador NO-CODE criado em `docs/HOMOLOGACAO-FASE-3.6.md`; 13 cenários executados com o mesmo avaliador declarativo e aprovados.
- Endpoint do simulador protegido por `simulationRequestSchema`, sem propriedades arbitrárias, com falha de avaliação classificada e confirmação de `externalCalls=0`.

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

- Homologar visualmente a apresentação, impressão e PDF na Hostinger com dados fictícios.
- Validar compartilhamento de arquivo em Android/iOS e fallback no desktop.
- Integrar cabeçalho com código público do emissor, contato por perfil e numeração quando o módulo de orçamentos persistidos existir.

- Homologar visualmente e executar a versão `0.3.8` do simulador online com dados fictícios; essa etapa permanece sob responsabilidade do proprietário.

- Executar a conferência visual manual dos painéis em desktop e mobile na Hostinger.
- Homologar os cenários do simulador no-code com dados fictícios e registrar respostas reais.
- Homologar a comissão individual nos três estados: herdar, customizar e desativar.
- Validar manualmente no ambiente online o carregamento, edição, recarregamento e auditoria das configurações gerais.
- Executar no painel autenticado a criação do segundo serviço demonstrativo de suspensão rebaixada e registrar o resultado.

- Criar/usar uma conta fictícia de parceiro e validar cadastro, status pendente, aprovação, recusa, suspensão e reativação com o administrador.
- Validar cadastro de parceiro com CPF e CNPJ pela máscara dinâmica e confirmar a versão `0.3.2` online.
- Conferência visual manual do menu, cadastro e painéis em mobile e desktop.
- Configurar SMTP para validar recuperação de senha real.
- Conferência visual manual das novas telas.
- Domínio/canonical definitivo.
- Não iniciar a Fase 4 nem consumir créditos da Simples API.

## Problemas conhecidos/limitações

- A conferência autenticada do construtor no-code e a criação do segundo serviço demonstrativo continuam pendentes do proprietário; os testes locais do avaliador foram executados separadamente.
- Recuperação de senha exige SMTP configurado; sem SMTP, não é possível concluir o envio real.
- Links institucionais de política/termos são âncoras temporárias até conteúdo jurídico aprovado.
- O formulário comercial geral continua encaminhando atendimento para o WhatsApp; o cadastro de parceiro usa `/cadastro-parceiro` e persiste no MySQL.
- O navegador local não foi usado para homologação visual; essa conferência permanece manual.

## Testes realizados

- Fase 3.8 local: `npm test -- --run --pool=threads --minWorkers=1 --maxWorkers=1`: 13 arquivos e 120 testes aprovados, incluindo geração de PDF real.
- Fase 3.8 local: `npm run lint`, `npm run typecheck`, `node --check server/services.js`, `node --check server/service-config.js` e `git diff --check`: aprovados.
- Fase 3.8 local: `npm run build`: aprovado; bundle com aviso de tamanho acima de 500 kB, sem falha de compilação.
- Homologação visual e compartilhamento na Hostinger: pendentes de validação humana; não foram simulados.

- `npm run typecheck`: aprovado após os ajustes da Fase 3.6.
- `npm run lint`: aprovado após os ajustes da Fase 3.6.
- `npm test -- --run --pool=threads --minWorkers=1 --maxWorkers=1`: 72 testes aprovados.
- `git diff --check`: aprovado.
- `npm run generate:hostinger-sql`: aprovado; os SQLs 002–004 validados não são reescritos pelo gerador para evitar qualificação cumulativa.
- Navegador automatizado e conferência visual: não executados; permanecem pendentes de validação humana.
- Revalidação HTTP após os commits `78f9d76`, `54b726f` e `c7c446c`: não executada porque `docmotor.online` continuou sem resolução DNS neste ambiente (`curl: (6) Could not resolve host`).

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
- Fase 3.7: `npm test -- --run --pool=threads --minWorkers=1 --maxWorkers=1` aprovou 87 testes; lint, typecheck, build, sintaxe Node e diff-check também aprovados.
- Publicação da Fase 3.7.2: `main` em `5230e7c`, tag de rollback `rollback-before-fase-3-7-2-20261126`; homologação HTTP automatizada não foi concluída por falha de resolução DNS neste ambiente.
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

Homologar visualmente o resultado, PDF, impressão e compartilhamento da versão `0.3.9` na Hostinger com dados fictícios. Não iniciar a Fase 4.
