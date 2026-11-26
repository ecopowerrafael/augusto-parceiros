import { FormEvent, useEffect, useState } from 'react'

type CatalogItem = { id: string; code: string; name: string; category: string; description?: string | null; status: 'ACTIVE' | 'INACTIVE'; display_order: number; requires_description: number; requires_manual_review: number; legal_status: string; billing_name?: string | null; billing_amount_cents?: number | null }

type ApiResponse = { items?: CatalogItem[]; error?: string }

async function catalogApi<T extends ApiResponse>(path: string, options: RequestInit = {}) {
  const csrf = sessionStorage.getItem('doc_motor_csrf') || ''
  const response = await fetch(path, { ...options, credentials: 'include', headers: { 'Content-Type': 'application/json', ...(csrf ? { 'X-CSRF-Token': csrf } : {}), ...(options.headers || {}) } })
  const body = await response.json().catch(() => ({})) as T
  if (!response.ok) throw new Error(body.error || 'Não foi possível atualizar o catálogo.')
  return body
}

export function ModificationCatalogPage() {
  const [items, setItems] = useState<CatalogItem[]>([])
  const [message, setMessage] = useState('Carregando catálogo…')
  const [form, setForm] = useState({ code: '', name: '', category: 'Outros', description: '', requiresDescription: false, requiresManualReview: true })
  const load = () => catalogApi<ApiResponse>('/api/admin/modification-catalog').then((result) => { setItems(result.items || []); setMessage('') }).catch((error) => setMessage(error instanceof Error ? error.message : 'Não foi possível carregar o catálogo.'))
  useEffect(() => { void load() }, [])
  const save = async (event: FormEvent) => { event.preventDefault(); setMessage(''); try { await catalogApi('/api/admin/modification-catalog', { method: 'POST', body: JSON.stringify({ ...form, code: form.code.toUpperCase(), displayOrder: items.length * 10, status: 'ACTIVE', legalStatus: 'A_CONFIRMAR' }) }); setForm({ code: '', name: '', category: 'Outros', description: '', requiresDescription: false, requiresManualReview: true }); setMessage('Modificação cadastrada.'); await load() } catch (error) { setMessage(error instanceof Error ? error.message : 'Não foi possível cadastrar a modificação.') } }
  const toggle = async (item: CatalogItem) => { try { await catalogApi(`/api/admin/modification-catalog/${item.id}`, { method: 'PATCH', body: JSON.stringify({ status: item.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE' }) }); await load() } catch (error) { setMessage(error instanceof Error ? error.message : 'Não foi possível alterar o status.') } }
  return <section className="service-builder"><div className="builder-heading"><div><p className="auth-kicker">CONFIGURAÇÕES</p><h2>Catálogo de modificações</h2><p className="auth-muted">Opções reutilizáveis pelo construtor no-code. O cadastro é preliminar e não representa autorização legal.</p></div></div>{message && <p className="auth-muted" role="status">{message}</p>}<form className="auth-grid" onSubmit={save}><label className="auth-field"><span>Código interno</span><input value={form.code} onChange={(event) => setForm({ ...form, code: event.target.value })} pattern="[A-Za-z0-9_]{3,80}" required /></label><label className="auth-field"><span>Nome</span><input value={form.name} onChange={(event) => setForm({ ...form, name: event.target.value })} required /></label><label className="auth-field"><span>Categoria</span><input value={form.category} onChange={(event) => setForm({ ...form, category: event.target.value })} required /></label><label className="auth-field"><span>Descrição</span><textarea value={form.description} onChange={(event) => setForm({ ...form, description: event.target.value })} rows={3} /></label><label className="auth-consent"><input type="checkbox" checked={form.requiresDescription} onChange={(event) => setForm({ ...form, requiresDescription: event.target.checked })} /> Exigir descrição complementar</label><label className="auth-consent"><input type="checkbox" checked={form.requiresManualReview} onChange={(event) => setForm({ ...form, requiresManualReview: event.target.checked })} /> Encaminhar para análise manual</label><button className="auth-button" type="submit">Cadastrar modificação</button></form><div className="admin-table">{items.map((item) => <article className="admin-row" key={item.id}><div><strong>{item.name}</strong><span>{item.category} · {item.code}</span><span>{item.billing_name || 'Cobrança não vinculada'} · {item.legal_status}</span></div><button type="button" className="auth-button" onClick={() => void toggle(item)}>{item.status === 'ACTIVE' ? 'Desativar' : 'Ativar'}</button></article>)}</div></section>
}
