export type DeclarativeCondition = {
  all?: DeclarativeCondition[]
  any?: DeclarativeCondition[]
  field?: string
  operator?: string
  value?: unknown
  value2?: unknown
  valueField?: string
  values?: unknown[]
}

const isEmpty = (value: unknown) => value === undefined || value === null || value === ''
const numberValue = (value: unknown) => typeof value === 'number' && Number.isFinite(value) ? value : typeof value === 'string' && value.trim() !== '' && Number.isFinite(Number(value)) ? Number(value) : null

export function evaluateDeclarativeCondition(condition: unknown, values: Record<string, unknown>): boolean {
  if (!condition || typeof condition !== 'object') return false
  const current = condition as DeclarativeCondition
  if (Array.isArray(current.all)) return current.all.every((item) => evaluateDeclarativeCondition(item, values))
  if (Array.isArray(current.any)) return current.any.some((item) => evaluateDeclarativeCondition(item, values))
  const left = current.field ? values[current.field] : undefined
  const right = current.valueField ? values[current.valueField] : current.value
  const leftNumber = numberValue(left); const rightNumber = numberValue(right)
  switch (current.operator) {
    case 'FILLED': return !isEmpty(left)
    case 'EMPTY': return isEmpty(left)
    case 'TRUE': return left === true
    case 'FALSE': return left === false
    case 'IN_LIST': return Array.isArray(current.values) && current.values.includes(left)
    case 'NOT_IN_LIST': return Array.isArray(current.values) && !current.values.includes(left)
    case 'CONTAINS': return Array.isArray(left) ? left.includes(right) : String(left ?? '').includes(String(right ?? ''))
    case 'NOT_CONTAINS': return Array.isArray(left) ? !left.includes(right) : !String(left ?? '').includes(String(right ?? ''))
    case 'EQUALS': return left === right || (leftNumber !== null && rightNumber !== null && leftNumber === rightNumber)
    case 'NOT_EQUALS': return !isEmpty(left) && !isEmpty(right) && !(left === right || (leftNumber !== null && rightNumber !== null && leftNumber === rightNumber))
    case 'GREATER_THAN': return leftNumber !== null && rightNumber !== null && leftNumber > rightNumber
    case 'LESS_THAN': return leftNumber !== null && rightNumber !== null && leftNumber < rightNumber
    case 'GREATER_OR_EQUAL': return leftNumber !== null && rightNumber !== null && leftNumber >= rightNumber
    case 'LESS_OR_EQUAL': return leftNumber !== null && rightNumber !== null && leftNumber <= rightNumber
    case 'BETWEEN': { const end = numberValue(current.value2); return leftNumber !== null && rightNumber !== null && end !== null && leftNumber >= rightNumber && leftNumber <= end }
    case 'PERCENTAGE_COMPARISON': return leftNumber !== null && rightNumber !== null && Math.abs(leftNumber - rightNumber) / Math.max(Math.abs(rightNumber), 1) * 100 <= Number(current.value2 ?? 0)
    default: return false
  }
}
