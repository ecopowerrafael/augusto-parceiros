-- Pré-verificação da Migration 003
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Pré-verificação somente leitura da Migration 003.

SELECT DATABASE() AS selected_database;
SELECT VERSION() AS mysql_version;
SELECT COUNT(*) AS migration_003_already_registered FROM `u891593158_doc`.`schema_migrations` WHERE name = '003_complete_engine_service_seed.sql';
SELECT COUNT(*) AS required_tables_present FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name IN ('services', 'service_versions', 'service_form_fields', 'service_field_options', 'service_data_sources', 'service_external_queries', 'service_query_mappings', 'billing_items', 'service_billing_items', 'technical_rules', 'technical_rule_actions', 'schema_migrations');
SELECT COUNT(*) AS compatible_columns_present FROM information_schema.columns WHERE table_schema = 'u891593158_doc' AND ((table_name = 'service_form_fields' AND column_name IN ('calculation', 'visibility_condition', 'data_origin')) OR (table_name = 'service_external_queries' AND column_name IN ('source_id', 'plate_field_key')) OR (table_name = 'service_query_mappings' AND column_name IN ('target_field_key', 'normalized_path')));
SELECT COUNT(*) AS motor_version_present FROM `u891593158_doc`.`service_versions` WHERE id = '33000000-0000-4000-8000-000000000001';
SELECT COUNT(*) AS existing_uf_options FROM `u891593158_doc`.`service_field_options` WHERE field_id = '36000000-0000-4000-8000-000000000003';
SELECT COUNT(*) AS existing_external_queries FROM `u891593158_doc`.`service_external_queries` WHERE service_version_id = '33000000-0000-4000-8000-000000000001';
