import { describe, expect, it } from 'vitest'
import { evaluateMotor, motorFormDefinition } from './motor-flow.js'

const charges = [
  { code: 'ENGINE_REGISTRATION', name: 'Cadastro de motor', billing_mode: 'REQUIRED', default_amount_cents: 30000, quantity: 1, include_in_total: 1 },
  { code: 'TRANSFER_FEE', name: 'Taxa de transferência', billing_mode: 'REQUIRED', default_amount_cents: 29580, quantity: 1, include_in_total: 1 },
  { code: 'MODIFICATION_REQUEST', name: 'Solicitação de modificação', billing_mode: 'CONDITIONAL', default_amount_cents: 16000, quantity: 1, include_in_total: 1, condition_expression: { field: 'engine.power_variation_percent', operator: 'NOT_EQUALS', value: 0 } },
]

const base = { 'vehicle_target.plate': 'ABC1D23', 'vehicle_target.category': 'AUTOMOBILE', 'vehicle_target.state': 'SP', 'vehicle_target.power_cv': 100, 'vehicle_target.engine_cc': 1600, 'vehicle_target.fuel': 'FLEX', 'engine.has_invoice': 'YES', 'engine.identification_mode': 'MANUAL', 'vehicle_donor.power_cv': 100, 'vehicle_donor.engine_cc': 1600, 'vehicle_donor.fuel': 'FLEX' }

describe('fluxo híbrido de regularização de motor', () => {
  it('expõe contrato versionado sem depender do editor persistido', () => {
    const definition = motorFormDefinition()
    expect(definition.implementation).toBe('MOTOR_V1')
    expect(definition.fields.some((field) => field.field_key === 'motorcycle.compatibility_declaration')).toBe(true)
    expect(definition.options['vehicle_target.state']).toEqual([{ value: 'SP', label: 'São Paulo' }, { value: 'OTHER_STATE', label: 'Outros estados' }])
  })

  it('mantém motocicleta com declaração como viável sem potência/cilindrada', () => {
    const result = evaluateMotor({ answers: { 'vehicle_target.plate': 'ABC1D23', 'vehicle_target.category': 'MOTORCYCLE', 'vehicle_target.state': 'SP', 'engine.has_invoice': 'NO', 'motorcycle.compatibility_declaration': true }, billingItems: charges })
    expect(result.viability).toBe('VIABLE')
    expect(result.commercial_available).toBe(true)
  })

  it('encaminha motocicleta sem declaração para análise manual', () => {
    const result = evaluateMotor({ answers: { ...base, 'vehicle_target.category': 'MOTORCYCLE', 'engine.has_invoice': 'YES', 'motorcycle.compatibility_declaration': false }, billingItems: charges })
    expect(result.viability).toBe('MANUAL_REVIEW')
    expect(result.total_cents).toBeNull()
  })

  it('preserva o limite de 10% e bloqueia aumento superior', () => {
    const within = evaluateMotor({ answers: { ...base, 'vehicle_donor.power_cv': 110 }, billingItems: charges })
    const above = evaluateMotor({ answers: { ...base, 'vehicle_donor.power_cv': 111 }, billingItems: charges })
    expect(within.viability).toBe('VIABLE_WITH_REQUIREMENTS')
    expect(above.viability).toBe('OUT_OF_CRITERIA')
    expect(above.total_cents).toBeNull()
  })

  it('encaminha estado diferente de SP e origem desconhecida para análise manual', () => {
    const otherState = evaluateMotor({ answers: { ...base, 'vehicle_target.state': 'OTHER_STATE' }, billingItems: charges })
    const unknown = evaluateMotor({ answers: { ...base, 'engine.identification_mode': 'UNKNOWN' }, billingItems: charges })
    expect(otherState.viability).toBe('MANUAL_REVIEW')
    expect(unknown.viability).toBe('MANUAL_REVIEW')
  })
})
