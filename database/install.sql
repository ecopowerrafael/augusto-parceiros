-- Doc Motor — instalação manual da estrutura da Fase 2
-- Importar no banco selecionado pelo phpMyAdmin.
-- Este arquivo não executa DROP, não cria administrador e não executa migrations.

CREATE TABLE IF NOT EXISTS `schema_migrations` (
  `name` VARCHAR(255) NOT NULL PRIMARY KEY,
  `applied_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `users` (
  `id` CHAR(36) NOT NULL PRIMARY KEY,
  `role` VARCHAR(24) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'ACTIVE',
  `name` VARCHAR(180) NOT NULL,
  `cpf` VARCHAR(14) NULL,
  `email` VARCHAR(255) NOT NULL,
  `whatsapp` VARCHAR(30) NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `terms_accepted_at` DATETIME NULL,
  `privacy_acknowledged_at` DATETIME NULL,
  `approved_at` DATETIME NULL,
  `approved_by` CHAR(36) NULL,
  `last_login_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_users_email` (`email`),
  UNIQUE KEY `uq_users_cpf` (`cpf`),
  KEY `idx_users_role_status` (`role`, `status`),
  CONSTRAINT `fk_users_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `partner_companies` (
  `id` CHAR(36) NOT NULL PRIMARY KEY,
  `person_type` VARCHAR(2) NOT NULL,
  `legal_name` VARCHAR(180) NOT NULL,
  `trade_name` VARCHAR(180) NULL,
  `cpf_cnpj` VARCHAR(18) NOT NULL,
  `responsible_name` VARCHAR(180) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `whatsapp` VARCHAR(30) NOT NULL,
  `zip_code` VARCHAR(10) NULL,
  `address` VARCHAR(180) NULL,
  `address_number` VARCHAR(20) NULL,
  `complement` VARCHAR(120) NULL,
  `neighborhood` VARCHAR(120) NULL,
  `city` VARCHAR(120) NULL,
  `state` CHAR(2) NULL,
  `segment` VARCHAR(80) NOT NULL,
  `status` VARCHAR(24) NOT NULL DEFAULT 'PENDING',
  `rejection_reason` VARCHAR(500) NULL,
  `approved_at` DATETIME NULL,
  `approved_by` CHAR(36) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_partner_cpf_cnpj` (`cpf_cnpj`),
  KEY `idx_partner_status_created` (`status`, `created_at`),
  CONSTRAINT `fk_partner_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `company_members` (
  `company_id` CHAR(36) NOT NULL,
  `user_id` CHAR(36) NOT NULL,
  `company_role` VARCHAR(24) NOT NULL DEFAULT 'COLLABORATOR',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`company_id`, `user_id`),
  KEY `idx_members_user` (`user_id`),
  CONSTRAINT `fk_members_company` FOREIGN KEY (`company_id`) REFERENCES `partner_companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_members_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `client_profiles` (
  `user_id` CHAR(36) NOT NULL PRIMARY KEY,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_client_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sessions` (
  `id` CHAR(36) NOT NULL PRIMARY KEY,
  `user_id` CHAR(36) NOT NULL,
  `token_hash` CHAR(64) NOT NULL,
  `csrf_token_hash` CHAR(64) NOT NULL,
  `expires_at` DATETIME NOT NULL,
  `revoked_at` DATETIME NULL,
  `user_agent` VARCHAR(500) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_sessions_token` (`token_hash`),
  KEY `idx_sessions_user_active` (`user_id`, `revoked_at`, `expires_at`),
  CONSTRAINT `fk_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `password_reset_tokens` (
  `id` CHAR(36) NOT NULL PRIMARY KEY,
  `user_id` CHAR(36) NOT NULL,
  `token_hash` CHAR(64) NOT NULL,
  `expires_at` DATETIME NOT NULL,
  `used_at` DATETIME NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_reset_token` (`token_hash`),
  KEY `idx_reset_user` (`user_id`, `expires_at`),
  CONSTRAINT `fk_reset_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `rate_limit_events` (
  `bucket_key` VARCHAR(180) NOT NULL,
  `window_started_at` DATETIME NOT NULL,
  `attempts` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`bucket_key`, `window_started_at`),
  KEY `idx_rate_limit_window` (`window_started_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `actor_user_id` CHAR(36) NULL,
  `action` VARCHAR(80) NOT NULL,
  `entity_type` VARCHAR(80) NOT NULL,
  `entity_id` CHAR(36) NULL,
  `metadata` JSON NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_audit_actor_created` (`actor_user_id`, `created_at`),
  KEY `idx_audit_entity_created` (`entity_type`, `entity_id`, `created_at`),
  CONSTRAINT `fk_audit_actor` FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Registra a migration somente se as oito tabelas da Fase 2 existirem.
INSERT INTO `schema_migrations` (`name`)
SELECT '001_initial.sql'
FROM `information_schema`.`tables`
WHERE `table_schema` = DATABASE()
  AND `table_name` IN ('users', 'partner_companies', 'company_members', 'client_profiles', 'sessions', 'password_reset_tokens', 'rate_limit_events', 'audit_logs')
GROUP BY `table_schema`
HAVING COUNT(*) = 8
   AND NOT EXISTS (SELECT 1 FROM `schema_migrations` WHERE `name` = '001_initial.sql');

-- Doc Motor Fase 3.1: catálogo no-code de serviços, formulários, cobranças e regras.
-- Manual pelo phpMyAdmin. Não contém DROP, não executa alterações no startup e não cria preços publicados.

CREATE TABLE IF NOT EXISTS `brazilian_states` (
  `uf` CHAR(2) NOT NULL PRIMARY KEY,
  `name` VARCHAR(80) NOT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `vehicle_categories` (
  `id` CHAR(36) NOT NULL PRIMARY KEY,
  `code` VARCHAR(40) NOT NULL,
  `name` VARCHAR(80) NOT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_vehicle_categories_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `services` (
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
  CONSTRAINT `fk_services_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_services_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `service_vehicle_categories` (
  `service_id` CHAR(36) NOT NULL,
  `vehicle_category_id` CHAR(36) NOT NULL,
  PRIMARY KEY (`service_id`, `vehicle_category_id`),
  CONSTRAINT `fk_svc_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_svc_vehicle_category` FOREIGN KEY (`vehicle_category_id`) REFERENCES `vehicle_categories` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `service_ufs` (
  `service_id` CHAR(36) NOT NULL,
  `uf` CHAR(2) NOT NULL,
  `is_available` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`service_id`, `uf`),
  CONSTRAINT `fk_service_ufs_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_service_ufs_state` FOREIGN KEY (`uf`) REFERENCES `brazilian_states` (`uf`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `service_relations` (
  `service_id` CHAR(36) NOT NULL,
  `related_service_id` CHAR(36) NOT NULL,
  `relation_type` VARCHAR(24) NOT NULL,
  `condition_description` VARCHAR(500) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`service_id`, `related_service_id`),
  CONSTRAINT `fk_service_relations_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_service_relations_related` FOREIGN KEY (`related_service_id`) REFERENCES `services` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS service_versions (
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
  CONSTRAINT fk_service_versions_service FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE CASCADE,
  CONSTRAINT fk_service_versions_source FOREIGN KEY (source_version_id) REFERENCES service_versions (id) ON DELETE SET NULL,
  CONSTRAINT fk_service_versions_created_by FOREIGN KEY (created_by) REFERENCES users (id) ON DELETE SET NULL,
  CONSTRAINT fk_service_versions_updated_by FOREIGN KEY (updated_by) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS service_form_sections (
  id CHAR(36) NOT NULL PRIMARY KEY, service_version_id CHAR(36) NOT NULL, stable_key VARCHAR(80) NOT NULL,
  label VARCHAR(180) NOT NULL, description VARCHAR(500) NULL, display_order INT NOT NULL DEFAULT 0, visibility_condition JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_form_sections_key (service_version_id, stable_key),
  CONSTRAINT fk_form_sections_version FOREIGN KEY (service_version_id) REFERENCES service_versions (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS service_form_fields (
  id CHAR(36) NOT NULL PRIMARY KEY, service_version_id CHAR(36) NOT NULL, section_id CHAR(36) NULL, field_key VARCHAR(100) NOT NULL,
  label VARCHAR(180) NOT NULL, description VARCHAR(500) NULL, placeholder VARCHAR(180) NULL, field_type VARCHAR(32) NOT NULL,
  default_value JSON NULL, unit VARCHAR(32) NULL, is_required TINYINT(1) NOT NULL DEFAULT 0, is_editable TINYINT(1) NOT NULL DEFAULT 1,
  min_value DECIMAL(18,6) NULL, max_value DECIMAL(18,6) NULL, display_order INT NOT NULL DEFAULT 0,
  visibility_condition JSON NULL, required_condition JSON NULL, editability_condition JSON NULL, data_origin VARCHAR(24) NOT NULL DEFAULT 'MANUAL',
  source_path VARCHAR(180) NULL, calculation JSON NULL, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_form_fields_key (service_version_id, field_key),
  KEY idx_form_fields_order (service_version_id, display_order),
  CONSTRAINT fk_form_fields_version FOREIGN KEY (service_version_id) REFERENCES service_versions (id) ON DELETE CASCADE,
  CONSTRAINT fk_form_fields_section FOREIGN KEY (section_id) REFERENCES service_form_sections (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS service_field_options (
  id CHAR(36) NOT NULL PRIMARY KEY, field_id CHAR(36) NOT NULL, option_value VARCHAR(120) NOT NULL, option_label VARCHAR(180) NOT NULL,
  display_order INT NOT NULL DEFAULT 0, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_field_options_value (field_id, option_value),
  CONSTRAINT fk_field_options_field FOREIGN KEY (field_id) REFERENCES service_form_fields (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS service_data_sources (
  id CHAR(36) NOT NULL PRIMARY KEY, code VARCHAR(60) NOT NULL, name VARCHAR(180) NOT NULL, provider_type VARCHAR(32) NOT NULL,
  status VARCHAR(16) NOT NULL DEFAULT 'SIMULATED', supported_fields JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_data_sources_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS service_external_queries (
  id CHAR(36) NOT NULL PRIMARY KEY, service_version_id CHAR(36) NOT NULL, source_id CHAR(36) NOT NULL, query_key VARCHAR(80) NOT NULL,
  label VARCHAR(180) NOT NULL, context_key VARCHAR(80) NOT NULL, plate_field_key VARCHAR(100) NULL, is_required TINYINT(1) NOT NULL DEFAULT 0,
  is_enabled TINYINT(1) NOT NULL DEFAULT 1, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_external_queries_key (service_version_id, query_key),
  CONSTRAINT fk_external_queries_version FOREIGN KEY (service_version_id) REFERENCES service_versions (id) ON DELETE CASCADE,
  CONSTRAINT fk_external_queries_source FOREIGN KEY (source_id) REFERENCES service_data_sources (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS service_query_mappings (
  id CHAR(36) NOT NULL PRIMARY KEY, query_id CHAR(36) NOT NULL, target_field_key VARCHAR(100) NOT NULL, normalized_path VARCHAR(180) NOT NULL,
  data_origin VARCHAR(24) NOT NULL DEFAULT 'EXTERNAL', created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_query_mappings_path (query_id, target_field_key, normalized_path),
  CONSTRAINT fk_query_mappings_query FOREIGN KEY (query_id) REFERENCES service_external_queries (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `price_tables` (
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
  CONSTRAINT `fk_price_tables_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_price_tables_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS billing_items (
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
  CONSTRAINT fk_billing_items_state FOREIGN KEY (uf) REFERENCES brazilian_states (uf) ON DELETE RESTRICT,
  CONSTRAINT fk_billing_items_vehicle FOREIGN KEY (vehicle_category_id) REFERENCES vehicle_categories (id) ON DELETE RESTRICT,
  CONSTRAINT fk_billing_items_partner FOREIGN KEY (partner_company_id) REFERENCES partner_companies (id) ON DELETE RESTRICT,
  CONSTRAINT fk_billing_items_created_by FOREIGN KEY (created_by) REFERENCES users (id) ON DELETE SET NULL,
  CONSTRAINT fk_billing_items_updated_by FOREIGN KEY (updated_by) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS service_billing_items (
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
  CONSTRAINT fk_service_billing_items_version FOREIGN KEY (service_version_id) REFERENCES service_versions (id) ON DELETE CASCADE,
  CONSTRAINT fk_service_billing_items_item FOREIGN KEY (billing_item_id) REFERENCES billing_items (id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `service_prices` (
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
  CONSTRAINT `fk_service_prices_table` FOREIGN KEY (`price_table_id`) REFERENCES `price_tables` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_service_prices_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_service_prices_partner` FOREIGN KEY (`partner_company_id`) REFERENCES `partner_companies` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_service_prices_vehicle` FOREIGN KEY (`vehicle_category_id`) REFERENCES `vehicle_categories` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_service_prices_state` FOREIGN KEY (`uf`) REFERENCES `brazilian_states` (`uf`) ON DELETE RESTRICT,
  CONSTRAINT `fk_service_prices_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_service_prices_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `service_price_components` (
  `id` CHAR(36) NOT NULL PRIMARY KEY,
  `service_price_id` CHAR(36) NOT NULL,
  `component_type` VARCHAR(40) NOT NULL,
  `charge_mode` VARCHAR(24) NOT NULL,
  `amount_cents` BIGINT UNSIGNED NULL,
  `notes` VARCHAR(500) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_price_components_price` (`service_price_id`),
  CONSTRAINT `fk_price_components_price` FOREIGN KEY (`service_price_id`) REFERENCES `service_prices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `technical_rules` (
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
  CONSTRAINT `fk_rules_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_rules_version` FOREIGN KEY (`service_version_id`) REFERENCES `service_versions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_rules_vehicle` FOREIGN KEY (`vehicle_category_id`) REFERENCES `vehicle_categories` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_rules_state` FOREIGN KEY (`uf`) REFERENCES `brazilian_states` (`uf`) ON DELETE RESTRICT,
  CONSTRAINT `fk_rules_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_rules_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS technical_rule_actions (
  id CHAR(36) NOT NULL PRIMARY KEY,
  technical_rule_id CHAR(36) NOT NULL,
  action_type VARCHAR(40) NOT NULL,
  target_key VARCHAR(180) NULL,
  payload JSON NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_rule_actions_order (technical_rule_id, display_order),
  CONSTRAINT fk_rule_actions_rule FOREIGN KEY (technical_rule_id) REFERENCES technical_rules (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS service_documents (
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
  CONSTRAINT fk_service_documents_version FOREIGN KEY (service_version_id) REFERENCES service_versions (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS service_messages (
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
  CONSTRAINT fk_service_messages_version FOREIGN KEY (service_version_id) REFERENCES service_versions (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `technical_rule_services` (
  `technical_rule_id` CHAR(36) NOT NULL,
  `service_id` CHAR(36) NOT NULL,
  `relation_type` VARCHAR(24) NOT NULL DEFAULT 'CONDITIONAL',
  PRIMARY KEY (`technical_rule_id`, `service_id`),
  CONSTRAINT `fk_rule_services_rule` FOREIGN KEY (`technical_rule_id`) REFERENCES `technical_rules` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rule_services_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `brazilian_states` (`uf`, `name`) VALUES
('AC', 'Acre'), ('AL', 'Alagoas'), ('AP', 'Amapá'), ('AM', 'Amazonas'), ('BA', 'Bahia'), ('CE', 'Ceará'), ('DF', 'Distrito Federal'), ('ES', 'Espírito Santo'), ('GO', 'Goiás'), ('MA', 'Maranhão'), ('MT', 'Mato Grosso'), ('MS', 'Mato Grosso do Sul'), ('MG', 'Minas Gerais'), ('PA', 'Pará'), ('PB', 'Paraíba'), ('PR', 'Paraná'), ('PE', 'Pernambuco'), ('PI', 'Piauí'), ('RJ', 'Rio de Janeiro'), ('RN', 'Rio Grande do Norte'), ('RS', 'Rio Grande do Sul'), ('RO', 'Rondônia'), ('RR', 'Roraima'), ('SC', 'Santa Catarina'), ('SP', 'São Paulo'), ('SE', 'Sergipe'), ('TO', 'Tocantins')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `vehicle_categories` (`id`, `code`, `name`) VALUES
('30000000-0000-4000-8000-000000000001', 'MOTORCYCLE', 'Motocicleta'),
('30000000-0000-4000-8000-000000000002', 'AUTOMOBILE', 'Automóvel'),
('30000000-0000-4000-8000-000000000003', 'PICKUP', 'Caminhonete'),
('30000000-0000-4000-8000-000000000004', 'TRUCK', 'Caminhão'),
('30000000-0000-4000-8000-000000000005', 'BUS', 'Ônibus'),
('30000000-0000-4000-8000-000000000006', 'OTHER', 'Outros')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `services` (`id`, `code`, `name`, `slug`, `short_description`, `category`, `service_type`, `display_order`) VALUES
('31000000-0000-4000-8000-000000000001', 'ENGINE_REGISTRATION', 'Cadastro de motor', 'cadastro-de-motor', 'Regularização documental de motor substituído.', 'Documentação veicular', 'MAIN', 10),
('31000000-0000-4000-8000-000000000002', 'LOWERED_SUSPENSION', 'Regularização de suspensão rebaixada', 'regularizacao-de-suspensao-rebaixada', 'Orientação para veículos com suspensão modificada.', 'Modificações veiculares', 'MAIN', 20),
('31000000-0000-4000-8000-000000000003', 'WHEELS_TIRES', 'Regularização de pneus e rodas', 'regularizacao-de-pneus-e-rodas', 'Análise documental de alterações em rodas e pneus.', 'Modificações veiculares', 'MAIN', 30),
('31000000-0000-4000-8000-000000000004', 'VEHICLE_MODIFICATIONS', 'Regularização de modificações veiculares', 'regularizacao-de-modificacoes-veiculares', 'Avaliação de alterações nas características originais.', 'Modificações veiculares', 'MAIN', 40),
('31000000-0000-4000-8000-000000000005', 'MODIFICATION_AUTHORIZATION', 'Solicitação de autorização para modificação', 'solicitacao-de-autorizacao-para-modificacao', 'Serviço complementar sujeito à análise.', 'Serviços complementares', 'COMPLEMENTARY', 50),
('31000000-0000-4000-8000-000000000006', 'ITL_CSV_INSPECTION', 'Inspeção veicular / CSV', 'inspecao-veicular-csv', 'Serviço complementar de inspeção, quando aplicável.', 'Serviços complementares', 'COMPLEMENTARY', 60)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `slug` = VALUES(`slug`), `updated_at` = CURRENT_TIMESTAMP;

INSERT INTO `service_relations` (`service_id`, `related_service_id`, `relation_type`, `condition_description`) VALUES
('31000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000005', 'CONDITIONAL', 'Sujeito à análise técnica e administrativa.'),
('31000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000006', 'CONDITIONAL', 'Sujeito à exigência aplicável ao caso.')
ON DUPLICATE KEY UPDATE `relation_type` = VALUES(`relation_type`), `condition_description` = VALUES(`condition_description`);

INSERT INTO service_versions (id, service_id, version_number, status, change_summary)
VALUES ('33000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000001', 1, 'DRAFT', 'Configuração inicial no-code para validação administrativa.')
ON DUPLICATE KEY UPDATE change_summary = VALUES(change_summary), updated_at = CURRENT_TIMESTAMP;

-- Políticas preliminares, inativas até validação normativa e configuração administrativa.
INSERT INTO technical_rules (id, service_id, service_version_id, name, description, vehicle_category_id, conditions, technical_limits, expected_result, status, priority, version) VALUES
('32000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Motocicleta com mesma cilindrada', 'Política operacional preliminar; não representa garantia legal.', '30000000-0000-4000-8000-000000000001', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.engine_cc', 'operator', 'EQUALS', 'valueField', 'vehicle_donor.engine_cc'))), JSON_OBJECT(), 'VIABLE', 'DRAFT', 10, 1),
('32000000-0000-4000-8000-000000000002', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Motocicleta com cilindrada diferente', 'Fora dos critérios automatizados preliminares.', '30000000-0000-4000-8000-000000000001', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.engine_cc', 'operator', 'NOT_EQUALS', 'valueField', 'vehicle_donor.engine_cc'))), JSON_OBJECT(), 'OUT_OF_CRITERIA', 'DRAFT', 20, 1),
('32000000-0000-4000-8000-000000000003', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com mesma potência e cilindrada', 'Sujeito às demais exigências documentais.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.power_cv', 'operator', 'EQUALS', 'valueField', 'vehicle_donor.power_cv'), JSON_OBJECT('field', 'vehicle_target.engine_cc', 'operator', 'EQUALS', 'valueField', 'vehicle_donor.engine_cc'))), JSON_OBJECT(), 'VIABLE', 'DRAFT', 10, 1),
('32000000-0000-4000-8000-000000000004', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com alteração de potência até 10%', 'Política preliminar com análise de modificação e exigências complementares.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'GREATER_THAN', 'value', 0), JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'LESS_OR_EQUAL', 'value', 10))), JSON_OBJECT('max_increase_percent', 10), 'VIABLE_WITH_REQUIREMENTS', 'DRAFT', 20, 1),
('32000000-0000-4000-8000-000000000005', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com aumento superior a 10%', 'Fora dos critérios automatizados preliminares.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'GREATER_THAN', 'value', 10))), JSON_OBJECT('max_increase_percent', 10), 'OUT_OF_CRITERIA', 'DRAFT', 30, 1),
('32000000-0000-4000-8000-000000000006', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com dados técnicos insuficientes', 'Encaminhar para análise manual.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('any', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.power_cv', 'operator', 'EMPTY'), JSON_OBJECT('field', 'vehicle_donor.power_cv', 'operator', 'EMPTY'))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 40, 1),
('32000000-0000-4000-8000-000000000007', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Caminhão com alteração técnica', 'Sem limite operacional fixo; CSV e demais exigências pendentes de validação.', '30000000-0000-4000-8000-000000000004', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'EQUALS', 'value', 'TRUCK'))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 10, 1),
('32000000-0000-4000-8000-000000000008', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Outras categorias', 'Análise manual até definição de regra específica.', '30000000-0000-4000-8000-000000000006', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'EQUALS', 'value', 'OTHER'))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 100, 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), updated_at = CURRENT_TIMESTAMP;

INSERT INTO service_data_sources (id, code, name, provider_type, status, supported_fields)
VALUES ('34000000-0000-4000-8000-000000000001', 'VEHICLE_PROVIDER_PENDING', 'Consulta veicular — provedor a definir', 'VEHICLE_API', 'SIMULATED', JSON_ARRAY('vehicle_target.category', 'vehicle_target.state', 'vehicle_target.power_cv', 'vehicle_target.engine_cc', 'vehicle_target.fuel', 'vehicle_donor.power_cv', 'vehicle_donor.engine_cc', 'vehicle_donor.fuel'))
ON DUPLICATE KEY UPDATE name = VALUES(name), status = VALUES(status), supported_fields = VALUES(supported_fields);

INSERT INTO service_form_sections (id, service_version_id, stable_key, label, description, display_order)
VALUES ('35000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'vehicle_target', 'Veículo que receberá o motor', 'Dados do veículo principal.', 10),
       ('35000000-0000-4000-8000-000000000002', '33000000-0000-4000-8000-000000000001', 'engine_origin', 'Motor de origem', 'Identificação e dados técnicos do motor.', 20)
ON DUPLICATE KEY UPDATE label = VALUES(label), description = VALUES(description), display_order = VALUES(display_order);

INSERT INTO service_form_fields (id, service_version_id, section_id, field_key, label, field_type, is_required, display_order, data_origin)
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

INSERT INTO service_field_options (id, field_id, option_value, option_label, display_order)
VALUES ('37000000-0000-4000-8000-000000000001', '36000000-0000-4000-8000-000000000002', 'MOTORCYCLE', 'Motocicleta', 10),
       ('37000000-0000-4000-8000-000000000002', '36000000-0000-4000-8000-000000000002', 'AUTOMOBILE', 'Automóvel', 20),
       ('37000000-0000-4000-8000-000000000003', '36000000-0000-4000-8000-000000000002', 'TRUCK', 'Caminhão', 30),
       ('37000000-0000-4000-8000-000000000004', '36000000-0000-4000-8000-000000000002', 'OTHER', 'Outra categoria', 40),
       ('37000000-0000-4000-8000-000000000005', '36000000-0000-4000-8000-000000000008', 'PLATE', 'Consultar pela placa', 10),
       ('37000000-0000-4000-8000-000000000006', '36000000-0000-4000-8000-000000000008', 'MANUAL', 'Informar dados manualmente', 20)
ON DUPLICATE KEY UPDATE option_label = VALUES(option_label), display_order = VALUES(display_order);

INSERT INTO billing_items (id, code, name, description, financial_category, default_amount_cents, status, charge_nature, amount_status, payment_mode, is_public_fee)
VALUES ('39000000-0000-0000-8000-000000000001', 'TRANSFER_FEE', 'Taxa de transferência', 'Valor comercial informado pelo proprietário; confirmar vigência e natureza antes da publicação.', 'DOCUMENTATION', 29580, 'DRAFT', 'PUBLIC_FEE', 'INFORMED', 'CLIENT_DIRECT', 0),
       ('39000000-0000-0000-8000-000000000002', 'SERVICE_FEE', 'Honorário', 'Honorário comercial informado pelo proprietário.', 'HONORARY', 16000, 'DRAFT', 'HONORARY', 'INFORMED', 'DOC_MOTOR', 0),
       ('39000000-0000-0000-8000-000000000003', 'ENGINE_REGISTRATION', 'Cadastro de motor', 'Serviço próprio informado pelo proprietário.', 'ENGINE', 30000, 'DRAFT', 'OWN_SERVICE', 'INFORMED', 'DOC_MOTOR', 0),
       ('39000000-0000-0000-8000-000000000004', 'ENGINE_NO_INVOICE', 'Adicional sem nota fiscal', 'Aplicável somente quando configurado pela regra do serviço.', 'ENGINE', 30000, 'DRAFT', 'OWN_SERVICE', 'INFORMED', 'DOC_MOTOR', 0),
       ('39000000-0000-0000-8000-000000000005', 'MERCOSUR_PLATE_AUTHORIZATION', 'Autorização de emplacamento Mercosul', 'Aplicabilidade depende do padrão da placa principal e confirmação administrativa.', 'DOCUMENTATION', 22000, 'DRAFT', 'ADDITIONAL_EXPENSE', 'INFORMED', 'CLIENT_DIRECT', 0),
       ('39000000-0000-0000-8000-000000000006', 'MODIFICATION_REQUEST', 'Solicitação de modificação', 'Aplicabilidade depende da categoria e da regra técnica publicada.', 'TECHNICAL', 30000, 'DRAFT', 'OWN_SERVICE', 'INFORMED', 'DOC_MOTOR', 0)
ON DUPLICATE KEY UPDATE name = VALUES(name), default_amount_cents = VALUES(default_amount_cents), updated_at = CURRENT_TIMESTAMP;

INSERT INTO service_billing_items (id, service_version_id, billing_item_id, billing_mode, display_order, condition_expression)
VALUES ('38000000-0000-0000-8000-000000000001', '33000000-0000-4000-8000-000000000001', '39000000-0000-0000-8000-000000000001', 'REQUIRED', 10, NULL),
       ('38000000-0000-0000-8000-000000000002', '33000000-0000-4000-8000-000000000001', '39000000-0000-0000-8000-000000000002', 'REQUIRED', 20, NULL),
       ('38000000-0000-0000-8000-000000000003', '33000000-0000-4000-8000-000000000001', '39000000-0000-0000-8000-000000000003', 'REQUIRED', 30, NULL),
       ('38000000-0000-0000-8000-000000000004', '33000000-0000-4000-8000-000000000001', '39000000-0000-0000-8000-000000000004', 'CONDITIONAL', 40, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.has_invoice', 'operator', 'EQUALS', 'value', 'NO')))),
       ('38000000-0000-0000-8000-000000000005', '33000000-0000-4000-8000-000000000001', '39000000-0000-0000-8000-000000000005', 'CONDITIONAL', 50, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.plate_pattern', 'operator', 'EQUALS', 'value', 'OLD')))),
       ('38000000-0000-0000-8000-000000000006', '33000000-0000-4000-8000-000000000001', '39000000-0000-0000-8000-000000000006', 'CONDITIONAL', 60, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'GREATER_THAN', 'value', 0), JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'LESS_OR_EQUAL', 'value', 10))))
ON DUPLICATE KEY UPDATE billing_mode = VALUES(billing_mode), condition_expression = VALUES(condition_expression);

INSERT INTO service_documents (id, service_version_id, document_code, name, requirement_type, condition_expression, display_order)
VALUES ('3A000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'ENGINE_INVOICE', 'Nota fiscal do motor', 'CONDITIONAL', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.has_invoice', 'operator', 'EQUALS', 'value', 'YES'))), 10),
       ('3A000000-0000-4000-8000-000000000002', '33000000-0000-4000-8000-000000000001', 'VEHICLE_REGISTRATION', 'CRLV-e do veículo', 'REQUIRED', NULL, 20)
ON DUPLICATE KEY UPDATE name = VALUES(name), requirement_type = VALUES(requirement_type), condition_expression = VALUES(condition_expression);

INSERT INTO technical_rule_actions (id, technical_rule_id, action_type, target_key, payload, display_order)
VALUES ('3B000000-0000-4000-8000-000000000001', '32000000-0000-4000-8000-000000000004', 'ADD_BILLING_ITEM', 'MODIFICATION_REQUEST', JSON_OBJECT('billingMode', 'CONDITIONAL'), 10),
       ('3B000000-0000-4000-8000-000000000002', '32000000-0000-4000-8000-000000000004', 'ADD_BILLING_ITEM', 'ITL_CSV_INSPECTION', JSON_OBJECT('valueStatus', 'NOT_DEFINED'), 20),
       ('3B000000-0000-4000-8000-000000000003', '32000000-0000-4000-8000-000000000005', 'BLOCK_AUTOMATED_QUOTE', NULL, JSON_OBJECT('reason', 'Aumento superior a 10%'), 10),
       ('3B000000-0000-4000-8000-000000000004', '32000000-0000-4000-8000-000000000006', 'MANUAL_REVIEW', NULL, JSON_OBJECT('reason', 'Dados técnicos insuficientes'), 10)
ON DUPLICATE KEY UPDATE action_type = VALUES(action_type), payload = VALUES(payload), display_order = VALUES(display_order);

INSERT INTO `schema_migrations` (`name`)
SELECT '002_services_pricing_rules.sql'
FROM `information_schema`.`tables`
WHERE `table_schema` = DATABASE()
  AND `table_name` IN ('brazilian_states', 'vehicle_categories', 'services', 'service_vehicle_categories', 'service_ufs', 'service_relations', 'service_versions', 'service_form_sections', 'service_form_fields', 'service_field_options', 'service_data_sources', 'service_external_queries', 'service_query_mappings', 'price_tables', 'billing_items', 'service_prices', 'service_price_components', 'service_billing_items', 'technical_rules', 'technical_rule_actions', 'technical_rule_services', 'service_documents', 'service_messages')
GROUP BY `table_schema`
HAVING COUNT(*) = 23
   AND NOT EXISTS (SELECT 1 FROM `schema_migrations` WHERE `name` = '002_services_pricing_rules.sql');
