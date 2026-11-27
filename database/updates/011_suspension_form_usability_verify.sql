-- Verificação da Migration 011
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Verificação posterior da Migration 011; diagnóstica inclusive em execução parcial.
SELECT VERSION() AS mysql_version;
SET @docmotor_verify_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name = 'schema_migrations'), 'SELECT COUNT(*) AS migration_011_count FROM `u891593158_doc`.schema_migrations WHERE name = ''011_suspension_form_usability.sql''', 'SELECT CAST(NULL AS UNSIGNED) AS migration_011_count');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql; EXECUTE docmotor_verify_stmt; DEALLOCATE PREPARE docmotor_verify_stmt;
SELECT f.field_key, f.label FROM `u891593158_doc`.service_form_fields f JOIN `u891593158_doc`.service_versions v ON v.id = f.service_version_id JOIN `u891593158_doc`.services s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' AND f.field_key IN ('suspension.contact_check','wheels.contact_check','suspension.clearance_check','wheels.fender_check','wheels.diameter_check') ORDER BY f.field_key;
SELECT f.field_key, o.option_value, o.option_label FROM `u891593158_doc`.service_field_options o JOIN `u891593158_doc`.service_form_fields f ON f.id = o.field_id JOIN `u891593158_doc`.service_versions v ON v.id = f.service_version_id JOIN `u891593158_doc`.services s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' AND f.field_key IN ('suspension.contact_check','wheels.contact_check','suspension.clearance_check','wheels.fender_check','wheels.diameter_check') ORDER BY f.field_key, o.display_order;
SELECT COUNT(*) AS other_state_manual_rules FROM `u891593158_doc`.technical_rules r JOIN `u891593158_doc`.services s ON s.id = r.service_id WHERE s.code = 'LOWERED_SUSPENSION' AND r.id = '5A000000-0000-4000-8000-000000000008' AND r.expected_result = 'MANUAL_REVIEW' AND r.priority = 1;
SELECT COUNT(*) AS duplicate_migration_rows FROM `u891593158_doc`.schema_migrations WHERE name = '011_suspension_form_usability.sql';
