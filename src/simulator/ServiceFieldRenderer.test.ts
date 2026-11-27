import { describe, expect, it } from 'vitest'
import { documentaryWarningFor, getVehicleStateOptions, ruleRequiresField, shouldRenderServiceField } from './ServiceFieldRenderer'

describe('renderização declarativa compartilhada', () => {
  it('mantém somente São Paulo e Outros estados como opções internas do UF', () => {
    expect(getVehicleStateOptions().map((option) => option.value)).toEqual(['SP', 'OTHER_STATE'])
    expect(getVehicleStateOptions()).toHaveLength(2)
  })

  it('oculta PBT sem regra aplicável e exibe quando uma regra o referencia', () => {
    const field = { field_key: 'vehicle_target.pbt_kg', field_type: 'INTEGER' }
    expect(shouldRenderServiceField(field, { 'vehicle_target.category': 'AUTOMOBILE' }, [])).toBe(false)
    expect(shouldRenderServiceField(field, { 'vehicle_target.category': 'TRUCK' }, [{ vehicle_category_code: 'TRUCK', conditions: { field: 'vehicle_target.pbt_kg', operator: 'GREATER_THAN', value: 3500 } }])).toBe(true)
  })

  it('considera a categoria ao decidir se a regra exige PBT', () => {
    const rule = { vehicle_category_code: 'TRUCK', conditions: { field: 'vehicle_target.pbt_kg', operator: 'FILLED' } }
    expect(ruleRequiresField('vehicle_target.pbt_kg', [rule], { 'vehicle_target.category': 'AUTOMOBILE' })).toBe(false)
    expect(ruleRequiresField('vehicle_target.pbt_kg', [rule], { 'vehicle_target.category': 'TRUCK' })).toBe(true)
  })

  it('emite somente um aviso orientativo para combinação documental contraditória', () => {
    expect(documentaryWarningFor({ 'suspension.already_done': 'YES', 'suspension.installation_invoice': 'NOT_PERFORMED' })).toContain('Confira as respostas')
    expect(documentaryWarningFor({ 'suspension.already_done': 'NO', 'suspension.installation_invoice': 'NOT_PERFORMED' })).toBe('')
  })
})
