export type PlatePattern = 'OLD' | 'MERCOSUR' | 'UNKNOWN'
export type CylinderUnit = 'L' | 'CM3' | ''

export const FUEL_OPTIONS = [
  { value: 'ALCOHOL', label: 'Álcool' },
  { value: 'GASOLINE', label: 'Gasolina' },
  { value: 'DIESEL', label: 'Diesel' },
  { value: 'FLEX', label: 'Flex' },
] as const

export function normalizeFuel(value: string): string {
  const key = value.normalize('NFD').replace(/[\u0300-\u036f]/g, '').trim().toUpperCase()
  return ({ ALCOOL: 'ALCOHOL', ETANOL: 'ALCOHOL', ETHANOL: 'ALCOHOL', GASOLINA: 'GASOLINE', GASOLINE: 'GASOLINE', DIESEL: 'DIESEL', FLEX: 'FLEX' } as Record<string, string>)[key] || value
}

export function normalizePlateInput(value: string): string {
  return value.toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 7)
}

export function getPlatePattern(value: string): PlatePattern {
  const plate = normalizePlateInput(value)
  if (/^[A-Z]{3}[0-9]{4}$/.test(plate)) return 'OLD'
  if (/^[A-Z]{3}[0-9][A-Z][0-9]{2}$/.test(plate)) return 'MERCOSUR'
  return 'UNKNOWN'
}

export function normalizeCylinderInput(value: string, unit: CylinderUnit = ''): string {
  void unit // A unidade é aplicada na conversão para cm³; a entrada aceita decimal em ambos os formatos.
  return value.replace(',', '.').replace(/[^0-9.]/g, '').replace(/\.(?=.*\.)/g, '')
}

export function normalizeCylinderToCc(value: string | number, unit: CylinderUnit = ''): number | null {
  const numeric = Number(String(value).replace(',', '.').trim())
  if (!Number.isFinite(numeric) || numeric <= 0) return null
  const normalized = unit === 'L' ? numeric * 1000 : unit === 'CM3' ? numeric : numeric < 100 ? numeric * 1000 : numeric
  return Number.isFinite(normalized) && normalized > 0 ? Number(normalized.toFixed(3)) : null
}
