import { FormEvent, ReactNode, useEffect, useState } from 'react'
import { BrandLogo } from '../components/BrandLogo'

type User = { id: string; role: string; status: string; name: string; email: string }
type ApiResult = { user?: User; csrfToken?: string; status?: string; error?: string; fields?: Array<{ field: string; message: string }> }
type AdminSummary = { users?: Record<string, string | number>; partners?: Record<string, string | number> }

const csrfKey = 'doc_motor_csrf'
const saveCsrf = (value?: string) => { if (value) sessionStorage.setItem(csrfKey, value) }
const csrf = () => sessionStorage.getItem(csrfKey) || ''

async function api(path: string, options: RequestInit = {}): Promise<ApiResult> {
  const headers = new Headers(options.headers)
  headers.set('Content-Type', 'application/json')
  const token = csrf()
  if (token) headers.set('X-CSRF-Token', token)
  const response = await fetch(path, { ...options, headers, credentials: 'include' })
  const body = response.status === 204 ? {} : await response.json().catch(() => ({}))
  if (!response.ok) throw new Error(body.fields?.map((item: { message: string }) => item.message).join(' ') || body.error || 'Não foi possível concluir a operação.')
  saveCsrf(body.csrfToken)
  return body
}

function Shell({ children }: { children: ReactNode }) {
  return <main className="auth-shell"><a className="auth-brand" href="/"><BrandLogo /></a>{children}<p className="auth-footnote">Doc Motor · Documentação Veicular</p></main>
}

function Field({ label, name, type = 'text', required = true, value, onChange }: { label: string; name: string; type?: string; required?: boolean; value: string; onChange: (value: string) => void }) {
  return <label className="auth-field"><span>{label}</span><input name={name} type={type} required={required} value={value} onChange={(event) => onChange(event.target.value)} /></label>
}

function Message({ error }: { error: string }) { return error ? <p className="auth-error" role="alert">{error}</p> : null }

export function LoginPage() {
  const [form, setForm] = useState({ email: '', password: '' }); const [error, setError] = useState('')
  const submit = async (event: FormEvent) => { event.preventDefault(); setError(''); try { const result = await api('/api/auth/login', { method: 'POST', body: JSON.stringify(form) }); saveCsrf(result.csrfToken); window.location.assign(result.user?.role === 'ADMINISTRATOR' ? '/admin' : result.user?.role === 'PARTNER' ? '/parceiro' : '/cliente') } catch (err) { setError(err instanceof Error ? err.message : 'Falha ao entrar.') } }
  return <Shell><section className="auth-card"><p className="auth-kicker">ÁREA RESTRITA</p><h1>Entrar na plataforma</h1><p className="auth-muted">Acesse seu painel Doc Motor.</p><form onSubmit={submit}><Field label="E-mail" name="email" type="email" value={form.email} onChange={(value) => setForm({ ...form, email: value })} /><Field label="Senha" name="password" type="password" value={form.password} onChange={(value) => setForm({ ...form, password: value })} /><Message error={error} /><button className="auth-button" type="submit">Entrar</button></form><div className="auth-links"><a href="/cadastro-parceiro">Quero ser parceiro</a><a href="/cadastro-cliente">Criar conta de cliente</a><a href="/recuperar-senha">Esqueci minha senha</a></div></section></Shell>
}

export function ClientRegistrationPage() {
  const [form, setForm] = useState({ name: '', email: '', cpf: '', whatsapp: '', password: '', passwordConfirmation: '', acceptTerms: false, privacyAcknowledgement: false }); const [error, setError] = useState('')
  const set = (key: string, value: string | boolean) => setForm((current) => ({ ...current, [key]: value }))
  const submit = async (event: FormEvent) => { event.preventDefault(); setError(''); try { await api('/api/auth/register/client', { method: 'POST', body: JSON.stringify(form) }); window.location.assign('/cliente') } catch (err) { setError(err instanceof Error ? err.message : 'Falha no cadastro.') } }
  return <Shell><section className="auth-card auth-card-wide"><p className="auth-kicker">NOVO CLIENTE</p><h1>Crie sua conta</h1><p className="auth-muted">Use dados verdadeiros para que o atendimento documental seja seguro.</p><form onSubmit={submit} className="auth-grid"><Field label="Nome completo" name="name" value={form.name} onChange={(value) => set('name', value)} /><Field label="CPF" name="cpf" value={form.cpf} onChange={(value) => set('cpf', value)} /><Field label="WhatsApp" name="whatsapp" value={form.whatsapp} onChange={(value) => set('whatsapp', value)} /><Field label="E-mail" name="email" type="email" value={form.email} onChange={(value) => set('email', value)} /><Field label="Senha" name="password" type="password" value={form.password} onChange={(value) => set('password', value)} /><Field label="Confirme a senha" name="passwordConfirmation" type="password" value={form.passwordConfirmation} onChange={(value) => set('passwordConfirmation', value)} /><Consent form={form} set={set} /><Message error={error} /><button className="auth-button" type="submit">Criar conta</button></form><a className="auth-back" href="/login">Já tenho uma conta</a></section></Shell>
}

function Consent({ form, set }: { form: { acceptTerms: boolean; privacyAcknowledgement: boolean }; set: (key: string, value: boolean) => void }) { return <div className="auth-consent"><label><input type="checkbox" checked={form.acceptTerms} onChange={(event) => set('acceptTerms', event.target.checked)} required /> Aceito os termos de uso.</label><label><input type="checkbox" checked={form.privacyAcknowledgement} onChange={(event) => set('privacyAcknowledgement', event.target.checked)} required /> Estou ciente da política de privacidade.</label></div> }

export function PartnerRegistrationPage() {
  const [form, setForm] = useState({ name: '', email: '', whatsapp: '', password: '', passwordConfirmation: '', acceptTerms: false, privacyAcknowledgement: false, personType: 'PJ', legalName: '', tradeName: '', cpfCnpj: '', responsibleName: '', zipCode: '', address: '', addressNumber: '', complement: '', neighborhood: '', city: '', state: '', segment: 'Desmanche' }); const [error, setError] = useState('')
  const set = (key: string, value: string | boolean) => setForm((current) => ({ ...current, [key]: value }))
  const submit = async (event: FormEvent) => { event.preventDefault(); setError(''); try { const result = await api('/api/auth/register/partner', { method: 'POST', body: JSON.stringify(form) }); saveCsrf(result.csrfToken); window.location.assign('/aguardando-aprovacao') } catch (err) { setError(err instanceof Error ? err.message : 'Falha no cadastro.') } }
  return <Shell><section className="auth-card auth-card-wide"><p className="auth-kicker">SEJA PARCEIRO</p><h1>Cadastre seu interesse</h1><p className="auth-muted">A conta ficará pendente de aprovação administrativa antes do acesso operacional.</p><form onSubmit={submit} className="auth-grid"><SelectField label="Tipo de pessoa" value={form.personType} options={['PJ', 'PF']} onChange={(value) => set('personType', value)} /><Field label="Responsável" name="responsibleName" value={form.responsibleName} onChange={(value) => set('responsibleName', value)} /><Field label="Nome de acesso" name="name" value={form.name} onChange={(value) => set('name', value)} /><Field label="Nome ou razão social" name="legalName" value={form.legalName} onChange={(value) => set('legalName', value)} /><Field label="Nome fantasia" name="tradeName" required={false} value={form.tradeName} onChange={(value) => set('tradeName', value)} /><Field label="CPF ou CNPJ" name="cpfCnpj" value={form.cpfCnpj} onChange={(value) => set('cpfCnpj', value)} /><SelectField label="Segmento" value={form.segment} options={['Desmanche', 'Revenda de motores', 'Autopeças', 'Oficina mecânica', 'Centro automotivo', 'Revenda de veículos', 'Prestador de serviços', 'Outros']} onChange={(value) => set('segment', value)} /><Field label="WhatsApp" name="whatsapp" value={form.whatsapp} onChange={(value) => set('whatsapp', value)} /><Field label="E-mail" name="email" type="email" value={form.email} onChange={(value) => set('email', value)} /><Field label="CEP" name="zipCode" required={false} value={form.zipCode} onChange={(value) => set('zipCode', value)} /><Field label="Endereço" name="address" required={false} value={form.address} onChange={(value) => set('address', value)} /><Field label="Número" name="addressNumber" required={false} value={form.addressNumber} onChange={(value) => set('addressNumber', value)} /><Field label="Complemento" name="complement" required={false} value={form.complement} onChange={(value) => set('complement', value)} /><Field label="Bairro" name="neighborhood" required={false} value={form.neighborhood} onChange={(value) => set('neighborhood', value)} /><Field label="Cidade" name="city" required={false} value={form.city} onChange={(value) => set('city', value)} /><Field label="Estado (UF)" name="state" value={form.state} onChange={(value) => set('state', value.toUpperCase())} /><Field label="Senha" name="password" type="password" value={form.password} onChange={(value) => set('password', value)} /><Field label="Confirme a senha" name="passwordConfirmation" type="password" value={form.passwordConfirmation} onChange={(value) => set('passwordConfirmation', value)} /><Consent form={form} set={set} /><Message error={error} /><button className="auth-button" type="submit">Enviar cadastro</button></form><a className="auth-back" href="/login">Voltar para entrar</a></section></Shell>
}

function SelectField({ label, value, options, onChange }: { label: string; value: string; options: string[]; onChange: (value: string) => void }) { return <label className="auth-field"><span>{label}</span><select value={value} onChange={(event) => onChange(event.target.value)}>{options.map((option) => <option key={option} value={option}>{option}</option>)}</select></label> }

export function PasswordRecoveryPage() {
  const [email, setEmail] = useState(''); const [sent, setSent] = useState(false); const [error, setError] = useState('')
  const submit = async (event: FormEvent) => { event.preventDefault(); setError(''); try { await api('/api/auth/forgot-password', { method: 'POST', body: JSON.stringify({ email }) }); setSent(true) } catch (err) { setError(err instanceof Error ? err.message : 'Não foi possível solicitar a recuperação.') } }
  return <Shell><section className="auth-card"><p className="auth-kicker">SEGURANÇA</p><h1>Recuperar senha</h1>{sent ? <p className="auth-muted">Se existir uma conta para este e-mail, enviaremos as instruções de redefinição.</p> : <form onSubmit={submit}><Field label="E-mail" name="email" type="email" value={email} onChange={setEmail} /><Message error={error} /><button className="auth-button" type="submit">Enviar instruções</button></form>}<a className="auth-back" href="/login">Voltar para entrar</a></section></Shell>
}

export function ResetPasswordPage() {
  const token = new URLSearchParams(window.location.search).get('token') || ''; const [form, setForm] = useState({ password: '', passwordConfirmation: '' }); const [done, setDone] = useState(false); const [error, setError] = useState('')
  const submit = async (event: FormEvent) => { event.preventDefault(); setError(''); try { await api('/api/auth/reset-password', { method: 'POST', body: JSON.stringify({ token, ...form }) }); setDone(true) } catch (err) { setError(err instanceof Error ? err.message : 'Não foi possível redefinir a senha.') } }
  return <Shell><section className="auth-card"><p className="auth-kicker">SEGURANÇA</p><h1>Nova senha</h1>{done ? <><p className="auth-muted">Senha alterada com sucesso.</p><a className="auth-button auth-button-link" href="/login">Entrar</a></> : <form onSubmit={submit}><Field label="Nova senha" name="password" type="password" value={form.password} onChange={(value) => setForm({ ...form, password: value })} /><Field label="Confirme a senha" name="passwordConfirmation" type="password" value={form.passwordConfirmation} onChange={(value) => setForm({ ...form, passwordConfirmation: value })} /><Message error={error} /><button className="auth-button" type="submit">Alterar senha</button></form>}</section></Shell>
}

export function StatusPage({ title, text, href = '/' }: { title: string; text: string; href?: string }) { return <Shell><section className="auth-card"><p className="auth-kicker">DOC MOTOR</p><h1>{title}</h1><p className="auth-muted">{text}</p><a className="auth-button auth-button-link" href={href}>Continuar</a></section></Shell> }

function LogoutButton() { const logout = async () => { await api('/api/auth/logout', { method: 'POST' }).catch(() => undefined); sessionStorage.removeItem(csrfKey); window.location.assign('/login') }; return <button className="auth-button auth-secondary" onClick={logout}>Sair</button> }

function DashboardFrame({ user, title, children }: { user: User; title: string; children: ReactNode }) { return <Shell><section className="dashboard-layout"><aside className="dashboard-sidebar"><BrandLogo /><p className="auth-kicker">{title}</p><a href="/">Site comercial</a><LogoutButton /></aside><div className="dashboard-main"><p className="auth-kicker">{title}</p><h1>Olá, {user.name}.</h1>{children}</div></section></Shell> }

function AdminDashboard({ user }: { user: User }) {
  const [summary, setSummary] = useState<AdminSummary | null>(null); const [partners, setPartners] = useState<Array<Record<string, string>>>([]); const [error, setError] = useState(''); const [filter, setFilter] = useState('PENDING')
  const load = () => Promise.all([api('/api/admin/summary'), api(`/api/admin/partners?status=${filter}`)]).then(([summaryResult, partnerResult]) => { setSummary(summaryResult as AdminSummary); setPartners(((partnerResult as ApiResult & { items?: Array<Record<string, string>> }).items || [])) }).catch((err) => setError(err instanceof Error ? err.message : 'Não foi possível carregar a gestão administrativa.'))
  useEffect(() => { load() }, [filter])
  const changeStatus = async (id: string, status: string) => { const reason = status === 'REJECTED' ? window.prompt('Justificativa da recusa:') || '' : ''; if (status === 'REJECTED' && !reason) return; try { await api(`/api/admin/partners/${id}/status`, { method: 'PATCH', body: JSON.stringify({ status, reason }) }); await load() } catch (err) { setError(err instanceof Error ? err.message : 'Não foi possível atualizar o parceiro.') } }
  return <DashboardFrame user={user} title="PAINEL ADMINISTRATIVO"><p className="auth-muted">Indicadores e aprovações persistidos no MySQL.</p>{error && <Message error={error} />}<div className="metric-grid"><Metric label="Usuários" value={summary?.users?.total_users ?? '—'} /><Metric label="Clientes" value={summary?.users?.total_clients ?? '—'} /><Metric label="Parceiros" value={summary?.partners?.total_partners ?? '—'} /><Metric label="Pendentes" value={summary?.partners?.pending_partners ?? '—'} /></div><div className="admin-toolbar"><h2>Parceiros</h2><select value={filter} onChange={(event) => setFilter(event.target.value)}><option value="PENDING">Pendentes</option><option value="ACTIVE">Ativos</option><option value="SUSPENDED">Suspensos</option><option value="REJECTED">Recusados</option></select></div><div className="admin-table">{partners.length === 0 ? <p className="auth-muted">Nenhum cadastro neste filtro.</p> : partners.map((partner) => <article className="admin-row" key={partner.id}><div><strong>{partner.trade_name || partner.legal_name}</strong><span>{partner.email} · {partner.segment}</span></div><div className="admin-actions">{partner.status === 'PENDING' && <><button onClick={() => changeStatus(partner.id, 'ACTIVE')}>Aprovar</button><button onClick={() => changeStatus(partner.id, 'REJECTED')}>Recusar</button></>}{partner.status === 'ACTIVE' && <button onClick={() => changeStatus(partner.id, 'SUSPENDED')}>Suspender</button>}{partner.status === 'SUSPENDED' && <button onClick={() => changeStatus(partner.id, 'ACTIVE')}>Ativar</button>}</div></article>)}</div></DashboardFrame>
}

function Metric({ label, value }: { label: string; value: string | number }) { return <div className="metric"><span>{label}</span><strong>{value}</strong></div> }

function PartnerDashboard({ user }: { user: User }) { const [company, setCompany] = useState<Record<string, string> | null>(null); const [members, setMembers] = useState<Array<Record<string, string>>>([]); const [error, setError] = useState(''); useEffect(() => { Promise.all([api('/api/partner/dashboard'), api('/api/partner/members')]).then(([companyResult, membersResult]) => { setCompany((companyResult as ApiResult & { company?: Record<string, string> }).company || null); setMembers((membersResult as ApiResult & { items?: Array<Record<string, string>> }).items || []) }).catch((err) => setError(err instanceof Error ? err.message : 'Não foi possível carregar o painel.')) }, []); return <DashboardFrame user={user} title="PAINEL DO PARCEIRO"><p className="auth-muted">Status do cadastro: <strong>{company?.status || '—'}</strong></p>{error && <Message error={error} />}<div className="dashboard-notice"><strong>{company?.trade_name || company?.legal_name || 'Empresa'}</strong><br />{company?.segment || 'Segmento não informado'} · {company?.city || 'Cidade não informada'}/{company?.state || '—'}</div><h2>Usuários vinculados</h2><div className="admin-table">{members.map((member) => <article className="admin-row" key={member.id}><div><strong>{member.name}</strong><span>{member.email} · {member.company_role}</span></div><span>{member.status}</span></article>)}</div><p className="auth-muted dashboard-disabled">Orçamentos, clientes, documentos e financeiro estarão disponíveis em fases futuras.</p></DashboardFrame> }

function ClientDashboard({ user }: { user: User }) { return <DashboardFrame user={user} title="PAINEL DO CLIENTE"><div className="dashboard-notice"><strong>Meus dados</strong><br />{user.email}<br />{user.status}</div><p className="auth-muted dashboard-disabled">Veículos, orçamentos, serviços, documentos e acompanhamento serão adicionados em fases futuras.</p></DashboardFrame> }

export function DashboardPage({ role }: { role: 'ADMINISTRATOR' | 'PARTNER' | 'CLIENT' }) {
  const [user, setUser] = useState<User | null>(null); const [error, setError] = useState('')
  useEffect(() => { api('/api/auth/me').then((result) => { if (!result.user || result.user.role !== role) window.location.assign('/acesso-nao-autorizado'); else setUser(result.user) }).catch((err) => setError(err instanceof Error ? err.message : 'Não foi possível carregar seu acesso.')) }, [role])
  if (!user) return <Shell><section className="auth-card"><p className="auth-muted">{error || 'Carregando seu painel…'}</p></section></Shell>
  if (role === 'ADMINISTRATOR') return <AdminDashboard user={user} />
  if (role === 'PARTNER') return <PartnerDashboard user={user} />
  return <ClientDashboard user={user} />
}
