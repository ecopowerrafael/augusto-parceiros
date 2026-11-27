import { FormEvent, useEffect, useMemo, useState } from 'react'
import { ServiceResultView } from '../simulator/ServiceResultView'
import { ServiceFieldRenderer, shouldRenderServiceField } from '../simulator/ServiceFieldRenderer'

type Item = Record<string, unknown>
type Editor = { version: Item; fields: Item[]; options: Item[]; rules?: Item[]; validationErrors?: string[] }
type CatalogItem = { code: string; name: string; category: string; status: string; requires_description?: number; vehicle_category_codes?: string[]; ufs?: string[] }

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

  const visibleFields = useMemo(() => (editor?.fields || []).filter((field) => shouldRenderServiceField(field, answers, editor?.rules as Array<Record<string, unknown>> || [])), [answers, editor])

  const update = (key: string, value: unknown) => { setAnswers((current) => ({ ...current, [key]: value })); setResult(null) }
  const renderField = (field: Item) => <ServiceFieldRenderer key={String(field.field_key)} field={field} options={(editor?.options || []).filter((option) => option.field_id === field.id)} catalog={catalog} rules={(editor?.rules || []) as Array<Record<string, unknown>>} values={answers} onChange={update} />

  const simulate = async (event: FormEvent) => { event.preventDefault(); if (!editor?.version.id) return; setMessage(''); try { const response = await request<{ result?: Record<string, unknown> }>(`/api/admin/service-versions/${String(editor.version.id)}/simulate`, { method: 'POST', body: JSON.stringify({ answers }) }); setResult(response.result || null) } catch (error) { setResult(null); setMessage(error instanceof Error ? error.message : 'Não foi possível simular.') } }
  if (!editor) return <section className="service-builder"><p className="auth-muted" role="status">{message}</p></section>
  return <section className="service-builder"><div className="builder-heading"><div><p className="auth-kicker">SIMULADOR DECLARATIVO</p><h2>{String(editor.version.service_name || 'Regularização de suspensão')}</h2><p className="auth-muted">Os campos, condições, cobranças e regras são carregados da versão persistida no construtor no-code.</p></div></div>{message && <p className="auth-muted" role="status">{message}</p>}<form className="builder-simulator" onSubmit={simulate}>{visibleFields.map(renderField)}<button className="auth-button" type="submit">Executar simulação</button></form>{result && <ServiceResultView serviceName={String(editor.version.service_name || 'Doc Motor')} simulation={result} fields={editor.fields as Array<Record<string, unknown>>} />}</section>
}
