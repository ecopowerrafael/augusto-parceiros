export const PARTNER_COMPANY_STATUSES = ['PENDING', 'ACTIVE', 'REJECTED', 'SUSPENDED']

export function isPartnerCompanyStatus(value) {
  return PARTNER_COMPANY_STATUSES.includes(String(value || '').toUpperCase())
}

export function partnerUserStatusForCompanyStatus(value) {
  const status = String(value || '').toUpperCase()
  if (status === 'ACTIVE') return 'ACTIVE'
  if (status === 'SUSPENDED') return 'SUSPENDED'
  if (status === 'PENDING') return 'PENDING'
  return 'DISABLED'
}

export function canAccessPartnerOperations(userStatus) {
  return String(userStatus || '').toUpperCase() === 'ACTIVE'
}
