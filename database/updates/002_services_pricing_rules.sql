-- Doc Motor Fase 3: serviços, disponibilidade, preços e regras técnicas.
-- Não contém DROP, não executa alterações no startup e não cria preços.

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
  KEY `idx_rules_lookup` (`service_id`, `vehicle_category_id`, `uf`, `status`, `priority`),
  CONSTRAINT `fk_rules_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_rules_vehicle` FOREIGN KEY (`vehicle_category_id`) REFERENCES `vehicle_categories` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_rules_state` FOREIGN KEY (`uf`) REFERENCES `brazilian_states` (`uf`) ON DELETE RESTRICT,
  CONSTRAINT `fk_rules_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_rules_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
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

-- Políticas preliminares, inativas até validação normativa e configuração administrativa.
INSERT INTO `technical_rules` (`id`, `service_id`, `name`, `description`, `vehicle_category_id`, `conditions`, `technical_limits`, `expected_result`, `status`, `priority`, `version`) VALUES
('32000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000001', 'Motocicleta com mesma cilindrada', 'Política operacional preliminar; não representa garantia legal.', '30000000-0000-4000-8000-000000000001', JSON_OBJECT('displacement', 'equal'), JSON_OBJECT(), 'VIABLE', 'DRAFT', 10, 1),
('32000000-0000-4000-8000-000000000002', '31000000-0000-4000-8000-000000000001', 'Motocicleta com cilindrada diferente', 'Fora dos critérios automatizados preliminares.', '30000000-0000-4000-8000-000000000001', JSON_OBJECT('displacement', 'different'), JSON_OBJECT(), 'OUT_OF_CRITERIA', 'DRAFT', 20, 1),
('32000000-0000-4000-8000-000000000003', '31000000-0000-4000-8000-000000000001', 'Automóvel com mesma potência e cilindrada', 'Sujeito às demais exigências documentais.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('power', 'equal', 'displacement', 'equal'), JSON_OBJECT(), 'VIABLE', 'DRAFT', 10, 1),
('32000000-0000-4000-8000-000000000004', '31000000-0000-4000-8000-000000000001', 'Automóvel com alteração de potência até 10%', 'Política preliminar com análise de modificação e exigências complementares.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('power', 'higher_or_lower'), JSON_OBJECT('max_increase_percent', 10), 'VIABLE_WITH_REQUIREMENTS', 'DRAFT', 20, 1),
('32000000-0000-4000-8000-000000000005', '31000000-0000-4000-8000-000000000001', 'Automóvel com aumento superior a 10%', 'Fora dos critérios automatizados preliminares.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('power', 'higher'), JSON_OBJECT('max_increase_percent', 10), 'OUT_OF_CRITERIA', 'DRAFT', 30, 1),
('32000000-0000-4000-8000-000000000006', '31000000-0000-4000-8000-000000000001', 'Automóvel com dados técnicos insuficientes', 'Encaminhar para análise manual.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('data', 'insufficient'), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 40, 1),
('32000000-0000-4000-8000-000000000007', '31000000-0000-4000-8000-000000000001', 'Caminhão com alteração técnica', 'Sem limite operacional fixo; CSV e demais exigências pendentes de validação.', '30000000-0000-4000-8000-000000000004', JSON_OBJECT('technical_change', 'present'), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 10, 1),
('32000000-0000-4000-8000-000000000008', '31000000-0000-4000-8000-000000000001', 'Outras categorias', 'Análise manual até definição de regra específica.', '30000000-0000-4000-8000-000000000006', JSON_OBJECT(), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 100, 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `updated_at` = CURRENT_TIMESTAMP;

INSERT INTO `schema_migrations` (`name`)
SELECT '002_services_pricing_rules.sql'
FROM `information_schema`.`tables`
WHERE `table_schema` = DATABASE()
  AND `table_name` IN ('brazilian_states', 'vehicle_categories', 'services', 'service_vehicle_categories', 'service_ufs', 'service_relations', 'price_tables', 'service_prices', 'service_price_components', 'technical_rules', 'technical_rule_services')
GROUP BY `table_schema`
HAVING COUNT(*) = 11
   AND NOT EXISTS (SELECT 1 FROM `schema_migrations` WHERE `name` = '002_services_pricing_rules.sql');

