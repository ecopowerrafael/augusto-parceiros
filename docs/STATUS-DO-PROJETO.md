# Status do projeto

## Fase atual

Fase 2.0 — Autenticação, perfis e base operacional — implementação local concluída; aguardando configuração e validação MySQL/SMTP na Hostinger.

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
- Versão da aplicação atualizada para `0.1.1`.
- Proprietário aprovou visualmente a página comercial publicada.
- API de autenticação com cadastro de cliente e parceiro, login, logout, alteração/reset de senha e sessão persistente.
- Perfis ADMINISTRATOR, PARTNER e CLIENT com autorização no servidor e painéis iniciais.
- Painel administrativo com indicadores reais, filtros e ações de aprovação, recusa e suspensão.
- Painel parceiro com dados da empresa e usuários vinculados; painel cliente com dados da própria conta.
- Matriz de autenticação e permissões em `docs/AUTENTICACAO-E-PERMISSOES.md`.
- Migration MySQL, rate limit persistido, auditoria e script seguro de provisionamento do administrador.

## Pendente

- Configurar `DATABASE_URL`, SMTP e primeiro administrador na Hostinger.
- Executar migration no banco real e testes HTTP de cadastro/login/aprovação/reset usando contas fictícias.
- Publicar e validar o deploy 0.2.0 na Hostinger.
- Conferência visual manual das novas telas.
- Domínio/canonical definitivo.

## Problemas conhecidos/limitações

- O ambiente local não possui credenciais MySQL e, portanto, migrations e fluxos persistidos ainda não foram executados contra banco real.
- Recuperação de senha exige SMTP configurado; sem SMTP, não é possível concluir o envio real.
- Links institucionais de política/termos são âncoras temporárias até conteúdo jurídico aprovado.
- Formulário não persiste dados.

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

## Próxima missão

Configurar as variáveis seguras da Hostinger, executar `node scripts/migrate.mjs`, provisionar o primeiro administrador e realizar a homologação HTTP da Fase 2. Não iniciar Fase 3 nem Simples API, motor de regras, orçamentos ou financeiro.
