-- Pré-verificação somente leitura da Migration 012.
SELECT VERSION() AS mysql_version;
SELECT DATABASE() AS selected_database;
SELECT COUNT(*) AS schema_migrations_table_present FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'schema_migrations';
SELECT COUNT(*) AS migration_012_registered FROM __DOCMOTOR_DATABASE__.schema_migrations WHERE name = '012_suspension_checklist_semantics.sql';
SELECT COUNT(*) AS suspension_version_present FROM information_schema.tables t WHERE t.table_schema = DATABASE() AND t.table_name = 'technical_rules';
SELECT id, expected_result, priority, JSON_VALID(conditions) AS conditions_json_valid, conditions
FROM __DOCMOTOR_DATABASE__.technical_rules
WHERE service_version_id = '57000000-0000-4000-8000-000000000001'
  AND id IN ('5A000000-0000-4000-8000-000000000002', '5A000000-0000-4000-8000-000000000006')
ORDER BY id;
