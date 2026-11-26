import { describe, expect, it } from 'vitest'
import { evaluateDeclarativeCondition } from './conditions'

describe('condições declarativas no formulário', () => {
  it('aplica visibilidade aninhada e não considera ausência como diferente', () => {
    expect(evaluateDeclarativeCondition({ all: [{ field: 'vehicle_target.category', operator: 'EQUALS', value: 'MOTORCYCLE' }, { any: [{ field: 'engine.identification_mode', operator: 'EMPTY' }, { field: 'motorcycle.compatibility_declaration', operator: 'TRUE' }] }] }, { 'vehicle_target.category': 'MOTORCYCLE' })).toBe(true)
    expect(evaluateDeclarativeCondition({ field: 'vehicle_donor.fuel', operator: 'NOT_EQUALS', value: 'ALCOHOL' }, {})).toBe(false)
  })
})
