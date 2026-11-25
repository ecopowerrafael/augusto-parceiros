-- Diagnóstico somente leitura da aprovação administrativa.
-- Não exibe senhas, hashes ou tokens; execute no phpMyAdmin somente após selecionar o banco.
USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;
SELECT VERSION() AS mysql_version;

SELECT COUNT(*) AS partner_company_count FROM `u891593158_doc`.`partner_companies`;
SELECT COUNT(*) AS pending_partner_count FROM `u891593158_doc`.`partner_companies` WHERE status = 'PENDING';
SELECT COUNT(*) AS administrator_count FROM `u891593158_doc`.`users` WHERE role = 'ADMINISTRATOR' AND status = 'ACTIVE';
SELECT COUNT(*) AS member_rows_without_company FROM `u891593158_doc`.`company_members` cm LEFT JOIN `u891593158_doc`.`partner_companies` pc ON pc.id = cm.company_id WHERE pc.id IS NULL;
SELECT COUNT(*) AS member_rows_without_user FROM `u891593158_doc`.`company_members` cm LEFT JOIN `u891593158_doc`.`users` u ON u.id = cm.user_id WHERE u.id IS NULL;

SELECT table_name, column_name, is_nullable, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'u891593158_doc'
  AND table_name IN ('users', 'partner_companies', 'company_members', 'audit_logs')
  AND column_name IN ('id', 'role', 'status', 'approved_at', 'approved_by', 'company_id', 'user_id', 'company_role', 'action', 'entity_type', 'entity_id')
ORDER BY table_name, ordinal_position;

SELECT table_name, constraint_name, column_name, referenced_table_name, referenced_column_name
FROM information_schema.key_column_usage
WHERE table_schema = 'u891593158_doc'
  AND table_name IN ('users', 'partner_companies', 'company_members', 'audit_logs')
  AND referenced_table_name IS NOT NULL
ORDER BY table_name, constraint_name;
