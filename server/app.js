/* global console, process */
import express from 'express'
import { randomUUID } from 'node:crypto'
import nodemailer from 'nodemailer'
import fs from 'node:fs/promises'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { config } from './config.js'
import { getDatabasePool, isDatabaseConfigured, withTransaction } from './database.js'
import { createPartnerServiceRouter, createPublicServiceRouter, createServiceRouter } from './services.js'
import { isPartnerCompanyStatus, partnerUserStatusForCompanyStatus } from './partner-flow.js'
import { COMMISSION_MODELS, evaluateCommission, resolveCommissionConfig, validateCommissionConfig } from './commissions.js'
import {
  assertSameOrigin,
  bcrypt,
  changePasswordSchema,
  clientRegistrationSchema,
  collaboratorRegistrationSchema,
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
  inferDocumentType,
  normalizeDocument,
  partnerRegistrationSchema,
  passwordPolicyError,
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
app.use((request, response, next) => {
  request.requestId = String(request.headers['x-request-id'] || randomUUID()).slice(0, 80)
  response.setHeader('X-Request-ID', request.requestId)
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
  const document = normalizeDocument(data.cpfCnpj)
  const inferredPersonType = inferDocumentType(document)
  if (!inferredPersonType) return response.status(400).json({ error: 'INVALID_DOCUMENT' })
  if (data.personType && data.personType !== inferredPersonType) return response.status(400).json({ error: 'DOCUMENT_TYPE_MISMATCH' })
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
        [companyId, inferredPersonType, data.legalName, data.tradeName || null, document, data.responsibleName, email, data.whatsapp, data.zipCode || null, data.address || null, data.addressNumber || null, data.complement || null, data.neighborhood || null, data.city || null, data.state, data.segment],
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
  const valid = user ? await verifyPassword(parsed.data.password, user.password_hash) : await bcrypt.compare(parsed.data.password, '$2b$12$P8sShDEiMudMS8KHptdtEuvg3TeNonKxaLu6TCBtvKUV15zY5.UIC')
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
  const policyMessage = passwordPolicyError(parsed.data.newPassword, request.auth.user.role)
  if (policyMessage) return response.status(400).json({ error: 'VALIDATION_ERROR', fields: [{ field: 'newPassword', message: policyMessage }] })
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
  const [rows] = await getDatabasePool().execute('SELECT prt.user_id, u.role FROM password_reset_tokens prt JOIN users u ON u.id = prt.user_id WHERE prt.token_hash = ? AND prt.used_at IS NULL AND prt.expires_at > UTC_TIMESTAMP() LIMIT 1', [tokenHash])
  if (!rows[0]) return response.status(400).json({ error: 'RESET_TOKEN_INVALID' })
  const policyMessage = passwordPolicyError(parsed.data.password, rows[0].role)
  if (policyMessage) return response.status(400).json({ error: 'VALIDATION_ERROR', fields: [{ field: 'password', message: policyMessage }] })
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
  const [companyRows] = await pool.query(`SELECT COUNT(*) AS total_partners, SUM(status = 'PENDING') AS pending_partners, SUM(status = 'ACTIVE') AS active_partners, SUM(status = 'REJECTED') AS rejected_partners, SUM(status = 'SUSPENDED') AS suspended_partners FROM partner_companies`)
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
  if (request.query.segment) { filters.push('segment = ?'); params.push(String(request.query.segment).trim().slice(0, 120)) }
  if (request.query.state) { filters.push('state = ?'); params.push(String(request.query.state).trim().toUpperCase().slice(0, 2)) }
  const where = filters.length ? `WHERE ${filters.join(' AND ')}` : ''
  const [rows] = await getDatabasePool().execute(`SELECT id, person_type, legal_name, trade_name, cpf_cnpj, responsible_name, email, whatsapp, zip_code, address, address_number, complement, neighborhood, city, state, segment, status, rejection_reason, created_at FROM partner_companies ${where} ORDER BY created_at DESC LIMIT ? OFFSET ?`, [...params, pageSize, offset])
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

app.get('/api/admin/settings', databaseRequired, requireRole('ADMINISTRATOR'), asyncRoute(async (_request, response) => {
  try {
    const [rows] = await getDatabasePool().execute('SELECT id, company_name, support_whatsapp, support_email, manual_whatsapp, manual_team_name, manual_message_template, city, state, privacy_url, terms_url, timezone, updated_at FROM application_settings WHERE id = ? LIMIT 1', ['55000000-0000-4000-8000-000000000001'])
    response.json({ settings: rows[0] || null, migrationRequired: !rows[0], runtime: { appEnv: config.appEnv, version: config.version, allowIndexing: config.allowIndexing } })
  } catch (error) {
    if (error.code === 'ER_NO_SUCH_TABLE') return response.json({ settings: null, migrationRequired: true, runtime: { appEnv: config.appEnv, version: config.version, allowIndexing: config.allowIndexing } })
    throw error
  }
}))

app.put('/api/admin/settings', databaseRequired, requireRole('ADMINISTRATOR'), requireCsrf, asyncRoute(async (request, response) => {
  const body = request.body || {}
  const values = {
    companyName: String(body.companyName || '').trim().slice(0, 180),
    supportWhatsapp: String(body.supportWhatsapp || '').trim().slice(0, 30) || null,
    supportEmail: String(body.supportEmail || '').trim().slice(0, 255) || null,
    city: String(body.city || '').trim().slice(0, 120) || null,
    state: String(body.state || '').trim().toUpperCase().slice(0, 2) || null,
    privacyUrl: String(body.privacyUrl || '').trim().slice(0, 500) || null,
    termsUrl: String(body.termsUrl || '').trim().slice(0, 500) || null,
    manualWhatsapp: String(body.manualWhatsapp || '').trim().slice(0, 30) || null,
    manualTeamName: String(body.manualTeamName || '').trim().slice(0, 180) || null,
    manualMessageTemplate: String(body.manualMessageTemplate || '').trim().slice(0, 1000) || null,
  }
  if (!values.companyName) return response.status(400).json({ error: 'COMPANY_NAME_REQUIRED' })
  if (values.state && !/^[A-Z]{2}$/.test(values.state)) return response.status(400).json({ error: 'INVALID_STATE' })
  if (values.supportEmail && !/^\S+@\S+\.\S+$/.test(values.supportEmail)) return response.status(400).json({ error: 'INVALID_EMAIL' })
  try {
    await getDatabasePool().execute(`UPDATE application_settings SET company_name = ?, support_whatsapp = ?, support_email = ?, manual_whatsapp = ?, manual_team_name = ?, manual_message_template = ?, city = ?, state = ?, privacy_url = ?, terms_url = ?, updated_by = ?, updated_at = UTC_TIMESTAMP() WHERE id = ?`, [values.companyName, values.supportWhatsapp, values.supportEmail, values.manualWhatsapp, values.manualTeamName, values.manualMessageTemplate, values.city, values.state, values.privacyUrl, values.termsUrl, request.auth.user.id, '55000000-0000-4000-8000-000000000001'])
  } catch (error) {
    if (error.code === 'ER_NO_SUCH_TABLE') return response.status(409).json({ error: 'SETTINGS_MIGRATION_REQUIRED' })
    throw error
  }
  await writeAudit(request.auth.user.id, 'APPLICATION_SETTINGS_UPDATED', 'application_settings', '55000000-0000-4000-8000-000000000001', { fields: Object.keys(values).filter((key) => key !== 'supportEmail') })
  response.json({ status: 'updated' })
}))

app.get('/api/admin/commissions', databaseRequired, requireRole('ADMINISTRATOR'), asyncRoute(async (_request, response) => {
  const [settings] = await getDatabasePool().execute('SELECT default_model, default_percentage, default_fixed_amount_cents, honorarium_only, updated_at FROM commission_settings WHERE id = ? LIMIT 1', ['45000000-0000-4000-8000-000000000001'])
  response.json({ models: COMMISSION_MODELS, settings: settings[0] || { default_model: 'NONE', default_percentage: null, default_fixed_amount_cents: null, honorarium_only: 0 }, migrationRequired: !settings[0] })
}))

app.get('/api/admin/api-keys', databaseRequired, requireRole('ADMINISTRATOR'), (_request, response) => {
  response.json({ storage: 'backend-environment', integrations: [{ code: 'SIMPLES_API', name: 'Simples API', configured: Boolean(process.env.SIMPLES_API_KEY), secretName: 'SIMPLES_API_KEY', realCallsEnabled: false }] })
})

app.put('/api/admin/commissions', databaseRequired, requireRole('ADMINISTRATOR'), requireCsrf, asyncRoute(async (request, response) => {
  const body = request.body || {}
  const model = String(body.model || 'NONE').toUpperCase()
  const percentage = body.percentage === null || body.percentage === undefined || body.percentage === '' ? null : Number(body.percentage)
  const fixedAmountCents = body.fixedAmountCents === null || body.fixedAmountCents === undefined || body.fixedAmountCents === '' ? null : Number(body.fixedAmountCents)
  try { validateCommissionConfig({ model, percentage, fixedAmountCents }) } catch (error) { return response.status(400).json({ error: error.message }) }
  await getDatabasePool().execute('UPDATE commission_settings SET default_model = ?, default_percentage = ?, default_fixed_amount_cents = ?, honorarium_only = ?, updated_by = ?, updated_at = UTC_TIMESTAMP() WHERE id = ?', [model, percentage, fixedAmountCents, body.honorariumOnly ? 1 : 0, request.auth.user.id, '45000000-0000-4000-8000-000000000001'])
  await writeAudit(request.auth.user.id, 'COMMISSION_SETTINGS_UPDATED', 'commission_settings', '45000000-0000-4000-8000-000000000001', { model })
  response.json({ status: 'updated', model })
}))

app.post('/api/admin/commissions/simulate', databaseRequired, requireRole('ADMINISTRATOR'), requireCsrf, asyncRoute(async (request, response) => {
  const body = request.body || {}
  const inputConfig = { model: String(body.model || 'NONE').toUpperCase(), percentage: body.percentage === null || body.percentage === undefined || body.percentage === '' ? null : Number(body.percentage), fixedAmountCents: body.fixedAmountCents === null || body.fixedAmountCents === undefined || body.fixedAmountCents === '' ? null : Number(body.fixedAmountCents) }
  let effectiveConfig = inputConfig
  if (body.partnerCompanyId) {
    const [globalRows] = await getDatabasePool().execute('SELECT default_model AS model, default_percentage AS percentage, default_fixed_amount_cents AS fixedAmountCents, honorarium_only AS honorariumOnly FROM commission_settings WHERE id = ? LIMIT 1', ['45000000-0000-4000-8000-000000000001'])
    const [overrideRows] = await getDatabasePool().execute('SELECT model, percentage, fixed_amount_cents AS fixedAmountCents, honorarium_only AS honorariumOnly FROM partner_commission_overrides WHERE partner_company_id = ? LIMIT 1', [String(body.partnerCompanyId)])
    const globalConfig = globalRows[0] ? { ...globalRows[0], model: String(globalRows[0].model).toUpperCase() } : { model: 'NONE' }
    effectiveConfig = resolveCommissionConfig(globalConfig, overrideRows[0] || null)
  }
  const charges = Array.isArray(body.charges) ? body.charges.map((charge) => ({ amountCents: charge.amountCents, chargeNature: charge.chargeNature, isPublicFee: Boolean(charge.isPublicFee) })) : []
  try {
    const result = evaluateCommission(effectiveConfig, charges)
    response.json({ simulated: true, config: effectiveConfig, result })
  } catch (error) {
    return response.status(400).json({ error: error.message })
  }
}))

app.get('/api/admin/partners/:id/details', databaseRequired, requireRole('ADMINISTRATOR'), asyncRoute(async (request, response) => {
  const [companies] = await getDatabasePool().execute('SELECT id, person_type, legal_name, trade_name, cpf_cnpj, responsible_name, email, whatsapp, zip_code, address, address_number, complement, neighborhood, city, state, segment, status, rejection_reason, approved_at, approved_by, created_at, updated_at FROM partner_companies WHERE id = ? LIMIT 1', [request.params.id])
  if (!companies[0]) return response.status(404).json({ error: 'PARTNER_NOT_FOUND' })
  const [members] = await getDatabasePool().execute('SELECT u.id, u.name, u.email, u.status, cm.company_role, cm.created_at FROM users u JOIN company_members cm ON cm.user_id = u.id WHERE cm.company_id = ? ORDER BY cm.created_at', [request.params.id])
  const [history] = await getDatabasePool().execute('SELECT action, entity_type, entity_id, metadata, created_at FROM audit_logs WHERE entity_type = \'partner_company\' AND entity_id = ? ORDER BY created_at DESC LIMIT 50', [request.params.id])
  response.json({ company: companies[0], members, history })
}))

app.patch('/api/admin/partners/:id', databaseRequired, requireRole('ADMINISTRATOR'), requireCsrf, asyncRoute(async (request, response) => {
  const allowed = { legalName: 'legal_name', tradeName: 'trade_name', responsibleName: 'responsible_name', email: 'email', whatsapp: 'whatsapp', segment: 'segment', zipCode: 'zip_code', address: 'address', addressNumber: 'address_number', complement: 'complement', neighborhood: 'neighborhood', city: 'city', state: 'state' }
  const fields = Object.entries(allowed).filter(([key]) => Object.prototype.hasOwnProperty.call(request.body || {}, key))
  if (fields.length === 0) return response.status(400).json({ error: 'NO_EDITABLE_FIELDS' })
  const values = fields.map(([key]) => { const value = request.body[key]; return value === null || value === '' ? null : String(value).trim().slice(0, key === 'email' ? 255 : 180) })
  const assignments = fields.map(([, column]) => `\`${column}\` = ?`).join(', ')
  const [result] = await getDatabasePool().execute(`UPDATE partner_companies SET ${assignments}, updated_at = UTC_TIMESTAMP() WHERE id = ?`, [...values, request.params.id])
  if (!result.affectedRows) return response.status(404).json({ error: 'PARTNER_NOT_FOUND' })
  await writeAudit(request.auth.user.id, 'PARTNER_UPDATED', 'partner_company', request.params.id, { fields: fields.map(([key]) => key) })
  response.json({ status: 'updated' })
}))

app.get('/api/admin/partners/:id/commission', databaseRequired, requireRole('ADMINISTRATOR'), asyncRoute(async (request, response) => {
  const [rows] = await getDatabasePool().execute('SELECT id, partner_company_id, model, percentage, fixed_amount_cents, honorarium_only, notes, valid_from, valid_until, updated_at FROM partner_commission_overrides WHERE partner_company_id = ? LIMIT 1', [request.params.id])
  response.json({ override: rows[0] || null })
}))

app.put('/api/admin/partners/:id/commission', databaseRequired, requireRole('ADMINISTRATOR'), requireCsrf, asyncRoute(async (request, response) => {
  const body = request.body || {}; const scope = String(body.scope || 'CUSTOM').toUpperCase()
  const [companies] = await getDatabasePool().execute('SELECT id FROM partner_companies WHERE id = ? LIMIT 1', [request.params.id]); if (!companies[0]) return response.status(404).json({ error: 'PARTNER_NOT_FOUND' })
  if (scope === 'INHERIT') {
    await getDatabasePool().execute('DELETE FROM partner_commission_overrides WHERE partner_company_id = ?', [request.params.id])
    await writeAudit(request.auth.user.id, 'PARTNER_COMMISSION_INHERIT', 'partner_company', request.params.id, {})
    return response.json({ status: 'updated', scope })
  }
  const bodyModel = scope === 'DISABLED' ? 'NONE' : String(body.model || 'NONE').toUpperCase(); const model = bodyModel; const percentage = body.percentage === null || body.percentage === undefined || body.percentage === '' ? null : Number(body.percentage); const fixedAmountCents = body.fixedAmountCents === null || body.fixedAmountCents === undefined || body.fixedAmountCents === '' ? null : Number(body.fixedAmountCents)
  try { validateCommissionConfig({ model, percentage, fixedAmountCents }) } catch (error) { return response.status(400).json({ error: error.message }) }
  await getDatabasePool().execute(`INSERT INTO partner_commission_overrides (id, partner_company_id, model, percentage, fixed_amount_cents, honorarium_only, notes, valid_from, valid_until, created_by, updated_by)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE model = VALUES(model), percentage = VALUES(percentage), fixed_amount_cents = VALUES(fixed_amount_cents), honorarium_only = VALUES(honorarium_only), notes = VALUES(notes), valid_from = VALUES(valid_from), valid_until = VALUES(valid_until), updated_by = VALUES(updated_by), updated_at = UTC_TIMESTAMP()`, [cryptoRandomId(), request.params.id, model, percentage, fixedAmountCents, body.honorariumOnly ? 1 : 0, body.notes ? String(body.notes).trim().slice(0, 500) : null, body.validFrom || null, body.validUntil || null, request.auth.user.id, request.auth.user.id])
  await writeAudit(request.auth.user.id, 'PARTNER_COMMISSION_UPDATED', 'partner_company', request.params.id, { model })
  response.json({ status: 'updated', model, scope: scope === 'DISABLED' ? 'DISABLED' : 'CUSTOM' })
}))

app.patch('/api/admin/partners/:id/status', databaseRequired, requireRole('ADMINISTRATOR'), requireCsrf, asyncRoute(async (request, response) => {
  const status = String(request.body.status || '').toUpperCase()
  if (!isPartnerCompanyStatus(status) || status === 'PENDING') return response.status(400).json({ error: 'INVALID_STATUS' })
  const reason = ['REJECTED', 'SUSPENDED'].includes(status) ? String(request.body.reason || '').trim().slice(0, 500) || null : null
  try {
    const result = await withTransaction(async (connection) => {
      const [companies] = await connection.execute('SELECT id FROM partner_companies WHERE id = ? FOR UPDATE', [request.params.id])
      if (companies.length === 0) return false
      const approvedAt = status === 'ACTIVE' ? new Date() : null
      const approvedBy = status === 'ACTIVE' ? request.auth.user.id : null
      await connection.execute('UPDATE partner_companies SET status = ?, rejection_reason = ?, approved_at = COALESCE(?, approved_at), approved_by = COALESCE(?, approved_by), updated_at = UTC_TIMESTAMP() WHERE id = ?', [status, reason, approvedAt, approvedBy, request.params.id])
      await connection.execute('UPDATE users u JOIN company_members cm ON cm.user_id = u.id SET u.status = ?, u.approved_at = COALESCE(?, u.approved_at), u.approved_by = COALESCE(?, u.approved_by), u.updated_at = UTC_TIMESTAMP() WHERE cm.company_id = ?', [partnerUserStatusForCompanyStatus(status), approvedAt, approvedBy, request.params.id])
      return true
    })
    if (!result) return response.status(404).json({ error: 'PARTNER_NOT_FOUND' })
    await writeAudit(request.auth.user.id, `PARTNER_${status}`, 'partner_company', request.params.id, { reason })
    return response.json({ status })
  } catch (error) {
    console.error(JSON.stringify({ event: 'admin_partner_status_failed', requestId: request.requestId, companyId: request.params.id, targetStatus: status, code: error.code || 'UNKNOWN', errno: error.errno || null, sqlState: error.sqlState || null }))
    return response.status(500).json({ error: 'PARTNER_STATUS_UPDATE_FAILED', requestId: request.requestId })
  }
}))

app.get('/api/partner/dashboard', databaseRequired, requireRole('PARTNER'), activeAccount, asyncRoute(async (request, response) => {
  const [rows] = await getDatabasePool().execute(`SELECT c.id, c.legal_name, c.trade_name, c.person_type, c.cpf_cnpj, c.email, c.whatsapp, c.segment, c.city, c.state, c.zip_code, c.status, cm.company_role FROM partner_companies c JOIN company_members cm ON cm.company_id = c.id WHERE cm.user_id = ? LIMIT 1`, [request.auth.user.id])
  response.json({ user: request.auth.user, company: rows[0] || null })
}))

app.get('/api/partner/status', databaseRequired, requireRole('PARTNER'), asyncRoute(async (request, response) => {
  const [rows] = await getDatabasePool().execute(`SELECT c.id, c.legal_name, c.trade_name, c.person_type, c.status, c.segment, c.city, c.state, c.created_at, c.rejection_reason, cm.company_role FROM partner_companies c JOIN company_members cm ON cm.company_id = c.id WHERE cm.user_id = ? LIMIT 1`, [request.auth.user.id])
  if (rows.length === 0) return response.status(404).json({ error: 'PARTNER_COMPANY_NOT_FOUND' })
  response.json({ user: request.auth.user, company: rows[0] })
}))

app.get('/api/partner/members', databaseRequired, requireRole('PARTNER'), activeAccount, asyncRoute(async (request, response) => {
  const [rows] = await getDatabasePool().execute(`SELECT u.id, u.name, u.email, u.status, cm.company_role, cm.created_at FROM users u JOIN company_members cm ON cm.user_id = u.id WHERE cm.company_id = (SELECT company_id FROM company_members WHERE user_id = ? LIMIT 1) ORDER BY cm.created_at`, [request.auth.user.id])
  response.json({ items: rows })
}))

app.post('/api/partner/members', databaseRequired, requireRole('PARTNER'), activeAccount, requireCsrf, asyncRoute(async (request, response) => {
  const parsed = collaboratorRegistrationSchema.safeParse(request.body)
  if (!parsed.success) return response.status(400).json(validationError(parsed.error))
  const [owners] = await getDatabasePool().execute('SELECT company_id FROM company_members WHERE user_id = ? AND company_role = \'OWNER\' LIMIT 1', [request.auth.user.id])
  if (owners.length === 0) return response.status(403).json({ error: 'COLLABORATOR_MANAGEMENT_FORBIDDEN' })
  const data = parsed.data; const email = data.email.toLowerCase()
  try {
    const user = await withTransaction(async (connection) => {
      const userId = cryptoRandomId(); const passwordHash = await hashPassword(data.password)
      await connection.execute(`INSERT INTO users (id, role, status, name, email, whatsapp, password_hash, terms_accepted_at, privacy_acknowledged_at, approved_at) VALUES (?, 'PARTNER', 'ACTIVE', ?, ?, ?, ?, UTC_TIMESTAMP(), UTC_TIMESTAMP(), UTC_TIMESTAMP())`, [userId, data.name, email, data.whatsapp || null, passwordHash])
      await connection.execute('INSERT INTO company_members (company_id, user_id, company_role) VALUES (?, ?, \'COLLABORATOR\')', [owners[0].company_id, userId])
      return { id: userId, role: 'PARTNER', status: 'ACTIVE', name: data.name, email, cpf: null, whatsapp: data.whatsapp || null }
    })
    await writeAudit(request.auth.user.id, 'COLLABORATOR_CREATED', 'user', user.id, { companyId: owners[0].company_id })
    return response.status(201).json({ user })
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') return response.status(409).json({ error: 'REGISTRATION_CONFLICT' })
    throw error
  }
}))

app.get('/api/client/dashboard', databaseRequired, requireRole('CLIENT'), activeAccount, (request, response) => response.json({ user: request.auth.user, features: { vehicles: false, budgets: false, services: false, documents: false } }))

app.use('/api/services', createPublicServiceRouter({ databaseRequired }))
app.use('/api/partner', createPartnerServiceRouter({ databaseRequired, activeAccount }))
app.use('/api/admin', createServiceRouter({ databaseRequired, activeAccount }))

app.use(express.static(dist, { index: false }))
app.get('*', asyncRoute(async (_request, response, next) => {
  try {
    const html = await fs.readFile(indexFile, 'utf8')
    const robots = config.allowIndexing ? 'index, follow' : 'noindex, nofollow'
    const runtimeConfig = JSON.stringify({ appEnv: config.appEnv, version: config.version, allowIndexing: config.allowIndexing })
    response.type('html').send(html.replace('</head>', `<meta name="robots" content="${robots}" />\n</head>`).replace('<body>', `<body><script>window.__DOC_MOTOR_CONFIG__=${runtimeConfig}</script>`))
  } catch (error) { next(error) }
}))

app.use((error, request, response, _next) => {
  void _next
  console.error(JSON.stringify({ event: 'unhandled_request_error', requestId: request.requestId || null, method: request.method, path: request.path, code: error.code || 'UNKNOWN', message: config.debug ? error.message : 'request_failed' }))
  if (response.headersSent) return
  const databaseUnavailable = error.code === 'DATABASE_NOT_CONFIGURED' || String(error.code || '').startsWith('ER_') || ['ECONNREFUSED', 'ETIMEDOUT', 'PROTOCOL_CONNECTION_LOST', 'ENOTFOUND', 'EAI_AGAIN'].includes(error.code)
  response.status(databaseUnavailable ? 503 : 500).json({ error: error.code === 'DATABASE_NOT_CONFIGURED' ? 'DATABASE_NOT_CONFIGURED' : databaseUnavailable ? 'DATABASE_NOT_READY' : 'INTERNAL_ERROR', requestId: request.requestId })
})

function cryptoRandomId() {
  return randomUUID()
}

export default app
