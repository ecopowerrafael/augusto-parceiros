-- Pré-verificação somente leitura da Migration 013.
SELECT VERSION() AS mysql_version;
SELECT DATABASE() AS selected_database;
SELECT COUNT(*) AS schema_migrations_table_present FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'schema_migrations';
SELECT COUNT(*) AS migration_013_registered FROM __DOCMOTOR_DATABASE__.schema_migrations WHERE name = '013_suspension_documentation_fields.sql';
SELECT COUNT(*) AS base_dependencies_present FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name IN ('services', 'service_versions', 'service_form_sections', 'service_form_fields', 'service_field_options');
SELECT COUNT(*) AS suspension_version_present FROM __DOCMOTOR_DATABASE__.service_versions v JOIN __DOCMOTOR_DATABASE__.services s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1;
SELECT COUNT(*) AS documentation_section_present FROM __DOCMOTOR_DATABASE__.service_form_sections sec JOIN __DOCMOTOR_DATABASE__.service_versions v ON v.id = sec.service_version_id JOIN __DOCMOTOR_DATABASE__.services s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1 AND sec.stable_key = 'documentation';
SELECT COUNT(*) AS documentary_fields_present FROM __DOCMOTOR_DATABASE__.service_form_fields f JOIN __DOCMOTOR_DATABASE__.service_versions v ON v.id = f.service_version_id JOIN __DOCMOTOR_DATABASE__.services s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1 AND f.field_key IN ('suspension.parts_invoice', 'suspension.installation_invoice');
