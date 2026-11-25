# Status do projeto

## Fase atual

Fase 1.1 — Preparação do ambiente online de homologação.

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

## Pendente

- Deploy na Hostinger e testes funcionais online.
- Domínio/canonical definitivo.
- Teste visual real em navegador e screenshots: tentativa feita, mas o navegador embutido retornou uma tela offline e o sandbox bloqueou acesso ao socket local.
- Fase 2 em diante, sob autorização.

## Problemas conhecidos/limitações

- Área do parceiro é apenas aviso de desenvolvimento; não há login.
- Links institucionais de política/termos são âncoras temporárias até conteúdo jurídico aprovado.
- Formulário não persiste dados.

## Testes realizados

- `vitest run`: 1 teste passou (link do WhatsApp usa o número comercial e codifica a mensagem).
- `eslint .`: passou.
- `tsc -b --pretty false`: passou.
- `vite build`: passou e gerou `dist`.
- Inicialização do Express em `NODE_ENV=production`, `APP_ENV=staging`, `ALLOW_INDEXING=false`, `APP_DEBUG=false`: passou, com log na porta de teste.
- Inspeção de assets: os arquivos da logo, hero, serviços e parceria existem em `public/assets` e foram incluídos em `dist/assets`.
- Navegador local: não concluído por limitação do ambiente de visualização; sem afirmação de QA visual completo.
- Homologação online: ainda não executada nesta sessão; depende de acesso ao painel/domínio da Hostinger.

## Próxima missão

Publicar a Fase 1.1, realizar o deploy na Hostinger e executar o checklist online. Não iniciar a Fase 2.
