export type ValidationIssue = { field: string; label: string; message: string; code?: string }
type Field = Record<string, unknown>

const fallbackLabels: Record<string, string> = {
  'vehicle_target.state': 'UF do veículo',
  'wheels.include': 'Regularização de rodas e pneus',
  'modifications.additional': 'Modificações adicionais',
}

export function normalizeValidationIssues(details: unknown, fields: Field[] = []): ValidationIssue[] {
  if (!Array.isArray(details)) return []
  return details.flatMap((detail) => {
    if (!detail || typeof detail !== 'object') return []
    const item = detail as Record<string, unknown>
    const field = String(item.field || '')
    const configured = fields.find((candidate) => String(candidate.field_key || '') === field)
    return [{ field, label: String(item.label || configured?.label || fallbackLabels[field] || 'Este campo'), message: String(item.message || 'Confira este campo.'), code: item.code ? String(item.code) : undefined }]
  })
}

export function firstValidationField(issues: ValidationIssue[]) {
  return issues.find((issue) => issue.field)?.field || ''
}

export function validationSummary(issues: ValidationIssue[]) {
  const labels = [...new Set(issues.map((issue) => issue.label).filter(Boolean))]
  if (labels.length === 1) return `Confira o campo destacado (${labels[0]}) antes de continuar.`
  if (labels.length > 1) return `Confira os campos destacados: ${labels.join(', ')}.`
  return 'Confira os campos destacados antes de continuar.'
}
