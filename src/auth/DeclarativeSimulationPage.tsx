import { FormEvent, useEffect, useMemo, useState } from 'react'
import { ServiceResultView } from '../simulator/ServiceResultView'
import { evaluateDeclarativeCondition } from '../simulator/conditions'
import { FUEL_OPTIONS, normalizeCylinderInput, normalizeCylinderToCc, normalizeFuel, normalizePlateInput } from '../simulator/normalizers'

type Item = Record<string, unknown>
type Editor = { version: Item; fields: Item[]; options: Item[]; validationErrors?: string[] }
type CatalogItem = { code: string; name: string; category: string; status: string; requires_description?: number }

const csrf = () => sessionStorage.getItem('doc_motor_csrf') || ''

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const response = await fetch(path, { ...options, credentials: 'include', headers: { 'Content-Type': 'application/json', ...(csrf() ? { 'X-CSRF-Token': csrf() } : {}) } })
  const body = await response.json().catch(() => ({})) as T & { error?: string }
  if (!response.ok) throw new Error(body.error || 'Não foi possível carregar a simulação.')
  return body
}

export function DeclarativeSimulationPage() {
  const [editor, setEditor] = useState<Editor | null>(null)
  const [catalog, setCatalog] = useState<CatalogItem[]>([])
  const [answers, setAnswers] = useState<Record<string, unknown>>({})
  const [result, setResult] = useState<Record<string, unknown> | null>(null)
  const [message, setMessage] = useState('Carregando configuração…')

  useEffect(() => {
    void Promise.all([
      request<{ items: Item[] }>('/api/admin/services'),
      request<{ items: CatalogItem[] }>('/api/admin/modification-catalog'),
    ]).then(async ([services, catalogResponse]) => {
      const service = services.items.find((item) => item.code === 'LOWERED_SUSPENSION')
      if (!service?.id) throw new Error('O serviço de suspensão ainda não foi encontrado.')
      const loaded = await request<Editor & { error?: string }>(`/api/admin/services/${String(service.id)}/editor`)
      setEditor(loaded)
      setCatalog((catalogResponse.items || []).filter((item) => item.status === 'ACTIVE'))
      setMessage('')
    }).catch((error) => setMessage(error instanceof Error ? error.message : 'Não foi possível carregar a configuração.'))
  }, [])

  const visibleFields = useMemo(() => (editor?.fields || []).filter((field) => {
    if (field.field_type === 'CALCULATED') return false
    const condition = field.visibility_condition as Record<string, unknown> | null | undefined
    return !condition || evaluateDeclarativeCondition(condition, answers)
  }), [answers, editor])

  const update = (key: string, value: unknown) => { setAnswers((current) => ({ ...current, [key]: value })); setResult(null) }
  const renderField = (field: Item) => {
    const key = String(field.field_key)
    const type = String(field.field_type)
    const value = answers[key]
    const options = (editor?.options || []).filter((option) => option.field_id === field.id)
    const isFuel = key.toLowerCase().endsWith('.fuel')
    const isCylinder = key.toLowerCase().includes('cylinder') || key.toLowerCase().includes('cilind') || key.toLowerCase().endsWith('.engine_cc')
    if (type === 'INFO') return <p className="builder-info" key={key}>{String(field.label)}</p>
    if (type === 'REPEATABLE_MODIFICATIONS') {
      const entries = Array.isArray(value) ? value as Array<{ code?: string; description?: string }> : []
      const updateEntries = (next: Array<{ code?: string; description?: string }>) => update(key, next)
      return <fieldset className="builder-field" key={key}><legend>{String(field.label)}</legend>{entries.map((entry, index) => <div className="builder-row" key={`${key}-${index}`}><label><span>Modificação {index + 1}</span><select value={entry.code || ''} onChange={(event) => updateEntries(entries.map((item, itemIndex) => itemIndex === index ? { ...item, code: event.target.value } : item))}><option value="">Selecione</option>{catalog.filter((item) => item.code !== 'WHEELS_TIRES' && !item.code.startsWith('SUSPENSION_')).map((item) => <option key={item.code} value={item.code}>{item.name} · {item.category}</option>)}</select></label><label><span>Descrição</span><input value={entry.description || ''} placeholder="Descreva a alteração" onChange={(event) => updateEntries(entries.map((item, itemIndex) => itemIndex === index ? { ...item, description: event.target.value } : item))} /></label><button type="button" onClick={() => updateEntries(entries.filter((_, itemIndex) => itemIndex !== index))}>Remover</button></div>)}<button type="button" onClick={() => updateEntries([...entries, {}])}>Adicionar outra modificação</button></fieldset>
    }
    const hasDescription = field.description !== undefined && field.description !== null && field.description !== ''
    const required = field.is_required === true || field.is_required === 1
    if (type === 'CHECKBOX') return <label className="builder-field builder-checkbox" key={key}><span><input type="checkbox" checked={value === true} onChange={(event) => update(key, event.target.checked)} /> {String(field.label)}</span>{hasDescription && <small>{String(field.description)}</small>}</label>
    if (type === 'YES_NO' || isFuel || ['SINGLE_SELECT', 'RADIO'].includes(type)) { const selectOptions = isFuel ? FUEL_OPTIONS : type === 'YES_NO' ? [{ value: 'YES', label: 'Sim' }, { value: 'NO', label: 'Não' }] : options.map((option) => ({ value: String(option.option_value), label: String(option.option_label) })); return <label className="builder-field" key={key}><span>{String(field.label)}{required ? ' *' : ''}</span><select value={String(value ?? '')} onChange={(event) => update(key, isFuel ? normalizeFuel(event.target.value) : event.target.value)}><option value="">Selecione</option>{selectOptions.map((option) => <option key={option.value} value={option.value}>{option.label}</option>)}</select>{hasDescription && <small>{String(field.description)}</small>}</label> }
    const normalizeOnBlur = () => { if (!isCylinder) return; const normalized = normalizeCylinderToCc(String(answers[key] ?? '')); if (normalized !== null) update(key, normalized) }
    return <label className="builder-field" key={key}><span>{String(field.label)}{required ? ' *' : ''}</span><input type={type === 'DATE' ? 'date' : 'text'} inputMode={isCylinder || ['INTEGER', 'DECIMAL', 'MONEY', 'PERCENT'].includes(type) ? 'decimal' : undefined} maxLength={type === 'VEHICLE_PLATE' ? 7 : undefined} value={String(value ?? '')} onChange={(event) => update(key, type === 'VEHICLE_PLATE' ? normalizePlateInput(event.target.value) : isCylinder ? normalizeCylinderInput(event.target.value) : event.target.value)} onBlur={normalizeOnBlur} />{hasDescription && <small>{String(field.description)}</small>}</label>
  }

  const simulate = async (event: FormEvent) => { event.preventDefault(); if (!editor?.version.id) return; setMessage(''); try { const response = await request<{ result?: Record<string, unknown> }>(`/api/admin/service-versions/${String(editor.version.id)}/simulate`, { method: 'POST', body: JSON.stringify({ answers }) }); setResult(response.result || null) } catch (error) { setResult(null); setMessage(error instanceof Error ? error.message : 'Não foi possível simular.') } }
  if (!editor) return <section className="service-builder"><p className="auth-muted" role="status">{message}</p></section>
  return <section className="service-builder"><div className="builder-heading"><div><p className="auth-kicker">SIMULADOR DECLARATIVO</p><h2>{String(editor.version.service_name || 'Regularização de suspensão')}</h2><p className="auth-muted">Os campos, condições, cobranças e regras são carregados da versão persistida no construtor no-code.</p></div></div>{message && <p className="auth-muted" role="status">{message}</p>}<form className="builder-simulator" onSubmit={simulate}>{visibleFields.map(renderField)}<button className="auth-button" type="submit">Executar simulação</button></form>{result && <ServiceResultView serviceName={String(editor.version.service_name || 'Doc Motor')} simulation={result} fields={editor.fields as Array<Record<string, unknown>>} />}</section>
}
