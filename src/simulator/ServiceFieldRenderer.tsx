import { ReactNode, useEffect, useState } from 'react'
import { Plus, Trash2 } from 'lucide-react'
import { evaluateDeclarativeCondition } from './conditions'
import { FUEL_OPTIONS, normalizeCylinderInput, normalizeCylinderToCc, normalizeFuel, normalizePlateInput } from './normalizers'

type Field = Record<string, unknown>
type Option = Record<string, unknown>
type Rule = Record<string, unknown>
type CatalogItem = { code: string; name: string; category?: string; status?: string; requires_description?: number | boolean; billing_amount_cents?: number | null; vehicle_category_codes?: string[]; ufs?: string[] }
let catalogRequest: Promise<CatalogItem[]> | null = null

export const getVehicleStateOptions = () => [{ value: 'SP', label: 'São Paulo' }, { value: 'OTHER_STATE', label: 'Outros estados' }]

const valueString = (value: unknown) => String(value ?? '')
const isPresent = (value: unknown) => value !== undefined && value !== null && valueString(value).trim() !== ''

function referencesField(condition: unknown, fieldKey: string): boolean {
  if (!condition || typeof condition !== 'object') return false
  if (Array.isArray(condition)) return condition.some((item) => referencesField(item, fieldKey))
  return Object.entries(condition as Record<string, unknown>).some(([key, value]) => key === 'field' && value === fieldKey || referencesField(value, fieldKey))
}

export function ruleRequiresField(fieldKey: string, rules: Rule[], values: Record<string, unknown>) {
  const category = valueString(values['vehicle_target.category']).toUpperCase()
  return rules.some((rule) => {
    const ruleCategory = valueString(rule.vehicle_category_code).toUpperCase()
    return (!ruleCategory || !category || ruleCategory === category) && referencesField(rule.conditions, fieldKey)
  })
}

export function shouldRenderServiceField(field: Field, values: Record<string, unknown>, rules: Rule[] = []) {
  const type = valueString(field.field_type)
  if (type === 'CALCULATED') return false
  const condition = field.visibility_condition as Record<string, unknown> | null | undefined
  if (condition && !evaluateDeclarativeCondition(condition, values)) return false
  return valueString(field.field_key) !== 'vehicle_target.pbt_kg' || ruleRequiresField('vehicle_target.pbt_kg', rules, values)
}

function catalogFor(catalog: CatalogItem[], values: Record<string, unknown>, selected: Set<string>) {
  const category = valueString(values['vehicle_target.category']).toUpperCase()
  const uf = valueString(values['vehicle_target.state']).toUpperCase()
  return catalog.filter((item) => {
    if (valueString(item.status).toUpperCase() !== 'ACTIVE') return false
    if (item.code === 'WHEELS_TIRES' || item.code.startsWith('SUSPENSION_')) return false
    if (item.code !== 'OTHER_MODIFICATION' && selected.has(item.code)) return false
    const categories = (item.vehicle_category_codes || []).map((value) => value.toUpperCase())
    const ufs = (item.ufs || []).map((value) => value.toUpperCase())
    return (!categories.length || !category || categories.includes(category)) && (!ufs.length || !uf || ufs.includes(uf))
  })
}

type Props = { field: Field; options?: Option[]; catalog?: CatalogItem[]; rules?: Rule[]; values: Record<string, unknown>; onChange: (key: string, value: unknown) => void; error?: string }

export function ServiceFieldRenderer({ field, options = [], catalog = [], values, onChange, error }: Props): ReactNode {
  const [loadedCatalog, setLoadedCatalog] = useState<CatalogItem[]>([])
  useEffect(() => {
    if (catalog.length > 0) return
    catalogRequest ||= fetch('/api/admin/modification-catalog', { credentials: 'include' }).then((response) => response.ok ? response.json() as Promise<{ items?: CatalogItem[] }> : { items: [] }).then((body) => body.items || []).catch(() => [])
    void catalogRequest.then(setLoadedCatalog)
  }, [catalog.length])
  const effectiveCatalog = catalog.length > 0 ? catalog : loadedCatalog
  const key = valueString(field.field_key)
  const type = valueString(field.field_type)
  const value = values[key]
  const description = isPresent(field.description) ? valueString(field.description) : ''
  const required = field.is_required === true || field.is_required === 1
  const isFuel = key.toLowerCase().endsWith('.fuel')
  const isCylinder = key.toLowerCase().includes('cylinder') || key.toLowerCase().includes('cilind') || key.toLowerCase().endsWith('.engine_cc')
  const isChecklist = ['suspension.contact_check', 'wheels.contact_check', 'suspension.clearance_check', 'wheels.fender_check', 'wheels.diameter_check'].includes(key)
  useEffect(() => {
    if (!error) return
    const element = [...document.querySelectorAll<HTMLElement>('[data-field-key]')].find((candidate) => candidate.dataset.fieldKey === key)
    if (element) { element.scrollIntoView({ behavior: 'smooth', block: 'center' }); element.focus({ preventScroll: true }) }
  }, [error, key])
  const fieldClass = `builder-field${error ? ' has-error' : ''}`
  const errorMessage = error ? <small className="builder-field-error" role="alert">{error}</small> : null
  if (type === 'INFO') return <p className="builder-info">{valueString(field.label)}</p>
  if (type === 'REPEATABLE_MODIFICATIONS') {
    const entries = Array.isArray(value) ? value as Array<{ code?: string; description?: string }> : []
    const selected = new Set(entries.map((entry) => valueString(entry.code)).filter(Boolean))
    const available = catalogFor(effectiveCatalog, values, selected)
    const updateEntries = (next: Array<{ code?: string; description?: string }>) => onChange(key, next)
    return <fieldset className={`${fieldClass} builder-repeatable`} data-field-key={key} tabIndex={-1}><legend>Modificações adicionais</legend><p className="builder-repeatable-help">Inclua outras alterações que deseja regularizar no veículo.</p><select aria-label="Deseja regularizar outras modificações no veículo" value={entries.length ? 'YES' : 'NO'} onChange={(event) => updateEntries(event.target.value === 'YES' ? [{}] : [])}><option value="NO">Não</option><option value="YES">Sim</option></select>{entries.map((entry, index) => { const selectedItem = effectiveCatalog.find((item) => item.code === entry.code); const needsDescription = Boolean(selectedItem?.requires_description); return <div className="builder-repeatable-item" key={`${key}-${index}`}><strong>Modificação {index + 1}</strong><label><span>Selecione a modificação</span><select value={entry.code || ''} onChange={(event) => updateEntries(entries.map((item, itemIndex) => itemIndex === index ? { ...item, code: event.target.value } : item))}><option value="">Selecione</option>{entry.code && !available.some((item) => item.code === entry.code) && selectedItem ? <option value={selectedItem.code}>{selectedItem.name}</option> : null}{available.map((item) => <option key={item.code} value={item.code}>{item.name}{item.category ? ` · ${item.category}` : ''}</option>)}</select></label>{selectedItem?.billing_amount_cents !== null && selectedItem?.billing_amount_cents !== undefined && <small>Valor configurado: R$ {(Number(selectedItem.billing_amount_cents) / 100).toFixed(2).replace('.', ',')}</small>}<label><span>Descrição complementar{needsDescription ? ' *' : ''}</span><input value={entry.description || ''} placeholder={needsDescription ? 'Descreva a alteração' : 'Opcional'} onChange={(event) => updateEntries(entries.map((item, itemIndex) => itemIndex === index ? { ...item, description: event.target.value } : item))} /></label><button type="button" aria-label={`Remover modificação ${index + 1}`} onClick={() => updateEntries(entries.filter((_, itemIndex) => itemIndex !== index))}><Trash2 size={15} aria-hidden="true" /> Remover</button></div>})}{entries.length > 0 && <button type="button" onClick={() => updateEntries([...entries, {}])}><Plus size={15} aria-hidden="true" /> Adicionar outra modificação</button>}{description && <small>{description}</small>}{errorMessage}</fieldset>
  }
  const update = (next: unknown) => onChange(key, next)
  if (type === 'CHECKBOX') return <label className={`${fieldClass} builder-checkbox`} data-field-key={key}><span><input type="checkbox" checked={value === true} onChange={(event) => update(event.target.checked)} /> {valueString(field.label)}</span>{description && <small>{description}</small>}{errorMessage}</label>
  if (type === 'YES_NO' || isFuel || ['SINGLE_SELECT', 'RADIO'].includes(type)) {
    const selectOptions = key === 'vehicle_target.state' ? getVehicleStateOptions() : isFuel ? FUEL_OPTIONS : isChecklist ? options.map((option) => ({ value: valueString(option.option_value), label: valueString(option.option_label) })) : type === 'YES_NO' ? [{ value: 'YES', label: 'Sim' }, { value: 'NO', label: 'Não' }] : options.map((option) => ({ value: valueString(option.option_value), label: valueString(option.option_label) }))
    return <label className={fieldClass} data-field-key={key}><span>{valueString(field.label)}{required ? ' *' : ''}</span><select value={valueString(value)} onChange={(event) => update(isFuel ? normalizeFuel(event.target.value) : event.target.value)}><option value="">Selecione</option>{selectOptions.map((option) => <option key={option.value} value={option.value}>{option.label}</option>)}</select>{description && <small>{description}</small>}{errorMessage}</label>
  }
  const normalizeOnBlur = () => { if (!isCylinder) return; const normalized = normalizeCylinderToCc(valueString(value)); if (normalized !== null) update(normalized) }
  return <label className={fieldClass} data-field-key={key}><span>{valueString(field.label)}{required ? ' *' : ''}</span><input type={type === 'DATE' ? 'date' : 'text'} inputMode={isCylinder || ['INTEGER', 'DECIMAL', 'MONEY', 'PERCENT'].includes(type) ? 'decimal' : undefined} maxLength={type === 'VEHICLE_PLATE' ? 7 : undefined} value={valueString(value)} onChange={(event) => update(type === 'VEHICLE_PLATE' ? normalizePlateInput(event.target.value) : isCylinder ? normalizeCylinderInput(event.target.value) : event.target.value)} onBlur={normalizeOnBlur} />{type === 'VEHICLE_PLATE' && <small>Use uma placa antiga ou Mercosul. Espaços e hífens são removidos automaticamente.</small>}{isCylinder && <small>Informe em litros ou cm³; o valor será normalizado para cm³ ao sair do campo.</small>}{description && <small>{description}</small>}{errorMessage}</label>
}
