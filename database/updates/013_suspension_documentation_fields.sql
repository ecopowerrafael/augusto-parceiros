-- Atualização da Migration 013
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Doc Motor Fase 3.16: documentação da modificação de suspensão.
-- Migration incremental, idempotente e não destrutiva. Executar manualmente após o precheck.

INSERT INTO `u891593158_doc`.`service_form_sections` (id, service_version_id, stable_key, label, description, display_order)
SELECT '52000000-0000-4000-8000-000000000005', v.id, 'documentation',
       'Documentação da modificação',
       'Informe a situação das notas fiscais das peças e do serviço.', 50
FROM `u891593158_doc`.`service_versions` v
JOIN `u891593158_doc`.`services` s ON s.id = v.service_id
WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1
ON DUPLICATE KEY UPDATE label = VALUES(label), description = VALUES(description), display_order = VALUES(display_order);

INSERT INTO `u891593158_doc`.`service_form_fields`
  (id, service_version_id, section_id, field_key, label, description, field_type,
   default_value, is_required, is_editable, display_order, data_origin)
SELECT x.id, v.id, sec.id, x.field_key, x.label, x.description, 'SINGLE_SELECT',
       NULL, 1, 1, x.display_order, 'MANUAL'
FROM `u891593158_doc`.`service_versions` v
JOIN `u891593158_doc`.`services` s ON s.id = v.service_id
JOIN `u891593158_doc`.`service_form_sections` sec ON sec.service_version_id = v.id AND sec.stable_key = 'documentation'
JOIN (
  SELECT '53000000-0000-4000-8000-000000000016' id,
         'suspension.parts_invoice' field_key,
         'Nota fiscal das peças' label,
         'Esta informação é orientativa e será considerada na análise documental.' description,
         10 display_order
  UNION ALL
  SELECT '53000000-0000-4000-8000-000000000017',
         'suspension.installation_invoice',
         'Nota fiscal do serviço de instalação',
         'Esta informação é orientativa e não garante aprovação oficial.' description,
         20
) x ON 1 = 1
WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1
ON DUPLICATE KEY UPDATE
  section_id = VALUES(section_id), label = VALUES(label), description = VALUES(description),
  field_type = VALUES(field_type), is_required = VALUES(is_required), display_order = VALUES(display_order),
  default_value = NULL;

INSERT INTO `u891593158_doc`.`service_field_options` (id, field_id, option_value, option_label, display_order)
SELECT x.id, f.id, x.option_value, x.option_label, x.display_order
FROM `u891593158_doc`.`service_form_fields` f
JOIN `u891593158_doc`.`service_versions` v ON v.id = f.service_version_id
JOIN `u891593158_doc`.`services` s ON s.id = v.service_id
JOIN (
  SELECT '54000000-0000-4000-8000-000000000039' id, 'suspension.parts_invoice' field_key, 'YES' option_value, 'Sim, possuo nota fiscal das peças.' option_label, 10 display_order
  UNION ALL SELECT '54000000-0000-4000-8000-000000000040', 'suspension.parts_invoice', 'NO', 'Não possuo nota fiscal das peças.', 20
  UNION ALL SELECT '54000000-0000-4000-8000-000000000041', 'suspension.parts_invoice', 'NOT_PURCHASED', 'Ainda não comprei as peças.', 30
  UNION ALL SELECT '54000000-0000-4000-8000-000000000042', 'suspension.installation_invoice', 'YES', 'Sim, possuo nota fiscal do serviço.', 10
  UNION ALL SELECT '54000000-0000-4000-8000-000000000043', 'suspension.installation_invoice', 'NO', 'Não possuo nota fiscal do serviço.', 20
  UNION ALL SELECT '54000000-0000-4000-8000-000000000044', 'suspension.installation_invoice', 'NOT_PERFORMED', 'Ainda não realizei o serviço.', 30
) x ON x.field_key = f.field_key
WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1
ON DUPLICATE KEY UPDATE option_label = VALUES(option_label), display_order = VALUES(display_order);

INSERT INTO `u891593158_doc`.`schema_migrations` (name)
SELECT '013_suspension_documentation_fields.sql'
WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE name = '013_suspension_documentation_fields.sql')
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_form_fields` f JOIN `u891593158_doc`.`service_versions` v ON v.id = f.service_version_id JOIN `u891593158_doc`.`services` s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1 AND f.field_key IN ('suspension.parts_invoice', 'suspension.installation_invoice') AND f.is_required = 1 AND f.default_value IS NULL) = 2
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`service_field_options` o JOIN `u891593158_doc`.`service_form_fields` f ON f.id = o.field_id JOIN `u891593158_doc`.`service_versions` v ON v.id = f.service_version_id JOIN `u891593158_doc`.`services` s ON s.id = v.service_id WHERE s.code = 'LOWERED_SUSPENSION' AND v.version_number = 1 AND o.option_value IN ('YES', 'NO', 'NOT_PURCHASED', 'NOT_PERFORMED')) = 6;
