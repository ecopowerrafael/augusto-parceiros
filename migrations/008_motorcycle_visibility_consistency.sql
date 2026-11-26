-- Doc Motor Fase 3.11: tornar a identificação do motor não aplicável a motocicletas.
-- Migration incremental e não destrutiva. Não executar migrations anteriores novamente.

UPDATE service_form_fields
SET is_required = 1,
    visibility_condition = JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'IN_LIST', 'values', JSON_ARRAY('AUTOMOBILE', 'TRUCK', 'BUS')),
    required_condition = JSON_OBJECT('field', 'vehicle_target.category', 'operator', 'IN_LIST', 'values', JSON_ARRAY('AUTOMOBILE', 'TRUCK', 'BUS')),
    updated_at = UTC_TIMESTAMP()
WHERE service_version_id = '33000000-0000-4000-8000-000000000001'
  AND field_key = 'engine.identification_mode';

UPDATE service_form_fields
SET description = 'Ambiente de simulação: informe dados técnicos fictícios do veículo de origem. A integração operacional com provedor externo será implementada na Fase 4.',
    updated_at = UTC_TIMESTAMP()
WHERE service_version_id = '33000000-0000-4000-8000-000000000001'
  AND field_key = 'engine.identification_mode';

UPDATE service_form_fields
SET description = 'Atenção: motocicletas somente podem ser cadastradas automaticamente com motor de mesma cilindrada original, independentemente do ano de fabricação do motor ou da motocicleta. Um motor de 150 ou 160 cilindradas não pode ser cadastrado automaticamente em motocicleta de 125 cilindradas, ou vice-versa.',
    updated_at = UTC_TIMESTAMP()
WHERE service_version_id = '33000000-0000-4000-8000-000000000001'
  AND field_key = 'motorcycle.compatibility_declaration';

INSERT INTO schema_migrations (name)
SELECT '008_motorcycle_visibility_consistency.sql'
WHERE NOT EXISTS (SELECT 1 FROM schema_migrations WHERE name = '008_motorcycle_visibility_consistency.sql')
  AND (SELECT COUNT(*) FROM service_form_fields WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND field_key = 'engine.identification_mode' AND is_required = 1 AND visibility_condition IS NOT NULL AND required_condition IS NOT NULL) = 1;
