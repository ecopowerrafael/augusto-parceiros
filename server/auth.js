/* global process */
import bcrypt from 'bcryptjs'
import { createHash, randomBytes, randomUUID } from 'node:crypto'
import { z } from 'zod'
import { getDatabasePool } from './database.js'

export const SESSION_COOKIE = 'doc_motor_session'
const SESSION_TTL_HOURS = 8
const PASSWORD_RESET_TTL_MINUTES = 30

const passwordSchema = z.string().min(12).max(128).regex(/[a-z]/, 'Senha deve conter letra minúscula.').regex(/[A-Z]/, 'Senha deve conter letra maiúscula.').regex(/[0-9]/, 'Senha deve conter número.')
const basePersonSchema = z.object({
  name: z.string().trim().min(3).max(180),
  email: z.string().trim().email().max(255),
  whatsapp: z.string().trim().min(8).max(30),
  password: passwordSchema,
  passwordConfirmation: z.string(),
  acceptTerms: z.literal(true),
  privacyAcknowledgement: z.literal(true),
})

const matchingPasswords = (schema) => schema.refine((data) => data.password === data.passwordConfirmation, { path: ['passwordConfirmation'], message: 'As senhas não conferem.' })

export const clientRegistrationSchema = matchingPasswords(basePersonSchema.extend({
  cpf: z.string().trim().refine(isCpf, 'CPF inválido.'),
}))

export const partnerRegistrationSchema = matchingPasswords(basePersonSchema.extend({
  personType: z.enum(['PF', 'PJ']),
  legalName: z.string().trim().min(3).max(180),
  tradeName: z.string().trim().max(180).optional().or(z.literal('')),
  cpfCnpj: z.string().trim().refine((value) => isCpf(value) || isCnpj(value), 'CPF ou CNPJ inválido.'),
  responsibleName: z.string().trim().min(3).max(180),
  zipCode: z.string().trim().max(10).optional().or(z.literal('')),
  address: z.string().trim().max(180).optional().or(z.literal('')),
  addressNumber: z.string().trim().max(20).optional().or(z.literal('')),
  complement: z.string().trim().max(120).optional().or(z.literal('')),
  neighborhood: z.string().trim().max(120).optional().or(z.literal('')),
  city: z.string().trim().max(120).optional().or(z.literal('')),
  state: z.string().trim().length(2).toUpperCase(),
  segment: z.enum(['Desmanche', 'Revenda de motores', 'Autopeças', 'Oficina mecânica', 'Centro automotivo', 'Revenda de veículos', 'Prestador de serviços', 'Outros']),
}))

export const loginSchema = z.object({ email: z.string().trim().email().max(255), password: z.string().min(1).max(128) })
export const forgotPasswordSchema = z.object({ email: z.string().trim().email().max(255) })
export const changePasswordSchema = z.object({ currentPassword: z.string().min(1), newPassword: passwordSchema, newPasswordConfirmation: z.string() }).refine((data) => data.newPassword === data.newPasswordConfirmation, { path: ['newPasswordConfirmation'], message: 'As senhas não conferem.' })
export const resetPasswordSchema = z.object({ token: z.string().min(32), password: passwordSchema, passwordConfirmation: z.string() }).refine((data) => data.password === data.passwordConfirmation, { path: ['passwordConfirmation'], message: 'As senhas não conferem.' })

export function digits(value) {
  return String(value || '').replace(/\D/g, '')
}

export function isCpf(value) {
  const cpf = digits(value)
  if (cpf.length !== 11 || /^([0-9])\1+$/.test(cpf)) return false
  for (let factor = 9; factor <= 10; factor += 1) {
    let total = 0
    for (let index = 0; index < factor; index += 1) total += Number(cpf[index]) * (factor + 1 - index)
    const digit = (total * 10) % 11 % 10
    if (digit !== Number(cpf[factor])) return false
  }
  return true
}

export function isCnpj(value) {
  const cnpj = digits(value)
  if (cnpj.length !== 14 || /^([0-9])\1+$/.test(cnpj)) return false
  const calculate = (length) => {
    let weight = length - 7
    let total = 0
    for (let index = 0; index < length; index += 1) {
      total += Number(cnpj[index]) * weight
      weight -= 1
      if (weight < 2) weight = 9
    }
    const remainder = total % 11
    return remainder < 2 ? 0 : 11 - remainder
  }
  return calculate(12) === Number(cnpj[12]) && calculate(13) === Number(cnpj[13])
}

export function hashToken(value) {
  return createHash('sha256').update(value).digest('hex')
}

export function publicUser(user) {
  return { id: user.id, role: user.role, status: user.status, name: user.name, email: user.email, cpf: user.cpf, whatsapp: user.whatsapp }
}

export function parseCookies(request) {
  const header = request.headers.cookie || ''
  return Object.fromEntries(header.split(';').filter(Boolean).map((part) => {
    const index = part.indexOf('=')
    return [part.slice(0, index).trim(), decodeURIComponent(part.slice(index + 1).trim())]
  }))
}

function cookieOptions(maxAge) {
  const secure = process.env.NODE_ENV === 'production' ? '; Secure' : ''
  return `Path=/; HttpOnly; SameSite=Lax; Max-Age=${maxAge}${secure}`
}

function setSessionCookie(response, value) {
  response.setHeader('Set-Cookie', `${SESSION_COOKIE}=${encodeURIComponent(value)}; ${cookieOptions(SESSION_TTL_HOURS * 3600)}`)
}

export function clearSessionCookie(response) {
  response.setHeader('Set-Cookie', `${SESSION_COOKIE}=; ${cookieOptions(0)}`)
}

export function assertSameOrigin(request) {
  const origin = request.headers.origin
  if (!origin) return true
  const expected = `${request.protocol}://${request.get('host')}`
  return origin === expected || origin === 'https://docmotor.online'
}

export async function createSession(user, request, response) {
  const pool = getDatabasePool()
  if (!pool) throw new Error('DATABASE_NOT_CONFIGURED')
  const rawToken = randomBytes(32).toString('base64url')
  const csrfToken = randomBytes(32).toString('base64url')
  const expiresAt = new Date(Date.now() + SESSION_TTL_HOURS * 60 * 60 * 1000)
  await pool.execute(
    `INSERT INTO sessions (id, user_id, token_hash, csrf_token_hash, expires_at, user_agent) VALUES (?, ?, ?, ?, ?, ?)`,
    [randomUUID(), user.id, hashToken(rawToken), hashToken(csrfToken), expiresAt, String(request.headers['user-agent'] || '').slice(0, 500)],
  )
  setSessionCookie(response, rawToken)
  return csrfToken
}

export async function loadSession(request) {
  const rawToken = parseCookies(request)[SESSION_COOKIE]
  if (!rawToken) return null
  const pool = getDatabasePool()
  if (!pool) return null
  const [rows] = await pool.execute(
    `SELECT s.id AS session_id, s.user_id, s.csrf_token_hash, u.id, u.role, u.status, u.name, u.email, u.cpf, u.whatsapp
     FROM sessions s JOIN users u ON u.id = s.user_id
     WHERE s.token_hash = ? AND s.revoked_at IS NULL AND s.expires_at > UTC_TIMESTAMP() LIMIT 1`,
    [hashToken(rawToken)],
  )
  if (rows.length === 0 || ['SUSPENDED', 'DISABLED'].includes(rows[0].status)) return null
  return { sessionId: rows[0].session_id, csrfTokenHash: rows[0].csrf_token_hash, user: publicUser(rows[0]) }
}

export async function revokeSession(request) {
  const rawToken = parseCookies(request)[SESSION_COOKIE]
  const pool = getDatabasePool()
  if (rawToken && pool) await pool.execute('UPDATE sessions SET revoked_at = UTC_TIMESTAMP() WHERE token_hash = ?', [hashToken(rawToken)])
}

export async function requireCsrf(request, response, next) {
  if (!assertSameOrigin(request)) return response.status(403).json({ error: 'ORIGIN_NOT_ALLOWED' })
  if (!request.auth) return response.status(401).json({ error: 'AUTHENTICATION_REQUIRED' })
  const csrf = request.headers['x-csrf-token']
  if (!csrf || hashToken(csrf) !== request.auth.csrfTokenHash) return response.status(403).json({ error: 'CSRF_INVALID' })
  return next()
}

export function requireAuth(request, response, next) {
  if (!request.auth) return response.status(401).json({ error: 'AUTHENTICATION_REQUIRED' })
  return next()
}

export function requireRole(...roles) {
  return (request, response, next) => {
    if (!request.auth) return response.status(401).json({ error: 'AUTHENTICATION_REQUIRED' })
    if (!roles.includes(request.auth.user.role)) return response.status(403).json({ error: 'FORBIDDEN' })
    return next()
  }
}

export async function consumeRateLimit(bucketKey, limit = 5, windowSeconds = 900) {
  const pool = getDatabasePool()
  if (!pool) return true
  const windowStart = new Date(Math.floor(Date.now() / (windowSeconds * 1000)) * windowSeconds * 1000)
  const sqlDate = windowStart.toISOString().slice(0, 19).replace('T', ' ')
  await pool.execute(`INSERT INTO rate_limit_events (bucket_key, window_started_at, attempts) VALUES (?, ?, 1) ON DUPLICATE KEY UPDATE attempts = attempts + 1`, [bucketKey, sqlDate])
  const [rows] = await pool.execute('SELECT attempts FROM rate_limit_events WHERE bucket_key = ? AND window_started_at = ?', [bucketKey, sqlDate])
  return rows[0]?.attempts <= limit
}

export async function writeAudit(actorUserId, action, entityType, entityId, metadata = {}) {
  const pool = getDatabasePool()
  if (!pool) return
  await pool.execute('INSERT INTO audit_logs (actor_user_id, action, entity_type, entity_id, metadata) VALUES (?, ?, ?, ?, ?)', [actorUserId || null, action, entityType, entityId || null, JSON.stringify(metadata)])
}

export function validationError(error) {
  return { error: 'VALIDATION_ERROR', fields: error.issues.map((issue) => ({ field: issue.path.join('.'), message: issue.message })) }
}

export async function hashPassword(password) {
  return bcrypt.hash(password, 12)
}

export async function verifyPassword(password, hash) {
  return bcrypt.compare(password, hash)
}

export function createPasswordResetToken() {
  return randomBytes(32).toString('base64url')
}

export async function issuePasswordReset(userId) {
  const pool = getDatabasePool()
  if (!pool) throw new Error('DATABASE_NOT_CONFIGURED')
  const rawToken = createPasswordResetToken()
  const expiresAt = new Date(Date.now() + PASSWORD_RESET_TTL_MINUTES * 60 * 1000)
  await pool.execute('INSERT INTO password_reset_tokens (id, user_id, token_hash, expires_at) VALUES (?, ?, ?, ?)', [randomUUID(), userId, hashToken(rawToken), expiresAt])
  return rawToken
}

export { bcrypt, setSessionCookie }
