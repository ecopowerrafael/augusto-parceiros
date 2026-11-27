-- Pré-verificação somente leitura da Migration 010.
-- Consultas a tabelas opcionais usam SQL preparado apenas depois da confirmação
-- em information_schema, para funcionar antes da criação e após execução parcial.
SELECT VERSION() AS mysql_version;

SELECT COUNT(*) AS required_base_tables_present
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_name IN ('schema_migrations', 'services', 'service_versions', 'service_form_fields', 'billing_items', 'service_billing_items');

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

SELECT column_name, COUNT(*) AS column_present
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name = 'service_billing_items'
  AND column_name = 'quantity_expression'
GROUP BY column_name;

SET @docmotor_precheck_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'schema_migrations'), 'SELECT COUNT(*) AS migration_010_already_registered FROM schema_migrations WHERE name = ''010_suspension_modification_catalog.sql''', 'SELECT CAST(NULL AS UNSIGNED) AS migration_010_already_registered');
PREPARE docmotor_precheck_stmt FROM @docmotor_precheck_sql;
EXECUTE docmotor_precheck_stmt;
DEALLOCATE PREPARE docmotor_precheck_stmt;

SET @docmotor_precheck_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'services'), 'SELECT COUNT(*) AS suspension_service_count FROM services WHERE code = ''LOWERED_SUSPENSION''', 'SELECT CAST(NULL AS UNSIGNED) AS suspension_service_count');
PREPARE docmotor_precheck_stmt FROM @docmotor_precheck_sql;
EXECUTE docmotor_precheck_stmt;
DEALLOCATE PREPARE docmotor_precheck_stmt;

SET @docmotor_precheck_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('services', 'service_versions')) = 2, 'SELECT COUNT(*) AS suspension_versions_count FROM service_versions v JOIN services s ON s.id = v.service_id WHERE s.code = ''LOWERED_SUSPENSION''', 'SELECT CAST(NULL AS UNSIGNED) AS suspension_versions_count');
PREPARE docmotor_precheck_stmt FROM @docmotor_precheck_sql;
EXECUTE docmotor_precheck_stmt;
DEALLOCATE PREPARE docmotor_precheck_stmt;

SET @docmotor_precheck_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'billing_items'), 'SELECT COUNT(*) AS base_billing_items_present FROM billing_items WHERE code IN (''TRANSFER_FEE'', ''SERVICE_FEE'', ''MERCOSUR_PLATE_AUTHORIZATION'')', 'SELECT CAST(NULL AS UNSIGNED) AS base_billing_items_present');
PREPARE docmotor_precheck_stmt FROM @docmotor_precheck_sql;
EXECUTE docmotor_precheck_stmt;
DEALLOCATE PREPARE docmotor_precheck_stmt;

SET @docmotor_precheck_sql = IF(EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'vehicle_modifications'), 'SELECT COUNT(*) AS initial_catalog_count FROM vehicle_modifications WHERE code IN (''SUSPENSION_LOWERING'', ''SUSPENSION_LIFT'', ''SUSPENSION_OTHER'', ''WHEELS_TIRES'', ''GNV_INSTALLATION'', ''GNV_REMOVAL'', ''FUEL_CHANGE'', ''SECURITY_ARMOR_INSTALLATION'', ''SECURITY_ARMOR_REMOVAL'', ''POWER_CHANGE'', ''CYLINDER_CHANGE'', ''BODY_CHANGE'', ''MOTORHOME_CONVERSION'', ''CHASSIS_LENGTHENING'', ''CHASSIS_SHORTENING'', ''AXLE_ADDITION'', ''PCD_ADAPTATION'', ''DRIVING_SCHOOL_CONTROLS_INSTALLATION'', ''DRIVING_SCHOOL_CONTROLS_REMOVAL'', ''PASSENGER_CAPACITY_CHANGE'', ''COLOR_CHANGE'', ''WRAPPING'', ''LOAD_DEVICE_CHANGE'', ''SPECIES_COLLECTION'', ''SPECIES_COMPETITION'', ''SPECIES_OTHER'', ''OTHER_MODIFICATION'')', 'SELECT CAST(NULL AS UNSIGNED) AS initial_catalog_count');
PREPARE docmotor_precheck_stmt FROM @docmotor_precheck_sql;
EXECUTE docmotor_precheck_stmt;
DEALLOCATE PREPARE docmotor_precheck_stmt;

SET @docmotor_precheck_sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('services', 'service_versions', 'service_form_fields')) = 3, 'SELECT COUNT(*) AS suspension_required_fields_present FROM service_form_fields f JOIN service_versions v ON v.id = f.service_version_id JOIN services s ON s.id = v.service_id WHERE s.code = ''LOWERED_SUSPENSION'' AND f.field_key IN (''suspension.compliance'', ''wheels.include'', ''wheels.compliance'', ''wheels.fender_check'', ''wheels.contact_check'', ''wheels.diameter_check'', ''modifications.additional'')', 'SELECT CAST(NULL AS UNSIGNED) AS suspension_required_fields_present');
PREPARE docmotor_precheck_stmt FROM @docmotor_precheck_sql;
EXECUTE docmotor_precheck_stmt;
DEALLOCATE PREPARE docmotor_precheck_stmt;
