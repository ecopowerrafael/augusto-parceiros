import { evaluateDeclarativeCondition } from './conditions'

type Field = Record<string, unknown>

const labels: Record<string, string> = {
  'vehicle_target.plate': 'Placa do veículo',
  'vehicle_target.category': 'Categoria',
  'vehicle_target.state': 'Estado',
  'vehicle_target.power_cv': 'Potência original',
  'vehicle_target.engine_cc': 'Cilindrada original',
  'vehicle_target.fuel': 'Combustível original',
  'vehicle_donor.plate': 'Placa de origem',
  'vehicle_donor.power_cv': 'Potência do motor',
  'vehicle_donor.engine_cc': 'Cilindrada do motor',
  'vehicle_donor.fuel': 'Combustível do motor',
  'engine.has_invoice': 'Possui nota fiscal',
  'motorcycle.compatibility_declaration': 'Compatibilidade de cilindrada declarada',
}

const optionLabels: Record<string, string> = {
  AUTOMOBILE: 'Automóvel', MOTORCYCLE: 'Motocicleta', TRUCK: 'Caminhão', BUS: 'Ônibus', OTHER: 'Outra categoria',
  SP: 'São Paulo', OTHER_STATE: 'Outros estados', YES: 'Sim', NO: 'Não', ALCOHOL: 'Álcool', GASOLINE: 'Gasolina', DIESEL: 'Diesel', FLEX: 'Flex',
  PLATE: 'Consulta por placa', MANUAL: 'Informação manual', UNKNOWN: 'Dados desconhecidos',
}

const present = (value: unknown) => value !== undefined && value !== null && String(value).trim() !== ''

export const friendlyLabel = (field: Field) => labels[String(field.field_key || '')] || String(field.label || 'Informação')

export const friendlyValue = (value: unknown, fieldKey = '') => {
  if (typeof value === 'boolean') return value ? 'Sim' : 'Não'
  const text = optionLabels[String(value)] || String(value)
  if (fieldKey.endsWith('power_cv')) return `${new Intl.NumberFormat('pt-BR').format(Number(value))} CV`
  if (fieldKey.endsWith('engine_cc')) return `${new Intl.NumberFormat('pt-BR').format(Number(value))} cm³`
  return text
}

export const visiblePresentationFields = (fields: Field[], values: Record<string, unknown>) => fields.filter((field) => {
  const type = String(field.field_type || '')
  const key = String(field.field_key || '')
  if (type === 'CALCULATED' || type === 'INFO' || !present(values[key])) return false
  const condition = field.visibility_condition as Record<string, unknown> | null | undefined
  return !condition || evaluateDeclarativeCondition(condition, values)
})

export const buildManualWhatsAppMessage = (args: { template?: unknown; serviceName: string; fields: Field[]; values: Record<string, unknown>; reasons?: string[] }) => {
  const rows = visiblePresentationFields(args.fields, args.values)
  const vehicle = rows.filter((field) => String(field.field_key).startsWith('vehicle_target.'))
  const donor = rows.filter((field) => String(field.field_key).startsWith('vehicle_donor.'))
  const other = rows.filter((field) => !String(field.field_key).startsWith('vehicle_target.') && !String(field.field_key).startsWith('vehicle_donor.'))
  const section = (title: string, items: Field[]) => items.length ? `\n🚘 *${title}*\n${items.map((field) => `• ${friendlyLabel(field)}: ${friendlyValue(args.values[String(field.field_key)], String(field.field_key))}`).join('\n')}` : ''
  const reason = args.reasons?.filter(Boolean).join(' ') || 'Os dados informados precisam ser analisados individualmente.'
  const base = String(args.template || '👋 Olá! Gostaria de solicitar uma análise manual do meu cadastro de motor.').trim()
  return `${base}\n\n${section('DADOS DO VEÍCULO', vehicle)}${section('MOTOR QUE DESEJO INSTALAR', donor)}${section('INFORMAÇÕES ADICIONAIS', other)}\n\n⚠️ *RESULTADO DA ANÁLISE*\n${reason}\n\nGostaria de verificar com um consultor se existe alguma alternativa para regularizar meu veículo.\n\n📲 Consulta realizada pela plataforma Doc Motor.\n🌐 docmotor.online`.replace(/\n{3,}/g, '\n\n')
}
