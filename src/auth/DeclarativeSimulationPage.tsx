import { FormEvent, useEffect, useMemo, useState } from 'react'
import { ServiceResultView } from '../simulator/ServiceResultView'
import { ServiceFieldRenderer, shouldRenderServiceField } from '../simulator/ServiceFieldRenderer'
import { normalizeValidationIssues, validationSummary, ValidationIssue } from '../simulator/validation'

type Item = Record<string, unknown>
type Editor = { version: Item; fields: Item[]; options: Item[]; rules?: Item[]; validationErrors?: string[] }
type CatalogItem = { code: string; name: string; category: string; status: string; requires_description?: number; vehicle_category_codes?: string[]; ufs?: string[] }

const csrf = () => sessionStorage.getItem('doc_motor_csrf') || ''

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const response = await fetch(path, { ...options, credentials: 'include', headers: { 'Content-Type': 'application/json', ...(csrf() ? { 'X-CSRF-Token': csrf() } : {}) } })
  const body = await response.json().catch(() => ({})) as T & { error?: string; details?: unknown; fields?: unknown }
  if (!response.ok) { const error = new Error(body.error || 'Não foi possível carregar a simulação.') as Error & { details?: unknown }; error.details = body.details || body.fields; throw error }
  return body
}

export function DeclarativeSimulationPage({ serviceCode = 'LOWERED_SUSPENSION', title = 'Simulação do serviço', apiBase = '/api/admin' }: { serviceCode?: string; title?: string; apiBase?: string }) {
  const [editor, setEditor] = useState<Editor | null>(null)
  const [catalog, setCatalog] = useState<CatalogItem[]>([])
  const [answers, setAnswers] = useState<Record<string, unknown>>({})
  const [result, setResult] = useState<Record<string, unknown> | null>(null)
  const [message, setMessage] = useState('Carregando configuração…')
  const [validationIssues, setValidationIssues] = useState<ValidationIssue[]>([])

  useEffect(() => {
    void Promise.all([
      request<{ items: Item[] }>(`${apiBase}/services`),
      request<{ items: CatalogItem[] }>(`${apiBase === '/api/admin' ? '/api/admin/modification-catalog' : '/api/services/catalog'}`),
    ]).then(async ([services, catalogResponse]) => {
      const service = services.items.find((item) => item.code === serviceCode)
      if (!service?.id) throw new Error('O serviço solicitado ainda não foi configurado.')
      const loaded = await request<Editor & { error?: string }>(`${apiBase}/services/${String(service.id)}/editor`)
      setEditor(loaded)
      setCatalog((catalogResponse.items || []).filter((item) => item.status === 'ACTIVE'))
      setMessage('')
    }).catch((error) => setMessage(error instanceof Error ? error.message : 'Não foi possível carregar a configuração.'))
  }, [apiBase, serviceCode])

  const visibleFields = useMemo(() => (editor?.fields || []).filter((field) => shouldRenderServiceField(field, answers, editor?.rules as Array<Record<string, unknown>> || [])), [answers, editor])

  const update = (key: string, value: unknown) => { setAnswers((current) => ({ ...current, [key]: value })); setResult(null); setValidationIssues((current) => current.filter((issue) => issue.field !== key)) }
  const renderField = (field: Item) => <ServiceFieldRenderer key={String(field.field_key)} field={field} options={(editor?.options || []).filter((option) => option.field_id === field.id)} catalog={catalog} rules={(editor?.rules || []) as Array<Record<string, unknown>>} values={answers} error={validationIssues.find((issue) => issue.field === String(field.field_key))?.message} focusOnError={validationIssues[0]?.field === String(field.field_key)} onChange={update} />

  const simulate = async (event: FormEvent) => { event.preventDefault(); if (!editor?.version.id) return; setMessage(''); setValidationIssues([]); try { const response = await request<{ result?: Record<string, unknown> }>(`${apiBase}/service-versions/${String(editor.version.id)}/simulate`, { method: 'POST', body: JSON.stringify({ answers }) }); setResult(response.result || null) } catch (error) { const issues = normalizeValidationIssues((error as Error & { details?: unknown }).details, editor.fields); setValidationIssues(issues); setResult(null); setMessage(issues.length ? validationSummary(issues) : error instanceof Error ? error.message : 'Não foi possível simular.') } }
  if (!editor) return <section className="service-builder"><p className="auth-muted" role="status">{message}</p></section>
  return <section className="service-builder"><div className="builder-heading"><div><p className="auth-kicker">{title.toUpperCase()}</p><h2>{String(editor.version.service_name || title)}</h2><p className="auth-muted">{apiBase === '/api/admin' ? 'Os campos, condições, cobranças e regras são carregados da versão persistida no construtor.' : 'Informe o que você já sabe sobre o veículo. A análise é orientativa e poderá exigir conferência documental.'}</p></div></div>{message && <p className={validationIssues.length ? 'builder-error-summary' : 'auth-muted'} role="status">{message}</p>}<form className="builder-simulator" onSubmit={simulate}>{visibleFields.map(renderField)}<button className="auth-button" type="submit">Executar simulação</button></form>{result && <ServiceResultView serviceName={String(editor.version.service_name || 'Doc Motor')} simulation={result} fields={editor.fields as Array<Record<string, unknown>>} />}</section>
}
