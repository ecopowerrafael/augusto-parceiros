-- Pré-verificação da Migration 007
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Pré-verificação somente leitura da Migration 007.
SELECT VERSION() AS mysql_version;
SELECT DATABASE() AS selected_database;
SELECT COUNT(*) AS migration_007_already_registered FROM `u891593158_doc`.`schema_migrations` WHERE name = '007_engine_rules_and_documents.sql';
SELECT COUNT(*) AS application_settings_present FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name = 'application_settings';
SELECT column_name, column_type FROM information_schema.columns WHERE table_schema = 'u891593158_doc' AND table_name = 'application_settings' AND column_name IN ('manual_whatsapp', 'manual_team_name', 'manual_message_template') ORDER BY column_name;
SELECT COUNT(*) AS partial_engine_fields_present FROM `u891593158_doc`.`service_form_fields` WHERE id IN ('36000000-0000-4000-8000-000000000014', '36000000-0000-4000-8000-000000000015');
SELECT COUNT(*) AS category_options_present FROM `u891593158_doc`.`service_field_options` WHERE field_id = '36000000-0000-4000-8000-000000000002' AND option_value IN ('MOTORCYCLE', 'AUTOMOBILE', 'TRUCK', 'BUS', 'OTHER');
SELECT id, field_key, field_type, is_required, visibility_condition, required_condition FROM `u891593158_doc`.`service_form_fields` WHERE service_version_id = '33000000-0000-4000-8000-000000000001' ORDER BY display_order;
SELECT id, code, name, status FROM `u891593158_doc`.`billing_items` WHERE code IN ('MODIFICATION_REQUEST', 'ITL_CSV_INSPECTION');
SELECT sbi.id, bi.code, sbi.billing_mode, sbi.include_in_total, sbi.visible_to_client, sbi.visible_to_partner FROM `u891593158_doc`.`service_billing_items` sbi JOIN `u891593158_doc`.`billing_items` bi ON bi.id = sbi.billing_item_id WHERE sbi.service_version_id = '33000000-0000-4000-8000-000000000001' AND bi.code IN ('MODIFICATION_REQUEST', 'ITL_CSV_INSPECTION');
SELECT id, name, vehicle_category_id, expected_result, status, priority FROM `u891593158_doc`.`technical_rules` WHERE service_version_id = '33000000-0000-4000-8000-000000000001' ORDER BY priority, name;
SELECT document_code, name, requirement_type FROM `u891593158_doc`.`service_documents` WHERE service_version_id = '33000000-0000-4000-8000-000000000001' ORDER BY display_order;
SELECT message_key, severity, condition_expression FROM `u891593158_doc`.`service_messages` WHERE service_version_id = '33000000-0000-4000-8000-000000000001' ORDER BY display_order;
