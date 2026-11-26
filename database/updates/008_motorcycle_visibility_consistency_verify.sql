-- Verificação da Migration 008
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Verificação posterior somente leitura da Migration 008.
SELECT VERSION() AS mysql_version;
SELECT DATABASE() AS selected_database;
SELECT COUNT(*) AS migration_008_count FROM `u891593158_doc`.`schema_migrations` WHERE name = '008_motorcycle_visibility_consistency.sql';
SELECT field_key, is_required, visibility_condition, required_condition
FROM `u891593158_doc`.`service_form_fields`
WHERE service_version_id = '33000000-0000-4000-8000-000000000001'
  AND field_key = 'engine.identification_mode';
SELECT COUNT(*) AS motorcycle_mode_not_required
FROM `u891593158_doc`.`service_form_fields`
WHERE service_version_id = '33000000-0000-4000-8000-000000000001'
  AND field_key = 'engine.identification_mode'
  AND is_required = 1
  AND JSON_UNQUOTE(JSON_EXTRACT(visibility_condition, '$.operator')) = 'IN_LIST'
  AND JSON_CONTAINS(JSON_EXTRACT(visibility_condition, '$.values'), JSON_QUOTE('MOTORCYCLE')) = 0;
