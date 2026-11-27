-- Atualização da Migration 011
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Doc Motor Fase 3.14: semântica dos formulários e regra declarativa de UF.
-- Migration incremental, não destrutiva e destinada à importação manual.

UPDATE `u891593158_doc`.`service_form_fields` f
JOIN `u891593158_doc`.`service_versions` v ON v.id = f.service_version_id
JOIN `u891593158_doc`.`services` s ON s.id = v.service_id
SET f.label = CASE f.field_key
  WHEN 'suspension.contact_check' THEN 'Durante o funcionamento da suspensão, as rodas ou pneus encostam em alguma parte do veículo?'
  WHEN 'wheels.contact_check' THEN 'Os pneus encostam na carroceria, suspensão ou em outros componentes do veículo?'
  WHEN 'suspension.clearance_check' THEN 'O veículo possui a altura mínima exigida?'
  WHEN 'wheels.fender_check' THEN 'Os pneus estão dentro dos limites dos para-lamas?'
  WHEN 'wheels.diameter_check' THEN 'O diâmetro externo respeita a tolerância aplicável ao veículo?'
END,
f.updated_at = UTC_TIMESTAMP()
WHERE s.code = 'LOWERED_SUSPENSION'
  AND v.version_number = 1
  AND f.field_key IN ('suspension.contact_check', 'wheels.contact_check', 'suspension.clearance_check', 'wheels.fender_check', 'wheels.diameter_check');

UPDATE `u891593158_doc`.`service_field_options` o
JOIN `u891593158_doc`.`service_form_fields` f ON f.id = o.field_id
JOIN `u891593158_doc`.`service_versions` v ON v.id = f.service_version_id
JOIN `u891593158_doc`.`services` s ON s.id = v.service_id
SET o.option_label = CASE CONCAT(f.field_key, ':', o.option_value)
  WHEN 'suspension.contact_check:YES' THEN 'Sim, existe contato.'
  WHEN 'suspension.contact_check:NO' THEN 'Não, não existe contato.'
  WHEN 'suspension.contact_check:UNKNOWN' THEN 'Não sei informar.'
  WHEN 'wheels.contact_check:YES' THEN 'Sim, os pneus encostam.'
  WHEN 'wheels.contact_check:NO' THEN 'Não, os pneus não encostam.'
  WHEN 'wheels.contact_check:UNKNOWN' THEN 'Não sei informar.'
  WHEN 'suspension.clearance_check:YES' THEN 'Sim, possui a altura mínima exigida.'
  WHEN 'suspension.clearance_check:NO' THEN 'Não, está abaixo da altura mínima exigida.'
  WHEN 'suspension.clearance_check:UNKNOWN' THEN 'Não sei informar.'
  WHEN 'wheels.fender_check:YES' THEN 'Sim, os pneus estão dentro dos limites.'
  WHEN 'wheels.fender_check:NO' THEN 'Não, os pneus ultrapassam os limites.'
  WHEN 'wheels.fender_check:UNKNOWN' THEN 'Não sei informar.'
  WHEN 'wheels.diameter_check:YES' THEN 'Sim, respeita a tolerância aplicável.'
  WHEN 'wheels.diameter_check:NO' THEN 'Não, está fora da tolerância aplicável.'
  WHEN 'wheels.diameter_check:UNKNOWN' THEN 'Não sei informar.'
  ELSE o.option_label
END
WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1
  AND f.field_key IN ('suspension.contact_check', 'wheels.contact_check', 'suspension.clearance_check', 'wheels.fender_check', 'wheels.diameter_check');

INSERT INTO `u891593158_doc`.`technical_rules` (id, service_id, service_version_id, name, description, conditions, expected_result, status, priority, version)
SELECT '5A000000-0000-4000-8000-000000000008', s.id, v.id,
  'Veículo fora de São Paulo',
  'Veículos registrados fora de São Paulo exigem análise manual; não há viabilidade automática nesta configuração.',
  '{"field":"vehicle_target.state","operator":"EQUALS","value":"OTHER_STATE"}',
  'MANUAL_REVIEW', 'DRAFT', 1, 1
FROM `u891593158_doc`.`services` s JOIN `u891593158_doc`.`service_versions` v ON v.service_id = s.id
WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1
  AND NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`technical_rules` r WHERE r.id = '5A000000-0000-4000-8000-000000000008');

INSERT INTO `u891593158_doc`.`schema_migrations` (name)
SELECT '011_suspension_form_usability.sql'
WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE name = '011_suspension_form_usability.sql')
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_form_fields` f JOIN `u891593158_doc`.`service_versions` v ON v.id = f.service_version_id JOIN `u891593158_doc`.`services` s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' AND f.field_key IN ('suspension.contact_check', 'wheels.contact_check', 'suspension.clearance_check', 'wheels.fender_check', 'wheels.diameter_check')) = 5
  AND EXISTS (SELECT 1 FROM `u891593158_doc`.`technical_rules` WHERE id = '5A000000-0000-4000-8000-000000000008');
