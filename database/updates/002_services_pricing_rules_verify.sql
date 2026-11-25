-- Execute depois de 002_services_pricing_rules.sql.
-- Todas as consultas são de leitura.

SELECT DATABASE() AS selected_database;

SELECT table_name, table_rows
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_name IN (
    'brazilian_states', 'vehicle_categories', 'services',
    'service_vehicle_categories', 'service_ufs', 'service_relations',
    'service_versions', 'service_form_sections', 'service_form_fields', 'service_field_options',
    'service_data_sources', 'service_external_queries', 'service_query_mappings',
    'price_tables', 'billing_items', 'service_prices', 'service_price_components', 'service_billing_items',
    'technical_rules', 'technical_rule_actions', 'technical_rule_services', 'service_documents', 'service_messages'
  )
ORDER BY table_name;

SELECT name, applied_at
FROM schema_migrations
WHERE name IN ('001_initial.sql', '002_services_pricing_rules.sql')
ORDER BY name;

SELECT code, name, slug, service_type, is_active
FROM services
ORDER BY display_order, name;

SELECT code, name, is_active
FROM vehicle_categories
ORDER BY code;

SELECT COUNT(*) AS brazilian_state_count FROM brazilian_states;
SELECT COUNT(*) AS seeded_service_count FROM services;
SELECT COUNT(*) AS seeded_technical_rule_count FROM technical_rules;
SELECT COUNT(*) AS price_count FROM service_prices;
SELECT COUNT(*) AS price_component_count FROM service_price_components;
SELECT COUNT(*) AS billing_item_count FROM billing_items;
SELECT COUNT(*) AS form_field_count FROM service_form_fields;
SELECT COUNT(*) AS service_version_count FROM service_versions;
SELECT COUNT(*) AS document_requirement_count FROM service_documents;

SELECT COUNT(*) AS invalid_service_category_links
FROM service_vehicle_categories svc
LEFT JOIN services s ON s.id = svc.service_id
LEFT JOIN vehicle_categories vc ON vc.id = svc.vehicle_category_id
WHERE s.id IS NULL OR vc.id IS NULL;

SELECT COUNT(*) AS invalid_price_service_links
FROM service_prices sp
LEFT JOIN services s ON s.id = sp.service_id
LEFT JOIN price_tables pt ON pt.id = sp.price_table_id
WHERE s.id IS NULL OR pt.id IS NULL;

SELECT COUNT(*) AS draft_rule_count
FROM technical_rules
WHERE status = 'DRAFT';

SELECT COUNT(*) AS invalid_form_field_sections
FROM service_form_fields f
LEFT JOIN service_versions v ON v.id = f.service_version_id
LEFT JOIN service_form_sections s ON s.id = f.section_id
WHERE v.id IS NULL OR (f.section_id IS NOT NULL AND s.id IS NULL);

SELECT COUNT(*) AS invalid_rule_version_links
FROM technical_rules r
LEFT JOIN service_versions v ON v.id = r.service_version_id
WHERE r.service_version_id IS NOT NULL AND v.id IS NULL;
