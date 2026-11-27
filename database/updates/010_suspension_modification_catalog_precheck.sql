-- Pré-verificação da Migration 010
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Pré-verificação somente leitura da Migration 010.
SELECT VERSION() AS mysql_version;
SELECT COUNT(*) AS migration_010_already_registered FROM `u891593158_doc`.`schema_migrations` WHERE name = '010_suspension_modification_catalog.sql';
SELECT COUNT(*) AS suspension_service_count FROM `u891593158_doc`.`services` WHERE code = 'LOWERED_SUSPENSION';
SELECT COUNT(*) AS suspension_versions_count FROM `u891593158_doc`.`service_versions` v JOIN `u891593158_doc`.`services` s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION';
SELECT COUNT(*) AS quantity_expression_column FROM information_schema.columns WHERE table_schema = 'u891593158_doc' AND table_name = 'service_billing_items' AND column_name = 'quantity_expression';
SELECT COUNT(*) AS base_billing_items_present FROM `u891593158_doc`.`billing_items` WHERE code IN ('TRANSFER_FEE', 'SERVICE_FEE', 'MERCOSUR_PLATE_AUTHORIZATION');
SELECT COUNT(*) AS initial_catalog_count FROM `u891593158_doc`.`vehicle_modifications` WHERE code IN ('SUSPENSION_LOWERING', 'SUSPENSION_LIFT', 'SUSPENSION_OTHER', 'WHEELS_TIRES', 'GNV_INSTALLATION', 'GNV_REMOVAL', 'FUEL_CHANGE', 'SECURITY_ARMOR_INSTALLATION', 'SECURITY_ARMOR_REMOVAL', 'POWER_CHANGE', 'CYLINDER_CHANGE', 'BODY_CHANGE', 'MOTORHOME_CONVERSION', 'CHASSIS_LENGTHENING', 'CHASSIS_SHORTENING', 'AXLE_ADDITION', 'PCD_ADAPTATION', 'DRIVING_SCHOOL_CONTROLS_INSTALLATION', 'DRIVING_SCHOOL_CONTROLS_REMOVAL', 'PASSENGER_CAPACITY_CHANGE', 'COLOR_CHANGE', 'WRAPPING', 'LOAD_DEVICE_CHANGE', 'SPECIES_COLLECTION', 'SPECIES_COMPETITION', 'SPECIES_OTHER', 'OTHER_MODIFICATION');
SELECT COUNT(*) AS suspension_required_fields_present FROM `u891593158_doc`.`service_form_fields` f JOIN `u891593158_doc`.`service_versions` v ON v.id = f.service_version_id JOIN `u891593158_doc`.`services` s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' AND f.field_key IN ('suspension.compliance', 'wheels.include', 'wheels.compliance', 'wheels.fender_check', 'wheels.contact_check', 'wheels.diameter_check', 'modifications.additional');
SELECT COUNT(*) AS required_catalog_tables_present FROM information_schema.tables WHERE table_schema = 'u891593158_doc' AND table_name IN ('vehicle_modifications', 'vehicle_modification_categories', 'vehicle_modification_ufs', 'vehicle_modification_documents', 'vehicle_modification_messages');
