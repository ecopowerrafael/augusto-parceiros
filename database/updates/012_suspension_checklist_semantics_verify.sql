-- Verificação da Migration 012
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Verificação posterior somente leitura da Migration 012.
SELECT VERSION() AS mysql_version;
SELECT DATABASE() AS selected_database;
SELECT COUNT(*) AS schema_migrations_table_present FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name = 'schema_migrations';
SELECT COUNT(*) AS migration_012_count FROM `u891593158_doc`.schema_migrations WHERE name = '012_suspension_checklist_semantics.sql';
SELECT COUNT(*) AS corrected_rules_json_count
FROM `u891593158_doc`.technical_rules
WHERE service_version_id = '57000000-0000-4000-8000-000000000001'
  AND id IN ('5A000000-0000-4000-8000-000000000002', '5A000000-0000-4000-8000-000000000006')
  AND JSON_VALID(conditions) = 1
  AND ((id = '5A000000-0000-4000-8000-000000000002' AND JSON_UNQUOTE(JSON_EXTRACT(conditions, '$.any[1].values[0]')) = 'YES')
    OR (id = '5A000000-0000-4000-8000-000000000006' AND JSON_UNQUOTE(JSON_EXTRACT(conditions, '$.all[3].value')) = 'NO'));
SELECT id, conditions FROM `u891593158_doc`.technical_rules WHERE id IN ('5A000000-0000-4000-8000-000000000002', '5A000000-0000-4000-8000-000000000006') ORDER BY id;
