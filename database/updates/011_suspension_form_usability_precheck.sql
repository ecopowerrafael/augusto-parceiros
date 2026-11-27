-- Pré-verificação da Migration 011
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Pré-verificação somente leitura da Migration 011.
SELECT VERSION() AS mysql_version;
SELECT DATABASE() AS selected_database;
SELECT COUNT(*) AS schema_migrations_table_present FROM information_schema.tables t WHERE t.table_schema = 'u891593158_doc' AND t.table_name = 'schema_migrations';
SET @docmotor_precheck_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name = 'schema_migrations'), 'SELECT COUNT(*) AS migration_011_registered FROM `u891593158_doc`.schema_migrations WHERE name = ''011_suspension_form_usability.sql''', 'SELECT CAST(NULL AS UNSIGNED) AS migration_011_registered');
PREPARE docmotor_precheck_stmt FROM @docmotor_precheck_sql; EXECUTE docmotor_precheck_stmt; DEALLOCATE PREPARE docmotor_precheck_stmt;
SELECT table_name, table_rows FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name IN ('services','service_versions','service_form_fields','service_field_options','technical_rules','schema_migrations');
SELECT COUNT(*) AS required_fields_present FROM information_schema.columns WHERE table_schema = 'u891593158_doc' AND table_name = 'service_form_fields' AND column_name IN ('field_key','label','updated_at');
SELECT COUNT(*) AS suspension_service_present FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name = 'services';
