import { describe, expect, it } from 'vitest'
import { canAccessPartnerOperations, isPartnerCompanyStatus, partnerUserStatusForCompanyStatus } from './partner-flow.js'

describe('fluxo de status de parceiros', () => {
  it('aceita somente os status de empresa previstos', () => {
    expect(isPartnerCompanyStatus('PENDING')).toBe(true)
    expect(isPartnerCompanyStatus('ACTIVE')).toBe(true)
    expect(isPartnerCompanyStatus('REJECTED')).toBe(true)
    expect(isPartnerCompanyStatus('SUSPENDED')).toBe(true)
    expect(isPartnerCompanyStatus('ADMINISTRATOR')).toBe(false)
  })

  it.each([
    ['PENDING', 'PENDING'],
    ['ACTIVE', 'ACTIVE'],
    ['SUSPENDED', 'SUSPENDED'],
    ['REJECTED', 'DISABLED'],
  ])('mapeia empresa %s para usuário %s', (companyStatus, userStatus) => {
    expect(partnerUserStatusForCompanyStatus(companyStatus)).toBe(userStatus)
  })

  it('permite operações somente para parceiro ativo', () => {
    expect(canAccessPartnerOperations('ACTIVE')).toBe(true)
    expect(canAccessPartnerOperations('PENDING')).toBe(false)
    expect(canAccessPartnerOperations('SUSPENDED')).toBe(false)
    expect(canAccessPartnerOperations('DISABLED')).toBe(false)
  })
})
