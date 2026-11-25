# Status do projeto

## Fase atual

Fase 1.4 — Identidade visual oficial e encerramento da homologação inicial.

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

## Pendente

- Novo deploy na Hostinger após o commit desta correção; a substituição da marca ainda aguarda o redeploy desta Fase 1.4.
- Conferência visual manual pelo proprietário.
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
- Navegador automatizado: não utilizado conforme orientação; conferência visual manual pendente.
- Homologação online inicial: HTTPS, HTML, health, runtime-config, fallback e assets aprovados.
- Homologação online inicial: robots.txt e MIME do manifest reprovados e corrigidos no código; o domínio continuou entregando a versão anterior após duas consultas, aguardando redeploy efetivo/cache da Hostinger.
- Fase 1.4: validação visual aprovada pelo proprietário; pendente apenas validar tecnicamente os novos assets após o redeploy.

## Próxima missão

Publicar a Fase 1.4, validar novos assets e headers por HTTP após o redeploy e aguardar autorização explícita antes da Fase 2.
