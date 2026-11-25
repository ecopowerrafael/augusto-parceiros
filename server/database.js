/* global console, process, URL */
import mysql from 'mysql2/promise'

let pool

const CONNECTION_ERROR_CODES = new Set(['ECONNREFUSED', 'ETIMEDOUT', 'ENOTFOUND', 'EAI_AGAIN', 'ER_ACCESS_DENIED_ERROR', 'ER_BAD_DB_ERROR'])

function isValidDatabaseUrl(value) {
  try {
    const parsed = new URL(value)
    return ['mysql:', 'mysql2:'].includes(parsed.protocol) && Boolean(parsed.hostname) && Boolean(parsed.pathname && parsed.pathname !== '/')
  } catch {
    return false
  }
}

export function classifyDatabaseError(error) {
  if (CONNECTION_ERROR_CODES.has(error?.code)) return error.code
  if (error?.code === 'ERR_INVALID_URL' || error?.code === 'EINVAL') return 'DATABASE_CONFIG_INVALID'
  return 'DATABASE_CONNECTION_ERROR'
}

export function getDatabasePool() {
  if (!process.env.DATABASE_URL) return null
  if (!pool) {
    pool = mysql.createPool(process.env.DATABASE_URL, {
      waitForConnections: true,
      connectionLimit: Number(process.env.DB_POOL_SIZE || 5),
      queueLimit: 0,
      enableKeepAlive: true,
      keepAliveInitialDelay: 0,
      timezone: 'Z',
    })
  }
  return pool
}

export async function withTransaction(callback) {
  const connection = await getDatabasePool()?.getConnection()
  if (!connection) throw new Error('DATABASE_NOT_CONFIGURED')
  try {
    await connection.beginTransaction()
    const result = await callback(connection)
    await connection.commit()
    return result
  } catch (error) {
    await connection.rollback()
    throw error
  } finally {
    connection.release()
  }
}

export async function closeDatabasePool() {
  if (pool) {
    await pool.end()
    pool = undefined
  }
}

export function isDatabaseConfigured() {
  return Boolean(process.env.DATABASE_URL)
}

export async function diagnoseDatabase() {
  const databaseUrl = process.env.DATABASE_URL
  if (!databaseUrl) {
    console.log('[database-diagnostic] status=DATABASE_CONFIG_MISSING configured=false')
    return { status: 'DATABASE_CONFIG_MISSING' }
  }
  if (!isValidDatabaseUrl(databaseUrl)) {
    console.log('[database-diagnostic] status=DATABASE_CONFIG_INVALID configured=true')
    return { status: 'DATABASE_CONFIG_INVALID' }
  }

  console.log('[database-diagnostic] configured=true connection_attempt=started')
  try {
    const database = getDatabasePool()
    const [connectedRows] = await database.query('SELECT 1 AS connected')
    const [databaseRows] = await database.query('SELECT DATABASE() AS database_name')
    console.log(`[database-diagnostic] status=DATABASE_CONNECTED connected=${connectedRows[0]?.connected === 1 ? 1 : 0} database_name=${databaseRows[0]?.database_name || '(none)'}`)
    const [tableRows] = await database.query('SHOW TABLES')
    const tableCount = tableRows.length
    const status = tableCount === 0 ? 'DATABASE_CONNECTED_EMPTY_SCHEMA' : 'DATABASE_CONNECTED_SCHEMA_EXISTS'
    console.log(`[database-diagnostic] status=${status} table_count=${tableCount}`)
    return { status, tableCount }
  } catch (error) {
    const status = classifyDatabaseError(error)
    console.log(`[database-diagnostic] status=${status} code=${error?.code || '(none)'}`)
    return { status }
  }
}
