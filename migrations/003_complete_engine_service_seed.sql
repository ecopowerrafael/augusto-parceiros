-- Doc Motor Fase 3.1: completar a configuração no-code do serviço de cadastro de motor.
-- Migration incremental; não reexecutar 001/002 e não contém DROP/TRUNCATE.

UPDATE service_form_fields
SET calculation = JSON_OBJECT(
  'operation', 'PERCENT_VARIATION',
  'operands', JSON_ARRAY(
    JSON_OBJECT('field', 'vehicle_target.power_cv'),
    JSON_OBJECT('field', 'vehicle_donor.power_cv')
  ),
  'decimals', 2
), data_origin = 'CALCULATED', updated_at = UTC_TIMESTAMP()
WHERE id = '36000000-0000-4000-8000-000000000013';

UPDATE service_form_fields
SET visibility_condition = JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.identification_mode', 'operator', 'EQUALS', 'value', 'PLATE'))), updated_at = UTC_TIMESTAMP()
WHERE id = '36000000-0000-4000-8000-000000000009';

UPDATE service_form_fields
SET visibility_condition = JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.identification_mode', 'operator', 'EQUALS', 'value', 'MANUAL'))), updated_at = UTC_TIMESTAMP()
WHERE id IN ('36000000-0000-4000-8000-000000000010', '36000000-0000-4000-8000-000000000011', '36000000-0000-4000-8000-000000000012');

INSERT INTO service_field_options (id, field_id, option_value, option_label, display_order) VALUES
('3C000000-0000-4000-8000-000000000001', '36000000-0000-4000-8000-000000000003', 'AC', 'Acre', 10),
('3C000000-0000-4000-8000-000000000002', '36000000-0000-4000-8000-000000000003', 'AL', 'Alagoas', 20),
('3C000000-0000-4000-8000-000000000003', '36000000-0000-4000-8000-000000000003', 'AP', 'Amapá', 30),
('3C000000-0000-4000-8000-000000000004', '36000000-0000-4000-8000-000000000003', 'AM', 'Amazonas', 40),
('3C000000-0000-4000-8000-000000000005', '36000000-0000-4000-8000-000000000003', 'BA', 'Bahia', 50),
('3C000000-0000-4000-8000-000000000006', '36000000-0000-4000-8000-000000000003', 'CE', 'Ceará', 60),
('3C000000-0000-4000-8000-000000000007', '36000000-0000-4000-8000-000000000003', 'DF', 'Distrito Federal', 70),
('3C000000-0000-4000-8000-000000000008', '36000000-0000-4000-8000-000000000003', 'ES', 'Espírito Santo', 80),
('3C000000-0000-4000-8000-000000000009', '36000000-0000-4000-8000-000000000003', 'GO', 'Goiás', 90),
('3C000000-0000-4000-8000-000000000010', '36000000-0000-4000-8000-000000000003', 'MA', 'Maranhão', 100),
('3C000000-0000-4000-8000-000000000011', '36000000-0000-4000-8000-000000000003', 'MT', 'Mato Grosso', 110),
('3C000000-0000-4000-8000-000000000012', '36000000-0000-4000-8000-000000000003', 'MS', 'Mato Grosso do Sul', 120),
('3C000000-0000-4000-8000-000000000013', '36000000-0000-4000-8000-000000000003', 'MG', 'Minas Gerais', 130),
('3C000000-0000-4000-8000-000000000014', '36000000-0000-4000-8000-000000000003', 'PA', 'Pará', 140),
('3C000000-0000-4000-8000-000000000015', '36000000-0000-4000-8000-000000000003', 'PB', 'Paraíba', 150),
('3C000000-0000-4000-8000-000000000016', '36000000-0000-4000-8000-000000000003', 'PR', 'Paraná', 160),
('3C000000-0000-4000-8000-000000000017', '36000000-0000-4000-8000-000000000003', 'PE', 'Pernambuco', 170),
('3C000000-0000-4000-8000-000000000018', '36000000-0000-4000-8000-000000000003', 'PI', 'Piauí', 180),
('3C000000-0000-4000-8000-000000000019', '36000000-0000-4000-8000-000000000003', 'RJ', 'Rio de Janeiro', 190),
('3C000000-0000-4000-8000-000000000020', '36000000-0000-4000-8000-000000000003', 'RN', 'Rio Grande do Norte', 200),
('3C000000-0000-4000-8000-000000000021', '36000000-0000-4000-8000-000000000003', 'RS', 'Rio Grande do Sul', 210),
('3C000000-0000-4000-8000-000000000022', '36000000-0000-4000-8000-000000000003', 'RO', 'Rondônia', 220),
('3C000000-0000-4000-8000-000000000023', '36000000-0000-4000-8000-000000000003', 'RR', 'Roraima', 230),
('3C000000-0000-4000-8000-000000000024', '36000000-0000-4000-8000-000000000003', 'SC', 'Santa Catarina', 240),
('3C000000-0000-4000-8000-000000000025', '36000000-0000-4000-8000-000000000003', 'SP', 'São Paulo', 250),
('3C000000-0000-4000-8000-000000000026', '36000000-0000-4000-8000-000000000003', 'SE', 'Sergipe', 260),
('3C000000-0000-4000-8000-000000000027', '36000000-0000-4000-8000-000000000003', 'TO', 'Tocantins', 270)
ON DUPLICATE KEY UPDATE option_label = VALUES(option_label), display_order = VALUES(display_order);

INSERT INTO billing_items (id, code, name, description, financial_category, default_amount_cents, status, charge_nature, amount_status, payment_mode, is_public_fee)
VALUES ('3F000000-0000-4000-8000-000000000001', 'ITL_CSV_INSPECTION', 'Inspeção ITL / CSV', 'Valor não definido; exigir confirmação administrativa antes de qualquer publicação comercial.', 'TECHNICAL', NULL, 'DRAFT', 'THIRD_PARTY', 'NOT_DEFINED', 'UNDEFINED', 0)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), default_amount_cents = VALUES(default_amount_cents), status = VALUES(status), amount_status = VALUES(amount_status), updated_at = CURRENT_TIMESTAMP;

INSERT INTO service_billing_items (id, service_version_id, billing_item_id, billing_mode, display_order, condition_expression)
VALUES ('40000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', '3F000000-0000-4000-8000-000000000001', 'CONDITIONAL', 70, NULL)
ON DUPLICATE KEY UPDATE billing_mode = VALUES(billing_mode), display_order = VALUES(display_order);

INSERT INTO service_external_queries (id, service_version_id, source_id, query_key, label, context_key, plate_field_key, is_required, is_enabled) VALUES
('3D000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', '34000000-0000-4000-8000-000000000001', 'TARGET_VEHICLE', 'Consulta do veículo principal', 'vehicle_target', 'vehicle_target.plate', 1, 1),
('3D000000-0000-4000-8000-000000000002', '33000000-0000-4000-8000-000000000001', '34000000-0000-4000-8000-000000000001', 'DONOR_VEHICLE', 'Consulta do veículo doador', 'vehicle_donor', 'vehicle_donor.plate', 0, 1)
ON DUPLICATE KEY UPDATE label = VALUES(label), plate_field_key = VALUES(plate_field_key), is_required = VALUES(is_required), is_enabled = VALUES(is_enabled);

INSERT INTO service_query_mappings (id, query_id, target_field_key, normalized_path, data_origin) VALUES
('3E000000-0000-4000-8000-000000000001', '3D000000-0000-4000-8000-000000000001', 'vehicle_target.category', 'category', 'EXTERNAL'),
('3E000000-0000-4000-8000-000000000002', '3D000000-0000-4000-8000-000000000001', 'vehicle_target.state', 'state', 'EXTERNAL'),
('3E000000-0000-4000-8000-000000000003', '3D000000-0000-4000-8000-000000000001', 'vehicle_target.power_cv', 'power_cv', 'EXTERNAL'),
('3E000000-0000-4000-8000-000000000004', '3D000000-0000-4000-8000-000000000001', 'vehicle_target.engine_cc', 'engine_cc', 'EXTERNAL'),
('3E000000-0000-4000-8000-000000000005', '3D000000-0000-4000-8000-000000000001', 'vehicle_target.fuel', 'fuel', 'EXTERNAL'),
('3E000000-0000-4000-8000-000000000006', '3D000000-0000-4000-8000-000000000002', 'vehicle_donor.power_cv', 'power_cv', 'EXTERNAL'),
('3E000000-0000-4000-8000-000000000007', '3D000000-0000-4000-8000-000000000002', 'vehicle_donor.engine_cc', 'engine_cc', 'EXTERNAL'),
('3E000000-0000-4000-8000-000000000008', '3D000000-0000-4000-8000-000000000002', 'vehicle_donor.fuel', 'fuel', 'EXTERNAL')
ON DUPLICATE KEY UPDATE normalized_path = VALUES(normalized_path), data_origin = VALUES(data_origin);

INSERT INTO technical_rules (id, service_id, service_version_id, name, description, vehicle_category_id, conditions, technical_limits, expected_result, status, priority, version) VALUES
('41000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com redução de potência', 'Política preliminar com análise de modificação e inspeção; não representa garantia legal.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'LESS_THAN', 'value', 0))), JSON_OBJECT(), 'VIABLE_WITH_REQUIREMENTS', 'DRAFT', 21, 1),
('41000000-0000-4000-8000-000000000002', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com mesma potência e cilindrada diferente', 'Análise manual até definição da regra específica.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.power_cv', 'operator', 'EQUALS', 'valueField', 'vehicle_donor.power_cv'), JSON_OBJECT('field', 'vehicle_target.engine_cc', 'operator', 'NOT_EQUALS', 'valueField', 'vehicle_donor.engine_cc'))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 22, 1),
('41000000-0000-4000-8000-000000000003', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com alteração de combustível', 'Análise manual até definição da regra específica.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.fuel', 'operator', 'NOT_EQUALS', 'valueField', 'vehicle_donor.fuel'))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 23, 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), conditions = VALUES(conditions), expected_result = VALUES(expected_result), status = VALUES(status), priority = VALUES(priority), updated_at = CURRENT_TIMESTAMP;

INSERT INTO technical_rule_actions (id, technical_rule_id, action_type, target_key, payload, display_order) VALUES
('42000000-0000-4000-8000-000000000001', '41000000-0000-4000-8000-000000000001', 'ADD_BILLING_ITEM', 'MODIFICATION_REQUEST', JSON_OBJECT('billingMode', 'CONDITIONAL'), 10),
('42000000-0000-4000-8000-000000000002', '41000000-0000-4000-8000-000000000001', 'ADD_BILLING_ITEM', 'ITL_CSV_INSPECTION', JSON_OBJECT('valueStatus', 'NOT_DEFINED'), 20)
ON DUPLICATE KEY UPDATE action_type = VALUES(action_type), target_key = VALUES(target_key), payload = VALUES(payload), display_order = VALUES(display_order);

INSERT INTO schema_migrations (name)
SELECT '003_complete_engine_service_seed.sql'
WHERE NOT EXISTS (SELECT 1 FROM schema_migrations WHERE name = '003_complete_engine_service_seed.sql')
  AND (SELECT COUNT(*) FROM service_field_options WHERE field_id = '36000000-0000-4000-8000-000000000003') = 27
  AND (SELECT COUNT(*) FROM service_external_queries WHERE service_version_id = '33000000-0000-4000-8000-000000000001') = 2
  AND (SELECT COUNT(*) FROM service_query_mappings WHERE query_id IN (SELECT id FROM service_external_queries WHERE service_version_id = '33000000-0000-4000-8000-000000000001')) = 8
  AND (SELECT COUNT(*) FROM service_form_fields WHERE id = '36000000-0000-4000-8000-000000000013' AND calculation IS NOT NULL) = 1
  AND (SELECT COUNT(*) FROM billing_items WHERE code = 'ITL_CSV_INSPECTION') = 1
  AND (SELECT COUNT(*) FROM technical_rules WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND id IN ('32000000-0000-4000-8000-000000000001', '32000000-0000-4000-8000-000000000002', '32000000-0000-4000-8000-000000000003', '32000000-0000-4000-8000-000000000004', '32000000-0000-4000-8000-000000000005', '32000000-0000-4000-8000-000000000006', '32000000-0000-4000-8000-000000000007', '32000000-0000-4000-8000-000000000008', '41000000-0000-4000-8000-000000000001', '41000000-0000-4000-8000-000000000002', '41000000-0000-4000-8000-000000000003')) = 11;
