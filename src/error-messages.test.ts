import { describe, expect, it } from 'vitest'
import { friendlyApiDetails, friendlyApiMessage, friendlyValidationMessages } from './error-messages'

describe('mensagens amigáveis da API', () => {
  it('traduz códigos técnicos sem alterar o código retornado pelo backend', () => {
    expect(friendlyApiMessage('DOCUMENT_TYPE_MISMATCH')).toContain('documento')
    expect(friendlyApiMessage('AUTHENTICATION_REQUIRED')).toContain('Entre')
    expect(friendlyApiMessage('INTERNAL_ERROR', 500)).not.toContain('SQL')
  })

  it('preserva mensagens de validação úteis em português', () => {
    expect(friendlyValidationMessages([{ field: 'cpfCnpj', message: 'CPF inválido.' }])).toBe('CPF inválido.')
    expect(friendlyValidationMessages(undefined)).toBe('')
  })

  it('apresenta detalhes de combustível individualmente por campo', () => {
    expect(friendlyApiDetails('INVALID_SIMULATION_INPUT', [{ field: 'vehicle_target.fuel', code: 'INVALID_FUEL', message: 'Selecione um combustível válido.' }])).toContain('Combustível original: Selecione')
  })

  it('apresenta referência inválida de configuração', () => {
    expect(friendlyApiDetails('INVALID_SERVICE_CONFIGURATION', ['A configuração referencia o campo inexistente: vehicle_target.plate_pattern.'])).toContain('Configuração inválida')
  })
})
