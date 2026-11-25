import { describe, expect, it } from 'vitest'
import { evaluateService, normalizePlate, validateConfiguration } from './service-config.js'

const fields = [
  { field_key: 'vehicle_target.plate_pattern', field_type: 'TEXT' },
  { field_key: 'engine.has_invoice', field_type: 'YES_NO' },
  { field_key: 'engine.power_variation_percent', field_type: 'PERCENT' },
]
const billingItems = [
  { code: 'TRANSFER_FEE', name: 'Transferência', billing_mode: 'REQUIRED', default_amount_cents: 29580, quantity: 1, include_in_total: 1 },
  { code: 'SERVICE_FEE', name: 'Honorário', billing_mode: 'REQUIRED', default_amount_cents: 16000, quantity: 1, include_in_total: 1 },
  { code: 'ENGINE_REGISTRATION', name: 'Cadastro', billing_mode: 'REQUIRED', default_amount_cents: 30000, quantity: 1, include_in_total: 1 },
  { code: 'ENGINE_NO_INVOICE', name: 'Sem nota', billing_mode: 'CONDITIONAL', default_amount_cents: 30000, quantity: 1, include_in_total: 1, condition_expression: { all: [{ field: 'engine.has_invoice', operator: 'EQUALS', value: 'NO' }] } },
  { code: 'MERCOSUR_PLATE_AUTHORIZATION', name: 'Mercosul', billing_mode: 'CONDITIONAL', default_amount_cents: 22000, quantity: 1, include_in_total: 1, condition_expression: { all: [{ field: 'vehicle_target.plate_pattern', operator: 'EQUALS', value: 'OLD' }] } },
  { code: 'MODIFICATION_REQUEST', name: 'Modificação', billing_mode: 'CONDITIONAL', default_amount_cents: 30000, quantity: 1, include_in_total: 1, condition_expression: { all: [{ field: 'engine.power_variation_percent', operator: 'GREATER_THAN', value: 0 }, { field: 'engine.power_variation_percent', operator: 'LESS_OR_EQUAL', value: 10 }] } },
  { code: 'ITL_CSV_INSPECTION', name: 'CSV', billing_mode: 'CONDITIONAL', default_amount_cents: null, quantity: 1, include_in_total: 1 },
]
const rules = [
  { name: 'acréscimo até 10%', priority: 10, expected_result: 'VIABLE_WITH_REQUIREMENTS', conditions: { all: [{ field: 'engine.power_variation_percent', operator: 'GREATER_THAN', value: 0 }, { field: 'engine.power_variation_percent', operator: 'LESS_OR_EQUAL', value: 10 }] }, actions: [{ action_type: 'ADD_BILLING_ITEM', target_key: 'MODIFICATION_REQUEST' }, { action_type: 'ADD_BILLING_ITEM', target_key: 'ITL_CSV_INSPECTION' }] },
  { name: 'acréscimo acima de 10%', priority: 20, expected_result: 'OUT_OF_CRITERIA', conditions: { all: [{ field: 'engine.power_variation_percent', operator: 'GREATER_THAN', value: 10 }] }, actions: [{ action_type: 'BLOCK_AUTOMATED_QUOTE' }] },
  { name: 'potência ausente', priority: 30, expected_result: 'MANUAL_REVIEW', conditions: { all: [{ field: 'engine.power_variation_percent', operator: 'EMPTY' }] }, actions: [{ action_type: 'MANUAL_REVIEW' }] },
]
const evaluate = (answers) => evaluateService({ fields, billingItems, rules, answers })

describe('configuração no-code de serviços', () => {
  it('normaliza placas antiga e Mercosul sem confundir padrões', () => { expect(normalizePlate('abc-1234')).toEqual({ value: 'ABC1234', pattern: 'OLD' }); expect(normalizePlate('abc1d23')).toEqual({ value: 'ABC1D23', pattern: 'MERCOSUR' }); expect(normalizePlate('abc123')).toMatchObject({ pattern: 'UNKNOWN' }) })
  it('calcula o cenário A com nota e placa Mercosul', () => { expect(evaluate({ 'engine.has_invoice': 'YES', 'vehicle_target.plate_pattern': 'MERCOSUR', 'engine.power_variation_percent': 0 }).total_cents).toBe(75580) })
  it('calcula o cenário B sem nota', () => { expect(evaluate({ 'engine.has_invoice': 'NO', 'vehicle_target.plate_pattern': 'MERCOSUR', 'engine.power_variation_percent': 0 }).total_cents).toBe(105580) })
  it('calcula o cenário C sem nota e placa antiga', () => { expect(evaluate({ 'engine.has_invoice': 'NO', 'vehicle_target.plate_pattern': 'OLD', 'engine.power_variation_percent': 0 }).total_cents).toBe(127580) })
  it('calcula o cenário D e mantém CSV sem valor definido', () => { const result = evaluate({ 'engine.has_invoice': 'NO', 'vehicle_target.plate_pattern': 'OLD', 'engine.power_variation_percent': 5 }); expect(result.total_cents).toBe(157580); expect(result.missing_amount_items).toContain('ITL_CSV_INSPECTION'); expect(result.manual_review).toBe(true) })
  it('aceita exatamente 10% dentro do limite', () => { const result = evaluate({ 'engine.has_invoice': 'YES', 'vehicle_target.plate_pattern': 'MERCOSUR', 'engine.power_variation_percent': 10 }); expect(result.blocked).toBe(false); expect(result.viability).toBe('MANUAL_REVIEW'); expect(result.items.filter((item) => item.code === 'ITL_CSV_INSPECTION')).toHaveLength(1) })
  it('bloqueia acima de 10%', () => { const result = evaluate({ 'engine.has_invoice': 'YES', 'vehicle_target.plate_pattern': 'MERCOSUR', 'engine.power_variation_percent': 10.01 }); expect(result.blocked).toBe(true); expect(result.viability).toBe('OUT_OF_CRITERIA') })
  it('encaminha potência ausente para análise manual sem presumir zero', () => { const result = evaluate({ 'engine.has_invoice': 'YES', 'vehicle_target.plate_pattern': 'MERCOSUR' }); expect(result.manual_review).toBe(true); expect(result.values['engine.power_variation_percent']).toBeUndefined() })
  it('não usa placa doadora para cobrar autorização de Mercosul', () => { const result = evaluate({ 'engine.has_invoice': 'YES', 'vehicle_target.plate_pattern': 'MERCOSUR', 'vehicle_donor.plate_pattern': 'OLD', 'engine.power_variation_percent': 0 }); expect(result.items.find((item) => item.code === 'MERCOSUR_PLATE_AUTHORIZATION')).toBeUndefined() })
  it('não duplica cobrança adicionada por regra', () => { const duplicatedRules = [{ ...rules[0], actions: [...rules[0].actions, ...rules[0].actions] }]; const result = evaluateService({ fields, billingItems, rules: duplicatedRules, answers: { 'engine.has_invoice': 'YES', 'vehicle_target.plate_pattern': 'MERCOSUR', 'engine.power_variation_percent': 5 } }); expect(result.items.filter((item) => item.code === 'ITL_CSV_INSPECTION')).toHaveLength(1) })
  it('remove o adicional de sem nota quando a resposta muda para sim', () => { const result = evaluate({ 'engine.has_invoice': 'YES', 'vehicle_target.plate_pattern': 'MERCOSUR', 'engine.power_variation_percent': 0 }); expect(result.items.find((item) => item.code === 'ENGINE_NO_INVOICE')).toBeUndefined() })
  it('detecta referência inexistente e ciclo de campos calculados', () => { const invalid = validateConfiguration([{ field_key: 'a', calculation: { operands: [{ field: 'b' }] } }, { field_key: 'b', calculation: { operands: [{ field: 'a' }] } }], [{ all: [{ field: 'missing', operator: 'FILLED' }] }]); expect(invalid.some((message) => message.includes('inexistente'))).toBe(true); expect(invalid.some((message) => message.includes('circular'))).toBe(true) })
})
