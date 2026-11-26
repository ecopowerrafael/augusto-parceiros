-- Pré-verificação da Migration 009
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Pré-verificação somente leitura da Migration 009.
SELECT VERSION() AS mysql_version;
SELECT COUNT(*) AS migration_009_already_registered FROM `u891593158_doc`.`schema_migrations` WHERE name = '009_simulator_final_visibility.sql';
SELECT COUNT(*) AS required_fields_present FROM `u891593158_doc`.`service_form_fields`
WHERE service_version_id = '33000000-0000-4000-8000-000000000001'
  AND field_key IN ('vehicle_donor.plate', 'vehicle_donor.power_cv', 'vehicle_donor.engine_cc', 'vehicle_donor.fuel', 'motorcycle.compatibility_declaration');
SELECT COUNT(*) AS migration_008_registered FROM `u891593158_doc`.`schema_migrations` WHERE name = '008_motorcycle_visibility_consistency.sql';
