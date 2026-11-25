-- Execute antes de 002_services_pricing_rules.sql no banco selecionado.
-- Este arquivo é somente leitura e não altera dados.

SELECT DATABASE() AS selected_database;

SELECT TABLE_NAME AS phase3_table, TABLE_TYPE
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_name IN (
    'brazilian_states', 'vehicle_categories', 'services',
    'service_vehicle_categories', 'service_ufs', 'service_relations',
    'price_tables', 'service_prices', 'service_price_components',
    'technical_rules', 'technical_rule_services'
  )
ORDER BY table_name;

SELECT COUNT(*) AS migration_002_already_registered
FROM schema_migrations
WHERE name = '002_services_pricing_rules.sql';

SELECT table_name AS required_phase2_table, table_rows
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_name IN ('users', 'partner_companies', 'company_members', 'schema_migrations')
ORDER BY table_name;
