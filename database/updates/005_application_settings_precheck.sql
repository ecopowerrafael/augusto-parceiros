-- Pré-verificação da Migration 005
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Pré-verificação somente leitura da Migration 005.

SELECT VERSION() AS mysql_version;
SELECT COUNT(*) AS migration_005_already_registered FROM `u891593158_doc`.`schema_migrations` WHERE name = '005_application_settings.sql';
SELECT COUNT(*) AS required_base_tables_present FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name IN ('users', 'schema_migrations');
SELECT COUNT(*) AS application_settings_present FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name = 'application_settings';
