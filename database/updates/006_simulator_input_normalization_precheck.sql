-- Pré-verificação da Migration 006
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Pré-verificação somente leitura da Migration 006.
SELECT VERSION() AS mysql_version;
SELECT DATABASE() AS selected_database;
SELECT COUNT(*) AS migration_006_already_registered FROM `u891593158_doc`.`schema_migrations` WHERE name = '006_simulator_input_normalization.sql';
SELECT field_key, field_type, unit FROM `u891593158_doc`.`service_form_fields` WHERE field_key IN ('vehicle_target.plate', 'vehicle_target.fuel', 'vehicle_target.engine_cc', 'vehicle_donor.plate', 'vehicle_donor.fuel', 'vehicle_donor.engine_cc') ORDER BY field_key;
SELECT f.field_key, o.option_value, o.option_label FROM `u891593158_doc`.`service_field_options` o JOIN `u891593158_doc`.`service_form_fields` f ON f.id = o.field_id WHERE f.field_key IN ('vehicle_target.fuel', 'vehicle_donor.fuel') ORDER BY f.field_key, o.display_order;
