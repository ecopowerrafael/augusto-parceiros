import { describe, expect, it } from 'vitest'
import { buildManualWhatsAppMessage, visiblePresentationFields } from './presentation'

describe('apresentação da análise manual', () => {
  const fields = [
    { field_key: 'vehicle_target.category', label: 'Categoria', field_type: 'SINGLE_SELECT' },
    { field_key: 'vehicle_target.engine_cc', label: 'Cilindrada original', field_type: 'INTEGER' },
    { field_key: 'vehicle_donor.engine_cc', label: 'Cilindrada do motor', field_type: 'INTEGER', visibility_condition: { field: 'engine.identification_mode', operator: 'EQUALS', value: 'PLATE' } },
    { field_key: 'internal.hidden', label: 'Interno', field_type: 'TEXT' },
  ]
  it('remove campos ocultos e valores vazios', () => { expect(visiblePresentationFields(fields, { 'vehicle_target.category': 'AUTOMOBILE', 'vehicle_target.engine_cc': 2000, 'internal.hidden': '' }).map((field) => field.field_key)).toEqual(['vehicle_target.category', 'vehicle_target.engine_cc']) })
  it('gera WhatsApp com rótulos amigáveis e sem chaves internas', () => { const message = buildManualWhatsAppMessage({ serviceName: 'Cadastro de Motor', fields, values: { 'vehicle_target.category': 'AUTOMOBILE', 'vehicle_target.engine_cc': 2000 }, reasons: ['Dados insuficientes'] }); expect(message).toContain('Cilindrada original: 2.000 cm³'); expect(message).toContain('Automóvel'); expect(message).not.toContain('vehicle_target.') })
  it('usa rótulos persistidos para opções e modificações repetíveis', () => { const message = buildManualWhatsAppMessage({ serviceName: 'Regularização de suspensão', fields: [{ field_key: 'vehicle_target.state', label: 'UF do veículo', field_type: 'SINGLE_SELECT' }, { field_key: 'modifications.additional', label: 'Modificações adicionais', field_type: 'REPEATABLE_MODIFICATIONS' }], values: { 'vehicle_target.state': 'SP', 'modifications.additional': [{ code: 'COLOR_CHANGE', description: 'Pintura preta' }] }, presentation: { options: { 'vehicle_target.state': { SP: 'São Paulo' } }, modifications: { COLOR_CHANGE: { name: 'Alteração de cor' } } } }); expect(message).toContain('Estado: São Paulo'); expect(message).toContain('Alteração de cor — Pintura preta'); expect(message).not.toContain('COLOR_CHANGE') })
})
