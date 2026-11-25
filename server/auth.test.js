import { describe, expect, it } from 'vitest'
import { changePasswordSchema, clientRegistrationSchema, collaboratorRegistrationSchema, inferDocumentType, isCnpj, isCpf, loginSchema, normalizeDocument, partnerRegistrationSchema, passwordPolicyError, passwordSchemaForRole, resetPasswordSchema } from './auth.js'

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

  it('normalizes the single document field and infers its person type', () => {
    expect(normalizeDocument('001.002.003-04')).toBe('00100200304')
    expect(inferDocumentType('001.002.003-04')).toBe('PF')
    expect(inferDocumentType('04.252.011/0001-10')).toBe('PJ')
  })
})

describe('authentication input contracts', () => {
  it('accepts a simple six-character client password and numeric client password', () => {
    const base = { name: 'Cliente Teste', email: 'teste@example.com', cpf: '52998224725', whatsapp: '15997118125', passwordConfirmation: 'abcdef', acceptTerms: true, privacyAcknowledgement: true }
    expect(clientRegistrationSchema.safeParse({ ...base, password: 'abcdef' }).success).toBe(true)
    expect(clientRegistrationSchema.safeParse({ ...base, password: '246813', passwordConfirmation: '246813' }).success).toBe(true)
  })

  it('rejects a client password shorter than six characters or extremely common', () => {
    expect(passwordPolicyError('12345', 'CLIENT')).toContain('6')
    expect(passwordPolicyError('123456', 'CLIENT')).toContain('menos comum')
    expect(clientRegistrationSchema.safeParse({ name: 'Cliente Teste', email: 'teste@example.com', cpf: '52998224725', whatsapp: '15997118125', password: '12345', passwordConfirmation: '12345', acceptTerms: true, privacyAcknowledgement: true }).success).toBe(false)
  })

  it('accepts a partner password with eight characters without complexity requirements', () => {
    const result = partnerRegistrationSchema.safeParse({ legalName: 'Empresa Teste', tradeName: '', cpfCnpj: '04252011000110', responsibleName: 'Responsável Teste', state: 'SP', segment: 'Desmanche', email: 'parceiro@example.com', whatsapp: '15997118125', password: '24681357', passwordConfirmation: '24681357', acceptTerms: true, privacyAcknowledgement: true })
    expect(result.success).toBe(true)
    expect(passwordPolicyError('1234567', 'PARTNER')).toContain('8')
  })

  it('accepts partner CPF without a username and rejects an incomplete document', () => {
    const base = { legalName: 'Parceiro Pessoa Física', cpfCnpj: '52998224725', responsibleName: 'Responsável Teste', state: 'SP', segment: 'Oficina mecânica', email: 'pf@example.com', whatsapp: '15997118125', password: '24681357', passwordConfirmation: '24681357', acceptTerms: true, privacyAcknowledgement: true }
    expect(partnerRegistrationSchema.safeParse(base).success).toBe(true)
    expect(partnerRegistrationSchema.safeParse({ ...base, cpfCnpj: '5299822472' }).success).toBe(false)
  })

  it('keeps the administrative twelve-character complexity policy', () => {
    expect(passwordPolicyError('abcdef12345', 'ADMINISTRATOR')).toContain('12')
    expect(passwordPolicyError('Abcdefghijkl', 'ADMINISTRATOR')).toContain('número')
    expect(passwordPolicyError('Abcdefghij12', 'ADMINISTRATOR')).toBeNull()
    expect(passwordSchemaForRole('ADMINISTRATOR').safeParse('Abcdefghij12').success).toBe(true)
  })

  it('rejects malformed login and partner documents', () => {
    expect(loginSchema.safeParse({ email: 'invalido', password: '' }).success).toBe(false)
    expect(loginSchema.safeParse({ email: 'existente@example.com', password: '123' }).success).toBe(true)
    expect(partnerRegistrationSchema.safeParse({ personType: 'PJ', cpfCnpj: '123', name: 'x', email: 'x', whatsapp: 'x', password: 'SenhaSegura123', passwordConfirmation: 'SenhaSegura123', acceptTerms: true, privacyAcknowledgement: true }).success).toBe(false)
  })

  it('applies the profile policy to change and reset contracts at the backend boundary', () => {
    expect(changePasswordSchema.safeParse({ currentPassword: 'old', newPassword: '246813', newPasswordConfirmation: '246813' }).success).toBe(true)
    expect(resetPasswordSchema.safeParse({ token: 'a'.repeat(32), password: '12345678', passwordConfirmation: '12345678' }).success).toBe(true)
    expect(passwordPolicyError('246813', 'CLIENT')).toBeNull()
    expect(passwordPolicyError('246813', 'PARTNER')).toContain('8')
  })

  it('uses the partner policy for collaborator registration', () => {
    expect(collaboratorRegistrationSchema.safeParse({ name: 'Colaborador Teste', email: 'colaborador@example.com', whatsapp: '', password: '24681357', passwordConfirmation: '24681357' }).success).toBe(true)
    expect(collaboratorRegistrationSchema.safeParse({ name: 'Colaborador Teste', email: 'colaborador@example.com', whatsapp: '', password: '1234567', passwordConfirmation: '1234567' }).success).toBe(false)
  })
})
