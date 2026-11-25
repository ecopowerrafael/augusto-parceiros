# Segurança e LGPD

Na Fase 2, dados cadastrais de usuários e parceiros são persistidos no MySQL com consentimento de termos/privacidade, controle por perfil e auditoria. Senhas usam bcrypt; sessões usam tokens aleatórios armazenados somente como hash; cookies são HttpOnly e Secure em produção; mutações autenticadas exigem CSRF.

O reset usa token de uso único com expiração e SMTP configurável. Sem SMTP, a API informa explicitamente que a recuperação está indisponível e não simula envio. Com SMTP, a resposta de solicitação é genérica para não revelar se um e-mail existe. Credenciais ficam somente nas variáveis da Hostinger.

Na homologação, `ALLOW_INDEXING=false` produz `X-Robots-Tag: noindex, nofollow`, meta robots equivalente e `robots.txt` com `Disallow: /`. Isso reduz indexação, mas não é controle de acesso; proteção adicional deverá ser configurada na Hostinger se o ambiente precisar ser privado. `APP_DEBUG=false` impede que a aplicação use modo de diagnóstico detalhado.

Fases futuras devem definir retenção, validação de arquivos, tokens de upload com expiração/revogação e armazenamento privado fora de diretórios públicos.
