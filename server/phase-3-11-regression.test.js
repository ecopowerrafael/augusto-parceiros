import { describe, expect, it } from 'vitest'
import { evaluateService } from './service-config.js'

const motorcycleFields = [
  { field_key: 'vehicle_target.category', field_type: 'SINGLE_SELECT', is_required: 1 },
  { field_key: 'vehicle_target.plate', field_type: 'VEHICLE_PLATE', is_required: 1 },
  { field_key: 'vehicle_target.state', field_type: 'SINGLE_SELECT', is_required: 1 },
  { field_key: 'vehicle_target.fuel', field_type: 'TEXT', is_required: 0 },
  { field_key: 'engine.has_invoice', field_type: 'YES_NO', is_required: 1 },
  { field_key: 'engine.identification_mode', field_type: 'SINGLE_SELECT', is_required: 1, visibility_condition: { field: 'vehicle_target.category', operator: 'IN_LIST', values: ['AUTOMOBILE', 'TRUCK', 'BUS'] }, required_condition: { field: 'vehicle_target.category', operator: 'IN_LIST', values: ['AUTOMOBILE', 'TRUCK', 'BUS'] } },
  { field_key: 'motorcycle.compatibility_declaration', field_type: 'CHECKBOX', is_required: 0, visibility_condition: { field: 'vehicle_target.category', operator: 'EQUALS', value: 'MOTORCYCLE' } },
  { field_key: 'vehicle_donor.power_cv', field_type: 'DECIMAL', is_required: 0, visibility_condition: { field: 'engine.identification_mode', operator: 'EQUALS', value: 'PLATE' } },
]

const rules = [
  { name: 'compatibilidade', priority: 10, expected_result: 'VIABLE', vehicle_category_code: 'MOTORCYCLE', conditions: { field: 'motorcycle.compatibility_declaration', operator: 'TRUE' }, actions: [] },
  { name: 'sem compatibilidade', priority: 20, expected_result: 'MANUAL_REVIEW', vehicle_category_code: 'MOTORCYCLE', conditions: { field: 'motorcycle.compatibility_declaration', operator: 'FALSE' }, actions: [] },
]

describe('regressões da homologação 3.11', () => {
  it('não exige identification_mode oculto quando motocicleta declara compatibilidade', () => {
    const result = evaluateService({ fields: motorcycleFields, rules, answers: { 'vehicle_target.category': 'MOTORCYCLE', 'vehicle_target.plate': 'AAA1234', 'vehicle_target.state': 'SP', 'engine.has_invoice': 'YES', 'motorcycle.compatibility_declaration': true, 'engine.identification_mode': 'PLATE', 'vehicle_donor.power_cv': 99 } })
    expect(result.viability).toBe('VIABLE')
    expect(result.commercial_available).toBe(true)
    expect(result.values['engine.identification_mode']).toBeUndefined()
    expect(result.values['vehicle_donor.power_cv']).toBeUndefined()
  })

  it('encaminha motocicleta sem declaração para análise manual sem valores', () => {
    const result = evaluateService({ fields: motorcycleFields, rules, answers: { 'vehicle_target.category': 'MOTORCYCLE', 'vehicle_target.plate': 'AAA1234', 'vehicle_target.state': 'SP', 'engine.has_invoice': 'YES' } })
    expect(result.viability).toBe('MANUAL_REVIEW')
    expect(result.commercial_available).toBe(false)
    expect(result.items).toEqual([])
    expect(result.total_cents).toBeNull()
  })
})
