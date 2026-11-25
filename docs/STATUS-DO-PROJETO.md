# Status do projeto

## Fase atual

Fase 1 — Fundação e site comercial.

## Implementado

- Landing page comercial responsiva com hero, serviços, parceria, público, processo, FAQ e contato.
- Logo oficial fornecida preservada; imagens automotivas locais geradas para o projeto.
- CTAs e formulário de parceria com mensagens específicas para WhatsApp.
- SEO técnico básico, URLs descritas no sitemap, robots e manifest PWA.
- Servidor Express preparado para servir o build no mesmo domínio.
- Documentação persistente inicial.

## Pendente

- GitHub remoto, pois a autenticação local está inválida.
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
- Inspeção de assets: os arquivos da logo, hero, serviços e parceria existem em `public/assets` e foram incluídos em `dist/assets`.
- Navegador local: não concluído por limitação do ambiente de visualização; sem afirmação de QA visual completo.

## Próxima missão

Executar validação visual e de build da Fase 1; depois aguardar autorização para Fase 2.
