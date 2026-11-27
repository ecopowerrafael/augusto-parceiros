import { describe, expect, it } from 'vitest'
import { normalizeValidationIssues, validationSummary } from './validation'

describe('validação estruturada do simulador', () => {
  it('preserva o rótulo configurado e produz resumo em português', () => {
    const issues = normalizeValidationIssues([{ field: 'vehicle_target.state', label: 'UF do veículo', message: 'Preencha este campo.' }])
    expect(issues).toEqual([{ field: 'vehicle_target.state', label: 'UF do veículo', message: 'Preencha este campo.' }])
    expect(validationSummary(issues)).toContain('UF do veículo')
    expect(validationSummary(issues)).not.toContain('vehicle_target.state')
  })
})
