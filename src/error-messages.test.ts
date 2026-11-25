import { describe, expect, it } from 'vitest'
import { friendlyApiMessage, friendlyValidationMessages } from './error-messages'

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
})
