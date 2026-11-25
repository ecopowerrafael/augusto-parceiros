-- Verificação posterior somente leitura da Migration 004.
USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;
SELECT VERSION() AS mysql_version;
SELECT COUNT(*) AS migration_004_count FROM `u891593158_doc`.`schema_migrations` WHERE name = '004_partner_commissions.sql';
SELECT table_name FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name IN ('commission_settings', 'partner_commission_overrides') ORDER BY table_name;
SELECT default_model, default_percentage, default_fixed_amount_cents, honorarium_only FROM `u891593158_doc`.`commission_settings` WHERE id = '45000000-0000-4000-8000-000000000001';
SELECT COUNT(*) AS invalid_partner_overrides FROM `u891593158_doc`.`partner_commission_overrides` o LEFT JOIN `u891593158_doc`.`partner_companies` p ON p.id = o.partner_company_id WHERE p.id IS NULL;
