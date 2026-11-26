import { describe, expect, it } from 'vitest'
import { validateConfiguration } from './service-config.js'
import { simulateLoadedService } from './services.js'

const fields = [
  { field_key: 'vehicle_target.plate', field_type: 'VEHICLE_PLATE' },
  { field_key: 'vehicle_target.category', field_type: 'SINGLE_SELECT' },
  { field_key: 'vehicle_target.state', field_type: 'SINGLE_SELECT' },
  { field_key: 'vehicle_target.power_cv', field_type: 'DECIMAL' },
  { field_key: 'vehicle_target.engine_cc', field_type: 'INTEGER', unit: 'cm³' },
  { field_key: 'vehicle_target.fuel', field_type: 'SINGLE_SELECT' },
  { field_key: 'engine.has_invoice', field_type: 'YES_NO' },
  { field_key: 'engine.identification_mode', field_type: 'SINGLE_SELECT' },
  { field_key: 'vehicle_donor.plate', field_type: 'VEHICLE_PLATE' },
  { field_key: 'vehicle_donor.power_cv', field_type: 'DECIMAL' },
  { field_key: 'vehicle_donor.engine_cc', field_type: 'INTEGER', unit: 'cm³' },
  { field_key: 'vehicle_donor.fuel', field_type: 'SINGLE_SELECT' },
  { field_key: 'engine.power_variation_percent', field_type: 'CALCULATED', calculation: { operation: 'PERCENT_VARIATION', operands: [{ field: 'vehicle_target.power_cv' }, { field: 'vehicle_donor.power_cv' }], decimals: 2 } },
]

const options = [
  ...['vehicle_target.fuel', 'vehicle_donor.fuel'].flatMap((field_id) => ['ALCOHOL', 'GASOLINE', 'DIESEL', 'FLEX'].map((option_value) => ({ field_id, option_value }))),
]

const billingItems = [
  { code: 'TRANSFER_FEE', billing_mode: 'REQUIRED', default_amount_cents: 29580, quantity: 1, include_in_total: 1 },
  { code: 'SERVICE_FEE', billing_mode: 'REQUIRED', default_amount_cents: 16000, quantity: 1, include_in_total: 1 },
  { code: 'ENGINE_REGISTRATION', billing_mode: 'REQUIRED', default_amount_cents: 30000, quantity: 1, include_in_total: 1 },
  { code: 'MERCOSUR_PLATE_AUTHORIZATION', billing_mode: 'CONDITIONAL', default_amount_cents: 22000, quantity: 1, include_in_total: 1, condition_expression: { all: [{ field: 'vehicle_target.plate_pattern', operator: 'EQUALS', value: 'OLD' }] } },
]

const rules = [
  { name: 'motor equivalente', vehicle_category_code: 'AUTOMOBILE', priority: 10, expected_result: 'VIABLE', conditions: { all: [{ field: 'vehicle_target.power_cv', operator: 'EQUALS', valueField: 'vehicle_donor.power_cv' }, { field: 'vehicle_target.engine_cc', operator: 'EQUALS', valueField: 'vehicle_donor.engine_cc' }, { field: 'vehicle_target.fuel', operator: 'EQUALS', valueField: 'vehicle_donor.fuel' }] }, actions: [] },
  { name: 'motocicleta com cilindrada diferente', vehicle_category_code: 'MOTORCYCLE', priority: 15, expected_result: 'OUT_OF_CRITERIA', conditions: { field: 'vehicle_target.engine_cc', operator: 'NOT_EQUALS', valueField: 'vehicle_donor.engine_cc' }, actions: [] },
  { name: 'combustível alterado', vehicle_category_code: 'AUTOMOBILE', priority: 20, expected_result: 'MANUAL_REVIEW', conditions: { all: [{ field: 'vehicle_target.fuel', operator: 'NOT_EQUALS', valueField: 'vehicle_donor.fuel' }] }, actions: [] },
]
const editorConditions = [billingItems[3].condition_expression, rules[0].conditions, { field: 'vehicle_target.plate_pattern' }, { field: 'vehicle_donor.plate_pattern' }]

const editor = { version: { version_number: 1 }, fields, options, billingItems, rules, documents: [], validationErrors: validateConfiguration(fields, editorConditions) }

describe('integração do contrato real do simulador Fase 3.7.1', () => {
  it('aceita o editor equivalente às migrations 001–006 e reproduz a entrada real', () => {
    expect(editor.validationErrors).toEqual([])
    const response = simulateLoadedService(editor, { answers: {
      'vehicle_target.plate': 'AAA2222', 'vehicle_target.category': 'AUTOMOBILE', 'vehicle_target.state': 'SP', 'vehicle_target.power_cv': '66', 'vehicle_target.engine_cc': '2.2', 'vehicle_target.fuel': 'Gasolina', 'engine.has_invoice': 'YES', 'engine.identification_mode': 'PLATE', 'vehicle_donor.plate': 'BBB4444', 'vehicle_donor.power_cv': '66', 'vehicle_donor.engine_cc': '2,2', 'vehicle_donor.fuel': 'GASOLINE',
    }, fixtureContext: {} })
    expect(response.simulated).toBe(true)
    expect(response.externalCalls).toBe(0)
    expect(response.result.values['vehicle_target.engine_cc']).toBe(2200)
    expect(response.result.values['vehicle_donor.engine_cc']).toBe(2200)
    expect(response.result.values['engine.power_variation_percent']).toBe(0)
    expect(response.result.values['vehicle_target.plate_pattern']).toBe('OLD')
    expect(response.result.viability).toBe('VIABLE')
    expect(response.result.items.filter((item) => item.code === 'MERCOSUR_PLATE_AUTHORIZATION')).toHaveLength(1)
    expect(response.result.total_cents).toBe(97580)
  })

  it('mantém a validação ativa e rejeita somente uma referência realmente inexistente', () => {
    const invalidEditor = { ...editor, validationErrors: validateConfiguration(fields, [{ field: 'vehicle_target.not_registered' }]) }
    expect(() => simulateLoadedService(invalidEditor, { answers: {}, fixtureContext: {} })).toThrow('INVALID_SERVICE_CONFIGURATION')
  })

  it.each(['ALCOHOL', 'GASOLINE', 'DIESEL', 'FLEX'])('aceita o valor interno %s nos dois veículos', (fuel) => {
    const response = simulateLoadedService(editor, { answers: { 'vehicle_target.plate': 'AAA1234', 'vehicle_target.category': 'AUTOMOBILE', 'vehicle_target.state': 'SP', 'vehicle_target.power_cv': 75, 'vehicle_target.engine_cc': 1000, 'vehicle_target.fuel': fuel, 'engine.has_invoice': 'YES', 'engine.identification_mode': 'PLATE', 'vehicle_donor.plate': 'EEE1234', 'vehicle_donor.power_cv': 75, 'vehicle_donor.engine_cc': 1000, 'vehicle_donor.fuel': fuel }, fixtureContext: {} })
    expect(response.result.viability).toBe('VIABLE')
    expect(response.result.total_cents).toBe(97580)
    expect(response.externalCalls).toBe(0)
  })

  it.each([
    ['Álcool', 'ETHANOL'], ['Gasolina', 'GASOLINE'], ['Álcool/Gasolina', 'FLEX'], ['Gasolina/Etanol', 'FLEX'], ['Gasolina/Álcool', 'FLEX'],
  ])('trata representações equivalentes %s/%s como o mesmo combustível', (targetFuel, donorFuel) => {
    const response = simulateLoadedService(editor, { answers: { 'vehicle_target.plate': 'AAA1234', 'vehicle_target.power_cv': 75, 'vehicle_target.engine_cc': 1000, 'vehicle_target.fuel': targetFuel, 'engine.has_invoice': 'YES', 'vehicle_donor.plate': 'EEE1234', 'vehicle_donor.power_cv': 75, 'vehicle_donor.engine_cc': 1000, 'vehicle_donor.fuel': donorFuel }, fixtureContext: {} })
    expect(response.result.values['vehicle_target.fuel']).toBe(response.result.values['vehicle_donor.fuel'])
    expect(response.result.manual_review).toBe(false)
  })

  it('classifica alteração efetiva de combustível para análise manual e rejeita valor inválido', () => {
    const changed = simulateLoadedService(editor, { answers: { 'vehicle_target.plate': 'AAA1234', 'vehicle_target.power_cv': 75, 'vehicle_target.engine_cc': 1000, 'vehicle_target.fuel': 'DIESEL', 'vehicle_donor.plate': 'EEE1234', 'vehicle_donor.power_cv': 75, 'vehicle_donor.engine_cc': 1000, 'vehicle_donor.fuel': 'GASOLINE' }, fixtureContext: {} })
    expect(changed.result.viability).toBe('MANUAL_REVIEW')
    expect(() => simulateLoadedService(editor, { answers: { 'vehicle_target.fuel': 'Eletricidade' }, fixtureContext: {} })).toThrow('INVALID_SIMULATION_INPUT')
  })

  it('não aplica regra de motocicleta a automóvel', () => {
    const response = simulateLoadedService(editor, { answers: {
      'vehicle_target.category': 'AUTOMOBILE', 'vehicle_target.engine_cc': 2000, 'vehicle_donor.engine_cc': 4000,
      'vehicle_target.power_cv': 75, 'vehicle_donor.power_cv': 75, 'vehicle_target.fuel': 'ALCOHOL', 'vehicle_donor.fuel': 'ALCOHOL',
    }, fixtureContext: {} })
    expect(response.result.trace.find((item) => item.rule === 'motocicleta com cilindrada diferente')?.matched).toBe(false)
    expect(response.result.viability).toBe('UNCLASSIFIED')
  })

  it('descarta placa do motor quando a identificação é manual', () => {
    const response = simulateLoadedService(editor, { answers: {
      'engine.identification_mode': 'MANUAL', 'vehicle_donor.plate': 'EEE1234', 'vehicle_target.plate': 'AAA1234',
      'vehicle_target.category': 'AUTOMOBILE', 'vehicle_target.engine_cc': 1000, 'vehicle_donor.engine_cc': 1000,
      'vehicle_target.power_cv': 75, 'vehicle_donor.power_cv': 75, 'vehicle_target.fuel': 'ALCOHOL', 'vehicle_donor.fuel': 'ALCOHOL',
    }, fixtureContext: {} })
    expect(response.result.values['vehicle_donor.plate']).toBeUndefined()
    expect(response.result.values['vehicle_donor.plate_pattern']).toBeUndefined()
  })
})

