-- Atualização da Migration 009
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Doc Motor Fase 3.12: consistência final do simulador declarativo.
-- Migration incremental e não destrutiva. Não executar migrations anteriores novamente.

UPDATE `u891593158_doc`.`service_form_fields`
SET visibility_condition = JSON_OBJECT('all', JSON_ARRAY(
  JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'IN_LIST', 'values', JSON_ARRAY('AUTOMOBILE', 'TRUCK', 'BUS')),
  JSON_OBJECT('field', 'engine.identification_mode', 'operator', 'EQUALS', 'value', 'PLATE')
)), updated_at = UTC_TIMESTAMP()
WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND field_key = 'vehicle_donor.plate';

UPDATE `u891593158_doc`.`service_form_fields`
SET visibility_condition = JSON_OBJECT('all', JSON_ARRAY(
  JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'IN_LIST', 'values', JSON_ARRAY('AUTOMOBILE', 'TRUCK', 'BUS')),
  JSON_OBJECT('field', 'engine.identification_mode', 'operator', 'IN_LIST', 'values', JSON_ARRAY('PLATE', 'MANUAL'))
)), updated_at = UTC_TIMESTAMP()
WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND field_key IN ('vehicle_donor.power_cv', 'vehicle_donor.engine_cc', 'vehicle_donor.fuel');

UPDATE `u891593158_doc`.`service_form_fields`
SET label = 'Declaro que o motor que será instalado possui a mesma cilindrada do motor original da motocicleta.',
    description = '⚠ Atenção à cilindrada do motor\n\nMotocicletas somente podem ser cadastradas automaticamente quando a cilindrada do motor instalado for igual à do motor original.\n\nExemplos:\n✓ 125 cc → 125 cc: compatível\n✕ 125 cc → 150 cc: análise manual necessária\n✕ 160 cc → 125 cc: análise manual necessária',
    updated_at = UTC_TIMESTAMP()
WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND field_key = 'motorcycle.compatibility_declaration';

INSERT INTO `u891593158_doc`.`schema_migrations` (name)
SELECT '009_simulator_final_visibility.sql'
WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE name = '009_simulator_final_visibility.sql')
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_form_fields` WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND field_key IN ('vehicle_donor.plate', 'vehicle_donor.power_cv', 'vehicle_donor.engine_cc', 'vehicle_donor.fuel', 'motorcycle.compatibility_declaration')) = 5;
