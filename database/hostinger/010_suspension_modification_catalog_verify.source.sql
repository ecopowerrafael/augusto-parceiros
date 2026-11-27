-- Verificação posterior somente leitura da Migration 010.
SELECT VERSION() AS mysql_version;
SELECT COUNT(*) AS migration_010_count FROM schema_migrations WHERE name = '010_suspension_modification_catalog.sql';
SELECT code, name, category, status, requires_manual_review, requires_description, legal_status FROM vehicle_modifications ORDER BY display_order, name;
SELECT s.code, s.name, v.version_number, v.status, COUNT(DISTINCT f.id) AS field_count, COUNT(DISTINCT sbi.id) AS billing_item_count, COUNT(DISTINCT r.id) AS rule_count
FROM services s LEFT JOIN service_versions v ON v.service_id = s.id LEFT JOIN service_form_fields f ON f.service_version_id = v.id LEFT JOIN service_billing_items sbi ON sbi.service_version_id = v.id LEFT JOIN technical_rules r ON r.service_version_id = v.id
WHERE s.code = 'LOWERED_SUSPENSION' GROUP BY s.code, s.name, v.version_number, v.status;
SELECT field_key, field_type, is_required, visibility_condition, required_condition FROM service_form_fields f JOIN service_versions v ON v.id = f.service_version_id JOIN services s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' ORDER BY f.display_order;
SELECT field_key, is_required, required_condition FROM service_form_fields f JOIN service_versions v ON v.id = f.service_version_id JOIN services s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' AND f.field_key IN ('suspension.clearance_check', 'suspension.contact_check', 'wheels.compliance', 'wheels.fender_check', 'wheels.contact_check', 'wheels.diameter_check');
SELECT bi.code, bi.name, bi.default_amount_cents, sbi.billing_mode, sbi.quantity_expression, sbi.condition_expression FROM service_billing_items sbi JOIN billing_items bi ON bi.id = sbi.billing_item_id JOIN service_versions v ON v.id = sbi.service_version_id JOIN services s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' ORDER BY sbi.display_order;
SELECT name, expected_result, priority, conditions FROM technical_rules r JOIN service_versions v ON v.id = r.service_version_id JOIN services s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' ORDER BY priority, name;
