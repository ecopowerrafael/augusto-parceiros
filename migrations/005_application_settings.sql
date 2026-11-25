-- Doc Motor Fase 3.6: configurações gerais persistidas.
-- Importação manual pelo phpMyAdmin. Não contém DROP/TRUNCATE e não é executada no startup.

CREATE TABLE IF NOT EXISTS application_settings (
  id CHAR(36) NOT NULL PRIMARY KEY,
  company_name VARCHAR(180) NOT NULL DEFAULT 'Doc Motor',
  support_whatsapp VARCHAR(30) NULL,
  support_email VARCHAR(255) NULL,
  city VARCHAR(120) NULL,
  state CHAR(2) NULL,
  privacy_url VARCHAR(500) NULL,
  terms_url VARCHAR(500) NULL,
  timezone VARCHAR(64) NOT NULL DEFAULT 'America/Sao_Paulo',
  updated_by CHAR(36) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_application_settings_updated_by FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO application_settings (id, company_name, timezone)
VALUES ('55000000-0000-4000-8000-000000000001', 'Doc Motor', 'America/Sao_Paulo')
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO schema_migrations (name)
SELECT '005_application_settings.sql'
WHERE NOT EXISTS (SELECT 1 FROM schema_migrations WHERE name = '005_application_settings.sql')
  AND (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'application_settings') = 1;
