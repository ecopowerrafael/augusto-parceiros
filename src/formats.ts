export type DocumentType = 'PF' | 'PJ'

export function normalizeDocument(value: string) {
  return String(value || '').toUpperCase().replace(/[^0-9A-Z]/g, '').slice(0, 14)
}

export function documentTypeFor(value: string): DocumentType | undefined {
  const normalized = normalizeDocument(value)
  if (normalized.length > 11) return 'PJ'
  if (normalized.length > 0 && /^[0-9]+$/.test(normalized)) return 'PF'
  return undefined
}

export function formatCpfCnpj(value: string) {
  const normalized = normalizeDocument(value)
  if (normalized.length <= 11 && /^[0-9]*$/.test(normalized)) {
    return normalized.replace(/^([0-9]{3})([0-9])/, '$1.$2').replace(/^([0-9]{3})\.([0-9]{3})([0-9])/, '$1.$2.$3').replace(/^([0-9]{3})\.([0-9]{3})\.([0-9]{3})([0-9])/, '$1.$2.$3-$4')
  }
  return normalized.replace(/^(.{2})(.{3})(.{3})(.{4})(.{0,2})$/, (_match, a, b, c, d, e) => `${a}.${b}.${c}/${d}${e ? `-${e}` : ''}`)
}

export function formatPhone(value: string) {
  const normalized = String(value || '').replace(/\D/g, '').slice(0, 11)
  if (!normalized) return ''
  if (normalized.length <= 2) return `(${normalized}`
  if (normalized.length <= 10) return normalized.replace(/^(\d{2})(\d{0,4})(\d{0,4})$/, '($1) $2-$3').replace(/-$/, '')
  return normalized.replace(/^(\d{2})(\d{0,5})(\d{0,4})$/, '($1) $2-$3').replace(/-$/, '')
}

export function formatCep(value: string) {
  return String(value || '').replace(/\D/g, '').slice(0, 8).replace(/^(\d{5})(\d{0,3})$/, '$1-$2').replace(/-$/, '')
}
