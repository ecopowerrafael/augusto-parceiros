-- Fase 3.7: metadados persistidos para normalização do simulador.
-- Incremental e não destrutiva. Não executar antes do precheck da Hostinger.

UPDATE service_form_fields
SET field_type = 'SINGLE_SELECT', updated_at = UTC_TIMESTAMP()
WHERE field_key IN ('vehicle_target.fuel', 'vehicle_donor.fuel')
  AND field_type IN ('TEXT', 'SINGLE_SELECT', 'RADIO');

UPDATE service_form_fields
SET unit = 'cm³', updated_at = UTC_TIMESTAMP()
WHERE (field_key IN ('vehicle_target.engine_cc', 'vehicle_donor.engine_cc') OR field_key LIKE '%.cylinder_cc')
  AND (unit IS NULL OR unit = '');

INSERT INTO service_field_options (id, field_id, option_value, option_label, display_order)
SELECT UUID(), f.id, seed.option_value, seed.option_label, seed.display_order
FROM service_form_fields f
JOIN (
  SELECT 'ALCOHOL' AS option_value, 'Álcool' AS option_label, 10 AS display_order
  UNION ALL SELECT 'GASOLINE', 'Gasolina', 20
  UNION ALL SELECT 'DIESEL', 'Diesel', 30
  UNION ALL SELECT 'FLEX', 'Flex', 40
) seed
WHERE f.field_key IN ('vehicle_target.fuel', 'vehicle_donor.fuel')
  AND NOT EXISTS (
    SELECT 1 FROM service_field_options existing
    WHERE existing.field_id = f.id AND existing.option_value = seed.option_value
  );

INSERT INTO schema_migrations (name)
SELECT '006_simulator_input_normalization.sql'
WHERE NOT EXISTS (SELECT 1 FROM schema_migrations WHERE name = '006_simulator_input_normalization.sql')
  AND (SELECT COUNT(*) FROM service_form_fields WHERE field_key IN ('vehicle_target.fuel', 'vehicle_donor.fuel', 'vehicle_target.engine_cc', 'vehicle_donor.engine_cc')) >= 4
  AND (SELECT COUNT(*) FROM service_field_options o JOIN service_form_fields f ON f.id = o.field_id WHERE f.field_key IN ('vehicle_target.fuel', 'vehicle_donor.fuel') AND o.option_value IN ('ALCOHOL', 'GASOLINE', 'DIESEL', 'FLEX')) >= 8;
