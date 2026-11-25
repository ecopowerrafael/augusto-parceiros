import { z } from 'zod'

export const FIELD_TYPES = ['TEXT', 'LONG_TEXT', 'INTEGER', 'DECIMAL', 'MONEY', 'PERCENT', 'DATE', 'PHONE', 'EMAIL', 'CPF_CNPJ', 'VEHICLE_PLATE', 'SINGLE_SELECT', 'MULTI_SELECT', 'RADIO', 'CHECKBOX', 'YES_NO', 'CALCULATED', 'API_FIELD', 'INFO', 'DOCUMENT_REQUIREMENT']
export const DATA_ORIGINS = ['MANUAL', 'EXTERNAL', 'CALCULATED', 'ADMIN_CONFIRMED', 'UNAVAILABLE']
export const OPERATORS = ['EQUALS', 'NOT_EQUALS', 'GREATER_THAN', 'LESS_THAN', 'GREATER_OR_EQUAL', 'LESS_OR_EQUAL', 'BETWEEN', 'CONTAINS', 'NOT_CONTAINS', 'FILLED', 'EMPTY', 'TRUE', 'FALSE', 'IN_LIST', 'NOT_IN_LIST', 'PERCENTAGE_COMPARISON']
export const ACTION_TYPES = ['ADD_BILLING_ITEM', 'REMOVE_BILLING_ITEM', 'SET_QUANTITY', 'SET_AMOUNT', 'REQUIRE_FIELD', 'SHOW_FIELD', 'HIDE_FIELD', 'REQUIRE_DOCUMENT', 'SHOW_GUIDANCE', 'SHOW_ALERT', 'REQUIRE_EXTERNAL_QUERY', 'MANUAL_REVIEW', 'BLOCK_AUTOMATED_QUOTE', 'CLASSIFY_VIABILITY', 'REQUIRE_ADMIN_APPROVAL']

const refSchema = z.object({ field: z.string().trim().min(1).max(100) }).strict()
const leafSchema = z.object({ field: z.string().trim().min(1).max(100), operator: z.enum(OPERATORS), value: z.unknown().optional(), value2: z.unknown().optional(), valueField: z.string().trim().min(1).max(100).optional(), values: z.array(z.unknown()).max(100).optional() }).strict()
const conditionSchema = z.lazy(() => z.union([
  z.object({ all: z.array(z.union([leafSchema, conditionSchema])).min(1).max(50) }).strict(),
  z.object({ any: z.array(z.union([leafSchema, conditionSchema])).min(1).max(50) }).strict(),
  leafSchema,
]))

export const conditionExpressionSchema = conditionSchema

export const serviceSchema = z.object({
  code: z.string().trim().regex(/^[A-Z0-9_]{3,60}$/),
  name: z.string().trim().min(3).max(180),
  slug: z.string().trim().regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/).max(180),
  shortDescription: z.string().trim().max(500).optional().or(z.literal('')),
  detailedDescription: z.string().trim().max(10000).optional().or(z.literal('')),
  category: z.string().trim().min(2).max(80),
  serviceType: z.enum(['MAIN', 'COMPLEMENTARY']).default('MAIN'),
  availabilityMode: z.enum(['ALL', 'CONFIGURED']).default('ALL'),
  displayOrder: z.coerce.number().int().min(0).max(100000).default(0),
  availableToClient: z.boolean().default(true),
  availableToPartner: z.boolean().default(true),
  generalGuidance: z.string().trim().max(10000).optional().or(z.literal('')),
  internalNotes: z.string().trim().max(10000).optional().or(z.literal('')),
})

export const sectionSchema = z.object({
  stableKey: z.string().trim().regex(/^[a-zA-Z0-9_.-]{2,80}$/),
  label: z.string().trim().min(2).max(180),
  description: z.string().trim().max(500).optional().or(z.literal('')),
  displayOrder: z.coerce.number().int().min(0).max(100000).default(0),
  visibilityCondition: conditionSchema.nullable().optional(),
})

export const fieldSchema = z.object({
  sectionId: z.string().uuid().nullable().optional(),
  fieldKey: z.string().trim().regex(/^[a-zA-Z][a-zA-Z0-9_.-]{1,99}$/),
  label: z.string().trim().min(2).max(180),
  description: z.string().trim().max(500).optional().or(z.literal('')),
  placeholder: z.string().trim().max(180).optional().or(z.literal('')),
  fieldType: z.enum(FIELD_TYPES),
  defaultValue: z.unknown().nullable().optional(),
  unit: z.string().trim().max(32).optional().or(z.literal('')),
  isRequired: z.boolean().default(false),
  isEditable: z.boolean().default(true),
  minValue: z.coerce.number().finite().nullable().optional(),
  maxValue: z.coerce.number().finite().nullable().optional(),
  displayOrder: z.coerce.number().int().min(0).max(100000).default(0),
  visibilityCondition: conditionSchema.nullable().optional(),
  requiredCondition: conditionSchema.nullable().optional(),
  editabilityCondition: conditionSchema.nullable().optional(),
  dataOrigin: z.enum(DATA_ORIGINS).default('MANUAL'),
  sourcePath: z.string().trim().max(180).optional().or(z.literal('')),
  calculation: z.object({ operation: z.enum(['ADD', 'SUBTRACT', 'MULTIPLY', 'DIVIDE', 'PERCENT', 'PERCENT_VARIATION', 'ROUND']), operands: z.array(refSchema).min(1).max(4), decimals: z.number().int().min(0).max(6).optional() }).strict().nullable().optional(),
}).superRefine((value, context) => {
  if (value.minValue !== null && value.minValue !== undefined && value.maxValue !== null && value.maxValue !== undefined && value.minValue > value.maxValue) context.addIssue({ code: z.ZodIssueCode.custom, path: ['maxValue'], message: 'O limite máximo deve ser maior ou igual ao mínimo.' })
  if (value.fieldType === 'CALCULATED' && !value.calculation) context.addIssue({ code: z.ZodIssueCode.custom, path: ['calculation'], message: 'Campo calculado precisa de uma operação configurada.' })
})

export const optionSchema = z.object({ optionValue: z.string().trim().min(1).max(120), optionLabel: z.string().trim().min(1).max(180), displayOrder: z.coerce.number().int().min(0).max(100000).default(0) })
export const billingItemSchema = z.object({
  code: z.string().trim().regex(/^[A-Z0-9_]{3,80}$/), name: z.string().trim().min(2).max(180), description: z.string().trim().max(500).optional().or(z.literal('')),
  financialCategory: z.string().trim().min(2).max(80), defaultAmountCents: z.coerce.number().int().min(0).max(999999999999).nullable().optional(), status: z.enum(['DRAFT', 'PUBLISHED', 'ARCHIVED']).default('DRAFT'),
  chargeNature: z.enum(['HONORARY', 'PUBLIC_FEE', 'OWN_SERVICE', 'THIRD_PARTY', 'ADDITIONAL_EXPENSE']), amountStatus: z.enum(['FIXED', 'ESTIMATED', 'QUOTE_ONLY', 'CLIENT_DIRECT', 'NOT_DEFINED']), paymentMode: z.string().trim().max(32).default('UNDEFINED'), isPublicFee: z.boolean().default(false), uf: z.string().regex(/^[A-Z]{2}$/).nullable().optional(), vehicleCategoryId: z.string().uuid().nullable().optional(), commercialProfile: z.string().trim().max(16).nullable().optional(), partnerCompanyId: z.string().uuid().nullable().optional(), validFrom: z.string().date().nullable().optional(), validUntil: z.string().date().nullable().optional(),
})

export const serviceBillingSchema = z.object({ billingItemId: z.string().uuid(), billingMode: z.enum(['REQUIRED', 'OPTIONAL', 'CONDITIONAL']), quantity: z.coerce.number().positive().max(1000).default(1), amountOverrideCents: z.coerce.number().int().min(0).max(999999999999).nullable().optional(), discountAllowed: z.boolean().default(false), visibleToPartner: z.boolean().default(true), visibleToClient: z.boolean().default(true), includeInTotal: z.boolean().default(true), conditionExpression: conditionSchema.nullable().optional(), displayOrder: z.coerce.number().int().min(0).max(100000).default(0) })
export const ruleSchema = z.object({ serviceId: z.string().uuid(), serviceVersionId: z.string().uuid().nullable().optional(), name: z.string().trim().min(2).max(180), description: z.string().trim().max(10000).optional().or(z.literal('')), vehicleCategoryId: z.string().uuid().nullable().optional(), uf: z.string().regex(/^[A-Z]{2}$/).nullable().optional(), conditions: conditionSchema, technicalLimits: z.record(z.unknown()).default({}), expectedResult: z.enum(['VIABLE', 'OUT_OF_CRITERIA', 'VIABLE_WITH_REQUIREMENTS', 'MANUAL_REVIEW']), status: z.enum(['DRAFT', 'PUBLISHED', 'ARCHIVED']).default('DRAFT'), priority: z.coerce.number().int().min(0).max(100000).default(100), referenceText: z.string().trim().max(500).optional().or(z.literal('')) })
export const actionSchema = z.object({ actionType: z.enum(ACTION_TYPES), targetKey: z.string().trim().max(180).nullable().optional(), payload: z.record(z.unknown()).default({}), displayOrder: z.coerce.number().int().min(0).max(100000).default(0) })
export const documentSchema = z.object({ documentCode: z.string().trim().regex(/^[A-Z0-9_]{2,80}$/), name: z.string().trim().min(2).max(180), description: z.string().trim().max(500).optional().or(z.literal('')), requirementType: z.enum(['REQUIRED', 'OPTIONAL', 'CONDITIONAL', 'MANUAL_REVIEW']), conditionExpression: conditionSchema.nullable().optional(), displayOrder: z.coerce.number().int().min(0).max(100000).default(0) })
export const externalQuerySchema = z.object({ sourceId: z.string().uuid(), queryKey: z.string().trim().regex(/^[A-Z0-9_]{2,80}$/), label: z.string().trim().min(2).max(180), contextKey: z.string().trim().regex(/^[a-zA-Z][a-zA-Z0-9_.-]{1,79}$/), plateFieldKey: z.string().trim().max(100).nullable().optional(), isRequired: z.boolean().default(false), isEnabled: z.boolean().default(true) })
export const queryMappingSchema = z.object({ targetFieldKey: z.string().trim().regex(/^[a-zA-Z][a-zA-Z0-9_.-]{1,99}$/), normalizedPath: z.string().trim().min(1).max(180), dataOrigin: z.enum(['EXTERNAL', 'ADMIN_CONFIRMED']).default('EXTERNAL') })
export const messageSchema = z.object({ messageKey: z.string().trim().regex(/^[A-Z0-9_]{2,80}$/), severity: z.enum(['INFO', 'WARNING', 'ERROR', 'SUCCESS']).default('INFO'), content: z.string().trim().min(2).max(5000), conditionExpression: conditionSchema.nullable().optional(), displayOrder: z.coerce.number().int().min(0).max(100000).default(0) })

function depth(value, current = 0) { if (!value || typeof value !== 'object') return current; if (current > 8) return current; const values = Array.isArray(value) ? value : Object.values(value); return values.reduce((max, item) => Math.max(max, depth(item, current + 1)), current) }
function lookup(value, key) { return Object.prototype.hasOwnProperty.call(value, key) ? value[key] : undefined }
function operand(condition, values) { return condition.valueField ? lookup(values, condition.valueField) : condition.value }
function isEmpty(value) { return value === undefined || value === null || value === '' }
function numeric(value) { return typeof value === 'number' && Number.isFinite(value) ? value : (typeof value === 'string' && value.trim() !== '' && Number.isFinite(Number(value)) ? Number(value) : null) }

export function normalizePlate(value) {
  const plate = String(value || '').toUpperCase().replace(/[ -]/g, '')
  if (/^[A-Z]{3}[0-9]{4}$/.test(plate)) return { value: plate, pattern: 'OLD' }
  if (/^[A-Z]{3}[0-9][A-Z][0-9]{2}$/.test(plate)) return { value: plate, pattern: 'MERCOSUR' }
  return { value: plate, pattern: 'UNKNOWN' }
}

export function evaluateCondition(condition, values) {
  if (!condition) return false
  if (Array.isArray(condition.all)) return condition.all.every((item) => evaluateCondition(item, values))
  if (Array.isArray(condition.any)) return condition.any.some((item) => evaluateCondition(item, values))
  const left = lookup(values, condition.field); const right = operand(condition, values); const op = condition.operator
  if (op === 'FILLED') return !isEmpty(left)
  if (op === 'EMPTY') return isEmpty(left)
  if (op === 'TRUE') return left === true
  if (op === 'FALSE') return left === false
  if (op === 'IN_LIST') return Array.isArray(condition.values) && condition.values.includes(left)
  if (op === 'NOT_IN_LIST') return Array.isArray(condition.values) && !condition.values.includes(left)
  if (op === 'CONTAINS' || op === 'NOT_CONTAINS') { const result = Array.isArray(left) ? left.includes(right) : String(left ?? '').includes(String(right ?? '')); return op === 'CONTAINS' ? result : !result }
  const leftNumber = numeric(left); const rightNumber = numeric(right)
  if (['GREATER_THAN', 'LESS_THAN', 'GREATER_OR_EQUAL', 'LESS_OR_EQUAL', 'BETWEEN', 'PERCENTAGE_COMPARISON'].includes(op) && (leftNumber === null || rightNumber === null)) return false
  if (op === 'EQUALS') return left === right || (leftNumber !== null && rightNumber !== null && leftNumber === rightNumber)
  if (op === 'NOT_EQUALS') return !evaluateCondition({ field: condition.field, operator: 'EQUALS', value: right }, values)
  if (op === 'GREATER_THAN') return leftNumber > rightNumber
  if (op === 'LESS_THAN') return leftNumber < rightNumber
  if (op === 'GREATER_OR_EQUAL') return leftNumber >= rightNumber
  if (op === 'LESS_OR_EQUAL') return leftNumber <= rightNumber
  if (op === 'BETWEEN') { const end = numeric(condition.value2); return end !== null && leftNumber >= rightNumber && leftNumber <= end }
  if (op === 'PERCENTAGE_COMPARISON') return Math.abs(leftNumber - rightNumber) / Math.max(Math.abs(rightNumber), 1) * 100 <= Number(condition.value2 ?? 0)
  return false
}

export function calculateFields(fields, input) {
  const values = { ...input }
  const calculated = fields.filter((field) => field.field_type === 'CALCULATED' && field.calculation)
  for (let pass = 0; pass < calculated.length; pass += 1) {
    for (const field of calculated) {
      const calc = typeof field.calculation === 'string' ? JSON.parse(field.calculation) : field.calculation
      const args = calc.operands.map((ref) => numeric(lookup(values, ref.field)))
      if (args.some((arg) => arg === null)) continue
      let result = null
      if (calc.operation === 'ADD') result = args.reduce((sum, value) => sum + value, 0)
      if (calc.operation === 'SUBTRACT') result = args.slice(1).reduce((total, value) => total - value, args[0])
      if (calc.operation === 'MULTIPLY') result = args.reduce((total, value) => total * value, 1)
      if (calc.operation === 'DIVIDE' && args.slice(1).every((value) => value !== 0)) result = args.slice(1).reduce((total, value) => total / value, args[0])
      if (calc.operation === 'PERCENT' && args[1] !== 0) result = args[0] * args[1] / 100
      if (calc.operation === 'PERCENT_VARIATION' && args[0] !== 0) result = (args[1] - args[0]) / args[0] * 100
      if (calc.operation === 'ROUND') result = Number(args[0].toFixed(calc.decimals ?? 2))
      if (result !== null && Number.isFinite(result)) values[field.field_key] = result
    }
  }
  return values
}

export function validateConfiguration(fields, conditions = []) {
  const keys = new Set(fields.map((field) => field.field_key)); const errors = []
  for (const condition of conditions) { if (depth(condition) > 8) errors.push('A condição excede a profundidade máxima de 8 níveis.') ; const references = JSON.stringify(condition).match(/"field"\s*:\s*"([^"]+)"/g) || []; for (const reference of references) { const key = reference.replace(/.*"field"\s*:\s*"|"$/g, ''); if (!keys.has(key)) errors.push(`A configuração referencia o campo inexistente: ${key}.`) } }
  const graph = new Map(fields.filter((field) => field.calculation).map((field) => [field.field_key, field.calculation.operands.map((operand) => operand.field)])); const visiting = new Set(); const visited = new Set()
  const visit = (key) => { if (visiting.has(key)) return true; if (visited.has(key)) return false; visiting.add(key); const cycle = (graph.get(key) || []).some((dependency) => graph.has(dependency) && visit(dependency)); visiting.delete(key); visited.add(key); return cycle }
  for (const key of graph.keys()) if (visit(key)) errors.push(`Dependência circular detectada no campo ${key}.`)
  return [...new Set(errors)]
}

export function evaluateService({ fields, billingItems = [], rules = [], documents = [], answers = {}, context = {} }) {
  const values = calculateFields(fields, { ...context, ...answers }); const trace = []; const appliedItems = new Map(); const documentsResult = []; const actions = []; let blocked = false; let manualReview = false; let viability = null
  for (const item of billingItems) { const condition = item.condition_expression ? (typeof item.condition_expression === 'string' ? JSON.parse(item.condition_expression) : item.condition_expression) : null; const applies = item.billing_mode === 'REQUIRED' || Boolean(condition && evaluateCondition(condition, values)); if (applies) appliedItems.set(item.code, { ...item, reason: item.billing_mode === 'REQUIRED' ? 'Obrigatório' : 'Condição atendida' }) }
  for (const rule of [...rules].sort((a, b) => a.priority - b.priority)) { const condition = typeof rule.conditions === 'string' ? JSON.parse(rule.conditions) : rule.conditions; if (!evaluateCondition(condition, values)) { trace.push({ rule: rule.name, matched: false }); continue } const result = { rule: rule.name, matched: true, expectedResult: rule.expected_result }; trace.push(result); if (rule.expected_result === 'OUT_OF_CRITERIA') blocked = true; if (rule.expected_result === 'MANUAL_REVIEW') manualReview = true; if (rule.expected_result === 'VIABLE_WITH_REQUIREMENTS') manualReview = true; viability = rule.expected_result
    const ruleActions = rule.actions || []; for (const action of ruleActions) { actions.push(action); if (action.action_type === 'BLOCK_AUTOMATED_QUOTE') blocked = true; if (action.action_type === 'MANUAL_REVIEW' || action.action_type === 'REQUIRE_ADMIN_APPROVAL') manualReview = true; if (action.action_type === 'CLASSIFY_VIABILITY') viability = action.payload?.result || viability; if (action.action_type === 'ADD_BILLING_ITEM' && action.target_key && !appliedItems.has(action.target_key)) { const target = billingItems.find((item) => item.code === action.target_key); if (target) appliedItems.set(target.code, { ...target, reason: 'Regra atendida' }) } if (action.action_type === 'REMOVE_BILLING_ITEM' && action.target_key) appliedItems.delete(action.target_key) }
  }
  for (const document of documents) { const condition = document.condition_expression ? (typeof document.condition_expression === 'string' ? JSON.parse(document.condition_expression) : document.condition_expression) : null; if (document.requirement_type === 'REQUIRED' || (condition && evaluateCondition(condition, values))) documentsResult.push(document) }
  const items = [...appliedItems.values()].map((item) => ({ ...item, amount_cents: item.amount_override_cents ?? item.default_amount_cents, total_cents: item.amount_override_cents !== null && item.amount_override_cents !== undefined ? Number(item.amount_override_cents) * Number(item.quantity || 1) : (item.default_amount_cents === null ? null : Number(item.default_amount_cents) * Number(item.quantity || 1)) }))
  return { values, items, total_cents: items.reduce((sum, item) => sum + (item.include_in_total && item.total_cents !== null ? item.total_cents : 0), 0), missing_amount_items: items.filter((item) => item.total_cents === null).map((item) => item.code), documents: documentsResult, actions, trace, blocked, manual_review: manualReview, viability: blocked ? 'OUT_OF_CRITERIA' : manualReview ? 'MANUAL_REVIEW' : viability || 'UNCLASSIFIED' }
}
