import { describe, expect, it } from 'vitest'
import { evaluateSuspension, SUSPENSION_FIELDS, suspensionFormDefinition } from './suspension-flow.js'

const billing = [
  { code: 'TRANSFER_FEE', billing_mode: 'REQUIRED', default_amount_cents: 29580, quantity: 1, include_in_total: 1 },
  { code: 'SERVICE_FEE', billing_mode: 'REQUIRED', default_amount_cents: 16000, quantity: 1, include_in_total: 1 },
  { code: 'SUSPENSION_REGULARIZATION', billing_mode: 'REQUIRED', default_amount_cents: 30000, quantity: 1, include_in_total: 1 },
  { code: 'MERCOSUR_PLATE_AUTHORIZATION', billing_mode: 'CONDITIONAL', default_amount_cents: 22000, quantity: 1, include_in_total: 1, condition_expression: { field: 'vehicle_target.plate_pattern', operator: 'EQUALS', value: 'OLD' } },
  { code: 'WHEELS_TIRES_REGULARIZATION', billing_mode: 'CONDITIONAL', default_amount_cents: 30000, quantity: 1, include_in_total: 1, condition_expression: { field: 'wheels.include', operator: 'EQUALS', value: 'YES' } },
  { code: 'ADDITIONAL_MODIFICATION', billing_mode: 'CONDITIONAL', default_amount_cents: 30000, quantity_expression: { field: 'modifications.additional', operator: 'COUNT_FILLED' }, include_in_total: 1, condition_expression: { field: 'modifications.additional', operator: 'COUNT_FILLED' } },
]
const catalog = [{ code: 'COLOR_CHANGE', name: 'Mudança de cor', status: 'ACTIVE', vehicle_category_codes: ['AUTOMOBILE'], ufs: ['SP'] }, { code: 'OTHER_MODIFICATION', name: 'Outra modificação', status: 'ACTIVE', requires_description: 1, vehicle_category_codes: ['AUTOMOBILE'], ufs: ['SP'] }]
const base = { 'vehicle_target.plate': 'ABC1D23', 'vehicle_target.category': 'AUTOMOBILE', 'vehicle_target.state': 'SP', 'suspension.change_type': 'LOWERING', 'suspension.type': 'FIXED', 'suspension.already_done': 'YES', 'suspension.prior_authorization': 'NO', 'suspension.compliance': 'YES', 'wheels.include': 'NO', 'modifications.include': 'NO', 'suspension.parts_invoice': 'YES', 'suspension.installation_invoice': 'YES' }

describe('SUSPENSION_V1', () => {
  it('mantém definição própria, somente SP e outros estados, sem PBT', () => {
    const definition = suspensionFormDefinition(catalog)
    expect(definition.fields).toBe(SUSPENSION_FIELDS)
    expect(definition.options['vehicle_target.state']).toEqual([{ value: 'SP', label: 'São Paulo' }, { value: 'OTHER_STATE', label: 'Outros estados' }])
    expect(definition.fields.some((field) => field.field_key === 'vehicle_target.pbt_kg')).toBe(false)
  })
  it('calcula suspensão + Mercosul com honorário único', () => {
    expect(evaluateSuspension({ answers: base, billingItems: billing, modificationCatalog: catalog }).total_cents).toBe(75580)
  })
  it('cobra placa antiga, rodas e duas modificações sem duplicar honorário', () => {
    const result = evaluateSuspension({ answers: { ...base, 'vehicle_target.plate': 'ABC-1234', 'wheels.include': 'YES', 'wheels.compliance': 'YES', 'modifications.include': 'YES', 'modifications.additional': [{ code: 'COLOR_CHANGE' }, { code: 'OTHER_MODIFICATION', description: 'Alteração diversa' }] }, billingItems: billing, modificationCatalog: catalog })
    expect(result.total_cents).toBe(187580)
    expect(result.items.filter((item) => item.code === 'SERVICE_FEE')).toHaveLength(1)
  })
  it('mantém os valores de referência de todos os cenários comerciais', () => {
    const one = { code: 'COLOR_CHANGE' }; const two = { code: 'OTHER_MODIFICATION', description: 'Alteração diversa' }
    const scenarios = [
      [{ ...base, 'vehicle_target.plate': 'ABC-1234' }, 97580],
      [{ ...base, 'wheels.include': 'YES', 'wheels.compliance': 'YES' }, 105580],
      [{ ...base, 'modifications.include': 'YES', 'modifications.additional': [one] }, 105580],
      [{ ...base, 'modifications.include': 'YES', 'modifications.additional': [one, two] }, 135580],
      [{ ...base, 'vehicle_target.plate': 'ABC-1234', 'wheels.include': 'YES', 'wheels.compliance': 'YES', 'modifications.include': 'YES', 'modifications.additional': [one, two] }, 187580],
    ]
    for (const [answers, expected] of scenarios) expect(evaluateSuspension({ answers, billingItems: billing, modificationCatalog: catalog }).total_cents).toBe(expected)
  })
  it('encaminha contato confirmado, desconhecido e outros estados para análise manual', () => {
    for (const answers of [{ ...base, 'suspension.compliance': 'NO' }, { ...base, 'suspension.compliance': 'UNKNOWN', 'suspension.clearance_check': 'YES', 'suspension.contact_check': 'CONTACT_PRESENT' }, { ...base, 'vehicle_target.state': 'OTHER_STATE' }]) {
      expect(evaluateSuspension({ answers, billingItems: billing, modificationCatalog: catalog }).viability).toBe('MANUAL_REVIEW')
    }
  })
  it('preserva o checklist favorável como viável com exigências', () => {
    const result = evaluateSuspension({ answers: { ...base, 'suspension.compliance': 'UNKNOWN', 'suspension.clearance_check': 'YES', 'suspension.contact_check': 'NO_CONTACT' }, billingItems: billing, modificationCatalog: catalog })
    expect(result.viability).toBe('VIABLE_WITH_REQUIREMENTS')
  })
  it('cobre todas as combinações favoráveis entre suspensão e rodas', () => {
    const cases = [
      [{ ...base, 'wheels.include': 'YES', 'wheels.compliance': 'YES' }, 'VIABLE'],
      [{ ...base, 'wheels.include': 'YES', 'wheels.compliance': 'UNKNOWN', 'wheels.fender_check': 'YES', 'wheels.contact_check': 'NO_CONTACT', 'wheels.diameter_check': 'YES' }, 'VIABLE_WITH_REQUIREMENTS'],
      [{ ...base, 'suspension.compliance': 'UNKNOWN', 'suspension.clearance_check': 'YES', 'suspension.contact_check': 'NO_CONTACT', 'wheels.include': 'YES', 'wheels.compliance': 'YES' }, 'VIABLE_WITH_REQUIREMENTS'],
      [{ ...base, 'suspension.compliance': 'UNKNOWN', 'suspension.clearance_check': 'YES', 'suspension.contact_check': 'NO_CONTACT', 'wheels.include': 'YES', 'wheels.compliance': 'UNKNOWN', 'wheels.fender_check': 'YES', 'wheels.contact_check': 'NO_CONTACT', 'wheels.diameter_check': 'YES' }, 'VIABLE_WITH_REQUIREMENTS'],
    ]
    for (const [answers, expected] of cases) expect(evaluateSuspension({ answers, billingItems: billing, modificationCatalog: catalog }).viability).toBe(expected)
  })
  it('rejeita duplicidade e cadastro de motor como modificação adicional', () => {
    expect(() => evaluateSuspension({ answers: { ...base, 'modifications.include': 'YES', 'modifications.additional': [{ code: 'COLOR_CHANGE' }, { code: 'COLOR_CHANGE' }] }, billingItems: billing, modificationCatalog: catalog })).toThrow('INVALID_SIMULATION_INPUT')
    expect(() => evaluateSuspension({ answers: { ...base, 'modifications.include': 'YES', 'modifications.additional': [{ code: 'ENGINE_REGISTRATION' }] }, billingItems: billing, modificationCatalog: catalog })).toThrow('INVALID_SIMULATION_INPUT')
  })
  it('rejeita códigos desconhecidos mesmo com catálogo vazio e ignora fixtureContext', () => {
    expect(() => evaluateSuspension({ answers: { ...base, 'modifications.include': 'YES', 'modifications.additional': [{ code: 'NOT_IN_CATALOG' }] }, fixtureContext: { 'vehicle_target.category': 'AUTOMOBILE' }, billingItems: billing, modificationCatalog: [] })).toThrow('INVALID_SIMULATION_INPUT')
    const result = evaluateSuspension({ answers: base, fixtureContext: { 'vehicle_target.category': 'MOTORCYCLE' }, billingItems: billing, modificationCatalog: catalog })
    expect(result.viability).toBe('VIABLE')
  })
  it('limpa campos ocultos e rejeita catálogo inativo, limite e outras duplicadas', () => {
    const hidden = evaluateSuspension({ answers: { ...base, 'suspension.clearance_check': 'NO', 'suspension.contact_check': 'CONTACT_PRESENT', 'wheels.compliance': 'NO' }, billingItems: billing, modificationCatalog: catalog })
    expect(hidden.values['suspension.clearance_check']).toBeUndefined()
    const inactive = [{ ...catalog[0], status: 'INACTIVE' }]
    expect(() => evaluateSuspension({ answers: { ...base, 'modifications.include': 'YES', 'modifications.additional': [{ code: 'COLOR_CHANGE' }] }, billingItems: billing, modificationCatalog: inactive })).toThrow('INVALID_SIMULATION_INPUT')
    expect(() => evaluateSuspension({ answers: { ...base, 'modifications.include': 'YES', 'modifications.additional': [{ code: 'OTHER_MODIFICATION', description: 'A' }, { code: 'OTHER_MODIFICATION', description: 'A' }] }, billingItems: billing, modificationCatalog: catalog })).toThrow('INVALID_SIMULATION_INPUT')
    expect(() => evaluateSuspension({ answers: { ...base, 'modifications.include': 'YES', 'modifications.additional': Array.from({ length: 11 }, (_, index) => ({ code: index ? 'COLOR_CHANGE' : 'OTHER_MODIFICATION', description: String(index) })) }, billingItems: billing, modificationCatalog: catalog })).toThrow('INVALID_SIMULATION_INPUT')
  })
  it('mantém os campos documentais no resultado e sinaliza contradição sem alterar o preço', () => {
    const result = evaluateSuspension({ answers: { ...base, 'suspension.installation_invoice': 'NOT_PERFORMED' }, billingItems: billing, modificationCatalog: catalog })
    expect(result.values['suspension.parts_invoice']).toBe('YES')
    expect(result.values['suspension.installation_invoice']).toBe('NOT_PERFORMED')
    expect(result.messages.some((message) => message.message_key === 'DOCUMENTARY_CONTRADICTION')).toBe(true)
    expect(result.total_cents).toBe(75580)
  })
})
