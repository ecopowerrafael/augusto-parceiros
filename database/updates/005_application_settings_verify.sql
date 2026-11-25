-- Verificação da Migration 005
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Verificação posterior somente leitura da Migration 005.

SELECT VERSION() AS mysql_version;
SELECT COUNT(*) AS migration_005_count FROM `u891593158_doc`.`schema_migrations` WHERE name = '005_application_settings.sql';
SELECT COUNT(*) AS application_settings_count FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name = 'application_settings';
SELECT id, company_name, timezone FROM `u891593158_doc`.`application_settings` WHERE id = '55000000-0000-4000-8000-000000000001';
