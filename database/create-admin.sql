-- Modelo manual para o primeiro administrador.
-- NÃO execute sem substituir os três placeholders abaixo.
-- Este arquivo não contém senha, e-mail ou hash reais.

SET @admin_name = NULL; -- substitua pelo nome do administrador
SET @admin_email = NULL; -- substitua pelo e-mail do administrador
SET @admin_password_hash = NULL; -- substitua pelo hash bcrypt gerado localmente

INSERT INTO `users` (
  `id`, `role`, `status`, `name`, `email`, `password_hash`,
  `terms_accepted_at`, `privacy_acknowledged_at`, `approved_at`
)
SELECT UUID(), 'ADMINISTRATOR', 'ACTIVE', @admin_name, LOWER(@admin_email), @admin_password_hash,
       UTC_TIMESTAMP(), UTC_TIMESTAMP(), UTC_TIMESTAMP()
WHERE NOT EXISTS (
  SELECT 1 FROM `users` WHERE `role` = 'ADMINISTRATOR'
);

-- Verificação imediata: deve retornar exatamente um administrador após a substituição.
SELECT COUNT(*) AS administrators FROM `users` WHERE `role` = 'ADMINISTRATOR';
