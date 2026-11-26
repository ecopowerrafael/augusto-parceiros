-- Pré-verificação da Migration 008
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Pré-verificação somente leitura da Migration 008.
SELECT VERSION() AS mysql_version;
SELECT DATABASE() AS selected_database;
SELECT COUNT(*) AS migration_008_already_registered FROM `u891593158_doc`.`schema_migrations` WHERE name = '008_motorcycle_visibility_consistency.sql';
SELECT field_key, is_required, visibility_condition, required_condition
FROM `u891593158_doc`.`service_form_fields`
WHERE service_version_id = '33000000-0000-4000-8000-000000000001'
  AND field_key = 'engine.identification_mode';
SELECT COUNT(*) AS migration_007_registered FROM `u891593158_doc`.`schema_migrations` WHERE name = '007_engine_rules_and_documents.sql';
