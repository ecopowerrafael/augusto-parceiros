-- Verificação da Migration 003
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Verificação posterior somente leitura da Migration 003.

SELECT DATABASE() AS selected_database;
SELECT VERSION() AS mysql_version;
SELECT COUNT(*) AS migration_003_count FROM `u891593158_doc`.`schema_migrations` WHERE name = '003_complete_engine_service_seed.sql';
SELECT table_name AS expected_table FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name IN ('services', 'service_versions', 'service_form_fields', 'service_field_options', 'service_data_sources', 'service_external_queries', 'service_query_mappings', 'billing_items', 'service_billing_items', 'technical_rules', 'technical_rule_actions', 'schema_migrations') ORDER BY table_name;
SELECT COUNT(*) AS expected_table_count FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name IN ('services', 'service_versions', 'service_form_fields', 'service_field_options', 'service_data_sources', 'service_external_queries', 'service_query_mappings', 'billing_items', 'service_billing_items', 'technical_rules', 'technical_rule_actions', 'schema_migrations');
SELECT COUNT(*) AS uf_option_count FROM `u891593158_doc`.`service_field_options` WHERE field_id = '36000000-0000-4000-8000-000000000003';
SELECT COUNT(*) AS external_query_count FROM `u891593158_doc`.`service_external_queries` WHERE service_version_id = '33000000-0000-4000-8000-000000000001';
SELECT COUNT(*) AS query_mapping_count FROM `u891593158_doc`.`service_query_mappings` WHERE query_id IN (SELECT id FROM `u891593158_doc`.`service_external_queries` WHERE service_version_id = '33000000-0000-4000-8000-000000000001');
SELECT COUNT(*) AS engine_calculation_count FROM `u891593158_doc`.`service_form_fields` WHERE id = '36000000-0000-4000-8000-000000000013' AND calculation IS NOT NULL;
SELECT COUNT(*) AS csv_catalog_count FROM `u891593158_doc`.`billing_items` WHERE code = 'ITL_CSV_INSPECTION';
SELECT COUNT(*) AS technical_rule_count FROM `u891593158_doc`.`technical_rules` WHERE service_version_id = '33000000-0000-4000-8000-000000000001';
SELECT COUNT(*) AS invalid_query_sources FROM `u891593158_doc`.`service_external_queries` q LEFT JOIN `u891593158_doc`.`service_data_sources` s ON s.id = q.source_id WHERE q.service_version_id = '33000000-0000-4000-8000-000000000001' AND s.id IS NULL;
SELECT COUNT(*) AS invalid_query_mappings FROM `u891593158_doc`.`service_query_mappings` m LEFT JOIN `u891593158_doc`.`service_external_queries` q ON q.id = m.query_id WHERE q.id IS NULL;
SELECT COUNT(*) AS invalid_rule_versions FROM `u891593158_doc`.`technical_rules` r LEFT JOIN `u891593158_doc`.`service_versions` v ON v.id = r.service_version_id WHERE r.service_version_id IS NOT NULL AND v.id IS NULL;
