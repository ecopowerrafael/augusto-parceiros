-- Verificação posterior somente leitura da Migration 009.
SELECT VERSION() AS mysql_version;
SELECT COUNT(*) AS migration_009_count FROM schema_migrations WHERE name = '009_simulator_final_visibility.sql';
SELECT field_key, label, description, visibility_condition
FROM service_form_fields
WHERE service_version_id = '33000000-0000-4000-8000-000000000001'
  AND field_key IN ('vehicle_donor.plate', 'vehicle_donor.power_cv', 'vehicle_donor.engine_cc', 'vehicle_donor.fuel', 'motorcycle.compatibility_declaration')
ORDER BY display_order;
