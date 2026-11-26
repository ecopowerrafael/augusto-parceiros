-- Atualização da Migration 007
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Doc Motor Fase 3.9: regras autorizadas, formulário condicional e documentos comerciais.
-- Migration incremental, não destrutiva. Executar manualmente após o precheck.

ALTER TABLE `u891593158_doc`.`application_settings`
  ADD COLUMN IF NOT EXISTS manual_whatsapp VARCHAR(30) NULL,
  ADD COLUMN IF NOT EXISTS manual_team_name VARCHAR(180) NULL,
  ADD COLUMN IF NOT EXISTS manual_message_template TEXT NULL;

INSERT INTO `u891593158_doc`.`service_field_options` (id, field_id, option_value, option_label, display_order)
VALUES ('37000000-0000-4000-8000-000000000007', '36000000-0000-4000-8000-000000000002', 'BUS', 'Ônibus', 35)
ON DUPLICATE KEY UPDATE option_label = VALUES(option_label), display_order = VALUES(display_order);

INSERT INTO `u891593158_doc`.`service_form_fields` (id, service_version_id, section_id, field_key, label, description, field_type, default_value, is_required, display_order, visibility_condition, required_condition, data_origin, calculation)
VALUES
('36000000-0000-4000-8000-000000000014', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000002', 'engine.cylinder_variation_percent', 'Variação percentual de cilindrada', 'Comparação calculada entre os dados técnicos informados.', 'CALCULATED', NULL, 0, 135, NULL, NULL, 'CALCULATED', JSON_OBJECT('operation', 'PERCENT_VARIATION', 'operands', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_donor.engine_cc'), JSON_OBJECT('field', 'vehicle_target.engine_cc')), 'decimals', 6)),
('36000000-0000-4000-8000-000000000015', '33000000-0000-4000-8000-000000000001', '35000000-0000-4000-8000-000000000002', 'motorcycle.compatibility_declaration', 'Declaro que o motor que será instalado possui a mesma cilindrada do motor original da motocicleta.', 'Declaração manual de compatibilidade para análise preliminar.', 'CHECKBOX', FALSE, 0, 140, JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'EQUALS', 'value', 'MOTORCYCLE'), JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'EQUALS', 'value', 'MOTORCYCLE'), 'MANUAL', JSON_OBJECT('default', FALSE))
ON DUPLICATE KEY UPDATE label = VALUES(label), description = VALUES(description), field_type = VALUES(field_type), default_value = VALUES(default_value), is_required = VALUES(is_required), display_order = VALUES(display_order), visibility_condition = VALUES(visibility_condition), required_condition = VALUES(required_condition), data_origin = VALUES(data_origin), calculation = VALUES(calculation), updated_at = UTC_TIMESTAMP();

UPDATE `u891593158_doc`.`service_form_fields`
SET visibility_condition = JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'NOT_EQUALS', 'value', 'MOTORCYCLE'), updated_at = UTC_TIMESTAMP()
WHERE id IN ('36000000-0000-4000-8000-000000000004', '36000000-0000-4000-8000-000000000005');

UPDATE `u891593158_doc`.`service_form_fields`
SET visibility_condition = JSON_OBJECT('all', JSON_ARRAY(
  JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'NOT_EQUALS', 'value', 'MOTORCYCLE'),
  JSON_OBJECT('field', 'engine.identification_mode', 'operator', 'EQUALS', 'value', 'MANUAL')
)), updated_at = UTC_TIMESTAMP()
WHERE id IN ('36000000-0000-4000-8000-000000000010', '36000000-0000-4000-8000-000000000011');

UPDATE `u891593158_doc`.`service_billing_items` sbi JOIN `u891593158_doc`.`billing_items` bi ON bi.id = sbi.billing_item_id
SET sbi.billing_mode = 'CONDITIONAL', sbi.condition_expression = '{"any":[{"all":[{"field":"vehicle_target.category","operator":"IN_LIST","values":["AUTOMOBILE","TRUCK","BUS"]},{"any":[{"field":"engine.power_variation_percent","operator":"NOT_EQUALS","value":0},{"field":"engine.cylinder_variation_percent","operator":"NOT_EQUALS","value":0},{"field":"vehicle_target.fuel","operator":"NOT_EQUALS","valueField":"vehicle_donor.fuel"}]}]},{"all":[{"field":"vehicle_target.category","operator":"EQUALS","value":"MOTORCYCLE"},{"field":"vehicle_target.fuel","operator":"NOT_EQUALS","valueField":"vehicle_donor.fuel"}]}]}'
WHERE sbi.service_version_id = '33000000-0000-4000-8000-000000000001' AND bi.code = 'MODIFICATION_REQUEST';

UPDATE `u891593158_doc`.`service_billing_items` sbi JOIN `u891593158_doc`.`billing_items` bi ON bi.id = sbi.billing_item_id
SET sbi.billing_mode = 'OPTIONAL', sbi.include_in_total = 0, sbi.visible_to_client = 0, sbi.visible_to_partner = 0, sbi.condition_expression = NULL
WHERE sbi.service_version_id = '33000000-0000-4000-8000-000000000001' AND bi.code = 'ITL_CSV_INSPECTION';

UPDATE `u891593158_doc`.`technical_rule_actions` a
JOIN `u891593158_doc`.`technical_rules` r ON r.id = a.technical_rule_id
SET a.action_type = 'SHOW_GUIDANCE', a.target_key = NULL, a.payload = JSON_OBJECT('message', 'Eventuais despesas externas de vistoria ou inspeção não estão incluídas no orçamento.')
WHERE a.target_key = 'ITL_CSV_INSPECTION'
  AND r.service_id = '31000000-0000-4000-8000-000000000001'
  AND r.service_version_id = '33000000-0000-4000-8000-000000000001';

UPDATE `u891593158_doc`.`technical_rules`
SET status = 'ARCHIVED', updated_at = UTC_TIMESTAMP()
WHERE id IN ('32000000-0000-4000-8000-000000000001', '32000000-0000-4000-8000-000000000002', '41000000-0000-4000-8000-000000000002', '41000000-0000-4000-8000-000000000003');

INSERT INTO `u891593158_doc`.`technical_rules` (id, service_id, service_version_id, name, description, vehicle_category_id, conditions, technical_limits, expected_result, status, priority, version)
VALUES
('43000000-0000-4000-8000-000000000001', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Veículo fora de São Paulo', 'O veículo está registrado fora do estado de São Paulo. Será necessária uma análise individual para verificar a disponibilidade do serviço e os procedimentos aplicáveis.', NULL, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.state', 'operator', 'NOT_EQUALS', 'value', 'SP'))), '{}', 'MANUAL_REVIEW', 'DRAFT', 1, 1),
('43000000-0000-4000-8000-000000000009', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Dados técnicos insuficientes', 'Potência, cilindrada e combustível dos veículos não foram informados em quantidade suficiente para uma análise automática.', NULL, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'IN_LIST', 'values', JSON_ARRAY('AUTOMOBILE', 'TRUCK', 'BUS')), JSON_OBJECT('any', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.power_cv', 'operator', 'EMPTY'), JSON_OBJECT('field', 'vehicle_target.engine_cc', 'operator', 'EMPTY'), JSON_OBJECT('field', 'vehicle_target.fuel', 'operator', 'EMPTY'), JSON_OBJECT('field', 'vehicle_donor.power_cv', 'operator', 'EMPTY'), JSON_OBJECT('field', 'vehicle_donor.engine_cc', 'operator', 'EMPTY'), JSON_OBJECT('field', 'vehicle_donor.fuel', 'operator', 'EMPTY'))))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 3, 1),
('43000000-0000-4000-8000-000000000002', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Motocicleta sem declaração de compatibilidade', 'A compatibilidade da cilindrada da motocicleta não foi confirmada.', '30000000-0000-4000-8000-000000000001', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'motorcycle.compatibility_declaration', 'operator', 'FALSE'))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 2, 1),
('43000000-0000-4000-8000-000000000003', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Motocicleta com compatibilidade declarada', 'Compatibilidade declarada para orçamento preliminar, sujeita à conferência documental.', '30000000-0000-4000-8000-000000000001', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'motorcycle.compatibility_declaration', 'operator', 'TRUE'))), JSON_OBJECT(), 'VIABLE', 'DRAFT', 10, 1),
('43000000-0000-4000-8000-000000000004', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel sem alteração fora dos limites', 'Mesma potência e cilindrada, com combustível compatível.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'EQUALS', 'value', 0), JSON_OBJECT('field', 'engine.cylinder_variation_percent', 'operator', 'EQUALS', 'value', 0), JSON_OBJECT('field', 'vehicle_target.fuel', 'operator', 'EQUALS', 'valueField', 'vehicle_donor.fuel'))), JSON_OBJECT(), 'VIABLE', 'DRAFT', 10, 1),
('43000000-0000-4000-8000-000000000008', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Automóvel com alteração dentro do limite', 'Qualquer alteração de potência, cilindrada ou combustível, desde que os aumentos de potência e cilindrada não ultrapassem 10%, exige solicitação de modificação.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('any', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'NOT_EQUALS', 'value', 0), JSON_OBJECT('field', 'engine.cylinder_variation_percent', 'operator', 'NOT_EQUALS', 'value', 0), JSON_OBJECT('field', 'vehicle_target.fuel', 'operator', 'NOT_EQUALS', 'valueField', 'vehicle_donor.fuel'))), JSON_OBJECT('any', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'EMPTY'), JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'LESS_OR_EQUAL', 'value', 10))), JSON_OBJECT('any', JSON_ARRAY(JSON_OBJECT('field', 'engine.cylinder_variation_percent', 'operator', 'EMPTY'), JSON_OBJECT('field', 'engine.cylinder_variation_percent', 'operator', 'LESS_OR_EQUAL', 'value', 10))))), JSON_OBJECT('max_increase_percent', 10), 'VIABLE_WITH_REQUIREMENTS', 'DRAFT', 20, 1),
('43000000-0000-4000-8000-000000000005', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Cilindrada acima de 10%', 'Aumento de cilindrada superior a 10% está fora dos critérios automáticos.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.cylinder_variation_percent', 'operator', 'GREATER_THAN', 'value', 10))), JSON_OBJECT('max_increase_percent', 10), 'OUT_OF_CRITERIA', 'DRAFT', 25, 1),
('43000000-0000-4000-8000-000000000011', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Potência acima de 10%', 'Aumento de potência superior a 10% está fora dos critérios automáticos.', '30000000-0000-4000-8000-000000000002', JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'GREATER_THAN', 'value', 10))), JSON_OBJECT('max_increase_percent', 10), 'OUT_OF_CRITERIA', 'DRAFT', 25, 1),
('43000000-0000-4000-8000-000000000006', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Caminhões e ônibus com alteração técnica', 'Caminhões e ônibus não possuem limite percentual automático nesta política; qualquer alteração de potência, cilindrada ou combustível exige modificação.', NULL, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'IN_LIST', 'values', JSON_ARRAY('TRUCK', 'BUS')), JSON_OBJECT('any', JSON_ARRAY(JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'NOT_EQUALS', 'value', 0), JSON_OBJECT('field', 'engine.cylinder_variation_percent', 'operator', 'NOT_EQUALS', 'value', 0), JSON_OBJECT('field', 'vehicle_target.fuel', 'operator', 'NOT_EQUALS', 'valueField', 'vehicle_donor.fuel'))))), JSON_OBJECT(), 'VIABLE_WITH_REQUIREMENTS', 'DRAFT', 20, 1),
('43000000-0000-4000-8000-000000000010', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Caminhões e ônibus sem alteração', 'Mesma potência, cilindrada e combustível.', NULL, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'IN_LIST', 'values', JSON_ARRAY('TRUCK', 'BUS')), JSON_OBJECT('field', 'engine.power_variation_percent', 'operator', 'EQUALS', 'value', 0), JSON_OBJECT('field', 'engine.cylinder_variation_percent', 'operator', 'EQUALS', 'value', 0), JSON_OBJECT('field', 'vehicle_target.fuel', 'operator', 'EQUALS', 'valueField', 'vehicle_donor.fuel'))), JSON_OBJECT(), 'VIABLE', 'DRAFT', 10, 1),
('43000000-0000-4000-8000-000000000007', '31000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'Categoria sem regra específica', 'A categoria informada ainda precisa de análise manual.', NULL, JSON_OBJECT('all', JSON_ARRAY(JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'NOT_IN_LIST', 'values', JSON_ARRAY('AUTOMOBILE', 'MOTORCYCLE', 'TRUCK', 'BUS')))), JSON_OBJECT(), 'MANUAL_REVIEW', 'DRAFT', 90, 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), conditions = VALUES(conditions), vehicle_category_id = VALUES(vehicle_category_id), expected_result = VALUES(expected_result), status = VALUES(status), priority = VALUES(priority), updated_at = UTC_TIMESTAMP();

INSERT INTO `u891593158_doc`.`service_documents` (id, service_version_id, document_code, name, description, requirement_type, condition_expression, display_order)
VALUES
('3A000000-0000-4000-8000-000000000003', '33000000-0000-4000-8000-000000000001', 'OWNER_IDENTIFICATION', 'Documento de identificação do proprietário', 'Se o recibo de transferência estiver preenchido, será considerado o comprador identificado no documento.', 'REQUIRED', NULL, 20),
('3A000000-0000-4000-8000-000000000004', '33000000-0000-4000-8000-000000000001', 'INSPECTION_REPORT', 'Laudo de vistoria', 'Se já realizada, a equipe poderá analisar o laudo, inclusive se estiver vencido; se não, será solicitado posteriormente.', 'REQUIRED', NULL, 30)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), requirement_type = VALUES(requirement_type), condition_expression = VALUES(condition_expression), display_order = VALUES(display_order), updated_at = UTC_TIMESTAMP();

UPDATE `u891593158_doc`.`service_documents` SET name = 'CRLV (Documento do veículo)', description = 'Documento do veículo.', requirement_type = 'REQUIRED', condition_expression = NULL, display_order = 10 WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND document_code = 'VEHICLE_REGISTRATION';
UPDATE `u891593158_doc`.`service_documents` SET name = 'Nota fiscal do motor', description = 'Nota fiscal do motor, caso possua.', requirement_type = 'CONDITIONAL', condition_expression = JSON_OBJECT('field', 'engine.has_invoice', 'operator', 'EQUALS', 'value', 'YES'), display_order = 40 WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND document_code = 'ENGINE_INVOICE';

INSERT INTO `u891593158_doc`.`service_messages` (id, service_version_id, message_key, severity, content, condition_expression, display_order)
VALUES
('44000000-0000-4000-8000-000000000001', '33000000-0000-4000-8000-000000000001', 'MANUAL_REVIEW_TITLE', 'WARNING', 'Seu cadastro não é viável pela análise automática.', NULL, 10),
('44000000-0000-4000-8000-000000000002', '33000000-0000-4000-8000-000000000001', 'MANUAL_REVIEW_GUIDANCE', 'INFO', 'Mas ainda é possível solicitar uma análise manual com um de nossos consultores.', NULL, 20),
('44000000-0000-4000-8000-000000000003', '33000000-0000-4000-8000-000000000001', 'DOCUMENTS_NOTE', 'INFO', 'Em casos de modificação veicular, nossa equipe poderá solicitar documentos adicionais.', NULL, 30),
('44000000-0000-4000-8000-000000000004', '33000000-0000-4000-8000-000000000001', 'EXTERNAL_EXPENSES', 'INFO', 'Eventuais despesas externas de vistoria ou inspeção não estão incluídas no orçamento e serão pagas diretamente às empresas responsáveis.', NULL, 40)
ON DUPLICATE KEY UPDATE severity = VALUES(severity), content = VALUES(content), condition_expression = VALUES(condition_expression), display_order = VALUES(display_order), updated_at = UTC_TIMESTAMP();

INSERT INTO `u891593158_doc`.`schema_migrations` (name)
SELECT '007_engine_rules_and_documents.sql'
WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE name = '007_engine_rules_and_documents.sql')
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_form_fields` WHERE id IN ('36000000-0000-4000-8000-000000000014', '36000000-0000-4000-8000-000000000015')) = 2
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`technical_rules` WHERE id IN ('43000000-0000-4000-8000-000000000001', '43000000-0000-4000-8000-000000000007')) = 2
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_documents` WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND document_code IN ('ENGINE_INVOICE', 'VEHICLE_REGISTRATION', 'OWNER_IDENTIFICATION', 'INSPECTION_REPORT')) = 4
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`technical_rules` WHERE id IN ('43000000-0000-4000-8000-000000000001', '43000000-0000-4000-8000-000000000002', '43000000-0000-4000-8000-000000000003', '43000000-0000-4000-8000-000000000004', '43000000-0000-4000-8000-000000000005', '43000000-0000-4000-8000-000000000006', '43000000-0000-4000-8000-000000000007', '43000000-0000-4000-8000-000000000008', '43000000-0000-4000-8000-000000000009', '43000000-0000-4000-8000-000000000010', '43000000-0000-4000-8000-000000000011')) = 11
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_messages` WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND message_key IN ('MANUAL_REVIEW_TITLE', 'MANUAL_REVIEW_GUIDANCE', 'DOCUMENTS_NOTE', 'EXTERNAL_EXPENSES')) = 4
  AND (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'u891593158_doc' AND table_name = 'application_settings' AND column_name IN ('manual_whatsapp', 'manual_team_name', 'manual_message_template')) = 3
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_billing_items` sbi JOIN `u891593158_doc`.`billing_items` bi ON bi.id = sbi.billing_item_id WHERE sbi.service_version_id = '33000000-0000-4000-8000-000000000001' AND bi.code = 'MODIFICATION_REQUEST') = 1
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_billing_items` sbi JOIN `u891593158_doc`.`billing_items` bi ON bi.id = sbi.billing_item_id WHERE sbi.service_version_id = '33000000-0000-4000-8000-000000000001' AND bi.code = 'ITL_CSV_INSPECTION' AND sbi.include_in_total = 0 AND sbi.visible_to_client = 0 AND sbi.visible_to_partner = 0) = 1;
