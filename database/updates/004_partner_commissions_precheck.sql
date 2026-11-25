-- Pré-verificação da Migration 004
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Pré-verificação somente leitura da Migration 004.

SELECT VERSION() AS mysql_version;
SELECT COUNT(*) AS migration_004_already_registered FROM `u891593158_doc`.`schema_migrations` WHERE name = '004_partner_commissions.sql';
SELECT COUNT(*) AS required_tables_present FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name IN ('users', 'partner_companies', 'schema_migrations');
SELECT COUNT(*) AS administrator_count FROM `u891593158_doc`.`users` WHERE role = 'ADMINISTRATOR';
