import { describe, expect, it } from 'vitest'
import { clientRegistrationSchema, isCnpj, isCpf, loginSchema, partnerRegistrationSchema } from './auth.js'

describe('document validation', () => {
  it('accepts valid CPF and rejects repeated or invalid digits', () => {
    expect(isCpf('529.982.247-25')).toBe(true)
    expect(isCpf('111.111.111-11')).toBe(false)
    expect(isCpf('529.982.247-26')).toBe(false)
  })

  it('accepts valid CNPJ and rejects invalid values', () => {
    expect(isCnpj('04.252.011/0001-10')).toBe(true)
    expect(isCnpj('11.111.111/1111-11')).toBe(false)
    expect(isCnpj('04.252.011/0001-11')).toBe(false)
  })
})

describe('authentication input contracts', () => {
  it('requires strong matching passwords and consent for clients', () => {
    const result = clientRegistrationSchema.safeParse({ name: 'Cliente Teste', email: 'teste@example.com', cpf: '52998224725', whatsapp: '15997118125', password: 'SenhaFraca', passwordConfirmation: 'SenhaFraca', acceptTerms: true, privacyAcknowledgement: true })
    expect(result.success).toBe(false)
  })

  it('rejects malformed login and partner documents', () => {
    expect(loginSchema.safeParse({ email: 'invalido', password: '' }).success).toBe(false)
    expect(partnerRegistrationSchema.safeParse({ personType: 'PJ', cpfCnpj: '123', name: 'x', email: 'x', whatsapp: 'x', password: 'SenhaSegura123', passwordConfirmation: 'SenhaSegura123', acceptTerms: true, privacyAcknowledgement: true }).success).toBe(false)
  })
})
