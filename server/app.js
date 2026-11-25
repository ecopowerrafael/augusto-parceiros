/* global console, process */
import express from 'express'
import { randomUUID } from 'node:crypto'
import nodemailer from 'nodemailer'
import fs from 'node:fs/promises'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { config } from './config.js'
import { getDatabasePool, isDatabaseConfigured, withTransaction } from './database.js'
import {
  assertSameOrigin,
  bcrypt,
  changePasswordSchema,
  clientRegistrationSchema,
  consumeRateLimit,
  createPasswordResetToken,
  createSession,
  digits,
  forgotPasswordSchema,
  hashPassword,
  hashToken,
  issuePasswordReset,
  loadSession,
  loginSchema,
  partnerRegistrationSchema,
  publicUser,
  requireAuth,
  requireCsrf,
  requireRole,
  resetPasswordSchema,
  revokeSession,
  validationError,
  verifyPassword,
  writeAudit,
} from './auth.js'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const dist = path.resolve(__dirname, '../dist')
const indexFile = path.join(dist, 'index.html')
const app = express()

const asyncRoute = (handler) => (request, response, next) => Promise.resolve(handler(request, response, next)).catch(next)
const databaseRequired = (_request, response, next) => isDatabaseConfigured() ? next() : response.status(503).json({ error: 'DATABASE_NOT_CONFIGURED' })
const activeAccount = (request, response, next) => request.auth?.user.status === 'ACTIVE' ? next() : response.status(403).json({ error: 'ACCOUNT_NOT_ACTIVE' })

app.disable('x-powered-by')
app.set('trust proxy', 1)
app.use(express.json({ limit: '100kb' }))
app.use((_request, response, next) => {
  if (!config.allowIndexing) response.setHeader('X-Robots-Tag', 'noindex, nofollow')
  response.setHeader('X-Content-Type-Options', 'nosniff')
  response.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin')
  response.setHeader('Permissions-Policy', 'camera=(), microphone=(), geolocation=()')
  response.setHeader('X-Frame-Options', 'SAMEORIGIN')
  next()
})
app.use(asyncRoute(async (request, _response, next) => {
  request.auth = await loadSession(request)
  next()
}))

app.get('/api/health', (_request, response) => response.json({ status: 'ok', environment: config.appEnv, version: config.version }))
app.get('/api/runtime-config', (_request, response) => response.json({ appEnv: config.appEnv, version: config.version, allowIndexing: config.allowIndexing }))
app.get('/api/robots-diagnostic', requireRole('ADMINISTRATOR'), (_request, response) => response.json({ indexingAllowed: config.allowIndexing }))

app.get('/robots.txt', (_request, response) => response.type('text/plain').send(config.allowIndexing ? 'User-agent: *\nAllow: /\nSitemap: /sitemap.xml\n' : 'User-agent: *\nDisallow: /\n'))
app.get('/manifest.webmanifest', asyncRoute(async (_request, response, next) => {
  try {
    const manifest = await fs.readFile(path.join(dist, 'manifest.json'), 'utf8')
    response.type('application/manifest+json').send(manifest)
  } catch (error) { next(error) }
}))

app.get('/api/auth/me', databaseRequired, (request, response) => {
  if (!request.auth) return response.json({ authenticated: false })
  return response.json({ authenticated: true, user: request.auth.user })
})

app.get('/api/auth/csrf', databaseRequired, requireAuth, asyncRoute(async (request, response) => {
  const rawCsrf = createPasswordResetToken()
  await getDatabasePool().execute('UPDATE sessions SET csrf_token_hash = ? WHERE id = ?', [hashToken(rawCsrf), request.auth.sessionId])
  response.json({ csrfToken: rawCsrf })
}))

app.post('/api/auth/register/client', databaseRequired, asyncRoute(async (request, response) => {
  if (!assertSameOrigin(request)) return response.status(403).json({ error: 'ORIGIN_NOT_ALLOWED' })
  const parsed = clientRegistrationSchema.safeParse(request.body)
  if (!parsed.success) return response.status(400).json(validationError(parsed.error))
  if (!await consumeRateLimit(`register-client:${request.ip}`, 5, 900)) return response.status(429).json({ error: 'TOO_MANY_REQUESTS' })
  const data = parsed.data
  const email = data.email.toLowerCase()
  try {
    const user = await withTransaction(async (connection) => {
      const userId = cryptoRandomId()
      const passwordHash = await hashPassword(data.password)
      await connection.execute(
        `INSERT INTO users (id, role, status, name, cpf, email, whatsapp, password_hash, terms_accepted_at, privacy_acknowledged_at)
         VALUES (?, 'CLIENT', 'ACTIVE', ?, ?, ?, ?, ?, UTC_TIMESTAMP(), UTC_TIMESTAMP())`,
        [userId, data.name, digits(data.cpf), email, data.whatsapp, passwordHash],
      )
      await connection.execute('INSERT INTO client_profiles (user_id) VALUES (?)', [userId])
      return { id: userId, role: 'CLIENT', status: 'ACTIVE', name: data.name, email, cpf: digits(data.cpf), whatsapp: data.whatsapp }
    })
    const csrfToken = await createSession(user, request, response)
    return response.status(201).json({ user, csrfToken })
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') return response.status(409).json({ error: 'REGISTRATION_CONFLICT' })
    throw error
  }
}))

app.post('/api/auth/register/partner', databaseRequired, asyncRoute(async (request, response) => {
  if (!assertSameOrigin(request)) return response.status(403).json({ error: 'ORIGIN_NOT_ALLOWED' })
  const parsed = partnerRegistrationSchema.safeParse(request.body)
  if (!parsed.success) return response.status(400).json(validationError(parsed.error))
  if (!await consumeRateLimit(`register-partner:${request.ip}`, 5, 900)) return response.status(429).json({ error: 'TOO_MANY_REQUESTS' })
  const data = parsed.data
  const document = digits(data.cpfCnpj)
  if ((data.personType === 'PF' && document.length !== 11) || (data.personType === 'PJ' && document.length !== 14)) return response.status(400).json({ error: 'DOCUMENT_TYPE_MISMATCH' })
  const email = data.email.toLowerCase()
  try {
    const user = await withTransaction(async (connection) => {
      const userId = cryptoRandomId()
      const companyId = cryptoRandomId()
      const passwordHash = await hashPassword(data.password)
      await connection.execute(
        `INSERT INTO users (id, role, status, name, email, whatsapp, password_hash, terms_accepted_at, privacy_acknowledged_at)
         VALUES (?, 'PARTNER', 'PENDING', ?, ?, ?, ?, UTC_TIMESTAMP(), UTC_TIMESTAMP())`,
        [userId, data.responsibleName, email, data.whatsapp, passwordHash],
      )
      await connection.execute(
        `INSERT INTO partner_companies (id, person_type, legal_name, trade_name, cpf_cnpj, responsible_name, email, whatsapp, zip_code, address, address_number, complement, neighborhood, city, state, segment)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [companyId, data.personType, data.legalName, data.tradeName || null, document, data.responsibleName, email, data.whatsapp, data.zipCode || null, data.address || null, data.addressNumber || null, data.complement || null, data.neighborhood || null, data.city || null, data.state, data.segment],
      )
      await connection.execute('INSERT INTO company_members (company_id, user_id, company_role) VALUES (?, ?, \'OWNER\')', [companyId, userId])
      return { id: userId, role: 'PARTNER', status: 'PENDING', name: data.responsibleName, email, cpf: null, whatsapp: data.whatsapp, companyId }
    })
    const csrfToken = await createSession(user, request, response)
    return response.status(201).json({ user, csrfToken, status: 'PENDING_APPROVAL' })
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') return response.status(409).json({ error: 'REGISTRATION_CONFLICT' })
    throw error
  }
}))

app.post('/api/auth/login', databaseRequired, asyncRoute(async (request, response) => {
  if (!assertSameOrigin(request)) return response.status(403).json({ error: 'ORIGIN_NOT_ALLOWED' })
  const parsed = loginSchema.safeParse(request.body)
  if (!parsed.success) return response.status(400).json(validationError(parsed.error))
  const email = parsed.data.email.toLowerCase()
  if (!await consumeRateLimit(`login:${request.ip}:${email}`, 8, 900)) return response.status(429).json({ error: 'TOO_MANY_REQUESTS' })
  const [rows] = await getDatabasePool().execute('SELECT id, role, status, name, email, cpf, whatsapp, password_hash FROM users WHERE email = ? LIMIT 1', [email])
  const user = rows[0]
  const valid = user ? await verifyPassword(parsed.data.password, user.password_hash) : await bcrypt.compare(parsed.data.password, '$2b$12$C6UzMDM.H6dfI/f/IKcEe.0pQ5qF5f0z5mVfJpKqP0D/1A1G8cE6G')
  if (!user || !valid || ['SUSPENDED', 'DISABLED'].includes(user.status)) return response.status(401).json({ error: 'INVALID_CREDENTIALS' })
  await getDatabasePool().execute('UPDATE users SET last_login_at = UTC_TIMESTAMP() WHERE id = ?', [user.id])
  const csrfToken = await createSession(publicUser(user), request, response)
  return response.json({ user: publicUser(user), csrfToken })
}))

app.post('/api/auth/logout', databaseRequired, requireAuth, asyncRoute(async (request, response) => {
  if (!assertSameOrigin(request)) return response.status(403).json({ error: 'ORIGIN_NOT_ALLOWED' })
  await revokeSession(request)
  response.setHeader('Set-Cookie', 'doc_motor_session=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0')
  return response.status(204).send()
}))

app.post('/api/auth/change-password', databaseRequired, requireAuth, requireCsrf, asyncRoute(async (request, response) => {
  const parsed = changePasswordSchema.safeParse(request.body)
  if (!parsed.success) return response.status(400).json(validationError(parsed.error))
  const [rows] = await getDatabasePool().execute('SELECT password_hash FROM users WHERE id = ? LIMIT 1', [request.auth.user.id])
  if (!rows[0] || !await verifyPassword(parsed.data.currentPassword, rows[0].password_hash)) return response.status(400).json({ error: 'CURRENT_PASSWORD_INVALID' })
  await getDatabasePool().execute('UPDATE users SET password_hash = ?, updated_at = UTC_TIMESTAMP() WHERE id = ?', [await hashPassword(parsed.data.newPassword), request.auth.user.id])
  await getDatabasePool().execute('UPDATE sessions SET revoked_at = UTC_TIMESTAMP() WHERE user_id = ? AND id <> ?', [request.auth.user.id, request.auth.sessionId])
  return response.json({ status: 'ok' })
}))

app.post('/api/auth/forgot-password', databaseRequired, asyncRoute(async (request, response) => {
  if (!assertSameOrigin(request)) return response.status(403).json({ error: 'ORIGIN_NOT_ALLOWED' })
  const parsed = forgotPasswordSchema.safeParse(request.body)
  if (!parsed.success) return response.status(400).json(validationError(parsed.error))
  if (!await consumeRateLimit(`forgot-password:${request.ip}`, 5, 900)) return response.status(429).json({ error: 'TOO_MANY_REQUESTS' })
  const generic = { status: 'ok' }
  if (!process.env.SMTP_HOST || !process.env.SMTP_FROM || !process.env.SMTP_USER || !process.env.SMTP_PASSWORD) return response.status(503).json({ error: 'PASSWORD_RECOVERY_NOT_CONFIGURED' })
  const [rows] = await getDatabasePool().execute('SELECT id, email, name FROM users WHERE email = ? AND status NOT IN (\'DISABLED\') LIMIT 1', [parsed.data.email.toLowerCase()])
  if (rows.length === 0) return response.json(generic)
  const token = await issuePasswordReset(rows[0].id)
  const transporter = nodemailer.createTransport({ host: process.env.SMTP_HOST, port: Number(process.env.SMTP_PORT || 587), secure: String(process.env.SMTP_SECURE).toLowerCase() === 'true', auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASSWORD } })
  const resetUrl = `${request.protocol}://${request.get('host')}/redefinir-senha?token=${encodeURIComponent(token)}`
  await transporter.sendMail({ from: process.env.SMTP_FROM, to: rows[0].email, subject: 'Redefinição de senha — Doc Motor', text: `Olá, ${rows[0].name}. Use este link para redefinir sua senha: ${resetUrl}\n\nO link expira em 30 minutos.` })
  return response.json(generic)
}))

app.post('/api/auth/reset-password', databaseRequired, asyncRoute(async (request, response) => {
  if (!assertSameOrigin(request)) return response.status(403).json({ error: 'ORIGIN_NOT_ALLOWED' })
  const parsed = resetPasswordSchema.safeParse(request.body)
  if (!parsed.success) return response.status(400).json(validationError(parsed.error))
  const tokenHash = hashToken(parsed.data.token)
  const [rows] = await getDatabasePool().execute('SELECT user_id FROM password_reset_tokens WHERE token_hash = ? AND used_at IS NULL AND expires_at > UTC_TIMESTAMP() LIMIT 1', [tokenHash])
  if (!rows[0]) return response.status(400).json({ error: 'RESET_TOKEN_INVALID' })
  await withTransaction(async (connection) => {
    await connection.execute('UPDATE users SET password_hash = ?, updated_at = UTC_TIMESTAMP() WHERE id = ?', [await hashPassword(parsed.data.password), rows[0].user_id])
    await connection.execute('UPDATE password_reset_tokens SET used_at = UTC_TIMESTAMP() WHERE token_hash = ?', [tokenHash])
    await connection.execute('UPDATE sessions SET revoked_at = UTC_TIMESTAMP() WHERE user_id = ?', [rows[0].user_id])
  })
  return response.json({ status: 'ok' })
}))

app.get('/api/admin/summary', databaseRequired, requireRole('ADMINISTRATOR'), asyncRoute(async (_request, response) => {
  const pool = getDatabasePool()
  const [userRows] = await pool.query(`SELECT COUNT(*) AS total_users, SUM(role = 'CLIENT') AS total_clients, SUM(role = 'PARTNER') AS total_partner_users FROM users`)
  const [companyRows] = await pool.query(`SELECT COUNT(*) AS total_partners, SUM(status = 'PENDING') AS pending_partners, SUM(status = 'ACTIVE') AS active_partners, SUM(status = 'SUSPENDED') AS suspended_partners FROM partner_companies`)
  response.json({ users: userRows[0], partners: companyRows[0] })
}))

app.get('/api/admin/partners', databaseRequired, requireRole('ADMINISTRATOR'), asyncRoute(async (request, response) => {
  const page = Math.max(1, Number(request.query.page || 1))
  const pageSize = Math.min(50, Math.max(1, Number(request.query.pageSize || 20)))
  const offset = (page - 1) * pageSize
  const status = String(request.query.status || '').toUpperCase()
  const params = []
  const filters = []
  if (request.query.q) { filters.push('(legal_name LIKE ? OR trade_name LIKE ? OR email LIKE ? OR cpf_cnpj LIKE ?)'); const query = `%${String(request.query.q).trim().slice(0, 80)}%`; params.push(query, query, query, query) }
  if (['PENDING', 'ACTIVE', 'SUSPENDED', 'REJECTED'].includes(status)) { filters.unshift('status = ?'); params.unshift(status) }
  const where = filters.length ? `WHERE ${filters.join(' AND ')}` : ''
  const [rows] = await getDatabasePool().execute(`SELECT id, person_type, legal_name, trade_name, cpf_cnpj, responsible_name, email, whatsapp, city, state, segment, status, rejection_reason, created_at FROM partner_companies ${where} ORDER BY created_at DESC LIMIT ? OFFSET ?`, [...params, pageSize, offset])
  const [countRows] = await getDatabasePool().query(`SELECT COUNT(*) AS total FROM partner_companies ${where}`, params)
  response.json({ items: rows, page, pageSize, total: countRows[0].total })
}))

app.get('/api/admin/users', databaseRequired, requireRole('ADMINISTRATOR'), asyncRoute(async (request, response) => {
  const page = Math.max(1, Number(request.query.page || 1)); const pageSize = Math.min(50, Math.max(1, Number(request.query.pageSize || 20))); const offset = (page - 1) * pageSize
  const filters = []; const params = []; const role = String(request.query.role || '').toUpperCase(); const status = String(request.query.status || '').toUpperCase()
  if (['ADMINISTRATOR', 'PARTNER', 'CLIENT'].includes(role)) { filters.push('role = ?'); params.push(role) }
  if (['ACTIVE', 'PENDING', 'SUSPENDED', 'DISABLED'].includes(status)) { filters.push('status = ?'); params.push(status) }
  if (request.query.q) { filters.push('(name LIKE ? OR email LIKE ?)'); const query = `%${String(request.query.q).trim().slice(0, 80)}%`; params.push(query, query) }
  const where = filters.length ? `WHERE ${filters.join(' AND ')}` : ''
  const [rows] = await getDatabasePool().execute(`SELECT id, role, status, name, email, whatsapp, created_at, last_login_at FROM users ${where} ORDER BY created_at DESC LIMIT ? OFFSET ?`, [...params, pageSize, offset])
  const [countRows] = await getDatabasePool().query(`SELECT COUNT(*) AS total FROM users ${where}`, params)
  response.json({ items: rows, page, pageSize, total: countRows[0].total })
}))

app.get('/api/admin/audit', databaseRequired, requireRole('ADMINISTRATOR'), asyncRoute(async (request, response) => {
  const page = Math.max(1, Number(request.query.page || 1)); const pageSize = Math.min(50, Math.max(1, Number(request.query.pageSize || 20))); const offset = (page - 1) * pageSize
  const [items] = await getDatabasePool().execute('SELECT id, actor_user_id, action, entity_type, entity_id, metadata, created_at FROM audit_logs ORDER BY created_at DESC LIMIT ? OFFSET ?', [pageSize, offset])
  response.json({ items, page, pageSize })
}))

app.patch('/api/admin/partners/:id/status', databaseRequired, requireRole('ADMINISTRATOR'), requireCsrf, asyncRoute(async (request, response) => {
  const status = String(request.body.status || '').toUpperCase()
  const allowed = ['ACTIVE', 'REJECTED', 'SUSPENDED']
  if (!allowed.includes(status)) return response.status(400).json({ error: 'INVALID_STATUS' })
  const reason = status === 'REJECTED' ? String(request.body.reason || '').trim().slice(0, 500) : null
  const result = await withTransaction(async (connection) => {
    const [companies] = await connection.execute('SELECT id FROM partner_companies WHERE id = ? FOR UPDATE', [request.params.id])
    if (companies.length === 0) return false
    await connection.execute('UPDATE partner_companies SET status = ?, rejection_reason = ?, approved_at = IF(? = \'ACTIVE\', UTC_TIMESTAMP(), approved_at), approved_by = IF(? = \'ACTIVE\', ?, approved_by), updated_at = UTC_TIMESTAMP() WHERE id = ?', [status, reason, status, status, request.auth.user.id, request.params.id])
    await connection.execute(`UPDATE users u JOIN company_members cm ON cm.user_id = u.id SET u.status = ?, u.approved_at = IF(? = 'ACTIVE', UTC_TIMESTAMP(), u.approved_at), u.approved_by = IF(? = 'ACTIVE', ?, u.approved_by), u.updated_at = UTC_TIMESTAMP() WHERE cm.company_id = ?`, [status === 'ACTIVE' ? 'ACTIVE' : status === 'SUSPENDED' ? 'SUSPENDED' : 'DISABLED', status, status, request.auth.user.id, request.params.id])
    return true
  })
  if (!result) return response.status(404).json({ error: 'PARTNER_NOT_FOUND' })
  await writeAudit(request.auth.user.id, `PARTNER_${status}`, 'partner_company', request.params.id, { reason })
  return response.json({ status })
}))

app.get('/api/partner/dashboard', databaseRequired, requireRole('PARTNER'), activeAccount, asyncRoute(async (request, response) => {
  const [rows] = await getDatabasePool().execute(`SELECT c.id, c.legal_name, c.trade_name, c.person_type, c.cpf_cnpj, c.email, c.whatsapp, c.segment, c.status, cm.company_role FROM partner_companies c JOIN company_members cm ON cm.company_id = c.id WHERE cm.user_id = ? LIMIT 1`, [request.auth.user.id])
  response.json({ user: request.auth.user, company: rows[0] || null })
}))

app.get('/api/partner/members', databaseRequired, requireRole('PARTNER'), activeAccount, asyncRoute(async (request, response) => {
  const [rows] = await getDatabasePool().execute(`SELECT u.id, u.name, u.email, u.status, cm.company_role, cm.created_at FROM users u JOIN company_members cm ON cm.user_id = u.id WHERE cm.company_id = (SELECT company_id FROM company_members WHERE user_id = ? LIMIT 1) ORDER BY cm.created_at`, [request.auth.user.id])
  response.json({ items: rows })
}))

app.get('/api/client/dashboard', databaseRequired, requireRole('CLIENT'), activeAccount, (request, response) => response.json({ user: request.auth.user, features: { vehicles: false, budgets: false, services: false, documents: false } }))

app.use(express.static(dist, { index: false }))
app.get('*', asyncRoute(async (_request, response, next) => {
  try {
    const html = await fs.readFile(indexFile, 'utf8')
    const robots = config.allowIndexing ? 'index, follow' : 'noindex, nofollow'
    const runtimeConfig = JSON.stringify({ appEnv: config.appEnv, version: config.version, allowIndexing: config.allowIndexing })
    response.type('html').send(html.replace('</head>', `<meta name="robots" content="${robots}" />\n</head>`).replace('<body>', `<body><script>window.__DOC_MOTOR_CONFIG__=${runtimeConfig}</script>`))
  } catch (error) { next(error) }
}))

app.use((error, _request, response, _next) => {
  void _next
  console.error('Unhandled request error', config.debug ? error : error.message)
  if (response.headersSent) return
  response.status(error.code === 'DATABASE_NOT_CONFIGURED' ? 503 : 500).json({ error: error.code === 'DATABASE_NOT_CONFIGURED' ? 'DATABASE_NOT_CONFIGURED' : 'INTERNAL_ERROR' })
})

function cryptoRandomId() {
  return randomUUID()
}

export default app
