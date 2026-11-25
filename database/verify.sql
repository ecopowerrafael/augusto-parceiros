-- Verificação não destrutiva da instalação Doc Motor Fase 2.

SHOW TABLES;

SELECT TABLE_NAME, ENGINE, TABLE_COLLATION
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('schema_migrations', 'users', 'partner_companies', 'company_members', 'client_profiles', 'sessions', 'password_reset_tokens', 'rate_limit_events', 'audit_logs')
ORDER BY TABLE_NAME;

SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_KEY
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('users', 'partner_companies', 'company_members', 'client_profiles', 'sessions', 'password_reset_tokens', 'rate_limit_events', 'audit_logs')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

SELECT name, applied_at FROM schema_migrations ORDER BY name;

SELECT COUNT(*) AS administrators
FROM users
WHERE role = 'ADMINISTRATOR';

SELECT COUNT(*) AS total_users,
       SUM(role = 'ADMINISTRATOR') AS administrators,
       SUM(role = 'PARTNER') AS partner_users,
       SUM(role = 'CLIENT') AS client_users
FROM users;

SELECT COUNT(*) AS orphan_company_members
FROM company_members cm
LEFT JOIN partner_companies pc ON pc.id = cm.company_id
LEFT JOIN users u ON u.id = cm.user_id
WHERE pc.id IS NULL OR u.id IS NULL;

SELECT COUNT(*) AS orphan_client_profiles
FROM client_profiles cp
LEFT JOIN users u ON u.id = cp.user_id
WHERE u.id IS NULL;

SELECT COUNT(*) AS orphan_sessions
FROM sessions s
LEFT JOIN users u ON u.id = s.user_id
WHERE u.id IS NULL;

SELECT COUNT(*) AS orphan_reset_tokens
FROM password_reset_tokens prt
LEFT JOIN users u ON u.id = prt.user_id
WHERE u.id IS NULL;
