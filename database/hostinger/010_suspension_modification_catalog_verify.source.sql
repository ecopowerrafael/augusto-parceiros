-- Verificação posterior somente leitura da Migration 010.
-- O EXECUTE grava apenas variáveis; os resultados são emitidos por SELECTs
-- normais para compatibilidade com a importação do phpMyAdmin.
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

SET @docmotor_verify_value = NULL;
SET @docmotor_verify_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'schema_migrations'), 'SELECT COUNT(*) INTO @docmotor_verify_value FROM __DOCMOTOR_DATABASE__.schema_migrations WHERE name = ''010_suspension_modification_catalog.sql''', 'SELECT CAST(NULL AS UNSIGNED) INTO @docmotor_verify_value');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;
SELECT @docmotor_verify_value AS migration_010_count;

SET @docmotor_verify_value = NULL;
SET @docmotor_verify_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'vehicle_modifications'), 'SELECT COUNT(*) INTO @docmotor_verify_value FROM __DOCMOTOR_DATABASE__.vehicle_modifications', 'SELECT CAST(NULL AS UNSIGNED) INTO @docmotor_verify_value');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;
SELECT @docmotor_verify_value AS catalog_count, 27 AS expected_catalog_count, @docmotor_verify_value = 27 AS catalog_count_matches;

SET @docmotor_verify_value = NULL;
SET @docmotor_verify_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'vehicle_modifications'), 'SELECT COUNT(DISTINCT code) INTO @docmotor_verify_value FROM __DOCMOTOR_DATABASE__.vehicle_modifications', 'SELECT CAST(NULL AS UNSIGNED) INTO @docmotor_verify_value');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;
SELECT @docmotor_verify_value AS catalog_distinct_code_count;

SET @docmotor_verify_value = NULL;
SET @docmotor_verify_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('services', 'service_versions', 'service_form_fields', 'service_billing_items', 'technical_rules')) = 5, 'SELECT COUNT(DISTINCT v.id), COUNT(DISTINCT f.id), COUNT(DISTINCT sbi.id), COUNT(DISTINCT r.id) INTO @docmotor_service_version_count, @docmotor_field_count, @docmotor_billing_count, @docmotor_rule_count FROM __DOCMOTOR_DATABASE__.services s LEFT JOIN __DOCMOTOR_DATABASE__.service_versions v ON v.service_id = s.id LEFT JOIN __DOCMOTOR_DATABASE__.service_form_fields f ON f.service_version_id = v.id LEFT JOIN __DOCMOTOR_DATABASE__.service_billing_items sbi ON sbi.service_version_id = v.id LEFT JOIN __DOCMOTOR_DATABASE__.technical_rules r ON r.service_version_id = v.id WHERE s.code = ''LOWERED_SUSPENSION''', 'SELECT NULL INTO @docmotor_service_version_count, @docmotor_field_count, @docmotor_billing_count, @docmotor_rule_count');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;
SELECT @docmotor_service_version_count AS suspension_version_count, @docmotor_field_count AS suspension_field_count, 17 AS expected_suspension_field_count, @docmotor_field_count = 17 AS suspension_field_count_matches, @docmotor_billing_count AS billing_item_count, 6 AS expected_billing_item_count, @docmotor_billing_count = 6 AS billing_item_count_matches, @docmotor_rule_count AS technical_rule_count, 7 AS expected_technical_rule_count, @docmotor_rule_count = 7 AS technical_rule_count_matches;

SET @docmotor_verify_value = NULL;
SET @docmotor_verify_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name = 'technical_rules'), 'SELECT COUNT(*) INTO @docmotor_verify_value FROM `u891593158_doc`.technical_rules WHERE id IN (''5A000000-0000-4000-8000-000000000001'', ''5A000000-0000-4000-8000-000000000002'', ''5A000000-0000-4000-8000-000000000003'', ''5A000000-0000-4000-8000-000000000004'', ''5A000000-0000-4000-8000-000000000005'', ''5A000000-0000-4000-8000-000000000006'', ''5A000000-0000-4000-8000-000000000007'') AND JSON_VALID(conditions) = 1', 'SELECT CAST(NULL AS UNSIGNED) INTO @docmotor_verify_value');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;
SELECT @docmotor_verify_value AS valid_suspension_rule_json_count, 7 AS expected_valid_suspension_rule_json_count, @docmotor_verify_value = 7 AS valid_suspension_rule_json_count_matches;

SET @docmotor_verify_value = NULL;
SET @docmotor_verify_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('services', 'service_versions', 'service_form_fields')) = 3, 'SELECT COUNT(*) INTO @docmotor_verify_value FROM __DOCMOTOR_DATABASE__.service_form_fields f JOIN __DOCMOTOR_DATABASE__.service_versions v ON v.id = f.service_version_id JOIN __DOCMOTOR_DATABASE__.services s ON s.id = v.service_id WHERE s.code = ''LOWERED_SUSPENSION'' AND f.field_key IN (''suspension.compliance'', ''wheels.include'', ''wheels.compliance'', ''wheels.fender_check'', ''wheels.contact_check'', ''wheels.diameter_check'', ''modifications.additional'')', 'SELECT CAST(NULL AS UNSIGNED) INTO @docmotor_verify_value');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;
SELECT @docmotor_verify_value AS required_suspension_fields_present, 7 AS expected_required_suspension_fields, @docmotor_verify_value = 7 AS required_suspension_fields_match;

SET @docmotor_verify_value = NULL;
SET @docmotor_verify_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('vehicle_modifications', 'vehicle_modification_categories', 'vehicle_categories')) = 3, 'SELECT COUNT(*) INTO @docmotor_verify_value FROM __DOCMOTOR_DATABASE__.vehicle_modification_categories', 'SELECT CAST(NULL AS UNSIGNED) INTO @docmotor_verify_value');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;
SELECT @docmotor_verify_value AS catalog_category_relationships, 54 AS expected_catalog_category_relationships, @docmotor_verify_value = 54 AS catalog_category_relationships_match;

SET @docmotor_verify_value = NULL;
SET @docmotor_verify_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'vehicle_modifications'), 'SELECT COUNT(*) INTO @docmotor_verify_value FROM (SELECT code FROM __DOCMOTOR_DATABASE__.vehicle_modifications GROUP BY code HAVING COUNT(*) > 1) duplicates', 'SELECT CAST(NULL AS UNSIGNED) INTO @docmotor_verify_value');
PREPARE docmotor_verify_stmt FROM @docmotor_verify_sql;
EXECUTE docmotor_verify_stmt;
DEALLOCATE PREPARE docmotor_verify_stmt;
SELECT @docmotor_verify_value AS duplicate_catalog_code_groups;
