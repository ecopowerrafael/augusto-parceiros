-- Atualização da Migration 012
-- Gerado por scripts/generate-hostinger-sql.mjs.
-- Banco alvo: u891593158_doc.
-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.

USE `u891593158_doc`;
SELECT DATABASE() AS selected_database;

-- Doc Motor Fase 3.14: corrige a semântica declarativa dos checklists de contato.
-- A Migration 011 alterou os textos para perguntas diretas; esta migration ajusta
-- somente as condições das regras existentes, sem alterar a Migration 011.

UPDATE `u891593158_doc`.`technical_rules`
SET conditions = '{"any":[{"field":"suspension.clearance_check","operator":"IN_LIST","values":["NO","UNKNOWN"]},{"field":"suspension.contact_check","operator":"IN_LIST","values":["YES","UNKNOWN"]},{"field":"wheels.fender_check","operator":"IN_LIST","values":["NO","UNKNOWN"]},{"field":"wheels.contact_check","operator":"IN_LIST","values":["YES","UNKNOWN"]},{"field":"wheels.diameter_check","operator":"IN_LIST","values":["NO","UNKNOWN"]}]}',
    description = 'Contato confirmado, medida fora do requisito ou resposta desconhecida exige análise manual.'
WHERE id = '5A000000-0000-4000-8000-000000000002'
  AND service_version_id = '57000000-0000-4000-8000-000000000001';

UPDATE `u891593158_doc`.`technical_rules`
SET conditions = '{"all":[{"field":"vehicle_target.category","operator":"IN_LIST","values":["AUTOMOBILE","PICKUP"]},{"field":"suspension.compliance","operator":"EQUALS","value":"UNKNOWN"},{"field":"suspension.clearance_check","operator":"EQUALS","value":"YES"},{"field":"suspension.contact_check","operator":"EQUALS","value":"NO"},{"any":[{"field":"wheels.include","operator":"EQUALS","value":"NO"},{"all":[{"field":"wheels.compliance","operator":"EQUALS","value":"UNKNOWN"},{"field":"wheels.fender_check","operator":"EQUALS","value":"YES"},{"field":"wheels.contact_check","operator":"EQUALS","value":"NO"},{"field":"wheels.diameter_check","operator":"EQUALS","value":"YES"}]}]}]}',
    description = 'Checklist compatível: ausência de contato e respostas favoráveis permitem análise preliminar condicionada.'
WHERE id = '5A000000-0000-4000-8000-000000000006'
  AND service_version_id = '57000000-0000-4000-8000-000000000001';

INSERT INTO `u891593158_doc`.`schema_migrations` (name)
SELECT '012_suspension_checklist_semantics.sql'
WHERE NOT EXISTS (SELECT 1 FROM `u891593158_doc`.`schema_migrations` WHERE name = '012_suspension_checklist_semantics.sql')
  AND (SELECT COUNT(*) FROM `u891593158_doc`.`technical_rules` WHERE service_version_id = '57000000-0000-4000-8000-000000000001' AND id IN ('5A000000-0000-4000-8000-000000000002', '5A000000-0000-4000-8000-000000000006') AND JSON_VALID(conditions) = 1) = 2;
