-- Instalação completa da estrutura Doc Motor
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`schema_migrations` (name VARCHAR(255) NOT NULL PRIMARY KEY, applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`users` (
  id CHAR(36) NOT NULL PRIMARY KEY,
  role VARCHAR(24) NOT NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'ACTIVE',
  name VARCHAR(180) NOT NULL,
  cpf VARCHAR(14) NULL,
  email VARCHAR(255) NOT NULL,
  whatsapp VARCHAR(30) NULL,
  password_hash VARCHAR(255) NOT NULL,
  terms_accepted_at DATETIME NULL,
  privacy_acknowledged_at DATETIME NULL,
  approved_at DATETIME NULL,
  approved_by CHAR(36) NULL,
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_users_email (email),
  UNIQUE KEY uq_users_cpf (cpf),
  KEY idx_users_role_status (role, status),
  CONSTRAINT fk_users_approved_by FOREIGN KEY (approved_by) REFERENCES `u891593158_doc`.`users`(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`partner_companies` (
  id CHAR(36) NOT NULL PRIMARY KEY,
  person_type VARCHAR(2) NOT NULL,
  legal_name VARCHAR(180) NOT NULL,
  trade_name VARCHAR(180) NULL,
  cpf_cnpj VARCHAR(18) NOT NULL,
  responsible_name VARCHAR(180) NOT NULL,
  email VARCHAR(255) NOT NULL,
  whatsapp VARCHAR(30) NOT NULL,
  zip_code VARCHAR(10) NULL,
  address VARCHAR(180) NULL,
  address_number VARCHAR(20) NULL,
  complement VARCHAR(120) NULL,
  neighborhood VARCHAR(120) NULL,
  city VARCHAR(120) NULL,
  state CHAR(2) NULL,
  segment VARCHAR(80) NOT NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'PENDING',
  rejection_reason VARCHAR(500) NULL,
  approved_at DATETIME NULL,
  approved_by CHAR(36) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_partner_cpf_cnpj (cpf_cnpj),
  KEY idx_partner_status_created (status, created_at),
  CONSTRAINT fk_partner_approved_by FOREIGN KEY (approved_by) REFERENCES `u891593158_doc`.`users`(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`company_members` (
  company_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  company_role VARCHAR(24) NOT NULL DEFAULT 'COLLABORATOR',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (company_id, user_id),
  KEY idx_members_user (user_id),
  CONSTRAINT fk_members_company FOREIGN KEY (company_id) REFERENCES `u891593158_doc`.`partner_companies`(id) ON DELETE CASCADE,
  CONSTRAINT fk_members_user FOREIGN KEY (user_id) REFERENCES `u891593158_doc`.`users`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`client_profiles` (
  user_id CHAR(36) NOT NULL PRIMARY KEY,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_client_user FOREIGN KEY (user_id) REFERENCES `u891593158_doc`.`users`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`sessions` (
  id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  token_hash CHAR(64) NOT NULL,
  csrf_token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  revoked_at DATETIME NULL,
  user_agent VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_sessions_token (token_hash),
  KEY idx_sessions_user_active (user_id, revoked_at, expires_at),
  CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES `u891593158_doc`.`users`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`password_reset_tokens` (
  id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_reset_token (token_hash),
  KEY idx_reset_user (user_id, expires_at),
  CONSTRAINT fk_reset_user FOREIGN KEY (user_id) REFERENCES `u891593158_doc`.`users`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`rate_limit_events` (
  bucket_key VARCHAR(180) NOT NULL,
  window_started_at DATETIME NOT NULL,
  attempts INT NOT NULL DEFAULT 0,
  PRIMARY KEY (bucket_key, window_started_at),
  KEY idx_rate_limit_window (window_started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`audit_logs` (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  actor_user_id CHAR(36) NULL,
  action VARCHAR(80) NOT NULL,
  entity_type VARCHAR(80) NOT NULL,
  entity_id CHAR(36) NULL,
  metadata JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_audit_actor_created (actor_user_id, created_at),
  KEY idx_audit_entity_created (entity_type, entity_id, created_at),
  CONSTRAINT fk_audit_actor FOREIGN KEY (actor_user_id) REFERENCES `u891593158_doc`.`users`(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Registra a migration somente se as oito tabelas da Fase 2 existirem.
INSERT INTO `u891593158_doc`.`schema_migrations` (name)
SELECT '001_initial.sql'
FROM information_schema.tables
WHERE table_schema = 'u891593158_doc'
  AND table_name IN ('users', 'partner_companies', 'company_members', 'client_profiles', 'sessions', 'password_reset_tokens', 'rate_limit_events', 'audit_logs')
GROUP BY table_schema
HAVING COUNT(*) = 8
   AND NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE name = '001_initial.sql');

-- Doc Motor Fase 3.1: catálogo no-code de serviços, formulários, cobranças e regras.
-- Manual pelo phpMyAdmin. Não contém DROP, não executa alterações no startup e não cria preços publicados.

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`brazilian_states` (
  `uf` CHAR(2) NOT NULL PRIMARY KEY,
  `name` VARCHAR(80) NOT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`vehicle_categories` (
  `id` CHAR(36) NOT NULL PRIMARY KEY,
  `code` VARCHAR(40) NOT NULL,
  `name` VARCHAR(80) NOT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_vehicle_categories_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`services` (
  `id` CHAR(36) NOT NULL PRIMARY KEY,
  `code` VARCHAR(60) NOT NULL,
  `name` VARCHAR(180) NOT NULL,
  `slug` VARCHAR(180) NOT NULL,
  `short_description` VARCHAR(500) NULL,
  `detailed_description` TEXT NULL,
  `category` VARCHAR(80) NOT NULL,
  `service_type` VARCHAR(24) NOT NULL DEFAULT 'MAIN',
  `availability_mode` VARCHAR(16) NOT NULL DEFAULT 'ALL',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `available_to_client` TINYINT(1) NOT NULL DEFAULT 1,
  `available_to_partner` TINYINT(1) NOT NULL DEFAULT 1,
  `display_order` INT NOT NULL DEFAULT 0,
  `general_guidance` TEXT NULL,
  `internal_notes` TEXT NULL,
  `created_by` CHAR(36) NULL,
  `updated_by` CHAR(36) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_services_code` (`code`),
  UNIQUE KEY `uq_services_slug` (`slug`),
  KEY `idx_services_active_order` (`is_active`, `display_order`),
  KEY `idx_services_type_category` (`service_type`, `category`),
  CONSTRAINT `fk_services_created_by` FOREIGN KEY (`created_by`) REFERENCES `u891593158_doc`.`users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_services_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `u891593158_doc`.`users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_vehicle_categories` (
  `service_id` CHAR(36) NOT NULL,
  `vehicle_category_id` CHAR(36) NOT NULL,
  PRIMARY KEY (`service_id`, `vehicle_category_id`),
  CONSTRAINT `fk_svc_service` FOREIGN KEY (`service_id`) REFERENCES `u891593158_doc`.`services` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_svc_vehicle_category` FOREIGN KEY (`vehicle_category_id`) REFERENCES `u891593158_doc`.`vehicle_categories` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_ufs` (
  `service_id` CHAR(36) NOT NULL,
  `uf` CHAR(2) NOT NULL,
  `is_available` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`service_id`, `uf`),
  CONSTRAINT `fk_service_ufs_service` FOREIGN KEY (`service_id`) REFERENCES `u891593158_doc`.`services` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_service_ufs_state` FOREIGN KEY (`uf`) REFERENCES `u891593158_doc`.`brazilian_states` (`uf`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_relations` (
  `service_id` CHAR(36) NOT NULL,
  `related_service_id` CHAR(36) NOT NULL,
  `relation_type` VARCHAR(24) NOT NULL,
  `condition_description` VARCHAR(500) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`service_id`, `related_service_id`),
  CONSTRAINT `fk_service_relations_service` FOREIGN KEY (`service_id`) REFERENCES `u891593158_doc`.`services` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_service_relations_related` FOREIGN KEY (`related_service_id`) REFERENCES `u891593158_doc`.`services` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_versions` (
  id CHAR(36) NOT NULL PRIMARY KEY,
  service_id CHAR(36) NOT NULL,
  version_number INT NOT NULL,
  status VARCHAR(16) NOT NULL DEFAULT 'DRAFT',
  source_version_id CHAR(36) NULL,
  change_summary VARCHAR(500) NULL,
  published_at DATETIME NULL,
  archived_at DATETIME NULL,
  created_by CHAR(36) NULL,
  updated_by CHAR(36) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_service_versions_number (service_id, version_number),
  KEY idx_service_versions_status (service_id, status),
  CONSTRAINT fk_service_versions_service FOREIGN KEY (service_id) REFERENCES `u891593158_doc`.`services` (id) ON DELETE CASCADE,
  CONSTRAINT fk_service_versions_source FOREIGN KEY (source_version_id) REFERENCES `u891593158_doc`.`service_versions` (id) ON DELETE SET NULL,
  CONSTRAINT fk_service_versions_created_by FOREIGN KEY (created_by) REFERENCES `u891593158_doc`.`users` (id) ON DELETE SET NULL,
  CONSTRAINT fk_service_versions_updated_by FOREIGN KEY (updated_by) REFERENCES `u891593158_doc`.`users` (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_form_sections` (
  id CHAR(36) NOT NULL PRIMARY KEY, service_version_id CHAR(36) NOT NULL, stable_key VARCHAR(80) NOT NULL,
  label VARCHAR(180) NOT NULL, description VARCHAR(500) NULL, display_order INT NOT NULL DEFAULT 0, visibility_condition JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_form_sections_key (service_version_id, stable_key),
  CONSTRAINT fk_form_sections_version FOREIGN KEY (service_version_id) REFERENCES `u891593158_doc`.`service_versions` (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_form_fields` (
  id CHAR(36) NOT NULL PRIMARY KEY, service_version_id CHAR(36) NOT NULL, section_id CHAR(36) NULL, field_key VARCHAR(100) NOT NULL,
  label VARCHAR(180) NOT NULL, description VARCHAR(500) NULL, placeholder VARCHAR(180) NULL, field_type VARCHAR(32) NOT NULL,
  default_value JSON NULL, unit VARCHAR(32) NULL, is_required TINYINT(1) NOT NULL DEFAULT 0, is_editable TINYINT(1) NOT NULL DEFAULT 1,
  min_value DECIMAL(18,6) NULL, max_value DECIMAL(18,6) NULL, display_order INT NOT NULL DEFAULT 0,
  visibility_condition JSON NULL, required_condition JSON NULL, editability_condition JSON NULL, data_origin VARCHAR(24) NOT NULL DEFAULT 'MANUAL',
  source_path VARCHAR(180) NULL, calculation JSON NULL, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_form_fields_key (service_version_id, field_key),
  KEY idx_form_fields_order (service_version_id, display_order),
  CONSTRAINT fk_form_fields_version FOREIGN KEY (service_version_id) REFERENCES `u891593158_doc`.`service_versions` (id) ON DELETE CASCADE,
  CONSTRAINT fk_form_fields_section FOREIGN KEY (section_id) REFERENCES `u891593158_doc`.`service_form_sections` (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_field_options` (
  id CHAR(36) NOT NULL PRIMARY KEY, field_id CHAR(36) NOT NULL, option_value VARCHAR(120) NOT NULL, option_label VARCHAR(180) NOT NULL,
  display_order INT NOT NULL DEFAULT 0, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_field_options_value (field_id, option_value),
  CONSTRAINT fk_field_options_field FOREIGN KEY (field_id) REFERENCES `u891593158_doc`.`service_form_fields` (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_data_sources` (
  id CHAR(36) NOT NULL PRIMARY KEY, code VARCHAR(60) NOT NULL, name VARCHAR(180) NOT NULL, provider_type VARCHAR(32) NOT NULL,
  status VARCHAR(16) NOT NULL DEFAULT 'SIMULATED', supported_fields JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_data_sources_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_external_queries` (
  id CHAR(36) NOT NULL PRIMARY KEY, service_version_id CHAR(36) NOT NULL, source_id CHAR(36) NOT NULL, query_key VARCHAR(80) NOT NULL,
  label VARCHAR(180) NOT NULL, context_key VARCHAR(80) NOT NULL, plate_field_key VARCHAR(100) NULL, is_required TINYINT(1) NOT NULL DEFAULT 0,
  is_enabled TINYINT(1) NOT NULL DEFAULT 1, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_external_queries_key (service_version_id, query_key),
  CONSTRAINT fk_external_queries_version FOREIGN KEY (service_version_id) REFERENCES `u891593158_doc`.`service_versions` (id) ON DELETE CASCADE,
  CONSTRAINT fk_external_queries_source FOREIGN KEY (source_id) REFERENCES `u891593158_doc`.`service_data_sources` (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_query_mappings` (
  id CHAR(36) NOT NULL PRIMARY KEY, query_id CHAR(36) NOT NULL, target_field_key VARCHAR(100) NOT NULL, normalized_path VARCHAR(180) NOT NULL,
  data_origin VARCHAR(24) NOT NULL DEFAULT 'EXTERNAL', created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_query_mappings_path (query_id, target_field_key, normalized_path),
  CONSTRAINT fk_query_mappings_query FOREIGN KEY (query_id) REFERENCES `u891593158_doc`.`service_external_queries` (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`price_tables` (
  `id` CHAR(36) NOT NULL PRIMARY KEY,
  `code` VARCHAR(60) NOT NULL,
  `name` VARCHAR(180) NOT NULL,
  `description` VARCHAR(500) NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'DRAFT',
  `valid_from` DATE NULL,
  `valid_until` DATE NULL,
  `created_by` CHAR(36) NULL,
  `updated_by` CHAR(36) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_price_tables_code` (`code`),
  KEY `idx_price_tables_status_validity` (`status`, `valid_from`, `valid_until`),
  CONSTRAINT `fk_price_tables_created_by` FOREIGN KEY (`created_by`) REFERENCES `u891593158_doc`.`users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_price_tables_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `u891593158_doc`.`users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`billing_items` (
  id CHAR(36) NOT NULL PRIMARY KEY,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(180) NOT NULL,
  description VARCHAR(500) NULL,
  financial_category VARCHAR(80) NOT NULL,
  default_amount_cents BIGINT UNSIGNED NULL,
  status VARCHAR(16) NOT NULL DEFAULT 'DRAFT',
  valid_from DATE NULL,
  valid_until DATE NULL,
  uf CHAR(2) NULL,
  vehicle_category_id CHAR(36) NULL,
  commercial_profile VARCHAR(16) NULL,
  partner_company_id CHAR(36) NULL,
  charge_nature VARCHAR(32) NOT NULL,
  amount_status VARCHAR(32) NOT NULL DEFAULT 'NOT_DEFINED',
  payment_mode VARCHAR(32) NOT NULL DEFAULT 'UNDEFINED',
  is_public_fee TINYINT(1) NOT NULL DEFAULT 0,
  created_by CHAR(36) NULL,
  updated_by CHAR(36) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_billing_items_code (code),
  CONSTRAINT fk_billing_items_state FOREIGN KEY (uf) REFERENCES `u891593158_doc`.`brazilian_states` (uf) ON DELETE RESTRICT,
  CONSTRAINT fk_billing_items_vehicle FOREIGN KEY (vehicle_category_id) REFERENCES `u891593158_doc`.`vehicle_categories` (id) ON DELETE RESTRICT,
  CONSTRAINT fk_billing_items_partner FOREIGN KEY (partner_company_id) REFERENCES `u891593158_doc`.`partner_companies` (id) ON DELETE RESTRICT,
  CONSTRAINT fk_billing_items_created_by FOREIGN KEY (created_by) REFERENCES `u891593158_doc`.`users` (id) ON DELETE SET NULL,
  CONSTRAINT fk_billing_items_updated_by FOREIGN KEY (updated_by) REFERENCES `u891593158_doc`.`users` (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_billing_items` (
  id CHAR(36) NOT NULL PRIMARY KEY,
  service_version_id CHAR(36) NOT NULL,
  billing_item_id CHAR(36) NOT NULL,
  billing_mode VARCHAR(24) NOT NULL DEFAULT 'REQUIRED',
  quantity DECIMAL(12,3) NOT NULL DEFAULT 1,
  amount_override_cents BIGINT UNSIGNED NULL,
  discount_allowed TINYINT(1) NOT NULL DEFAULT 0,
  editable_by_admin TINYINT(1) NOT NULL DEFAULT 1,
  visible_to_partner TINYINT(1) NOT NULL DEFAULT 1,
  visible_to_client TINYINT(1) NOT NULL DEFAULT 1,
  include_in_total TINYINT(1) NOT NULL DEFAULT 1,
  condition_expression JSON NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_service_billing_items (service_version_id, billing_item_id),
  CONSTRAINT fk_service_billing_items_version FOREIGN KEY (service_version_id) REFERENCES `u891593158_doc`.`service_versions` (id) ON DELETE CASCADE,
  CONSTRAINT fk_service_billing_items_item FOREIGN KEY (billing_item_id) REFERENCES `u891593158_doc`.`billing_items` (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_prices` (
  `id` CHAR(36) NOT NULL PRIMARY KEY,
  `price_table_id` CHAR(36) NOT NULL,
  `service_id` CHAR(36) NOT NULL,
  `commercial_profile` VARCHAR(16) NOT NULL,
  `partner_company_id` CHAR(36) NULL,
  `vehicle_category_id` CHAR(36) NULL,
  `uf` CHAR(2) NULL,
  `price_type` VARCHAR(24) NOT NULL DEFAULT 'UNDEFINED',
  `amount_cents` BIGINT UNSIGNED NULL,
  `valid_from` DATE NULL,
  `valid_until` DATE NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `notes` VARCHAR(500) NULL,
  `created_by` CHAR(36) NULL,
  `updated_by` CHAR(36) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_service_prices_lookup` (`service_id`, `commercial_profile`, `uf`, `vehicle_category_id`, `is_active`),
  KEY `idx_service_prices_partner` (`partner_company_id`, `is_active`),
  KEY `idx_service_prices_validity` (`valid_from`, `valid_until`),
  CONSTRAINT `fk_service_prices_table` FOREIGN KEY (`price_table_id`) REFERENCES `u891593158_doc`.`price_tables` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_service_prices_service` FOREIGN KEY (`service_id`) REFERENCES `u891593158_doc`.`services` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_service_prices_partner` FOREIGN KEY (`partner_company_id`) REFERENCES `u891593158_doc`.`partner_companies` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_service_prices_vehicle` FOREIGN KEY (`vehicle_category_id`) REFERENCES `u891593158_doc`.`vehicle_categories` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_service_prices_state` FOREIGN KEY (`uf`) REFERENCES `u891593158_doc`.`brazilian_states` (`uf`) ON DELETE RESTRICT,
  CONSTRAINT `fk_service_prices_created_by` FOREIGN KEY (`created_by`) REFERENCES `u891593158_doc`.`users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_service_prices_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `u891593158_doc`.`users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_price_components` (
  `id` CHAR(36) NOT NULL PRIMARY KEY,
  `service_price_id` CHAR(36) NOT NULL,
  `component_type` VARCHAR(40) NOT NULL,
  `charge_mode` VARCHAR(24) NOT NULL,
  `amount_cents` BIGINT UNSIGNED NULL,
  `notes` VARCHAR(500) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_price_components_price` (`service_price_id`),
  CONSTRAINT `fk_price_components_price` FOREIGN KEY (`service_price_id`) REFERENCES `u891593158_doc`.`service_prices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`technical_rules` (
  `id` CHAR(36) NOT NULL PRIMARY KEY,
  `service_id` CHAR(36) NOT NULL,
  `service_version_id` CHAR(36) NULL,
  `name` VARCHAR(180) NOT NULL,
  `description` TEXT NULL,
  `vehicle_category_id` CHAR(36) NULL,
  `uf` CHAR(2) NULL,
  `conditions` JSON NULL,
  `technical_limits` JSON NULL,
  `expected_result` VARCHAR(40) NOT NULL,
  `reference_text` VARCHAR(500) NULL,
  `last_verified_at` DATE NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'DRAFT',
  `priority` INT NOT NULL DEFAULT 100,
  `version` INT NOT NULL DEFAULT 1,
  `internal_notes` TEXT NULL,
  `created_by` CHAR(36) NULL,
  `updated_by` CHAR(36) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_rules_lookup` (`service_id`, `service_version_id`, `vehicle_category_id`, `uf`, `status`, `priority`),
  CONSTRAINT `fk_rules_service` FOREIGN KEY (`service_id`) REFERENCES `u891593158_doc`.`services` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_rules_version` FOREIGN KEY (`service_version_id`) REFERENCES `u891593158_doc`.`service_versions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_rules_vehicle` FOREIGN KEY (`vehicle_category_id`) REFERENCES `u891593158_doc`.`vehicle_categories` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_rules_state` FOREIGN KEY (`uf`) REFERENCES `u891593158_doc`.`brazilian_states` (`uf`) ON DELETE RESTRICT,
  CONSTRAINT `fk_rules_created_by` FOREIGN KEY (`created_by`) REFERENCES `u891593158_doc`.`users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_rules_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `u891593158_doc`.`users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`technical_rule_actions` (
  id CHAR(36) NOT NULL PRIMARY KEY,
  technical_rule_id CHAR(36) NOT NULL,
  action_type VARCHAR(40) NOT NULL,
  target_key VARCHAR(180) NULL,
  payload JSON NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_rule_actions_order (technical_rule_id, display_order),
  CONSTRAINT fk_rule_actions_rule FOREIGN KEY (technical_rule_id) REFERENCES `u891593158_doc`.`technical_rules` (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_documents` (
  id CHAR(36) NOT NULL PRIMARY KEY,
  service_version_id CHAR(36) NOT NULL,
  document_code VARCHAR(80) NOT NULL,
  name VARCHAR(180) NOT NULL,
  description VARCHAR(500) NULL,
  requirement_type VARCHAR(24) NOT NULL DEFAULT 'OPTIONAL',
  condition_expression JSON NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_service_documents_code (service_version_id, document_code),
  CONSTRAINT fk_service_documents_version FOREIGN KEY (service_version_id) REFERENCES `u891593158_doc`.`service_versions` (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`service_messages` (
  id CHAR(36) NOT NULL PRIMARY KEY,
  service_version_id CHAR(36) NOT NULL,
  message_key VARCHAR(80) NOT NULL,
  severity VARCHAR(16) NOT NULL DEFAULT 'INFO',
  content TEXT NOT NULL,
  condition_expression JSON NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_service_messages_key (service_version_id, message_key),
  CONSTRAINT fk_service_messages_version FOREIGN KEY (service_version_id) REFERENCES `u891593158_doc`.`service_versions` (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`technical_rule_services` (
  `technical_rule_id` CHAR(36) NOT NULL,
  `service_id` CHAR(36) NOT NULL,
  `relation_type` VARCHAR(24) NOT NULL DEFAULT 'CONDITIONAL',
  PRIMARY KEY (`technical_rule_id`, `service_id`),
  CONSTRAINT `fk_rule_services_rule` FOREIGN KEY (`technical_rule_id`) REFERENCES `u891593158_doc`.`technical_rules` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rule_services_service` FOREIGN KEY (`service_id`) REFERENCES `u891593158_doc`.`services` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `u891593158_doc`.`brazilian_states` (`uf`, `name`) VALUES
('AC', 'Acre'), ('AL', 'Alagoas'), ('AP', 'Amapá'), ('AM', 'Amazonas'), ('BA', 'Bahia'), ('CE', 'Ceará'), ('DF', 'Distrito Federal'), ('ES', 'Espírito Santo'), ('GO', 'Goiás'), ('MA', 'Maranhão'), ('MT', 'Mato Grosso'), ('MS', 'Mato Grosso do Sul'), ('MG', 'Minas Gerais'), ('PA', 'Pará'), ('PB', 'Paraíba'), ('PR', 'Paraná'), ('PE', 'Pernambuco'), ('PI', 'Piauí'), ('RJ', 'Rio de Janeiro'), ('RN', 'Rio Grande do Norte'), ('RS', 'Rio Grande do Sul'), ('RO', 'Rondônia'), ('RR', 'Roraima'), ('SC', 'Santa Catarina'), ('SP', 'São Paulo'), ('SE', 'Sergipe'), ('TO', 'Tocantins')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `u891593158_doc`.`vehicle_categories` (`id`, `code`, `name`) VALUES
('30000000-0000-4000-8000-000000000001', 'MOTORCYCLE', 'Motocicleta'),
('30000000-0000-4000-8000-000000000002', 'AUTOMOBILE', 'Automóvel'),
('30000000-0000-4000-8000-000000000003', 'PICKUP', 'Caminhonete'),
('30000000-0000-4000-8000-000000000004', 'TRUCK', 'Caminhão'),
('30000000-0000-4000-8000-000000000005', 'BUS', 'Ônibus'),
('30000000-0000-4000-8000-000000000006', 'OTHER', 'Outros')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `u891593158_doc`.`services` (`id`, `code`, `name`, `slug`, `short_description`, `category`, `service_type`, `display_order`) VALUES
('31000000-0000-4000-8000-000000000001', 'ENGINE_REGISTRATION', 'Cadastro de motor', 'cadastro-de-motor', 'Regularização documental de motor substituído.', 'Documentação veicular', 'MAIN', 10),
('31000000-0000-4000-8000-000000000002', 'LOWERED_SUSPENSION', 'Regularização de suspensão rebaixada', 'regularizacao-de-suspensao-rebaixada', 'Orientação para veículos com suspensão modificada.', 'Modificações veiculares', 'MAIN', 20),
('31000000-0000-4000-8000-000000000003', 'WHEELS_TIRES', 'Regularização de pneus e rodas', 'regularizacao-de-pneus-e-rodas', 'Análise documental de alterações em rodas e pneus.', 'Modificações veiculares', 'MAIN', 30),
('31000000-0000-4000-8000-000000000004', 'VEHICLE_MODIFICATIONS', 'Regularização de modificações veiculares', 'regularizacao-de-modificacoes-veiculares', 'Avaliação de alterações nas características originais.', 'Modificações veiculares', 'MAIN', 40),
('31000000-0000-4000-8000-000000000005', 'MODIFICATION_AUTHORIZATION', 'Solicitação de autorização para modificação', 'solicitacao-de-autorizacao-para-modificacao', 'Serviço complementar sujeito à análise.', 'Serviços complementares', 'COMPLEMENTARY', 50),
('31000000-0000-4000-8000-000000000006', 'ITL_CSV_INSPECTION', 'Inspeção veicular / CSV', 'inspecao-veicular-csv', 'Serviço complementar de inspeção, quando aplicável.', 'Serviços complementares', 'COMPLEMENTARY', 60)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `slug` = VALUES(`slug`), `updated_at` = CURRENT_TIMESTAMP;

INSERT INTO `u891593158_doc`.`service_relations` (`service_id`, `related_service_id`, `relation_type`, `condition_description`) VALUES
('31000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000005', 'CONDITIONAL', 'Sujeito à análise técnica e administrativa.'),
('31000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000006', 'CONDITIONAL', 'Sujeito à exigência aplicável ao caso.')
ON DUPLICATE KEY UPDATE `relation_type` = VALUES(`relation_type`), `condition_description` = VALUES(`condition_description`);

INSERT INTO `u891593158_doc`.`service_versions` (id, service_id, version_number, status, change_summary)
VALUES ('33000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000001', 1, 'DRAFT', 'Configuração inicial no-code para validação administrativa.')
ON DUPLICATE KEY UPDATE change_summary = VALUES(change_summary), updated_at = CURRENT_TIMESTAMP;

-- Políticas preliminares, inativas até validação normativa e configuração administrativa.
INSERT INTO `u891593158_doc`.`technical_rules` (id, service_id, service_version_id, name, description, vehicle_category_id, conditions, technical_limits, expected_result, status, priority, version) VALUES
('32000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Motocicleta com mesma cilindrada', 'Política operacional preliminar; não representa garantia legal.', '30000000-0000-4000-8000-000000000001', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.engine_cc', 'operator', 'EQUALS', 'valueField', 'vehicle_donor.engine_cc'))), JSON_OBJECT(), 'VIABLE', 'DRAFT', 10, 1),
('32000000-0000-4000-8000-000000000002', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Motocicleta com cilindrada diferente', 'Fora dos critérios automatizados preliminares.', '30000000-0000-4000-8000-000000000001', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.engine_cc', 'operator', 'NOT_EQUALS', 'valueField', 'vehicle_donor.engine_cc'))), JSON_OBJECT(), 'OUT_OF_CRITERIA', 'DRAFT', 20, 1),
('32000000-0000-4000-8000-000000000003', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com mesma potência e cilindrada', 'Sujeito às demais exigências documentais.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.power_cv', 'operator', 'EQUALS', 'valueField', 'vehicle_donor.power_cv'), JSON_OBJECT('field', 'vehicle_target.engine_cc', 'operator', 'EQUALS', 'valueField', 'vehicle_donor.engine_cc'))), JSON_OBJECT(), 'VIABLE', 'DRAFT', 10, 1),
('32000000-0000-4000-8000-000000000004', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com alteração de potência até 10%', 'Política preliminar com análise de modificação e exigências complementares.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'GREATER_THAN', 'value', 0), JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'LESS_OR_EQUAL', 'value', 10))), JSON_OBJECT('max_increase_percent', 10), 'VIABLE_WITH_REQUIREMENTS', 'DRAFT', 20, 1),
('32000000-0000-4000-8000-000000000005', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com aumento superior a 10%', 'Fora dos critérios automatizados preliminares.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'GREATER_THAN', 'value', 10))), JSON_OBJECT('max_increase_percent', 10), 'OUT_OF_CRITERIA', 'DRAFT', 30, 1),
('32000000-0000-4000-8000-000000000006', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com dados técnicos insuficientes', 'Encaminhar para análise manual.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('any', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.power_cv', 'operator', 'EMPTY'), JSON_OBJECT('field', 'vehicle_donor.power_cv', 'operator', 'EMPTY'))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 40, 1),
('32000000-0000-4000-8000-000000000007', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Caminhão com alteração técnica', 'Sem limite operacional fixo; CSV e demais exigências pendentes de validação.', '30000000-0000-4000-8000-000000000004', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'EQUALS', 'value', 'TRUCK'))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 10, 1),
('32000000-0000-4000-8000-000000000008', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Outras categorias', 'Análise manual até definição de regra específica.', '30000000-0000-4000-8000-000000000006', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'EQUALS', 'value', 'OTHER'))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 100, 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), updated_at = CURRENT_TIMESTAMP;

INSERT INTO `u891593158_doc`.`service_data_sources` (id, code, name, provider_type, status, supported_fields)
VALUES ('34000000-0000-4000-8000-000000000001', 'VEHICLE_PROVIDER_PENDING', 'Consulta veicular — provedor a definir', 'VEHICLE_API', 'SIMULATED', JSON_ARRAY('vehicle_target.category', 'vehicle_target.state', 'vehicle_target.power_cv', 'vehicle_target.engine_cc', 'vehicle_target.fuel', 'vehicle_donor.power_cv', 'vehicle_donor.engine_cc', 'vehicle_donor.fuel'))
ON DUPLICATE KEY UPDATE name = VALUES(name), status = VALUES(status), supported_fields = VALUES(supported_fields);

INSERT INTO `u891593158_doc`.`service_form_sections` (id, service_version_id, stable_key, label, description, display_order)
VALUES ('35000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'vehicle_target', 'Veículo que receberá o motor', 'Dados do veículo principal.', 10),
       ('35000000-0000-4000-8000-000000000002', '33000000-0000-4000-8000-000000000001', 'engine_origin', 'Motor de origem', 'Identificação e dados técnicos do motor.', 20)
ON DUPLICATE KEY UPDATE label = VALUES(label), description = VALUES(description), display_order = VALUES(display_order);

INSERT INTO `u891593158_doc`.`service_form_fields` (id, service_version_id, section_id, field_key, label, field_type, is_required, display_order, data_origin)
VALUES ('36000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000001', 'vehicle_target.plate', 'Placa do veículo que receberá o motor', 'VEHICLE_PLATE', 1, 10, 'MANUAL'),
       ('36000000-0000-4000-8000-000000000002', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000001', 'vehicle_target.category', 'Categoria veicular', 'SINGLE_SELECT', 1, 20, 'MANUAL'),
       ('36000000-0000-4000-8000-000000000003', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000001', 'vehicle_target.state', 'UF do veículo', 'SINGLE_SELECT', 1, 30, 'MANUAL'),
       ('36000000-0000-4000-8000-000000000004', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000001', 'vehicle_target.power_cv', 'Potência original (CV)', 'DECIMAL', 0, 40, 'MANUAL'),
       ('36000000-0000-4000-8000-000000000005', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000001', 'vehicle_target.engine_cc', 'Cilindrada original (cm³)', 'INTEGER', 0, 50, 'MANUAL'),
       ('36000000-0000-4000-8000-000000000006', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000001', 'vehicle_target.fuel', 'Combustível original', 'TEXT', 0, 60, 'MANUAL'),
       ('36000000-0000-4000-8000-000000000007', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000002', 'engine.has_invoice', 'O motor possui nota fiscal?', 'YES_NO', 1, 70, 'MANUAL'),
       ('36000000-0000-4000-8000-000000000008', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000002', 'engine.identification_mode', 'Como identificar o motor de origem?', 'SINGLE_SELECT', 1, 80, 'MANUAL'),
       ('36000000-0000-4000-8000-000000000009', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000002', 'vehicle_donor.plate', 'Placa do veículo de origem', 'VEHICLE_PLATE', 0, 90, 'MANUAL'),
       ('36000000-0000-4000-8000-000000000010', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000002', 'vehicle_donor.power_cv', 'Potência do motor (CV)', 'DECIMAL', 0, 100, 'MANUAL'),
       ('36000000-0000-4000-8000-000000000011', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000002', 'vehicle_donor.engine_cc', 'Cilindrada do motor (cm³)', 'INTEGER', 0, 110, 'MANUAL'),
       ('36000000-0000-4000-8000-000000000012', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000002', 'vehicle_donor.fuel', 'Combustível do motor', 'TEXT', 0, 120, 'MANUAL'),
       ('36000000-0000-4000-8000-000000000013', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000002', 'engine.power_variation_percent', 'Variação percentual de potência', 'CALCULATED', 0, 130, 'CALCULATED')
ON DUPLICATE KEY UPDATE label = VALUES(label), updated_at = CURRENT_TIMESTAMP;

INSERT INTO `u891593158_doc`.`service_field_options` (id, field_id, option_value, option_label, display_order)
VALUES ('37000000-0000-4000-8000-000000000001', '36000000-0000-4000-8000-000000000002', 'MOTORCYCLE', 'Motocicleta', 10),
       ('37000000-0000-4000-8000-000000000002', '36000000-0000-4000-8000-000000000002', 'AUTOMOBILE', 'Automóvel', 20),
       ('37000000-0000-4000-8000-000000000003', '36000000-0000-4000-8000-000000000002', 'TRUCK', 'Caminhão', 30),
       ('37000000-0000-4000-8000-000000000004', '36000000-0000-4000-8000-000000000002', 'OTHER', 'Outra categoria', 40),
       ('37000000-0000-4000-8000-000000000005', '36000000-0000-4000-8000-000000000008', 'PLATE', 'Consultar pela placa', 10),
       ('37000000-0000-4000-8000-000000000006', '36000000-0000-4000-8000-000000000008', 'MANUAL', 'Informar dados manualmente', 20)
ON DUPLICATE KEY UPDATE option_label = VALUES(option_label), display_order = VALUES(display_order);

INSERT INTO `u891593158_doc`.`billing_items` (id, code, name, description, financial_category, default_amount_cents, status, charge_nature, amount_status, payment_mode, is_public_fee)
VALUES ('39000000-0000-0000-8000-000000000001', 'TRANSFER_FEE', 'Taxa de transferência', 'Valor comercial informado pelo proprietário; confirmar vigência e natureza antes da publicação.', 'DOCUMENTATION', 29580, 'DRAFT', 'PUBLIC_FEE', 'INFORMED', 'CLIENT_DIRECT', 0),
       ('39000000-0000-0000-8000-000000000002', 'SERVICE_FEE', 'Honorário', 'Honorário comercial informado pelo proprietário.', 'HONORARY', 16000, 'DRAFT', 'HONORARY', 'INFORMED', 'DOC_MOTOR', 0),
       ('39000000-0000-0000-8000-000000000003', 'ENGINE_REGISTRATION', 'Cadastro de motor', 'Serviço próprio informado pelo proprietário.', 'ENGINE', 30000, 'DRAFT', 'OWN_SERVICE', 'INFORMED', 'DOC_MOTOR', 0),
       ('39000000-0000-0000-8000-000000000004', 'ENGINE_NO_INVOICE', 'Adicional sem nota fiscal', 'Aplicável somente quando configurado pela regra do serviço.', 'ENGINE', 30000, 'DRAFT', 'OWN_SERVICE', 'INFORMED', 'DOC_MOTOR', 0),
       ('39000000-0000-0000-8000-000000000005', 'MERCOSUR_PLATE_AUTHORIZATION', 'Autorização de emplacamento Mercosul', 'Aplicabilidade depende do padrão da placa principal e confirmação administrativa.', 'DOCUMENTATION', 22000, 'DRAFT', 'ADDITIONAL_EXPENSE', 'INFORMED', 'CLIENT_DIRECT', 0),
       ('39000000-0000-0000-8000-000000000006', 'MODIFICATION_REQUEST', 'Solicitação de modificação', 'Aplicabilidade depende da categoria e da regra técnica publicada.', 'TECHNICAL', 30000, 'DRAFT', 'OWN_SERVICE', 'INFORMED', 'DOC_MOTOR', 0)
ON DUPLICATE KEY UPDATE name = VALUES(name), default_amount_cents = VALUES(default_amount_cents), updated_at = CURRENT_TIMESTAMP;

INSERT INTO `u891593158_doc`.`service_billing_items` (id, service_version_id, billing_item_id, billing_mode, display_order, condition_expression)
VALUES ('38000000-0000-0000-8000-000000000001', '33000000-0000-4000-8000-000000000001', '39000000-0000-0000-8000-000000000001', 'REQUIRED', 10, NULL),
       ('38000000-0000-0000-8000-000000000002', '33000000-0000-4000-8000-000000000001', '39000000-0000-0000-8000-000000000002', 'REQUIRED', 20, NULL),
       ('38000000-0000-0000-8000-000000000003', '33000000-0000-4000-8000-000000000001', '39000000-0000-0000-8000-000000000003', 'REQUIRED', 30, NULL),
       ('38000000-0000-0000-8000-000000000004', '33000000-0000-4000-8000-000000000001', '39000000-0000-0000-8000-000000000004', 'CONDITIONAL', 40, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.has_invoice', 'operator', 'EQUALS', 'value', 'NO')))),
       ('38000000-0000-0000-8000-000000000005', '33000000-0000-4000-8000-000000000001', '39000000-0000-0000-8000-000000000005', 'CONDITIONAL', 50, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.plate_pattern', 'operator', 'EQUALS', 'value', 'OLD')))),
       ('38000000-0000-0000-8000-000000000006', '33000000-0000-4000-8000-000000000001', '39000000-0000-0000-8000-000000000006', 'CONDITIONAL', 60, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'GREATER_THAN', 'value', 0), JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'LESS_OR_EQUAL', 'value', 10))))
ON DUPLICATE KEY UPDATE billing_mode = VALUES(billing_mode), condition_expression = VALUES(condition_expression);

INSERT INTO `u891593158_doc`.`service_documents` (id, service_version_id, document_code, name, requirement_type, condition_expression, display_order)
VALUES ('3A000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'ENGINE_INVOICE', 'Nota fiscal do motor', 'CONDITIONAL', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.has_invoice', 'operator', 'EQUALS', 'value', 'YES'))), 10),
       ('3A000000-0000-4000-8000-000000000002', '33000000-0000-4000-8000-000000000001', 'VEHICLE_REGISTRATION', 'CRLV-e do veículo', 'REQUIRED', NULL, 20)
ON DUPLICATE KEY UPDATE name = VALUES(name), requirement_type = VALUES(requirement_type), condition_expression = VALUES(condition_expression);

INSERT INTO `u891593158_doc`.`technical_rule_actions` (id, technical_rule_id, action_type, target_key, payload, display_order)
VALUES ('3B000000-0000-4000-8000-000000000001', '32000000-0000-4000-8000-000000000004', 'ADD_BILLING_ITEM', 'MODIFICATION_REQUEST', JSON_OBJECT('billingMode', 'CONDITIONAL'), 10),
       ('3B000000-0000-4000-8000-000000000002', '32000000-0000-4000-8000-000000000004', 'ADD_BILLING_ITEM', 'ITL_CSV_INSPECTION', JSON_OBJECT('valueStatus', 'NOT_DEFINED'), 20),
       ('3B000000-0000-4000-8000-000000000003', '32000000-0000-4000-8000-000000000005', 'BLOCK_AUTOMATED_QUOTE', NULL, JSON_OBJECT('reason', 'Aumento superior a 10%'), 10),
       ('3B000000-0000-4000-8000-000000000004', '32000000-0000-4000-8000-000000000006', 'MANUAL_REVIEW', NULL, JSON_OBJECT('reason', 'Dados técnicos insuficientes'), 10)
ON DUPLICATE KEY UPDATE action_type = VALUES(action_type), payload = VALUES(payload), display_order = VALUES(display_order);

INSERT INTO `u891593158_doc`.`schema_migrations` (`name`)
SELECT '002_services_pricing_rules.sql'
FROM `information_schema`.`tables`
WHERE table_schema = 'u891593158_doc'
  AND `table_name` IN ('brazilian_states', 'vehicle_categories', 'services', 'service_vehicle_categories', 'service_ufs', 'service_relations', 'service_versions', 'service_form_sections', 'service_form_fields', 'service_field_options', 'service_data_sources', 'service_external_queries', 'service_query_mappings', 'price_tables', 'billing_items', 'service_prices', 'service_price_components', 'service_billing_items', 'technical_rules', 'technical_rule_actions', 'technical_rule_services', 'service_documents', 'service_messages')
GROUP BY `table_schema`
HAVING COUNT(*) = 23
   AND NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE `name` = '002_services_pricing_rules.sql');


-- Doc Motor Fase 3.1: completar a configuração no-code do serviço de cadastro de motor.
-- Migration incremental; não reexecutar 001/002 e não contém DROP/TRUNCATE.

UPDATE `u891593158_doc`.`service_form_fields`
SET calculation = JSON_OBJECT(
  'operation', 'PERCENT_VARIATION',
  'operands', JSON_ARRAY(
    JSON_OBJECT('field', 'vehicle_target.power_cv'),
    JSON_OBJECT('field', 'vehicle_donor.power_cv')
  ),
  'decimals', 2
), data_origin = 'CALCULATED', updated_at = UTC_TIMESTAMP()
WHERE id = '36000000-0000-4000-8000-000000000013';

UPDATE `u891593158_doc`.`service_form_fields`
SET visibility_condition = JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.identification_mode', 'operator', 'EQUALS', 'value', 'PLATE'))), updated_at = UTC_TIMESTAMP()
WHERE id = '36000000-0000-4000-8000-000000000009';

UPDATE `u891593158_doc`.`service_form_fields`
SET visibility_condition = JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.identification_mode', 'operator', 'EQUALS', 'value', 'MANUAL'))), updated_at = UTC_TIMESTAMP()
WHERE id IN ('36000000-0000-4000-8000-000000000010', '36000000-0000-4000-8000-000000000011', '36000000-0000-4000-8000-000000000012');

INSERT INTO `u891593158_doc`.`service_field_options` (id, field_id, option_value, option_label, display_order) VALUES
('3C000000-0000-4000-8000-000000000001', '36000000-0000-4000-8000-000000000003', 'AC', 'Acre', 10),
('3C000000-0000-4000-8000-000000000002', '36000000-0000-4000-8000-000000000003', 'AL', 'Alagoas', 20),
('3C000000-0000-4000-8000-000000000003', '36000000-0000-4000-8000-000000000003', 'AP', 'Amapá', 30),
('3C000000-0000-4000-8000-000000000004', '36000000-0000-4000-8000-000000000003', 'AM', 'Amazonas', 40),
('3C000000-0000-4000-8000-000000000005', '36000000-0000-4000-8000-000000000003', 'BA', 'Bahia', 50),
('3C000000-0000-4000-8000-000000000006', '36000000-0000-4000-8000-000000000003', 'CE', 'Ceará', 60),
('3C000000-0000-4000-8000-000000000007', '36000000-0000-4000-8000-000000000003', 'DF', 'Distrito Federal', 70),
('3C000000-0000-4000-8000-000000000008', '36000000-0000-4000-8000-000000000003', 'ES', 'Espírito Santo', 80),
('3C000000-0000-4000-8000-000000000009', '36000000-0000-4000-8000-000000000003', 'GO', 'Goiás', 90),
('3C000000-0000-4000-8000-000000000010', '36000000-0000-4000-8000-000000000003', 'MA', 'Maranhão', 100),
('3C000000-0000-4000-8000-000000000011', '36000000-0000-4000-8000-000000000003', 'MT', 'Mato Grosso', 110),
('3C000000-0000-4000-8000-000000000012', '36000000-0000-4000-8000-000000000003', 'MS', 'Mato Grosso do Sul', 120),
('3C000000-0000-4000-8000-000000000013', '36000000-0000-4000-8000-000000000003', 'MG', 'Minas Gerais', 130),
('3C000000-0000-4000-8000-000000000014', '36000000-0000-4000-8000-000000000003', 'PA', 'Pará', 140),
('3C000000-0000-4000-8000-000000000015', '36000000-0000-4000-8000-000000000003', 'PB', 'Paraíba', 150),
('3C000000-0000-4000-8000-000000000016', '36000000-0000-4000-8000-000000000003', 'PR', 'Paraná', 160),
('3C000000-0000-4000-8000-000000000017', '36000000-0000-4000-8000-000000000003', 'PE', 'Pernambuco', 170),
('3C000000-0000-4000-8000-000000000018', '36000000-0000-4000-8000-000000000003', 'PI', 'Piauí', 180),
('3C000000-0000-4000-8000-000000000019', '36000000-0000-4000-8000-000000000003', 'RJ', 'Rio de Janeiro', 190),
('3C000000-0000-4000-8000-000000000020', '36000000-0000-4000-8000-000000000003', 'RN', 'Rio Grande do Norte', 200),
('3C000000-0000-4000-8000-000000000021', '36000000-0000-4000-8000-000000000003', 'RS', 'Rio Grande do Sul', 210),
('3C000000-0000-4000-8000-000000000022', '36000000-0000-4000-8000-000000000003', 'RO', 'Rondônia', 220),
('3C000000-0000-4000-8000-000000000023', '36000000-0000-4000-8000-000000000003', 'RR', 'Roraima', 230),
('3C000000-0000-4000-8000-000000000024', '36000000-0000-4000-8000-000000000003', 'SC', 'Santa Catarina', 240),
('3C000000-0000-4000-8000-000000000025', '36000000-0000-4000-8000-000000000003', 'SP', 'São Paulo', 250),
('3C000000-0000-4000-8000-000000000026', '36000000-0000-4000-8000-000000000003', 'SE', 'Sergipe', 260),
('3C000000-0000-4000-8000-000000000027', '36000000-0000-4000-8000-000000000003', 'TO', 'Tocantins', 270)
ON DUPLICATE KEY UPDATE option_label = VALUES(option_label), display_order = VALUES(display_order);

INSERT INTO `u891593158_doc`.`billing_items` (id, code, name, description, financial_category, default_amount_cents, status, charge_nature, amount_status, payment_mode, is_public_fee)
VALUES ('3F000000-0000-4000-8000-000000000001', 'ITL_CSV_INSPECTION', 'Inspeção ITL / CSV', 'Valor não definido; exigir confirmação administrativa antes de qualquer publicação comercial.', 'TECHNICAL', NULL, 'DRAFT', 'THIRD_PARTY', 'NOT_DEFINED', 'UNDEFINED', 0)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), default_amount_cents = VALUES(default_amount_cents), status = VALUES(status), amount_status = VALUES(amount_status), updated_at = CURRENT_TIMESTAMP;

INSERT INTO `u891593158_doc`.`service_billing_items` (id, service_version_id, billing_item_id, billing_mode, display_order, condition_expression)
VALUES ('40000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', '3F000000-0000-4000-8000-000000000001', 'CONDITIONAL', 70, NULL)
ON DUPLICATE KEY UPDATE billing_mode = VALUES(billing_mode), display_order = VALUES(display_order);

INSERT INTO `u891593158_doc`.`service_external_queries` (id, service_version_id, source_id, query_key, label, context_key, plate_field_key, is_required, is_enabled) VALUES
('3D000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', '34000000-0000-4000-8000-000000000001', 'TARGET_VEHICLE', 'Consulta do veículo principal', 'vehicle_target', 'vehicle_target.plate', 1, 1),
('3D000000-0000-4000-8000-000000000002', '33000000-0000-4000-8000-000000000001', '34000000-0000-4000-8000-000000000001', 'DONOR_VEHICLE', 'Consulta do veículo doador', 'vehicle_donor', 'vehicle_donor.plate', 0, 1)
ON DUPLICATE KEY UPDATE label = VALUES(label), plate_field_key = VALUES(plate_field_key), is_required = VALUES(is_required), is_enabled = VALUES(is_enabled);

INSERT INTO `u891593158_doc`.`service_query_mappings` (id, query_id, target_field_key, normalized_path, data_origin) VALUES
('3E000000-0000-4000-8000-000000000001', '3D000000-0000-4000-8000-000000000001', 'vehicle_target.category', 'category', 'EXTERNAL'),
('3E000000-0000-4000-8000-000000000002', '3D000000-0000-4000-8000-000000000001', 'vehicle_target.state', 'state', 'EXTERNAL'),
('3E000000-0000-4000-8000-000000000003', '3D000000-0000-4000-8000-000000000001', 'vehicle_target.power_cv', 'power_cv', 'EXTERNAL'),
('3E000000-0000-4000-8000-000000000004', '3D000000-0000-4000-8000-000000000001', 'vehicle_target.engine_cc', 'engine_cc', 'EXTERNAL'),
('3E000000-0000-4000-8000-000000000005', '3D000000-0000-4000-8000-000000000001', 'vehicle_target.fuel', 'fuel', 'EXTERNAL'),
('3E000000-0000-4000-8000-000000000006', '3D000000-0000-4000-8000-000000000002', 'vehicle_donor.power_cv', 'power_cv', 'EXTERNAL'),
('3E000000-0000-4000-8000-000000000007', '3D000000-0000-4000-8000-000000000002', 'vehicle_donor.engine_cc', 'engine_cc', 'EXTERNAL'),
('3E000000-0000-4000-8000-000000000008', '3D000000-0000-4000-8000-000000000002', 'vehicle_donor.fuel', 'fuel', 'EXTERNAL')
ON DUPLICATE KEY UPDATE normalized_path = VALUES(normalized_path), data_origin = VALUES(data_origin);

INSERT INTO `u891593158_doc`.`technical_rules` (id, service_id, service_version_id, name, description, vehicle_category_id, conditions, technical_limits, expected_result, status, priority, version) VALUES
('41000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com redução de potência', 'Política preliminar com análise de modificação e inspeção; não representa garantia legal.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'LESS_THAN', 'value', 0))), JSON_OBJECT(), 'VIABLE_WITH_REQUIREMENTS', 'DRAFT', 21, 1),
('41000000-0000-4000-8000-000000000002', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com mesma potência e cilindrada diferente', 'Análise manual até definição da regra específica.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.power_cv', 'operator', 'EQUALS', 'valueField', 'vehicle_donor.power_cv'), JSON_OBJECT('field', 'vehicle_target.engine_cc', 'operator', 'NOT_EQUALS', 'valueField', 'vehicle_donor.engine_cc'))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 22, 1),
('41000000-0000-4000-8000-000000000003', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com alteração de combustível', 'Análise manual até definição da regra específica.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.fuel', 'operator', 'NOT_EQUALS', 'valueField', 'vehicle_donor.fuel'))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 23, 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), conditions = VALUES(conditions), expected_result = VALUES(expected_result), status = VALUES(status), priority = VALUES(priority), updated_at = CURRENT_TIMESTAMP;

INSERT INTO `u891593158_doc`.`technical_rule_actions` (id, technical_rule_id, action_type, target_key, payload, display_order) VALUES
('42000000-0000-4000-8000-000000000001', '41000000-0000-4000-8000-000000000001', 'ADD_BILLING_ITEM', 'MODIFICATION_REQUEST', JSON_OBJECT('billingMode', 'CONDITIONAL'), 10),
('42000000-0000-4000-8000-000000000002', '41000000-0000-4000-8000-000000000001', 'ADD_BILLING_ITEM', 'ITL_CSV_INSPECTION', JSON_OBJECT('valueStatus', 'NOT_DEFINED'), 20)
ON DUPLICATE KEY UPDATE action_type = VALUES(action_type), target_key = VALUES(target_key), payload = VALUES(payload), display_order = VALUES(display_order);

INSERT INTO `u891593158_doc`.`schema_migrations` (name)
SELECT '003_complete_engine_service_seed.sql'
WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE name = '003_complete_engine_service_seed.sql')
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_field_options` WHERE field_id = '36000000-0000-4000-8000-000000000003') = 27
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_external_queries` WHERE service_version_id = '33000000-0000-4000-8000-000000000001') = 2
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_query_mappings` WHERE query_id IN (SELECT id FROM `u891593158_doc`.`service_external_queries` WHERE service_version_id = '33000000-0000-4000-8000-000000000001')) = 8
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_form_fields` WHERE id = '36000000-0000-4000-8000-000000000013' AND calculation IS NOT NULL) = 1
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`billing_items` WHERE code = 'ITL_CSV_INSPECTION') = 1
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`technical_rules` WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND id IN ('32000000-0000-4000-8000-000000000001', '32000000-0000-4000-8000-000000000002', '32000000-0000-4000-8000-000000000003', '32000000-0000-4000-8000-000000000004', '32000000-0000-4000-8000-000000000005', '32000000-0000-4000-8000-000000000006', '32000000-0000-4000-8000-000000000007', '32000000-0000-4000-8000-000000000008', '41000000-0000-4000-8000-000000000001', '41000000-0000-4000-8000-000000000002', '41000000-0000-4000-8000-000000000003')) = 11;


-- Doc Motor Fase 3.5: configuração genérica de comissionamento.
-- Importação manual pelo phpMyAdmin. Não contém DROP/TRUNCATE e não é executada no startup.

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`commission_settings` (
  id CHAR(36) NOT NULL PRIMARY KEY,
  default_model VARCHAR(32) NOT NULL DEFAULT 'NONE',
  default_percentage DECIMAL(7,4) NULL,
  default_fixed_amount_cents BIGINT UNSIGNED NULL,
  honorarium_only TINYINT(1) NOT NULL DEFAULT 0,
  updated_by CHAR(36) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_commission_settings_updated_by FOREIGN KEY (updated_by) REFERENCES `u891593158_doc`.`users`(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`partner_commission_overrides` (
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
  CONSTRAINT fk_partner_commission_company FOREIGN KEY (partner_company_id) REFERENCES `u891593158_doc`.`partner_companies`(id) ON DELETE CASCADE,
  CONSTRAINT fk_partner_commission_created_by FOREIGN KEY (created_by) REFERENCES `u891593158_doc`.`users`(id) ON DELETE SET NULL,
  CONSTRAINT fk_partner_commission_updated_by FOREIGN KEY (updated_by) REFERENCES `u891593158_doc`.`users`(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `u891593158_doc`.`commission_settings` (id, default_model, default_percentage, default_fixed_amount_cents, honorarium_only)
VALUES ('45000000-0000-4000-8000-000000000001', 'NONE', NULL, NULL, 0)
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO `u891593158_doc`.`schema_migrations` (name)
SELECT '004_partner_commissions.sql'
WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE name = '004_partner_commissions.sql')
  AND (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name IN ('commission_settings', 'partner_commission_overrides')) = 2;


-- Doc Motor Fase 3.6: configurações gerais persistidas.
-- Importação manual pelo phpMyAdmin. Não contém DROP/TRUNCATE e não é executada no startup.

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`application_settings` (
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
  CONSTRAINT fk_application_settings_updated_by FOREIGN KEY (updated_by) REFERENCES `u891593158_doc`.`users`(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `u891593158_doc`.`application_settings` (id, company_name, timezone)
VALUES ('55000000-0000-4000-8000-000000000001', 'Doc Motor', 'America/Sao_Paulo')
ON DUPLICATE KEY UPDATE id = id;

INSERT INTO `u891593158_doc`.`schema_migrations` (name)
SELECT '005_application_settings.sql'
WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE name = '005_application_settings.sql')
  AND (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name = 'application_settings') = 1;


-- Fase 3.7: metadados persistidos para normalização do simulador.
-- Incremental e não destrutiva. Não executar antes do precheck da Hostinger.

UPDATE `u891593158_doc`.`service_form_fields`
SET field_type = 'SINGLE_SELECT', updated_at = UTC_TIMESTAMP()
WHERE field_key IN ('vehicle_target.fuel', 'vehicle_donor.fuel')
  AND field_type IN ('TEXT', 'SINGLE_SELECT', 'RADIO');

UPDATE `u891593158_doc`.`service_form_fields`
SET unit = 'cm³', updated_at = UTC_TIMESTAMP()
WHERE (field_key IN ('vehicle_target.engine_cc', 'vehicle_donor.engine_cc') OR field_key LIKE '%.cylinder_cc')
  AND (unit IS NULL OR unit = '');

INSERT INTO `u891593158_doc`.`service_field_options` (id, field_id, option_value, option_label, display_order)
SELECT UUID(), f.id, seed.option_value, seed.option_label, seed.display_order
FROM `u891593158_doc`.`service_form_fields` f
JOIN (
  SELECT 'ALCOHOL' AS option_value, 'Álcool' AS option_label, 10 AS display_order
  UNION ALL SELECT 'GASOLINE', 'Gasolina', 20
  UNION ALL SELECT 'DIESEL', 'Diesel', 30
  UNION ALL SELECT 'FLEX', 'Flex', 40
) seed
WHERE f.field_key IN ('vehicle_target.fuel', 'vehicle_donor.fuel')
  AND NOT EXISTS (
    SELECT 1 FROM `u891593158_doc`.`service_field_options` existing
    WHERE existing.field_id = f.id AND existing.option_value = seed.option_value
  );

INSERT INTO `u891593158_doc`.`schema_migrations` (name)
SELECT '006_simulator_input_normalization.sql'
WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE name = '006_simulator_input_normalization.sql')
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_form_fields` WHERE field_key IN ('vehicle_target.fuel', 'vehicle_donor.fuel', 'vehicle_target.engine_cc', 'vehicle_donor.engine_cc')) >= 4
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_field_options` o JOIN `u891593158_doc`.`service_form_fields` f ON f.id = o.field_id WHERE f.field_key IN ('vehicle_target.fuel', 'vehicle_donor.fuel') AND o.option_value IN ('ALCOHOL', 'GASOLINE', 'DIESEL', 'FLEX')) >= 8;


-- Doc Motor Fase 3.9: regras autorizadas, formulário condicional e documentos comerciais.
-- Migration incremental, não destrutiva. Executar manualmente após o precheck.

ALTER TABLE `u891593158_doc`.`application_settings`
  ADD COLUMN IF NOT EXISTS manual_whatsapp VARCHAR(30) NULL,
  ADD COLUMN IF NOT EXISTS manual_team_name VARCHAR(180) NULL,
  ADD COLUMN IF NOT EXISTS manual_message_template TEXT NULL;

INSERT INTO `u891593158_doc`.`service_field_options` (id, field_id, option_value, option_label, display_order)
VALUES ('37000000-0000-4000-8000-000000000007', '36000000-0000-4000-8000-000000000002', 'BUS', 'Ônibus', 35)
ON DUPLICATE KEY UPDATE option_label = VALUES(option_label), display_order = VALUES(display_order);

INSERT INTO `u891593158_doc`.`service_form_fields` (id, service_version_id, section_id, field_key, label, description, field_type, default_value, is_required, display_order, visibility_condition, required_condition, data_origin, calculation)
VALUES
('36000000-0000-4000-8000-000000000014', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000002', 'engine.cylinder_variation_percent', 'Variação percentual de cilindrada', 'Comparação calculada entre os dados técnicos informados.', 'CALCULATED', NULL, 0, 135, NULL, NULL, 'CALCULATED', JSON_OBJECT('operation', 'PERCENT_VARIATION', 'operands', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_donor.engine_cc'), JSON_OBJECT('field', 'vehicle_target.engine_cc')), 'decimals', 6)),
('36000000-0000-4000-8000-000000000015', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000002', 'motorcycle.compatibility_declaration', 'Declaro que o motor que será instalado possui a mesma cilindrada do motor original da motocicleta.', 'Declaração manual de compatibilidade para análise preliminar.', 'CHECKBOX', FALSE, 0, 140, JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'EQUALS', 'value', 'MOTORCYCLE'), JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'EQUALS', 'value', 'MOTORCYCLE'), 'MANUAL', JSON_OBJECT('default', FALSE))
ON DUPLICATE KEY UPDATE label = VALUES(label), description = VALUES(description), field_type = VALUES(field_type), default_value = VALUES(default_value), is_required = VALUES(is_required), display_order = VALUES(display_order), visibility_condition = VALUES(visibility_condition), required_condition = VALUES(required_condition), data_origin = VALUES(data_origin), calculation = VALUES(calculation), updated_at = UTC_TIMESTAMP();

UPDATE `u891593158_doc`.`service_form_fields`
SET visibility_condition = JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'NOT_EQUALS', 'value', 'MOTORCYCLE'), updated_at = UTC_TIMESTAMP()
WHERE id IN ('36000000-0000-4000-8000-000000000004', '36000000-0000-4000-8000-000000000005');

UPDATE `u891593158_doc`.`service_form_fields`
SET visibility_condition = JSON_OBJECT('all', JSON_ARRAY(
  JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'NOT_EQUALS', 'value', 'MOTORCYCLE'),
  JSON_OBJECT('field', 'engine.identification_mode', 'operator', 'EQUALS', 'value', 'MANUAL')
)), updated_at = UTC_TIMESTAMP()
WHERE id IN ('36000000-0000-4000-8000-000000000010', '36000000-0000-4000-8000-000000000011');

UPDATE `u891593158_doc`.`service_billing_items` sbi JOIN `u891593158_doc`.`billing_items` bi ON bi.id = sbi.billing_item_id
SET sbi.billing_mode = 'CONDITIONAL', sbi.condition_expression = '{"any":[{"all":[{"field":"vehicle_target.category","operator":"IN_LIST","values":["AUTOMOBILE","TRUCK","BUS"]},{"any":[{"field":"engine.power_variation_percent","operator":"NOT_EQUALS","value":0},{"field":"engine.cylinder_variation_percent","operator":"NOT_EQUALS","value":0},{"field":"vehicle_target.fuel","operator":"NOT_EQUALS","valueField":"vehicle_donor.fuel"}]}]},{"all":[{"field":"vehicle_target.category","operator":"EQUALS","value":"MOTORCYCLE"},{"field":"vehicle_target.fuel","operator":"NOT_EQUALS","valueField":"vehicle_donor.fuel"}]}]}'
WHERE sbi.service_version_id = '33000000-0000-4000-8000-000000000001' AND bi.code = 'MODIFICATION_REQUEST';

UPDATE `u891593158_doc`.`service_billing_items` sbi JOIN `u891593158_doc`.`billing_items` bi ON bi.id = sbi.billing_item_id
SET sbi.billing_mode = 'OPTIONAL', sbi.include_in_total = 0, sbi.visible_to_client = 0, sbi.visible_to_partner = 0, sbi.condition_expression = NULL
WHERE sbi.service_version_id = '33000000-0000-4000-8000-000000000001' AND bi.code = 'ITL_CSV_INSPECTION';

UPDATE `u891593158_doc`.`technical_rule_actions` a
JOIN `u891593158_doc`.`technical_rules` r ON r.id = a.technical_rule_id
SET a.action_type = 'SHOW_GUIDANCE', a.target_key = NULL, a.payload = JSON_OBJECT('message', 'Eventuais despesas externas de vistoria ou inspeção não estão incluídas no orçamento.')
WHERE a.target_key = 'ITL_CSV_INSPECTION'
  AND r.service_id = '31000000-0000-4000-8000-000000000001'
  AND r.service_version_id = '33000000-0000-4000-8000-000000000001';

UPDATE `u891593158_doc`.`technical_rules`
SET status = 'ARCHIVED', updated_at = UTC_TIMESTAMP()
WHERE id IN ('32000000-0000-4000-8000-000000000001', '32000000-0000-4000-8000-000000000002', '41000000-0000-4000-8000-000000000002', '41000000-0000-4000-8000-000000000003');

INSERT INTO `u891593158_doc`.`technical_rules` (id, service_id, service_version_id, name, description, vehicle_category_id, conditions, technical_limits, expected_result, status, priority, version)
VALUES
('43000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Veículo fora de São Paulo', 'O veículo está registrado fora do estado de São Paulo. Será necessária uma análise individual para verificar a disponibilidade do serviço e os procedimentos aplicáveis.', NULL, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.state', 'operator', 'NOT_EQUALS', 'value', 'SP'))), '{}', 'MANUAL_REVIEW', 'DRAFT', 1, 1),
('43000000-0000-4000-8000-000000000009', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Dados técnicos insuficientes', 'Potência, cilindrada e combustível dos veículos não foram informados em quantidade suficiente para uma análise automática.', NULL, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'IN_LIST', 'values', JSON_ARRAY('AUTOMOBILE', 'TRUCK', 'BUS')), JSON_OBJECT('any', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.power_cv', 'operator', 'EMPTY'), JSON_OBJECT('field', 'vehicle_target.engine_cc', 'operator', 'EMPTY'), JSON_OBJECT('field', 'vehicle_target.fuel', 'operator', 'EMPTY'), JSON_OBJECT('field', 'vehicle_donor.power_cv', 'operator', 'EMPTY'), JSON_OBJECT('field', 'vehicle_donor.engine_cc', 'operator', 'EMPTY'), JSON_OBJECT('field', 'vehicle_donor.fuel', 'operator', 'EMPTY'))))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 3, 1),
('43000000-0000-4000-8000-000000000002', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Motocicleta sem declaração de compatibilidade', 'A compatibilidade da cilindrada da motocicleta não foi confirmada.', '30000000-0000-4000-8000-000000000001', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'motorcycle.compatibility_declaration', 'operator', 'FALSE'))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 2, 1),
('43000000-0000-4000-8000-000000000003', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Motocicleta com compatibilidade declarada', 'Compatibilidade declarada para orçamento preliminar, sujeita à conferência documental.', '30000000-0000-4000-8000-000000000001', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'motorcycle.compatibility_declaration', 'operator', 'TRUE'))), JSON_OBJECT(), 'VIABLE', 'DRAFT', 10, 1),
('43000000-0000-4000-8000-000000000004', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel sem alteração fora dos limites', 'Mesma potência e cilindrada, com combustível compatível.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'EQUALS', 'value', 0), JSON_OBJECT('field', 'engine.cylinder_variation_percent', 'operator', 'EQUALS', 'value', 0), JSON_OBJECT('field', 'vehicle_target.fuel', 'operator', 'EQUALS', 'valueField', 'vehicle_donor.fuel'))), JSON_OBJECT(), 'VIABLE', 'DRAFT', 10, 1),
('43000000-0000-4000-8000-000000000008', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com alteração dentro do limite', 'Qualquer alteração de potência, cilindrada ou combustível, desde que os aumentos de potência e cilindrada não ultrapassem 10%, exige solicitação de modificação.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('any', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'NOT_EQUALS', 'value', 0), JSON_OBJECT('field', 'engine.cylinder_variation_percent', 'operator', 'NOT_EQUALS', 'value', 0), JSON_OBJECT('field', 'vehicle_target.fuel', 'operator', 'NOT_EQUALS', 'valueField', 'vehicle_donor.fuel'))), JSON_OBJECT('any', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'EMPTY'), JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'LESS_OR_EQUAL', 'value', 10))), JSON_OBJECT('any', JSON_ARRAY(JSON_OBJECT('field', 'engine.cylinder_variation_percent', 'operator', 'EMPTY'), JSON_OBJECT('field', 'engine.cylinder_variation_percent', 'operator', 'LESS_OR_EQUAL', 'value', 10))))), JSON_OBJECT('max_increase_percent', 10), 'VIABLE_WITH_REQUIREMENTS', 'DRAFT', 20, 1),
('43000000-0000-4000-8000-000000000005', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Cilindrada acima de 10%', 'Aumento de cilindrada superior a 10% está fora dos critérios automáticos.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.cylinder_variation_percent', 'operator', 'GREATER_THAN', 'value', 10))), JSON_OBJECT('max_increase_percent', 10), 'OUT_OF_CRITERIA', 'DRAFT', 25, 1),
('43000000-0000-4000-8000-000000000011', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Potência acima de 10%', 'Aumento de potência superior a 10% está fora dos critérios automáticos.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'GREATER_THAN', 'value', 10))), JSON_OBJECT('max_increase_percent', 10), 'OUT_OF_CRITERIA', 'DRAFT', 25, 1),
('43000000-0000-4000-8000-000000000006', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Caminhões e ônibus com alteração técnica', 'Caminhões e ônibus não possuem limite percentual automático nesta política; qualquer alteração de potência, cilindrada ou combustível exige modificação.', NULL, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'IN_LIST', 'values', JSON_ARRAY('TRUCK', 'BUS')), JSON_OBJECT('any', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'NOT_EQUALS', 'value', 0), JSON_OBJECT('field', 'engine.cylinder_variation_percent', 'operator', 'NOT_EQUALS', 'value', 0), JSON_OBJECT('field', 'vehicle_target.fuel', 'operator', 'NOT_EQUALS', 'valueField', 'vehicle_donor.fuel'))))), JSON_OBJECT(), 'VIABLE_WITH_REQUIREMENTS', 'DRAFT', 20, 1),
('43000000-0000-4000-8000-000000000010', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Caminhões e ônibus sem alteração', 'Mesma potência, cilindrada e combustível.', NULL, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'IN_LIST', 'values', JSON_ARRAY('TRUCK', 'BUS')), JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'EQUALS', 'value', 0), JSON_OBJECT('field', 'engine.cylinder_variation_percent', 'operator', 'EQUALS', 'value', 0), JSON_OBJECT('field', 'vehicle_target.fuel', 'operator', 'EQUALS', 'valueField', 'vehicle_donor.fuel'))), JSON_OBJECT(), 'VIABLE', 'DRAFT', 10, 1),
('43000000-0000-4000-8000-000000000007', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Categoria sem regra específica', 'A categoria informada ainda precisa de análise manual.', NULL, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'NOT_IN_LIST', 'values', JSON_ARRAY('AUTOMOBILE', 'MOTORCYCLE', 'TRUCK', 'BUS')))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 90, 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), conditions = VALUES(conditions), vehicle_category_id = VALUES(vehicle_category_id), expected_result = VALUES(expected_result), status = VALUES(status), priority = VALUES(priority), updated_at = UTC_TIMESTAMP();

INSERT INTO `u891593158_doc`.`service_documents` (id, service_version_id, document_code, name, description, requirement_type, condition_expression, display_order)
VALUES
('3A000000-0000-4000-8000-000000000003', '33000000-0000-4000-8000-000000000001', 'OWNER_IDENTIFICATION', 'Documento de identificação do proprietário', 'Se o recibo de transferência estiver preenchido, será considerado o comprador identificado no documento.', 'REQUIRED', NULL, 20),
('3A000000-0000-4000-8000-000000000004', '33000000-0000-4000-8000-000000000001', 'INSPECTION_REPORT', 'Laudo de vistoria', 'Se já realizada, a equipe poderá analisar o laudo, inclusive se estiver vencido; se não, será solicitado posteriormente.', 'REQUIRED', NULL, 30)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), requirement_type = VALUES(requirement_type), condition_expression = VALUES(condition_expression), display_order = VALUES(display_order), updated_at = UTC_TIMESTAMP();

UPDATE `u891593158_doc`.`service_documents` SET name = 'CRLV (Documento do veículo)', description = 'Documento do veículo.', requirement_type = 'REQUIRED', condition_expression = NULL, display_order = 10 WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND document_code = 'VEHICLE_REGISTRATION';
UPDATE `u891593158_doc`.`service_documents` SET name = 'Nota fiscal do motor', description = 'Nota fiscal do motor, caso possua.', requirement_type = 'CONDITIONAL', condition_expression = JSON_OBJECT('field', 'engine.has_invoice', 'operator', 'EQUALS', 'value', 'YES'), display_order = 40 WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND document_code = 'ENGINE_INVOICE';

INSERT INTO `u891593158_doc`.`service_messages` (id, service_version_id, message_key, severity, content, condition_expression, display_order)
VALUES
('44000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'MANUAL_REVIEW_TITLE', 'WARNING', 'Seu cadastro não é viável pela análise automática.', NULL, 10),
('44000000-0000-4000-8000-000000000002', '33000000-0000-4000-8000-000000000001', 'MANUAL_REVIEW_GUIDANCE', 'INFO', 'Mas ainda é possível solicitar uma análise manual com um de nossos consultores.', NULL, 20),
('44000000-0000-4000-8000-000000000003', '33000000-0000-4000-8000-000000000001', 'DOCUMENTS_NOTE', 'INFO', 'Em casos de modificação veicular, nossa equipe poderá solicitar documentos adicionais.', NULL, 30),
('44000000-0000-4000-8000-000000000004', '33000000-0000-4000-8000-000000000001', 'EXTERNAL_EXPENSES', 'INFO', 'Eventuais despesas externas de vistoria ou inspeção não estão incluídas no orçamento e serão pagas diretamente às empresas responsáveis.', NULL, 40)
ON DUPLICATE KEY UPDATE severity = VALUES(severity), content = VALUES(content), condition_expression = VALUES(condition_expression), display_order = VALUES(display_order), updated_at = UTC_TIMESTAMP();

INSERT INTO `u891593158_doc`.`schema_migrations` (name)
SELECT '007_engine_rules_and_documents.sql'
WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE name = '007_engine_rules_and_documents.sql')
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_form_fields` WHERE id IN ('36000000-0000-4000-8000-000000000014', '36000000-0000-4000-8000-000000000015')) = 2
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`technical_rules` WHERE id IN ('43000000-0000-4000-8000-000000000001', '43000000-0000-4000-8000-000000000007')) = 2
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_documents` WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND document_code IN ('ENGINE_INVOICE', 'VEHICLE_REGISTRATION', 'OWNER_IDENTIFICATION', 'INSPECTION_REPORT')) = 4
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`technical_rules` WHERE id IN ('43000000-0000-4000-8000-000000000001', '43000000-0000-4000-8000-000000000002', '43000000-0000-4000-8000-000000000003', '43000000-0000-4000-8000-000000000004', '43000000-0000-4000-8000-000000000005', '43000000-0000-4000-8000-000000000006', '43000000-0000-4000-8000-000000000007', '43000000-0000-4000-8000-000000000008', '43000000-0000-4000-8000-000000000009', '43000000-0000-4000-8000-000000000010', '43000000-0000-4000-8000-000000000011')) = 11
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_messages` WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND message_key IN ('MANUAL_REVIEW_TITLE', 'MANUAL_REVIEW_GUIDANCE', 'DOCUMENTS_NOTE', 'EXTERNAL_EXPENSES')) = 4
  AND (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'u891593158_doc' AND table_name = 'application_settings' AND column_name IN ('manual_whatsapp', 'manual_team_name', 'manual_message_template')) = 3
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_billing_items` sbi JOIN `u891593158_doc`.`billing_items` bi ON bi.id = sbi.billing_item_id WHERE sbi.service_version_id = '33000000-0000-4000-8000-000000000001' AND bi.code = 'MODIFICATION_REQUEST') = 1
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_billing_items` sbi JOIN `u891593158_doc`.`billing_items` bi ON bi.id = sbi.billing_item_id WHERE sbi.service_version_id = '33000000-0000-4000-8000-000000000001' AND bi.code = 'ITL_CSV_INSPECTION' AND sbi.include_in_total = 0 AND sbi.visible_to_client = 0 AND sbi.visible_to_partner = 0) = 1;


-- Doc Motor Fase 3.11: tornar a identificação do motor não aplicável a motocicletas.
-- Migration incremental e não destrutiva. Não executar migrations anteriores novamente.

UPDATE `u891593158_doc`.`service_form_fields`
SET is_required = 1,
    visibility_condition = JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'IN_LIST', 'values', JSON_ARRAY('AUTOMOBILE', 'TRUCK', 'BUS')),
    required_condition = JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'IN_LIST', 'values', JSON_ARRAY('AUTOMOBILE', 'TRUCK', 'BUS')),
    updated_at = UTC_TIMESTAMP()
WHERE service_version_id = '33000000-0000-4000-8000-000000000001'
  AND field_key = 'engine.identification_mode';

UPDATE `u891593158_doc`.`service_form_fields`
SET description = 'Ambiente de simulação: informe dados técnicos fictícios do veículo de origem. A integração operacional com provedor externo será implementada na Fase 4.',
    updated_at = UTC_TIMESTAMP()
WHERE service_version_id = '33000000-0000-4000-8000-000000000001'
  AND field_key = 'engine.identification_mode';

UPDATE `u891593158_doc`.`service_form_fields`
SET description = 'Atenção: motocicletas somente podem ser cadastradas automaticamente com motor de mesma cilindrada original, independentemente do ano de fabricação do motor ou da motocicleta. Um motor de 150 ou 160 cilindradas não pode ser cadastrado automaticamente em motocicleta de 125 cilindradas, ou vice-versa.',
    updated_at = UTC_TIMESTAMP()
WHERE service_version_id = '33000000-0000-4000-8000-000000000001'
  AND field_key = 'motorcycle.compatibility_declaration';

INSERT INTO `u891593158_doc`.`schema_migrations` (name)
SELECT '008_motorcycle_visibility_consistency.sql'
WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE name = '008_motorcycle_visibility_consistency.sql')
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_form_fields` WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND field_key = 'engine.identification_mode' AND is_required = 1 AND visibility_condition IS NOT NULL AND required_condition IS NOT NULL) = 1;


-- Doc Motor Fase 3.12: consistência final do simulador declarativo.
-- Migration incremental e não destrutiva. Não executar migrations anteriores novamente.

UPDATE `u891593158_doc`.`service_form_fields`
SET visibility_condition = JSON_OBJECT('all', JSON_ARRAY(
  JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'IN_LIST', 'values', JSON_ARRAY('AUTOMOBILE', 'TRUCK', 'BUS')),
  JSON_OBJECT('field', 'engine.identification_mode', 'operator', 'EQUALS', 'value', 'PLATE')
)), updated_at = UTC_TIMESTAMP()
WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND field_key = 'vehicle_donor.plate';

UPDATE `u891593158_doc`.`service_form_fields`
SET visibility_condition = JSON_OBJECT('all', JSON_ARRAY(
  JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'IN_LIST', 'values', JSON_ARRAY('AUTOMOBILE', 'TRUCK', 'BUS')),
  JSON_OBJECT('field', 'engine.identification_mode', 'operator', 'IN_LIST', 'values', JSON_ARRAY('PLATE', 'MANUAL'))
)), updated_at = UTC_TIMESTAMP()
WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND field_key IN ('vehicle_donor.power_cv', 'vehicle_donor.engine_cc', 'vehicle_donor.fuel');

UPDATE `u891593158_doc`.`service_form_fields`
SET label = 'Declaro que o motor que será instalado possui a mesma cilindrada do motor original da motocicleta.',
    description = '⚠ Atenção à cilindrada do motor\n\nMotocicletas somente podem ser cadastradas automaticamente quando a cilindrada do motor instalado for igual à do motor original.\n\nExemplos:\n✓ 125 cc → 125 cc: compatível\n✕ 125 cc → 150 cc: análise manual necessária\n✕ 160 cc → 125 cc: análise manual necessária',
    updated_at = UTC_TIMESTAMP()
WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND field_key = 'motorcycle.compatibility_declaration';

INSERT INTO `u891593158_doc`.`schema_migrations` (name)
SELECT '009_simulator_final_visibility.sql'
WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE name = '009_simulator_final_visibility.sql')
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_form_fields` WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND field_key IN ('vehicle_donor.plate', 'vehicle_donor.power_cv', 'vehicle_donor.engine_cc', 'vehicle_donor.fuel', 'motorcycle.compatibility_declaration')) = 5;


-- Doc Motor Fase 3.13: catálogo central de modificações e serviço de suspensão.
-- Migration incremental e não destrutiva. Executar manualmente após o precheck.

ALTER TABLE `u891593158_doc`.`service_billing_items` ADD COLUMN IF NOT EXISTS quantity_expression JSON NULL;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`vehicle_modifications` (
  id CHAR(36) NOT NULL PRIMARY KEY,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(180) NOT NULL,
  category VARCHAR(80) NOT NULL,
  description VARCHAR(500) NULL,
  status VARCHAR(16) NOT NULL DEFAULT 'ACTIVE',
  display_order INT NOT NULL DEFAULT 0,
  billing_item_id CHAR(36) NULL,
  requires_prior_authorization TINYINT(1) NOT NULL DEFAULT 0,
  requires_csv TINYINT(1) NOT NULL DEFAULT 0,
  requires_ecv TINYINT(1) NOT NULL DEFAULT 0,
  requires_manual_review TINYINT(1) NOT NULL DEFAULT 0,
  requires_description TINYINT(1) NOT NULL DEFAULT 0,
  official_reference_url VARCHAR(500) NULL,
  guidance TEXT NULL,
  legal_status VARCHAR(32) NOT NULL DEFAULT 'A_CONFIRMAR',
  created_by CHAR(36) NULL,
  updated_by CHAR(36) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_vehicle_modifications_code (code),
  KEY idx_vehicle_modifications_status_order (status, display_order),
  CONSTRAINT fk_vehicle_modification_billing FOREIGN KEY (billing_item_id) REFERENCES `u891593158_doc`.`billing_items` (id) ON DELETE SET NULL,
  CONSTRAINT fk_vehicle_modification_created_by FOREIGN KEY (created_by) REFERENCES `u891593158_doc`.`users` (id) ON DELETE SET NULL,
  CONSTRAINT fk_vehicle_modification_updated_by FOREIGN KEY (updated_by) REFERENCES `u891593158_doc`.`users` (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`vehicle_modification_categories` (
  modification_id CHAR(36) NOT NULL,
  vehicle_category_id CHAR(36) NOT NULL,
  PRIMARY KEY (modification_id, vehicle_category_id),
  CONSTRAINT fk_modification_categories_modification FOREIGN KEY (modification_id) REFERENCES `u891593158_doc`.`vehicle_modifications` (id) ON DELETE CASCADE,
  CONSTRAINT fk_modification_categories_vehicle FOREIGN KEY (vehicle_category_id) REFERENCES `u891593158_doc`.`vehicle_categories` (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`vehicle_modification_ufs` (
  modification_id CHAR(36) NOT NULL,
  uf CHAR(2) NOT NULL,
  PRIMARY KEY (modification_id, uf),
  CONSTRAINT fk_modification_ufs_modification FOREIGN KEY (modification_id) REFERENCES `u891593158_doc`.`vehicle_modifications` (id) ON DELETE CASCADE,
  CONSTRAINT fk_modification_ufs_state FOREIGN KEY (uf) REFERENCES `u891593158_doc`.`brazilian_states` (uf) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`vehicle_modification_documents` (
  id CHAR(36) NOT NULL PRIMARY KEY,
  modification_id CHAR(36) NOT NULL,
  document_code VARCHAR(80) NOT NULL,
  name VARCHAR(180) NOT NULL,
  requirement_type VARCHAR(24) NOT NULL DEFAULT 'A_CONFIRMAR',
  description VARCHAR(500) NULL,
  condition_expression JSON NULL,
  display_order INT NOT NULL DEFAULT 0,
  UNIQUE KEY uq_modification_document (modification_id, document_code),
  CONSTRAINT fk_modification_documents_modification FOREIGN KEY (modification_id) REFERENCES `u891593158_doc`.`vehicle_modifications` (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `u891593158_doc`.`vehicle_modification_messages` (
  id CHAR(36) NOT NULL PRIMARY KEY,
  modification_id CHAR(36) NOT NULL,
  message_key VARCHAR(80) NOT NULL,
  severity VARCHAR(16) NOT NULL DEFAULT 'INFO',
  content VARCHAR(1000) NOT NULL,
  condition_expression JSON NULL,
  display_order INT NOT NULL DEFAULT 0,
  UNIQUE KEY uq_modification_message (modification_id, message_key),
  CONSTRAINT fk_modification_messages_modification FOREIGN KEY (modification_id) REFERENCES `u891593158_doc`.`vehicle_modifications` (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

UPDATE `u891593158_doc`.`services` SET name = 'Regularização de suspensão', slug = 'regularizacao-de-suspensao', short_description = 'Orientação para rebaixamento, elevação, kits Lift e outras alterações de suspensão.', updated_at = UTC_TIMESTAMP() WHERE code = 'LOWERED_SUSPENSION';

INSERT INTO `u891593158_doc`.`billing_items` (id, code, name, description, financial_category, default_amount_cents, status, charge_nature, amount_status, payment_mode, is_public_fee)
VALUES
('59000000-0000-4000-8000-000000000001', 'SUSPENSION_REGULARIZATION', 'Regularização de suspensão', 'Valor comercial de referência, sujeito à configuração administrativa.', 'SUSPENSION', 30000, 'DRAFT', 'OWN_SERVICE', 'INFORMED', 'DOC_MOTOR', 0),
('59000000-0000-4000-8000-000000000002', 'WHEELS_TIRES_REGULARIZATION', 'Regularização de rodas e pneus', 'Uma modificação comercial para rodas, pneus ou ambos.', 'WHEELS_TIRES', 30000, 'DRAFT', 'OWN_SERVICE', 'INFORMED', 'DOC_MOTOR', 0),
('59000000-0000-4000-8000-000000000003', 'ADDITIONAL_MODIFICATION', 'Modificação adicional', 'Cobrança por modificação adicional válida.', 'MODIFICATION', 30000, 'DRAFT', 'OWN_SERVICE', 'INFORMED', 'DOC_MOTOR', 0)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), default_amount_cents = VALUES(default_amount_cents), updated_at = UTC_TIMESTAMP();

INSERT INTO `u891593158_doc`.`vehicle_modifications` (id, code, name, category, description, status, display_order, billing_item_id, requires_prior_authorization, requires_csv, requires_ecv, requires_manual_review, requires_description, official_reference_url, guidance, legal_status)
VALUES
('58000000-0000-4000-8000-000000000001', 'SUSPENSION_LOWERING', 'Rebaixamento de suspensão', 'Suspensão', 'Rebaixamento de suspensão, sujeito à análise técnica e documental.', 'ACTIVE', 10, '59000000-0000-4000-8000-000000000001', 0, 1, 1, 0, 0, 'https://www.gov.br/transportes/pt-br/assuntos/transito/conteudo-contran/resolucoes/Resolucao9162022.pdf', 'A configuração é comercial e preliminar; não representa autorização do Detran.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000002', 'SUSPENSION_LIFT', 'Elevação de suspensão / Kit Lift', 'Suspensão', 'Elevação, kit Lift ou alteração equivalente.', 'ACTIVE', 20, '59000000-0000-4000-8000-000000000001', 0, 1, 1, 1, 0, 'https://www.gov.br/transportes/pt-br/assuntos/transito/conteudo-contran/resolucoes/Resolucao9162022.pdf', 'Veículos pesados e categorias sem regra específica seguem para análise manual.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000003', 'SUSPENSION_OTHER', 'Outras alterações de suspensão', 'Suspensão', 'Outra modificação na suspensão.', 'ACTIVE', 30, '59000000-0000-4000-8000-000000000001', 0, 1, 1, 1, 1, 'https://www.gov.br/transportes/pt-br/assuntos/transito/conteudo-contran/resolucoes/Resolucao9162022.pdf', 'Descreva a alteração para análise individual.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000004', 'WHEELS_TIRES', 'Alteração do conjunto de rodas e pneus', 'Rodas e pneus', 'Uma modificação comercial para rodas, pneus ou ambos.', 'ACTIVE', 40, '59000000-0000-4000-8000-000000000002', 0, 0, 0, 0, 0, 'https://www.poupatempo.sp.gov.br/carta/3C5B0216-DF40-4427-BAB4-A6E5FF55B353', 'A dispensa de CSV específico depende do procedimento aplicável; outras exigências podem existir.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000005', 'GNV_INSTALLATION', 'Instalação de GNV', 'Combustível e GNV', 'Instalação ou regularização de GNV.', 'ACTIVE', 50, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Exigências legais e documentais devem ser confirmadas antes da contratação.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000006', 'GNV_REMOVAL', 'Retirada de GNV', 'Combustível e GNV', 'Retirada de GNV.', 'ACTIVE', 60, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Exigências legais e documentais devem ser confirmadas antes da contratação.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000007', 'FUEL_CHANGE', 'Alteração de combustível', 'Combustível e GNV', 'Alteração de combustível.', 'ACTIVE', 70, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Exigências legais e documentais devem ser confirmadas antes da contratação.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000008', 'SECURITY_ARMOR_INSTALLATION', 'Instalação de blindagem', 'Segurança', 'Instalação de blindagem.', 'ACTIVE', 80, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Exigências de autorização, inspeção e documentação devem ser confirmadas.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000009', 'SECURITY_ARMOR_REMOVAL', 'Retirada de blindagem', 'Segurança', 'Retirada de blindagem.', 'ACTIVE', 90, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Exigências devem ser confirmadas antes da contratação.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000010', 'POWER_CHANGE', 'Alteração de potência', 'Motor e potência', 'Alteração de potência do veículo.', 'ACTIVE', 100, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Não confundir com o serviço independente de cadastro de motor.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000011', 'CYLINDER_CHANGE', 'Alteração de cilindrada', 'Motor e potência', 'Alteração de cilindrada.', 'ACTIVE', 110, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Não confundir com o serviço independente de cadastro de motor.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000012', 'BODY_CHANGE', 'Alteração de carroceria', 'Carroceria e chassi', 'Alteração de carroceria.', 'ACTIVE', 120, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Exigências documentais dependem da alteração.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000013', 'MOTORHOME_CONVERSION', 'Conversão para motorcasa / Motorhome', 'Carroceria e chassi', 'Conversão para motorcasa ou Motorhome.', 'ACTIVE', 130, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Análise técnica e documental obrigatória.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000014', 'CHASSIS_LENGTHENING', 'Alongamento de chassi', 'Carroceria e chassi', 'Alongamento de chassi.', 'ACTIVE', 140, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Análise técnica e documental obrigatória.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000015', 'CHASSIS_SHORTENING', 'Encurtamento de chassi', 'Carroceria e chassi', 'Encurtamento de chassi.', 'ACTIVE', 150, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Análise técnica e documental obrigatória.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000016', 'AXLE_ADDITION', 'Inclusão de eixo', 'Carroceria e chassi', 'Inclusão de eixo.', 'ACTIVE', 160, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Análise técnica e documental obrigatória.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000017', 'PCD_ADAPTATION', 'Adaptação para PCD', 'Acessibilidade e lotação', 'Adaptação para pessoa com deficiência.', 'ACTIVE', 170, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Descreva a adaptação realizada.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000018', 'DRIVING_SCHOOL_CONTROLS_INSTALLATION', 'Instalação de comandos de autoescola', 'Acessibilidade e lotação', 'Instalação de comandos de autoescola.', 'ACTIVE', 180, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Exigências devem ser confirmadas.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000019', 'DRIVING_SCHOOL_CONTROLS_REMOVAL', 'Retirada de comandos de autoescola', 'Acessibilidade e lotação', 'Retirada de comandos de autoescola.', 'ACTIVE', 190, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Exigências devem ser confirmadas.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000020', 'PASSENGER_CAPACITY_CHANGE', 'Alteração da capacidade de passageiros', 'Acessibilidade e lotação', 'Alteração da capacidade de passageiros.', 'ACTIVE', 200, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Exigências devem ser confirmadas.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000021', 'COLOR_CHANGE', 'Mudança de cor', 'Estética', 'Mudança de cor.', 'ACTIVE', 210, '59000000-0000-4000-8000-000000000003', 0, 0, 0, 0, 1, NULL, 'A descrição da alteração é necessária para análise.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000022', 'WRAPPING', 'Envelopamento', 'Estética', 'Envelopamento do veículo.', 'ACTIVE', 220, '59000000-0000-4000-8000-000000000003', 0, 0, 0, 0, 1, NULL, 'A descrição da alteração é necessária para análise.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000023', 'LOAD_DEVICE_CHANGE', 'Instalação ou alteração de dispositivos de carga', 'Dispositivos de carga', 'Instalação ou alteração de dispositivo de carga.', 'ACTIVE', 230, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Análise técnica e documental obrigatória.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000024', 'SPECIES_COLLECTION', 'Alteração para coleção', 'Espécie', 'Alteração da espécie para coleção.', 'ACTIVE', 240, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Exigências devem ser confirmadas.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000025', 'SPECIES_COMPETITION', 'Alteração para competição', 'Espécie', 'Alteração da espécie para competição.', 'ACTIVE', 250, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Exigências devem ser confirmadas.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000026', 'SPECIES_OTHER', 'Outras alterações de espécie', 'Espécie', 'Outra alteração de espécie.', 'ACTIVE', 260, '59000000-0000-4000-8000-000000000003', 1, 1, 1, 1, 1, NULL, 'Descreva a alteração.', 'A_CONFIRMAR'),
('58000000-0000-4000-8000-000000000027', 'OTHER_MODIFICATION', 'Outra modificação — especifique', 'Outros', 'Outra alteração não listada.', 'ACTIVE', 999, '59000000-0000-4000-8000-000000000003', 0, 0, 0, 1, 1, NULL, 'Descreva a alteração realizada.', 'A_CONFIRMAR')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), status = VALUES(status), display_order = VALUES(display_order), updated_at = UTC_TIMESTAMP();

INSERT INTO `u891593158_doc`.`vehicle_modification_categories` (modification_id, vehicle_category_id)
SELECT vm.id, vc.id FROM `u891593158_doc`.`vehicle_modifications` vm CROSS JOIN `u891593158_doc`.`vehicle_categories` vc WHERE vm.code IN ('SUSPENSION_LOWERING', 'SUSPENSION_LIFT', 'SUSPENSION_OTHER', 'WHEELS_TIRES', 'GNV_INSTALLATION', 'GNV_REMOVAL', 'FUEL_CHANGE', 'SECURITY_ARMOR_INSTALLATION', 'SECURITY_ARMOR_REMOVAL', 'POWER_CHANGE', 'CYLINDER_CHANGE', 'BODY_CHANGE', 'MOTORHOME_CONVERSION', 'CHASSIS_LENGTHENING', 'CHASSIS_SHORTENING', 'AXLE_ADDITION', 'PCD_ADAPTATION', 'DRIVING_SCHOOL_CONTROLS_INSTALLATION', 'DRIVING_SCHOOL_CONTROLS_REMOVAL', 'PASSENGER_CAPACITY_CHANGE', 'COLOR_CHANGE', 'WRAPPING', 'LOAD_DEVICE_CHANGE', 'SPECIES_COLLECTION', 'SPECIES_COMPETITION', 'SPECIES_OTHER', 'OTHER_MODIFICATION') AND vc.code IN ('AUTOMOBILE', 'PICKUP') ON DUPLICATE KEY UPDATE modification_id = VALUES(modification_id);

INSERT INTO `u891593158_doc`.`service_versions` (id, service_id, version_number, status, change_summary)
SELECT '57000000-0000-4000-8000-000000000001', s.id, 1, 'DRAFT', 'Configuração inicial declarativa da regularização de suspensão.' FROM `u891593158_doc`.`services` s WHERE s.code = 'LOWERED_SUSPENSION' AND NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`service_versions` v WHERE v.service_id = s.id);

INSERT INTO `u891593158_doc`.`service_form_sections` (id, service_version_id, stable_key, label, description, display_order)
SELECT x.id, v.id, x.stable_key, x.label, x.description, x.display_order FROM `u891593158_doc`.`service_versions` v JOIN `u891593158_doc`.`services` s ON s.id = v.service_id JOIN (SELECT '52000000-0000-4000-8000-000000000001' id, 'vehicle' stable_key, 'Dados do veículo' label, 'Informe os dados manualmente nesta fase.' description, 10 display_order UNION ALL SELECT '52000000-0000-4000-8000-000000000002', 'suspension', 'Modificação da suspensão', 'Selecione a alteração e as condições conhecidas.', 20 UNION ALL SELECT '52000000-0000-4000-8000-000000000003', 'wheels', 'Rodas e pneus', 'A regularização de rodas e pneus é uma única modificação comercial.', 30 UNION ALL SELECT '52000000-0000-4000-8000-000000000004', 'additional', 'Outras modificações', 'Adicione modificações distintas quando necessário.', 40) x WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1 ON DUPLICATE KEY UPDATE label = VALUES(label), description = VALUES(description), display_order = VALUES(display_order);

INSERT INTO `u891593158_doc`.`service_form_fields` (id, service_version_id, section_id, field_key, label, description, field_type, is_required, display_order, visibility_condition, required_condition, data_origin)
SELECT f.id, v.id, sec.id, f.field_key, f.label, f.description, f.field_type, f.is_required, f.display_order, f.visibility_condition, f.required_condition, 'MANUAL' FROM `u891593158_doc`.`service_versions` v JOIN `u891593158_doc`.`services` s ON s.id = v.service_id JOIN (SELECT '53000000-0000-4000-8000-000000000001' id, 'vehicle_target.plate' field_key, 'Placa do veículo' label, 'Aceitamos placa antiga ou Mercosul.' description, 'VEHICLE_PLATE' field_type, 1 is_required, 10 display_order, NULL visibility_condition, NULL required_condition, 'vehicle' stable_key UNION ALL SELECT '53000000-0000-4000-8000-000000000002', 'vehicle_target.category', 'Categoria veicular', 'Casos não homologados seguem para análise manual.', 'SINGLE_SELECT', 1, 20, NULL, NULL, 'vehicle' UNION ALL SELECT '53000000-0000-4000-8000-000000000003', 'vehicle_target.state', 'UF do veículo', NULL, 'SINGLE_SELECT', 1, 30, NULL, NULL, 'vehicle' UNION ALL SELECT '53000000-0000-4000-8000-000000000004', 'vehicle_target.pbt_kg', 'PBT (kg), quando aplicável', 'Informe apenas quando souber.', 'INTEGER', 0, 40, NULL, NULL, 'vehicle' UNION ALL SELECT '53000000-0000-4000-8000-000000000005', 'suspension.change_type', 'Tipo de alteração', NULL, 'SINGLE_SELECT', 1, 50, NULL, NULL, 'suspension' UNION ALL SELECT '53000000-0000-4000-8000-000000000006', 'suspension.type', 'Tipo de suspensão', NULL, 'SINGLE_SELECT', 1, 60, NULL, NULL, 'suspension' UNION ALL SELECT '53000000-0000-4000-8000-000000000007', 'suspension.already_done', 'A modificação já foi realizada?', NULL, 'YES_NO', 1, 70, NULL, NULL, 'suspension' UNION ALL SELECT '53000000-0000-4000-8000-000000000008', 'suspension.prior_authorization', 'Já possui autorização prévia do Detran?', NULL, 'SINGLE_SELECT', 1, 80, NULL, NULL, 'suspension' UNION ALL SELECT '53000000-0000-4000-8000-000000000009', 'suspension.compliance', 'A instalação da suspensão respeita as regras do Detran?', 'Não selecione automaticamente. A resposta é orientativa.', 'SINGLE_SELECT', 1, 90, NULL, NULL, 'suspension' UNION ALL SELECT '53000000-0000-4000-8000-000000000010', 'suspension.clearance_check', 'O veículo possui altura livre mínima de 10 cm entre o solo e o ponto mais baixo da carroceria ou chassi?', 'Aplicável inicialmente a veículos de até 3.500 kg.', 'SINGLE_SELECT', 0, 100, '{"field":"suspension.compliance","operator":"EQUALS","value":"UNKNOWN"}', '{"field":"suspension.compliance","operator":"EQUALS","value":"UNKNOWN"}', 'suspension' UNION ALL SELECT '53000000-0000-4000-8000-000000000011', 'suspension.contact_check', 'As rodas e pneus não encostam durante o funcionamento?', NULL, 'SINGLE_SELECT', 0, 110, '{"field":"suspension.compliance","operator":"EQUALS","value":"UNKNOWN"}', '{"field":"suspension.compliance","operator":"EQUALS","value":"UNKNOWN"}', 'suspension' UNION ALL SELECT '53000000-0000-4000-8000-000000000012', 'wheels.include', 'Também deseja regularizar rodas e pneus?', NULL, 'YES_NO', 1, 120, NULL, NULL, 'wheels' UNION ALL SELECT '53000000-0000-4000-8000-000000000013', 'wheels.compliance', 'A instalação das rodas e pneus respeita as regras do Detran?', 'Não selecione automaticamente.', 'SINGLE_SELECT', 0, 130, '{"field":"wheels.include","operator":"EQUALS","value":"YES"}', '{"field":"wheels.include","operator":"EQUALS","value":"YES"}', 'wheels' UNION ALL SELECT '53000000-0000-4000-8000-000000000014', 'wheels.fender_check', 'Os pneus estão dentro dos limites dos para-lamas?', NULL, 'SINGLE_SELECT', 0, 140, '{"all":[{"field":"wheels.include","operator":"EQUALS","value":"YES"},{"field":"wheels.compliance","operator":"EQUALS","value":"UNKNOWN"}]}', NULL, 'wheels' UNION ALL SELECT '53000000-0000-4000-8000-000000000015', 'modifications.additional', 'Outras modificações', 'Use o catálogo para selecionar opções distintas e descreva cada alteração.', 'REPEATABLE_MODIFICATIONS', 0, 150, NULL, NULL, 'additional') f JOIN `u891593158_doc`.`service_form_sections` sec ON sec.service_version_id = v.id AND sec.stable_key = f.stable_key WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1 ON DUPLICATE KEY UPDATE label = VALUES(label), description = VALUES(description), field_type = VALUES(field_type), is_required = VALUES(is_required), display_order = VALUES(display_order), visibility_condition = VALUES(visibility_condition), required_condition = VALUES(required_condition);

INSERT INTO `u891593158_doc`.`service_field_options` (id, field_id, option_value, option_label, display_order)
SELECT o.id, f.id, o.option_value, o.option_label, o.display_order FROM `u891593158_doc`.`service_form_fields` f JOIN (SELECT '54000000-0000-4000-8000-000000000001' id, 'vehicle_target.category' field_key, 'AUTOMOBILE' option_value, 'Automóvel' option_label, 10 display_order UNION ALL SELECT '54000000-0000-4000-8000-000000000002', 'vehicle_target.category', 'MOTORCYCLE', 'Motocicleta', 20 UNION ALL SELECT '54000000-0000-4000-000000000003', 'vehicle_target.category', 'TRUCK', 'Caminhão', 30 UNION ALL SELECT '54000000-0000-4000-8000-000000000004', 'vehicle_target.category', 'BUS', 'Ônibus', 40 UNION ALL SELECT '54000000-0000-4000-8000-000000000005', 'vehicle_target.category', 'PICKUP', 'Caminhonete', 50 UNION ALL SELECT '54000000-0000-4000-8000-000000000006', 'suspension.change_type', 'LOWERING', 'Rebaixamento', 10 UNION ALL SELECT '54000000-0000-4000-8000-000000000007', 'suspension.change_type', 'LIFT', 'Elevação / Kit Lift', 20 UNION ALL SELECT '54000000-0000-4000-8000-000000000008', 'suspension.change_type', 'OTHER', 'Outra alteração', 30 UNION ALL SELECT '54000000-0000-4000-8000-000000000009', 'suspension.type', 'FIXED', 'Fixa', 10 UNION ALL SELECT '54000000-0000-4000-8000-000000000010', 'suspension.type', 'COILOVER', 'Rosca', 20 UNION ALL SELECT '54000000-0000-4000-8000-000000000011', 'suspension.type', 'AIR', 'A ar', 30 UNION ALL SELECT '54000000-0000-4000-8000-000000000012', 'suspension.type', 'LIFT_KIT', 'Kit Lift', 40 UNION ALL SELECT '54000000-0000-4000-8000-000000000013', 'suspension.type', 'OTHER', 'Outra', 50 UNION ALL SELECT '54000000-0000-4000-8000-000000000014', 'suspension.type', 'UNKNOWN', 'Não sei', 60 UNION ALL SELECT '54000000-0000-4000-8000-000000000015', 'suspension.prior_authorization', 'YES', 'Sim', 10 UNION ALL SELECT '54000000-0000-4000-8000-000000000016', 'suspension.prior_authorization', 'NO', 'Não', 20 UNION ALL SELECT '54000000-0000-4000-8000-000000000017', 'suspension.prior_authorization', 'UNKNOWN', 'Não sei', 30 UNION ALL SELECT '54000000-0000-4000-8000-000000000018', 'suspension.compliance', 'YES', 'Sim', 10 UNION ALL SELECT '54000000-0000-4000-8000-000000000019', 'suspension.compliance', 'NO', 'Não', 20 UNION ALL SELECT '54000000-0000-4000-8000-000000000020', 'suspension.compliance', 'UNKNOWN', 'Não sei', 30 UNION ALL SELECT '54000000-0000-4000-8000-000000000021', 'suspension.clearance_check', 'YES', 'Sim', 10 UNION ALL SELECT '54000000-0000-4000-8000-000000000022', 'suspension.clearance_check', 'NO', 'Não', 20 UNION ALL SELECT '54000000-0000-4000-8000-000000000023', 'suspension.clearance_check', 'UNKNOWN', 'Não sei', 30 UNION ALL SELECT '54000000-0000-4000-8000-000000000024', 'suspension.contact_check', 'YES', 'Sim', 10 UNION ALL SELECT '54000000-0000-4000-8000-000000000025', 'suspension.contact_check', 'NO', 'Não', 20 UNION ALL SELECT '54000000-0000-4000-8000-000000000026', 'suspension.contact_check', 'UNKNOWN', 'Não sei', 30 UNION ALL SELECT '54000000-0000-4000-8000-000000000027', 'wheels.compliance', 'YES', 'Sim', 10 UNION ALL SELECT '54000000-0000-4000-8000-000000000028', 'wheels.compliance', 'NO', 'Não', 20 UNION ALL SELECT '54000000-0000-4000-8000-000000000029', 'wheels.compliance', 'UNKNOWN', 'Não sei', 30 UNION ALL SELECT '54000000-0000-4000-8000-000000000030', 'wheels.fender_check', 'YES', 'Sim', 10 UNION ALL SELECT '54000000-0000-4000-8000-000000000031', 'wheels.fender_check', 'NO', 'Não', 20 UNION ALL SELECT '54000000-0000-4000-8000-000000000032', 'wheels.fender_check', 'UNKNOWN', 'Não sei', 30) o ON o.field_key = f.field_key WHERE f.service_version_id = (SELECT sv.id FROM `u891593158_doc`.`service_versions` sv JOIN `u891593158_doc`.`services` ss ON ss.id = sv.service_id WHERE ss.code = 'LOWERED_SUSPENSION' ORDER BY sv.version_number DESC LIMIT 1) ON DUPLICATE KEY UPDATE option_label = VALUES(option_label), display_order = VALUES(display_order);

INSERT INTO `u891593158_doc`.`service_billing_items` (id, service_version_id, billing_item_id, billing_mode, quantity_expression, display_order, condition_expression)
SELECT x.id, v.id, bi.id, x.billing_mode, x.quantity_expression, x.display_order, x.condition_expression FROM `u891593158_doc`.`service_versions` v JOIN `u891593158_doc`.`services` s ON s.id = v.service_id JOIN (SELECT '56000000-0000-4000-8000-000000000001' id, 'TRANSFER_FEE' code, 'REQUIRED' billing_mode, NULL quantity_expression, 10 display_order, NULL condition_expression UNION ALL SELECT '56000000-0000-4000-8000-000000000002', 'SERVICE_FEE', 'REQUIRED', NULL, 20, NULL UNION ALL SELECT '56000000-0000-4000-8000-000000000003', 'SUSPENSION_REGULARIZATION', 'REQUIRED', NULL, 30, NULL UNION ALL SELECT '56000000-0000-4000-8000-000000000004', 'MERCOSUR_PLATE_AUTHORIZATION', 'CONDITIONAL', NULL, 40, '{"field":"vehicle_target.plate_pattern","operator":"EQUALS","value":"OLD"}' UNION ALL SELECT '56000000-0000-4000-8000-000000000005', 'WHEELS_TIRES_REGULARIZATION', 'CONDITIONAL', NULL, 50, '{"field":"wheels.include","operator":"EQUALS","value":"YES"}' UNION ALL SELECT '56000000-0000-4000-8000-000000000006', 'ADDITIONAL_MODIFICATION', 'CONDITIONAL', '{"field":"modifications.additional","operator":"COUNT_FILLED"}', 60, '{"field":"modifications.additional","operator":"COUNT_FILLED"}') x JOIN `u891593158_doc`.`billing_items` bi ON bi.code = x.code WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1 ON DUPLICATE KEY UPDATE billing_mode = VALUES(billing_mode), quantity_expression = VALUES(quantity_expression), display_order = VALUES(display_order), condition_expression = VALUES(condition_expression);

INSERT INTO `u891593158_doc`.`technical_rules` (id, service_id, service_version_id, name, description, conditions, expected_result, status, priority, version)
SELECT r.id, s.id, v.id, r.name, r.description, r.conditions, r.expected_result, 'DRAFT', r.priority, 1 FROM `u891593158_doc`.`services` s JOIN `u891593158_doc`.`service_versions` v ON v.service_id = s.id JOIN (SELECT '5A000000-0000-4000-8000-000000000001' id, 'Suspensão não conforme' name, 'A resposta negativa exige análise manual e não representa autorização.' description, '{"field":"suspension.compliance","operator":"EQUALS","value":"NO"}' conditions, 'MANUAL_REVIEW' expected_result, 10 priority UNION ALL SELECT '5A000000-0000-4000-8000-000000000002', 'Suspensão sem confirmação', 'Respostas desconhecidas ou incompatíveis exigem análise manual.', '{"any":[{"field":"suspension.compliance","operator":"EQUALS","value":"UNKNOWN"},{"field":"suspension.clearance_check","operator":"IN_LIST","values":["NO","UNKNOWN"]},{"field":"suspension.contact_check","operator":"IN_LIST","values":["NO","UNKNOWN"]}]}', 'MANUAL_REVIEW', 20 UNION ALL SELECT '5A000000-0000-4000-8000-000000000003', 'Rodas e pneus não conformes', 'A resposta negativa exige análise manual.', '{"field":"wheels.compliance","operator":"EQUALS","value":"NO"}', 'MANUAL_REVIEW', 30 UNION ALL SELECT '5A000000-0000-4000-8000-000000000004', 'Categoria sem regra específica', 'Motocicletas, veículos pesados e categorias não homologadas seguem para análise manual.', '{"field":"vehicle_target.category","operator":"IN_LIST","values":["MOTORCYCLE","TRUCK","BUS"]}', 'MANUAL_REVIEW', 40) r ON s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1 WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`technical_rules` existing WHERE existing.id = r.id);

INSERT INTO `u891593158_doc`.`service_messages` (id, service_version_id, message_key, severity, content, display_order)
SELECT m.id, v.id, m.message_key, m.severity, m.content, m.display_order FROM `u891593158_doc`.`services` s JOIN `u891593158_doc`.`service_versions` v ON v.service_id = s.id JOIN (SELECT '5B000000-0000-4000-8000-000000000001' id, 'EXTERNAL_COSTS_NOTE' message_key, 'INFO' severity, 'Os valores de inspeções, certificados e vistorias eventualmente exigidos não estão inclusos neste orçamento e serão cobrados diretamente pelas empresas responsáveis.' content, 10 display_order) m ON s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1 ON DUPLICATE KEY UPDATE content = VALUES(content), severity = VALUES(severity), display_order = VALUES(display_order);

-- Regras positivas e checklist complementar. Mantém a avaliação declarativa no banco.
INSERT INTO `u891593158_doc`.`service_form_fields` (id, service_version_id, section_id, field_key, label, description, field_type, is_required, display_order, visibility_condition, required_condition, data_origin)
SELECT x.id, v.id, sec.id, x.field_key, x.label, x.description, x.field_type, x.is_required, x.display_order, x.visibility_condition, x.required_condition, 'MANUAL'
FROM `u891593158_doc`.`service_versions` v JOIN `u891593158_doc`.`services` s ON s.id = v.service_id JOIN `u891593158_doc`.`service_form_sections` sec ON sec.service_version_id = v.id AND sec.stable_key = 'wheels'
JOIN (SELECT '53000000-0000-4000-8000-000000000016' id, 'wheels.contact_check' field_key, 'Os pneus não encostam na carroceria, suspensão ou outros componentes?' label, NULL description, 'SINGLE_SELECT' field_type, 0 is_required, 145 display_order, '{"all":[{"field":"wheels.include","operator":"EQUALS","value":"YES"},{"field":"wheels.compliance","operator":"EQUALS","value":"UNKNOWN"}]}' visibility_condition, '{"all":[{"field":"wheels.include","operator":"EQUALS","value":"YES"},{"field":"wheels.compliance","operator":"EQUALS","value":"UNKNOWN"}]}' required_condition UNION ALL SELECT '53000000-0000-4000-8000-000000000017', 'wheels.diameter_check', 'O diâmetro externo respeita a tolerância aplicável ao veículo?' label, NULL, 'SINGLE_SELECT', 0, 150, '{"all":[{"field":"wheels.include","operator":"EQUALS","value":"YES"},{"field":"wheels.compliance","operator":"EQUALS","value":"UNKNOWN"}]}', '{"all":[{"field":"wheels.include","operator":"EQUALS","value":"YES"},{"field":"wheels.compliance","operator":"EQUALS","value":"UNKNOWN"}]}') x
ON s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1
ON DUPLICATE KEY UPDATE label = VALUES(label), description = VALUES(description), field_type = VALUES(field_type), is_required = VALUES(is_required), display_order = VALUES(display_order), visibility_condition = VALUES(visibility_condition), required_condition = VALUES(required_condition);

INSERT INTO `u891593158_doc`.`service_field_options` (id, field_id, option_value, option_label, display_order)
SELECT o.id, f.id, o.option_value, o.option_label, o.display_order FROM `u891593158_doc`.`service_form_fields` f JOIN (SELECT '54000000-0000-4000-8000-000000000033' id, 'wheels.contact_check' field_key, 'YES' option_value, 'Sim' option_label, 10 display_order UNION ALL SELECT '54000000-0000-4000-8000-000000000034', 'wheels.contact_check', 'NO', 'Não', 20 UNION ALL SELECT '54000000-0000-4000-8000-000000000035', 'wheels.contact_check', 'UNKNOWN', 'Não sei', 30 UNION ALL SELECT '54000000-0000-4000-8000-000000000036', 'wheels.diameter_check', 'YES', 'Sim', 10 UNION ALL SELECT '54000000-0000-4000-8000-000000000037', 'wheels.diameter_check', 'NO', 'Não', 20 UNION ALL SELECT '54000000-0000-4000-8000-000000000038', 'wheels.diameter_check', 'UNKNOWN', 'Não sei', 30) o ON o.field_key = f.field_key WHERE f.service_version_id = (SELECT v.id FROM `u891593158_doc`.`service_versions` v JOIN `u891593158_doc`.`services` s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' ORDER BY v.version_number DESC LIMIT 1) ON DUPLICATE KEY UPDATE option_label = VALUES(option_label), display_order = VALUES(display_order);

UPDATE `u891593158_doc`.`service_form_fields` f JOIN `u891593158_doc`.`service_versions` v ON v.id = f.service_version_id JOIN `u891593158_doc`.`services` s ON s.id = v.service_id
SET f.is_required = 1,
    f.required_condition = CASE
      WHEN f.field_key = 'wheels.fender_check' THEN '{"all":[{"field":"wheels.include","operator":"EQUALS","value":"YES"},{"field":"wheels.compliance","operator":"EQUALS","value":"UNKNOWN"}]}'
      ELSE f.required_condition
    END
WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1
  AND f.field_key IN ('suspension.clearance_check', 'suspension.contact_check', 'wheels.compliance', 'wheels.fender_check', 'wheels.contact_check', 'wheels.diameter_check');

UPDATE `u891593158_doc`.`technical_rules`
SET conditions = '{"all":[{"field":"suspension.compliance","operator":"EQUALS","value":"UNKNOWN"},{"any":[{"field":"suspension.clearance_check","operator":"IN_LIST","values":["NO","UNKNOWN"]},{"field":"suspension.contact_check","operator":"IN_LIST","values":["NO","UNKNOWN"]},{"field":"wheels.fender_check","operator":"IN_LIST","values":["NO","UNKNOWN"]},{"field":"wheels.contact_check","operator":"IN_LIST","values":["NO","UNKNOWN"]},{"field":"wheels.diameter_check","operator":"IN_LIST","values":["NO","UNKNOWN"]}]}]}'
WHERE id = '5A000000-0000-4000-8000-000000000002';

INSERT INTO `u891593158_doc`.`technical_rules` (id, service_id, service_version_id, name, description, conditions, expected_result, status, priority, version)
SELECT r.id, s.id, v.id, r.name, r.description, r.conditions, r.expected_result, 'DRAFT', r.priority, 1
FROM `u891593158_doc`.`services` s JOIN `u891593158_doc`.`service_versions` v ON v.service_id = s.id
JOIN (SELECT '5A000000-0000-4000-8000-000000000005' id, 'Suspensão compatível' name, 'As respostas informadas são compatíveis com a análise preliminar.' description, '{"all":[{"field":"vehicle_target.category","operator":"IN_LIST","values":["AUTOMOBILE","PICKUP"]},{"field":"suspension.compliance","operator":"EQUALS","value":"YES"},{"any":[{"field":"wheels.include","operator":"EQUALS","value":"NO"},{"field":"wheels.compliance","operator":"EQUALS","value":"YES"}]}]}' conditions, 'VIABLE' expected_result, 100 priority UNION ALL SELECT '5A000000-0000-4000-8000-000000000006', 'Checklist compatível', 'O checklist informado permite um orçamento preliminar condicionado à conferência documental.', '{"all":[{"field":"vehicle_target.category","operator":"IN_LIST","values":["AUTOMOBILE","PICKUP"]},{"field":"suspension.compliance","operator":"EQUALS","value":"UNKNOWN"},{"field":"suspension.clearance_check","operator":"EQUALS","value":"YES"},{"field":"suspension.contact_check","operator":"EQUALS","value":"YES"},{"any":[{"field":"wheels.include","operator":"EQUALS","value":"NO"},{"all":[{"field":"wheels.compliance","operator":"EQUALS","value":"UNKNOWN"},{"field":"wheels.fender_check","operator":"EQUALS","value":"YES"},{"field":"wheels.contact_check","operator":"EQUALS","value":"YES"},{"field":"wheels.diameter_check","operator":"EQUALS","value":"YES"}]}]}' conditions, 'VIABLE_WITH_REQUIREMENTS' expected_result, 110 priority) r
ON s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1
WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`technical_rules` existing WHERE existing.id = r.id);

INSERT INTO `u891593158_doc`.`technical_rules` (id, service_id, service_version_id, name, description, conditions, expected_result, status, priority, version)
SELECT '5A000000-0000-4000-8000-000000000007', s.id, v.id, 'Categoria sem configuração', 'Categorias fora do escopo inicial seguem para análise manual.', '{"field":"vehicle_target.category","operator":"NOT_IN_LIST","values":["AUTOMOBILE","PICKUP"]}', 'MANUAL_REVIEW', 'DRAFT', 45, 1
FROM `u891593158_doc`.`services` s JOIN `u891593158_doc`.`service_versions` v ON v.service_id = s.id
WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1
  AND NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`technical_rules` existing WHERE existing.id = '5A000000-0000-4000-8000-000000000007');

-- Registra somente depois de todas as tabelas, campos, opções, regras e seeds esperados.
INSERT INTO `u891593158_doc`.`schema_migrations` (name)
SELECT '010_suspension_modification_catalog.sql'
WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE name = '010_suspension_modification_catalog.sql')
  AND (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name IN ('vehicle_modifications', 'vehicle_modification_categories', 'vehicle_modification_ufs', 'vehicle_modification_documents', 'vehicle_modification_messages')) = 5
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`services` WHERE code = 'LOWERED_SUSPENSION' AND name = 'Regularização de suspensão') = 1
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`vehicle_modifications`) >= 27
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_form_fields` f JOIN `u891593158_doc`.`service_versions` v ON v.id = f.service_version_id JOIN `u891593158_doc`.`services` s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' AND f.field_key IN ('wheels.contact_check', 'wheels.diameter_check', 'modifications.additional')) = 3
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`technical_rules` WHERE id IN ('5A000000-0000-4000-8000-000000000005', '5A000000-0000-4000-8000-000000000006', '5A000000-0000-4000-8000-000000000007')) = 3;
