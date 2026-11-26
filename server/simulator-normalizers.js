const ACCENTED_CHARS = /[\u0300-\u036f]/g

function fold(value) {
  return String(value ?? '').normalize('NFD').replace(ACCENTED_CHARS, '').trim().toUpperCase()
}

export const FUEL_OPTIONS = [
  { value: 'ALCOHOL', label: 'Álcool' },
  { value: 'GASOLINE', label: 'Gasolina' },
  { value: 'DIESEL', label: 'Diesel' },
  { value: 'FLEX', label: 'Flex' },
]

const FUEL_ALIASES = new Map([
  ['ALCOOL', 'ALCOHOL'], ['ETANOL', 'ALCOHOL'], ['ETHANOL', 'ALCOHOL'],
  ['GASOLINA', 'GASOLINE'], ['GASOLINE', 'GASOLINE'], ['DIESEL', 'DIESEL'], ['FLEX', 'FLEX'],
])

export function normalizeFuel(value) {
  const normalized = FUEL_ALIASES.get(fold(value))
  return normalized ? { value: normalized, valid: true } : { value, valid: false, code: 'INVALID_FUEL', message: 'Selecione um combustível válido.' }
}

export function normalizePlate(value) {
  const normalized = String(value ?? '').toUpperCase().replace(/[^A-Z0-9]/g, '')
  if (!normalized) return { value: '', pattern: 'UNKNOWN', valid: true }
  if (/^[A-Z]{3}[0-9]{4}$/.test(normalized)) return { value: normalized, pattern: 'OLD', valid: true }
  if (/^[A-Z]{3}[0-9][A-Z][0-9]{2}$/.test(normalized)) return { value: normalized, pattern: 'MERCOSUR', valid: true }
  return { value: normalized, pattern: 'UNKNOWN', valid: false, code: 'INVALID_PLATE', message: 'Informe uma placa válida no padrão antigo ou Mercosul.' }
}

export function normalizeCylinder(value, unit = '') {
  const inputValue = value && typeof value === 'object' && !Array.isArray(value) ? value.value : value
  const inputUnit = value && typeof value === 'object' && !Array.isArray(value) ? value.unit || unit : unit
  if (inputValue === undefined || inputValue === null || String(inputValue).trim() === '') return { value: inputValue, valid: true }
  const numericValue = Number(String(inputValue).replace(',', '.').trim())
  if (!Number.isFinite(numericValue) || numericValue <= 0) return { value, valid: false, code: 'INVALID_CYLINDER', message: 'Informe uma cilindrada positiva em litros ou cm³.' }
  const normalizedUnit = fold(inputUnit)
  const cubicCentimeters = normalizedUnit.includes('LIT') ? numericValue * 1000 : normalizedUnit.includes('CM') || normalizedUnit.includes('CC') ? numericValue : numericValue < 100 ? numericValue * 1000 : numericValue
  if (!Number.isFinite(cubicCentimeters) || cubicCentimeters <= 0) return { value, valid: false, code: 'INVALID_CYLINDER', message: 'Informe uma cilindrada positiva em litros ou cm³.' }
  return { value: Number(cubicCentimeters.toFixed(3)), valid: true, unit: 'cm³' }
}

function isFuelField(field, options) {
  const values = options.filter((option) => option.field_id === field.id).map((option) => fold(option.option_value))
  return field.field_key.toLowerCase().endsWith('.fuel') || values.some((value) => FUEL_ALIASES.has(value))
}

function isCylinderField(field) {
  const key = field.field_key.toLowerCase()
  return key.includes('cylinder') || key.includes('cilind') || key.endsWith('.engine_cc') || fold(field.unit).includes('CM')
}

export function normalizeSimulationAnswers(fields, options = [], input = {}) {
  const values = { ...input }
  const errors = []
  for (const field of fields) {
    const key = field.field_key
    if (!(key in values) || values[key] === undefined || values[key] === null || values[key] === '') continue
    if (field.field_type === 'VEHICLE_PLATE') {
      const result = normalizePlate(values[key]); values[key] = result.value
      if (!result.valid) errors.push({ field: key, code: result.code, message: result.message })
      continue
    }
    if (isFuelField(field, options)) {
      const result = normalizeFuel(values[key]); if (result.valid) values[key] = result.value; else errors.push({ field: key, code: result.code, message: result.message })
      continue
    }
    if (isCylinderField(field)) {
      const result = normalizeCylinder(values[key]); if (result.valid) values[key] = result.value; else errors.push({ field: key, code: result.code, message: result.message })
    }
  }
  return { values, errors }
}
