-- Doc Motor Fase 3.5: configuração genérica de comissionamento.
-- Importação manual pelo phpMyAdmin. Não contém DROP/TRUNCATE e não é executada no startup.

CREATE TABLE IF NOT EXISTS commission_settings (
  id CHAR(36) NOT NULL PRIMARY KEY,
  default_model VARCHAR(32) NOT NULL DEFAULT 'NONE',
  default_percentage DECIMAL(7,4) NULL,
  default_fixed_amount_cents BIGINT UNSIGNED NULL,
  honorarium_only TINYINT(1) NOT NULL DEFAULT 0,
  updated_by CHAR(36) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_commission_settings_updated_by FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS partner_commission_overrides (
  id CHAR(36) NOT NULL PRIMARY KEY,
  partner_company_id CHAR(36) NOT NULL,
  model VARCHAR(32) NOT NULL,
  percentage DECIMAL(7,4) NULL,
  fixed_amount_cents BIGINT UNSIGNED NULL,
  honorarium_only TINYINT(1) NOT NULL DEFAULT 0,
  notes VARCHAR(500) NULL,
  valid_from DATE NULL,
  valid_until DATE NULL,
  created_by CHAR(36) NULL,
  updated_by CHAR(36) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_partner_commission_override (partner_company_id),
  KEY idx_partner_commission_validity (valid_from, valid_until),
  CONSTRAINT fk_partner_commission_company FOREIGN KEY (partner_company_id) REFERENCES partner_companies(id) ON DELETE CASCADE,
  CONSTRAINT fk_partner_commission_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_partner_commission_updated_by FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO commission_settings (id, default_model, default_percentage, default_fixed_amount_cents, honorarium_only)
VALUES ('45000000-0000-4000-8000-000000000001', 'NONE', NULL, NULL, 0)
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO schema_migrations (name)
SELECT '004_partner_commissions.sql'
WHERE NOT EXISTS (SELECT 1 FROM schema_migrations WHERE name = '004_partner_commissions.sql')
  AND (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('commission_settings', 'partner_commission_overrides')) = 2;
