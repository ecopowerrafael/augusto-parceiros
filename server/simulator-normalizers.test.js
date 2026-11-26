import { describe, expect, it } from 'vitest'
import { normalizeCylinder, normalizeFuel, normalizePlate } from './simulator-normalizers.js'

describe('normalizadores do simulador no-code', () => {
  it.each([
    ['Álcool', 'ALCOHOL'], ['Etanol', 'ALCOHOL'], ['Gasolina', 'GASOLINE'], ['Diesel', 'DIESEL'], ['Flex', 'FLEX'],
  ])('normaliza combustível %s', (input, expected) => expect(normalizeFuel(input)).toMatchObject({ value: expected, valid: true }))

  it.each([
    ['abc-1234', 'ABC1234', 'OLD'], ['abc1-d23', 'ABC1D23', 'MERCOSUR'], [' ABC 1234 ', 'ABC1234', 'OLD'],
  ])('normaliza placa digitada/colada %s', (input, value, pattern) => expect(normalizePlate(input)).toMatchObject({ value, pattern, valid: true }))

  it.each([
    ['2', '', 2000], ['2.5', '', 2500], ['2,5', 'L', 2500], ['125', '', 125], ['2500', '', 2500], ['2000', 'CM3', 2000], ['2000', 'cm³', 2000],
  ])('converte cilindrada %s %s para cm³', (input, unit, expected) => expect(normalizeCylinder(input, unit)).toMatchObject({ value: expected, valid: true }))

  it('rejeita valores inválidos sem inventar conversão', () => {
    expect(normalizeFuel('Elétrico').valid).toBe(false)
    expect(normalizePlate('ABC123').valid).toBe(false)
    expect(normalizeCylinder('-1').valid).toBe(false)
  })
})
