-- Verificação da Migration 010
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Verificação posterior somente leitura da Migration 010.
SELECT VERSION() AS mysql_version;
SELECT COUNT(*) AS migration_010_count FROM `u891593158_doc`.`schema_migrations` WHERE name = '010_suspension_modification_catalog.sql';
SELECT code, name, category, status, requires_manual_review, requires_description, legal_status FROM `u891593158_doc`.`vehicle_modifications` ORDER BY display_order, name;
SELECT s.code, s.name, v.version_number, v.status, COUNT(DISTINCT f.id) AS field_count, COUNT(DISTINCT sbi.id) AS billing_item_count, COUNT(DISTINCT r.id) AS rule_count
FROM `u891593158_doc`.`services` s LEFT JOIN `u891593158_doc`.`service_versions` v ON v.service_id = s.id LEFT JOIN `u891593158_doc`.`service_form_fields` f ON f.service_version_id = v.id LEFT JOIN `u891593158_doc`.`service_billing_items` sbi ON sbi.service_version_id = v.id LEFT JOIN `u891593158_doc`.`technical_rules` r ON r.service_version_id = v.id
WHERE s.code = 'LOWERED_SUSPENSION' GROUP BY s.code, s.name, v.version_number, v.status;
SELECT field_key, field_type, is_required, visibility_condition, required_condition FROM `u891593158_doc`.`service_form_fields` f JOIN `u891593158_doc`.`service_versions` v ON v.id = f.service_version_id JOIN `u891593158_doc`.`services` s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' ORDER BY f.display_order;
SELECT field_key, is_required, required_condition FROM `u891593158_doc`.`service_form_fields` f JOIN `u891593158_doc`.`service_versions` v ON v.id = f.service_version_id JOIN `u891593158_doc`.`services` s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' AND f.field_key IN ('suspension.clearance_check', 'suspension.contact_check', 'wheels.compliance', 'wheels.fender_check', 'wheels.contact_check', 'wheels.diameter_check');
SELECT bi.code, bi.name, bi.default_amount_cents, sbi.billing_mode, sbi.quantity_expression, sbi.condition_expression FROM `u891593158_doc`.`service_billing_items` sbi JOIN `u891593158_doc`.`billing_items` bi ON bi.id = sbi.billing_item_id JOIN `u891593158_doc`.`service_versions` v ON v.id = sbi.service_version_id JOIN `u891593158_doc`.`services` s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' ORDER BY sbi.display_order;
SELECT name, expected_result, priority, conditions FROM `u891593158_doc`.`technical_rules` r JOIN `u891593158_doc`.`service_versions` v ON v.id = r.service_version_id JOIN `u891593158_doc`.`services` s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' ORDER BY priority, name;
