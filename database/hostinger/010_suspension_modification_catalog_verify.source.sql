-- Verificação posterior somente leitura da Migration 010.
-- Cada consulta dependente de uma tabela usa SQL preparado após o diagnóstico
-- de information_schema, permitindo observar falhas parciais sem abortar o lote.
SELECT VERSION() AS mysql_version;

SELECT expected.table_name, COUNT(actual.table_name) AS table_present
FROM (SELECT 'vehicle_modifications' AS table_name
      UNION ALL SELECT 'vehicle_modification_categories'
      UNION ALL SELECT 'vehicle_modification_ufs'
      UNION ALL SELECT 'vehicle_modification_documents'
      UNION ALL SELECT 'vehicle_modification_messages') expected
LEFT JOIN information_schema.tables actual
  ON actual.table_schema = DATABASE() AND actual.table_name = expected.table_name
GROUP BY expected.table_name
ORDER BY table_name;

SELECT table_name, column_name, COUNT(*) AS column_present
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND ((table_name = 'service_billing_items' AND column_name = 'quantity_expression') OR (table_name = 'vehicle_modifications' AND column_name IN ('billing_item_id', 'requires_csv', 'requires_ecv', 'legal_status')))
GROUP BY table_name, column_name
ORDER BY table_name, column_name;

SET @docmotor_verify_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'schema_migrations'), 'SELECT COUNT(*) AS migration_010_count FROM schema_migrations WHERE name = ''010_suspension_modification_catalog.sql''', 'SELECT CAST(NULL AS UNSIGNED) AS migration_010_count');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;

SET @docmotor_verify_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'vehicle_modifications'), 'SELECT COUNT(*) AS catalog_count, 27 AS expected_catalog_count, COUNT(*) = 27 AS catalog_count_matches, COUNT(DISTINCT code) AS catalog_distinct_code_count, SUM(status = ''ACTIVE'') AS active_catalog_count FROM vehicle_modifications', 'SELECT CAST(NULL AS UNSIGNED) AS catalog_count, 27 AS expected_catalog_count, 0 AS catalog_count_matches, CAST(NULL AS UNSIGNED) AS catalog_distinct_code_count, CAST(NULL AS UNSIGNED) AS active_catalog_count');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;

SET @docmotor_verify_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'vehicle_modifications'), 'SELECT code, name, category, status, requires_manual_review, requires_description, legal_status FROM vehicle_modifications ORDER BY display_order, name', 'SELECT ''vehicle_modifications ausente'' AS diagnostic');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;

SET @docmotor_verify_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('services', 'service_versions', 'service_form_fields', 'service_billing_items', 'technical_rules')) = 5, 'SELECT s.code, s.name, v.version_number, v.status, COUNT(DISTINCT f.id) AS field_count, COUNT(DISTINCT sbi.id) AS billing_item_count, COUNT(DISTINCT r.id) AS rule_count FROM services s LEFT JOIN service_versions v ON v.service_id = s.id LEFT JOIN service_form_fields f ON f.service_version_id = v.id LEFT JOIN service_billing_items sbi ON sbi.service_version_id = v.id LEFT JOIN technical_rules r ON r.service_version_id = v.id WHERE s.code = ''LOWERED_SUSPENSION'' GROUP BY s.code, s.name, v.version_number, v.status', 'SELECT ''tabelas do serviço ou configuração ausentes'' AS diagnostic');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;

SET @docmotor_verify_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('services', 'service_versions', 'service_form_fields')) = 3, 'SELECT field_key, field_type, is_required, visibility_condition, required_condition FROM service_form_fields f JOIN service_versions v ON v.id = f.service_version_id JOIN services s ON s.id = v.service_id WHERE s.code = ''LOWERED_SUSPENSION'' ORDER BY f.display_order', 'SELECT ''tabelas de formulário ausentes'' AS diagnostic');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;

SET @docmotor_verify_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('services', 'service_versions', 'service_form_fields')) = 3, 'SELECT COUNT(DISTINCT f.field_key) AS suspension_field_count, 17 AS expected_suspension_field_count, COUNT(DISTINCT f.field_key) = 17 AS suspension_field_count_matches FROM service_form_fields f JOIN service_versions v ON v.id = f.service_version_id JOIN services s ON s.id = v.service_id WHERE s.code = ''LOWERED_SUSPENSION''', 'SELECT CAST(NULL AS UNSIGNED) AS suspension_field_count, 17 AS expected_suspension_field_count, 0 AS suspension_field_count_matches');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;

SET @docmotor_verify_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('services', 'service_versions', 'service_form_fields')) = 3, 'SELECT field_key, is_required, required_condition FROM service_form_fields f JOIN service_versions v ON v.id = f.service_version_id JOIN services s ON s.id = v.service_id WHERE s.code = ''LOWERED_SUSPENSION'' AND f.field_key IN (''suspension.clearance_check'', ''suspension.contact_check'', ''wheels.compliance'', ''wheels.fender_check'', ''wheels.contact_check'', ''wheels.diameter_check'')', 'SELECT ''campos de checklist ausentes'' AS diagnostic');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;

SET @docmotor_verify_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('services', 'service_versions', 'service_billing_items', 'billing_items')) = 4, 'SELECT COUNT(DISTINCT sbi.id) AS billing_item_count, 6 AS expected_billing_item_count, COUNT(DISTINCT sbi.id) = 6 AS billing_item_count_matches FROM service_billing_items sbi JOIN service_versions v ON v.id = sbi.service_version_id JOIN services s ON s.id = v.service_id WHERE s.code = ''LOWERED_SUSPENSION''', 'SELECT CAST(NULL AS UNSIGNED) AS billing_item_count, 6 AS expected_billing_item_count, 0 AS billing_item_count_matches');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;

SET @docmotor_verify_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('services', 'service_versions', 'service_billing_items', 'billing_items')) = 4, 'SELECT bi.code, bi.name, bi.default_amount_cents, sbi.billing_mode, sbi.quantity_expression, sbi.condition_expression FROM service_billing_items sbi JOIN billing_items bi ON bi.id = sbi.billing_item_id JOIN service_versions v ON v.id = sbi.service_version_id JOIN services s ON s.id = v.service_id WHERE s.code = ''LOWERED_SUSPENSION'' ORDER BY sbi.display_order', 'SELECT ''tabelas de cobrança ausentes'' AS diagnostic');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;

SET @docmotor_verify_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('services', 'service_versions', 'technical_rules')) = 3, 'SELECT COUNT(DISTINCT r.id) AS technical_rule_count, 7 AS expected_technical_rule_count, COUNT(DISTINCT r.id) = 7 AS technical_rule_count_matches FROM technical_rules r JOIN service_versions v ON v.id = r.service_version_id JOIN services s ON s.id = v.service_id WHERE s.code = ''LOWERED_SUSPENSION''', 'SELECT CAST(NULL AS UNSIGNED) AS technical_rule_count, 7 AS expected_technical_rule_count, 0 AS technical_rule_count_matches');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;

SET @docmotor_verify_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('services', 'service_versions', 'technical_rules')) = 3, 'SELECT name, expected_result, priority, conditions FROM technical_rules r JOIN service_versions v ON v.id = r.service_version_id JOIN services s ON s.id = v.service_id WHERE s.code = ''LOWERED_SUSPENSION'' ORDER BY priority, name', 'SELECT ''tabelas de regras ausentes'' AS diagnostic');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;

SET @docmotor_verify_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('vehicle_modifications', 'vehicle_modification_categories', 'vehicle_categories')) = 3, 'SELECT COUNT(*) AS catalog_category_relationships, COUNT(DISTINCT CONCAT(modification_id, ''|'', vehicle_category_id)) AS distinct_catalog_category_relationships FROM vehicle_modification_categories', 'SELECT CAST(NULL AS UNSIGNED) AS catalog_category_relationships, CAST(NULL AS UNSIGNED) AS distinct_catalog_category_relationships');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;

SET @docmotor_verify_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'vehicle_modifications'), 'SELECT code, COUNT(*) AS duplicate_count FROM vehicle_modifications GROUP BY code HAVING COUNT(*) > 1', 'SELECT ''vehicle_modifications ausente; duplicidades não avaliadas'' AS diagnostic');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;
