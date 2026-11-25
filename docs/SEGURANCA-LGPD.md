# Segurança e LGPD

Fase 1 não coleta nem armazena dados: o formulário apenas compõe uma mensagem e abre o WhatsApp. Não há autenticação, banco, uploads ou cookies próprios.

Na homologação, `ALLOW_INDEXING=false` produz `X-Robots-Tag: noindex, nofollow`, meta robots equivalente e `robots.txt` com `Disallow: /`. Isso reduz indexação, mas não é controle de acesso; proteção adicional deverá ser configurada na Hostinger se o ambiente precisar ser privado. `APP_DEBUG=false` impede que a aplicação use modo de diagnóstico detalhado.

Próximas fases devem definir base legal, minimização, retenção, controle de acesso, logs sem PII desnecessária, isolamento de tenant, proteção CSRF/XSS, validação de arquivos, tokens de upload com expiração/revogação e armazenamento privado fora de diretórios públicos.
