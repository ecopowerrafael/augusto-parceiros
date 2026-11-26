import { describe, expect, it } from 'vitest'
import { evaluateService } from './service-config.js'

const fields = [
  { field_key: 'vehicle_target.category', field_type: 'SINGLE_SELECT' },
  { field_key: 'vehicle_target.power_cv', field_type: 'DECIMAL' },
  { field_key: 'vehicle_target.engine_cc', field_type: 'INTEGER' },
  { field_key: 'vehicle_target.fuel', field_type: 'SINGLE_SELECT' },
  { field_key: 'engine.identification_mode', field_type: 'SINGLE_SELECT', is_required: 1, visibility_condition: { field: 'vehicle_target.category', operator: 'IN_LIST', values: ['AUTOMOBILE', 'TRUCK', 'BUS'] }, required_condition: { field: 'vehicle_target.category', operator: 'IN_LIST', values: ['AUTOMOBILE', 'TRUCK', 'BUS'] } },
  { field_key: 'vehicle_donor.plate', field_type: 'VEHICLE_PLATE', visibility_condition: { all: [{ field: 'vehicle_target.category', operator: 'IN_LIST', values: ['AUTOMOBILE', 'TRUCK', 'BUS'] }, { field: 'engine.identification_mode', operator: 'EQUALS', value: 'PLATE' }] } },
  { field_key: 'vehicle_donor.power_cv', field_type: 'DECIMAL', visibility_condition: { all: [{ field: 'vehicle_target.category', operator: 'IN_LIST', values: ['AUTOMOBILE', 'TRUCK', 'BUS'] }, { field: 'engine.identification_mode', operator: 'IN_LIST', values: ['PLATE', 'MANUAL'] }] } },
  { field_key: 'vehicle_donor.engine_cc', field_type: 'INTEGER', visibility_condition: { all: [{ field: 'vehicle_target.category', operator: 'IN_LIST', values: ['AUTOMOBILE', 'TRUCK', 'BUS'] }, { field: 'engine.identification_mode', operator: 'IN_LIST', values: ['PLATE', 'MANUAL'] }] } },
  { field_key: 'vehicle_donor.fuel', field_type: 'SINGLE_SELECT', visibility_condition: { all: [{ field: 'vehicle_target.category', operator: 'IN_LIST', values: ['AUTOMOBILE', 'TRUCK', 'BUS'] }, { field: 'engine.identification_mode', operator: 'IN_LIST', values: ['PLATE', 'MANUAL'] }] } },
  { field_key: 'motorcycle.compatibility_declaration', field_type: 'CHECKBOX', visibility_condition: { field: 'vehicle_target.category', operator: 'EQUALS', value: 'MOTORCYCLE' } },
]

const rules = [
  { name: 'motocicleta compatível', priority: 10, expected_result: 'VIABLE', conditions: { all: [{ field: 'vehicle_target.category', operator: 'EQUALS', value: 'MOTORCYCLE' }, { field: 'motorcycle.compatibility_declaration', operator: 'TRUE' }] }, actions: [] },
  { name: 'dados técnicos ausentes', priority: 20, expected_result: 'MANUAL_REVIEW', conditions: { all: [{ field: 'vehicle_target.category', operator: 'IN_LIST', values: ['AUTOMOBILE', 'TRUCK', 'BUS'] }, { any: [{ field: 'vehicle_target.power_cv', operator: 'EMPTY' }, { field: 'vehicle_donor.power_cv', operator: 'EMPTY' }] }] }, actions: [] },
]

describe('Fase 3.12 — fluxo final do simulador', () => {
  it('não exige identificação do motor quando a categoria ainda está vazia', () => {
    const result = evaluateService({ fields, rules, answers: {} })
    expect(result.values['engine.identification_mode']).toBeUndefined()
  })

  it('permite motocicleta declarada sem modo, potência ou cilindrada do doador', () => {
    const result = evaluateService({ fields, rules: [rules[0]], answers: { 'vehicle_target.category': 'MOTORCYCLE', 'vehicle_target.plate': 'AAA1234', 'vehicle_target.state': 'SP', 'engine.has_invoice': 'YES', 'motorcycle.compatibility_declaration': true } })
    expect(result.viability).toBe('VIABLE')
    expect(result.values['engine.identification_mode']).toBeUndefined()
    expect(result.values['vehicle_donor.engine_cc']).toBeUndefined()
  })

  it('aceita dados técnicos manuais no modo PLATE sem chamar integração externa', () => {
    const result = evaluateService({ fields, rules, answers: { 'vehicle_target.category': 'AUTOMOBILE', 'engine.identification_mode': 'PLATE', 'vehicle_donor.plate': 'ABC1234', 'vehicle_donor.power_cv': 100, 'vehicle_donor.engine_cc': 2000, 'vehicle_donor.fuel': 'GASOLINE' } })
    expect(result.values['vehicle_donor.power_cv']).toBe(100)
    expect(result.values['vehicle_donor.engine_cc']).toBe(2000)
    expect(result.values['vehicle_donor.fuel']).toBe('GASOLINE')
  })

  it('remove placa doadora no modo MANUAL e todos os dados do doador no modo UNKNOWN', () => {
    const manual = evaluateService({ fields, rules, answers: { 'vehicle_target.category': 'AUTOMOBILE', 'engine.identification_mode': 'MANUAL', 'vehicle_donor.plate': 'ABC1234', 'vehicle_donor.power_cv': 90 } })
    expect(manual.values['vehicle_donor.plate']).toBeUndefined()
    const unknown = evaluateService({ fields, rules, answers: { 'vehicle_target.category': 'AUTOMOBILE', 'engine.identification_mode': 'UNKNOWN', 'vehicle_donor.plate': 'ABC1234', 'vehicle_donor.power_cv': 90 } })
    expect(unknown.values['vehicle_donor.plate']).toBeUndefined()
    expect(unknown.values['vehicle_donor.power_cv']).toBeUndefined()
  })
})
