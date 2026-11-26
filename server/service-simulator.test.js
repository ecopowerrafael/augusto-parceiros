import { describe, expect, it } from 'vitest'
import { evaluateService } from './service-config.js'

const fields = [
  { field_key: 'vehicle_target.plate', field_type: 'VEHICLE_PLATE' },
  { field_key: 'vehicle_donor.plate', field_type: 'VEHICLE_PLATE' },
  { field_key: 'vehicle_target.power_cv', field_type: 'DECIMAL' },
  { field_key: 'vehicle_donor.power_cv', field_type: 'DECIMAL' },
  { field_key: 'vehicle_target.cylinder_cc', field_type: 'INTEGER' },
  { field_key: 'vehicle_donor.cylinder_cc', field_type: 'INTEGER' },
  { field_key: 'vehicle_target.fuel', field_type: 'TEXT' },
  { field_key: 'vehicle_donor.fuel', field_type: 'TEXT' },
  { field_key: 'vehicle.category', field_type: 'SINGLE_SELECT' },
  { field_key: 'engine.has_invoice', field_type: 'YES_NO' },
  { field_key: 'engine.power_variation_percent', field_type: 'CALCULATED', calculation: { operation: 'PERCENT_VARIATION', operands: [{ field: 'vehicle_target.power_cv' }, { field: 'vehicle_donor.power_cv' }], decimals: 2 } },
]

const billingItems = [
  { code: 'ENGINE_REGISTRATION', name: 'Cadastro de motor', billing_mode: 'REQUIRED', default_amount_cents: 30000, quantity: 1, include_in_total: 1 },
  { code: 'ENGINE_NO_INVOICE', name: 'Análise sem nota fiscal', billing_mode: 'CONDITIONAL', default_amount_cents: 30000, quantity: 1, include_in_total: 1, condition_expression: { all: [{ field: 'engine.has_invoice', operator: 'EQUALS', value: 'NO' }] } },
  { code: 'OLD_PLATE_AUTHORIZATION', name: 'Tratamento de placa antiga', billing_mode: 'CONDITIONAL', default_amount_cents: 22000, quantity: 1, include_in_total: 1, condition_expression: { any: [{ field: 'vehicle_target.plate_pattern', operator: 'EQUALS', value: 'OLD' }, { field: 'vehicle_donor.plate_pattern', operator: 'EQUALS', value: 'OLD' }] } },
  { code: 'MODIFICATION_REQUEST', name: 'Solicitação de modificação', billing_mode: 'CONDITIONAL', default_amount_cents: 30000, quantity: 1, include_in_total: 1, condition_expression: { all: [{ field: 'engine.power_variation_percent', operator: 'GREATER_THAN', value: 0 }, { field: 'engine.power_variation_percent', operator: 'LESS_OR_EQUAL', value: 10 }] } },
  { code: 'ITL_CSV_INSPECTION', name: 'Inspeção ITL/CSV', billing_mode: 'CONDITIONAL', default_amount_cents: null, quantity: 1, include_in_total: 1 },
]

const rules = [
  { name: 'acréscimo até 10%', priority: 10, expected_result: 'VIABLE_WITH_REQUIREMENTS', conditions: { all: [{ field: 'engine.power_variation_percent', operator: 'GREATER_THAN', value: 0 }, { field: 'engine.power_variation_percent', operator: 'LESS_OR_EQUAL', value: 10 }] }, actions: [{ action_type: 'ADD_BILLING_ITEM', target_key: 'ITL_CSV_INSPECTION' }] },
  { name: 'acréscimo acima de 10%', priority: 20, expected_result: 'OUT_OF_CRITERIA', conditions: { all: [{ field: 'engine.power_variation_percent', operator: 'GREATER_THAN', value: 10 }] }, actions: [{ action_type: 'BLOCK_AUTOMATED_QUOTE' }] },
  { name: 'redução de potência', priority: 30, expected_result: 'MANUAL_REVIEW', conditions: { all: [{ field: 'engine.power_variation_percent', operator: 'LESS_THAN', value: 0 }] }, actions: [{ action_type: 'ADD_BILLING_ITEM', target_key: 'ITL_CSV_INSPECTION' }, { action_type: 'MANUAL_REVIEW' }] },
  { name: 'dados de potência incompletos', priority: 40, expected_result: 'MANUAL_REVIEW', conditions: { all: [{ field: 'engine.power_variation_percent', operator: 'EMPTY' }] }, actions: [{ action_type: 'MANUAL_REVIEW' }] },
  { name: 'combustível alterado', priority: 50, expected_result: 'MANUAL_REVIEW', conditions: { all: [{ field: 'vehicle_target.fuel', operator: 'NOT_EQUALS', valueField: 'vehicle_donor.fuel' }] }, actions: [{ action_type: 'MANUAL_REVIEW' }] },
  { name: 'cilindrada divergente', priority: 60, expected_result: 'MANUAL_REVIEW', conditions: { all: [{ field: 'vehicle_target.cylinder_cc', operator: 'NOT_EQUALS', valueField: 'vehicle_donor.cylinder_cc' }, { field: 'vehicle.category', operator: 'NOT_EQUALS', value: 'MOTORCYCLE' }] }, actions: [{ action_type: 'MANUAL_REVIEW' }] },
  { name: 'motocicleta com cilindrada divergente', priority: 70, expected_result: 'OUT_OF_CRITERIA', conditions: { all: [{ field: 'vehicle.category', operator: 'EQUALS', value: 'MOTORCYCLE' }, { field: 'vehicle_target.cylinder_cc', operator: 'NOT_EQUALS', valueField: 'vehicle_donor.cylinder_cc' }] }, actions: [{ action_type: 'BLOCK_AUTOMATED_QUOTE' }] },
]

const evaluate = (answers) => evaluateService({ fields, billingItems, rules, documents: [{ document_code: 'INVOICE', name: 'Nota fiscal', requirement_type: 'REQUIRED', condition_expression: { all: [{ field: 'engine.has_invoice', operator: 'EQUALS', value: 'YES' }] } }], answers })
const base = { 'vehicle_target.plate': 'ABC1D23', 'vehicle_donor.plate': 'ABC1D23', 'vehicle_target.power_cv': 100, 'vehicle_donor.power_cv': 100, 'vehicle_target.cylinder_cc': 1600, 'vehicle_donor.cylinder_cc': 1600, 'vehicle_target.fuel': 'FLEX', 'vehicle_donor.fuel': 'FLEX', 'vehicle.category': 'CAR', 'engine.has_invoice': 'YES' }

describe('homologação do simulador de serviço no-code', () => {
  it.each([
    ['motor equivalente com nota fiscal', { ...base }, 'UNCLASSIFIED', false],
    ['motor equivalente sem nota fiscal', { ...base, 'engine.has_invoice': 'NO' }, 'UNCLASSIFIED', false],
    ['veículo de destino com placa antiga', { ...base, 'vehicle_target.plate': 'ABC1234' }, 'UNCLASSIFIED', false],
    ['motor antigo e destino Mercosul', { ...base, 'vehicle_donor.plate': 'ABC1234' }, 'UNCLASSIFIED', false],
    ['aumento de potência de 5%', { ...base, 'vehicle_target.power_cv': 105 }, 'MANUAL_REVIEW', false],
    ['aumento de exatamente 10%', { ...base, 'vehicle_target.power_cv': 110 }, 'MANUAL_REVIEW', false],
    ['aumento superior a 10%', { ...base, 'vehicle_target.power_cv': 111 }, 'OUT_OF_CRITERIA', true],
    ['redução de potência', { ...base, 'vehicle_target.power_cv': 95 }, 'MANUAL_REVIEW', false],
    ['alteração de combustível', { ...base, 'vehicle_target.fuel': 'DIESEL' }, 'MANUAL_REVIEW', false],
    ['mesma potência com cilindrada diferente', { ...base, 'vehicle_target.cylinder_cc': 1800 }, 'MANUAL_REVIEW', false],
    ['dados técnicos incompletos', { ...base, 'vehicle_target.power_cv': undefined }, 'MANUAL_REVIEW', false],
    ['motocicleta com cilindrada diferente', { ...base, 'vehicle.category': 'MOTORCYCLE', 'vehicle_target.cylinder_cc': 250 }, 'OUT_OF_CRITERIA', true],
  ])('%s', (_name, answers, viability, blocked) => {
    const result = evaluate(answers)
    expect(result.viability).toBe(viability)
    expect(result.blocked).toBe(blocked)
  })

  it('alterna entre motor informado por placa e preenchimento manual sem depender de API externa', () => {
    const byPlate = evaluate({ ...base, 'vehicle_donor.plate': 'ABC1234' })
    const manual = evaluate({ ...base, 'vehicle_donor.plate': undefined, 'vehicle_target.power_cv': 105 })
    expect(byPlate.values['vehicle_donor.plate_pattern']).toBe('OLD')
    expect(manual.values['engine.power_variation_percent']).toBe(5)
    expect(byPlate.items.some((item) => item.code === 'OLD_PLATE_AUTHORIZATION')).toBe(true)
  })
})
