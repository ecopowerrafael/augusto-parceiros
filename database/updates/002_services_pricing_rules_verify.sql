-- Execute depois de 002_services_pricing_rules.sql.
-- Todas as consultas são de leitura.

SELECT DATABASE() AS selected_database;

SELECT table_name, table_rows
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_name IN (
    'brazilian_states', 'vehicle_categories', 'services',
    'service_vehicle_categories', 'service_ufs', 'service_relations',
    'price_tables', 'service_prices', 'service_price_components',
    'technical_rules', 'technical_rule_services'
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
