/* global process */
import mysql from 'mysql2/promise'

let pool

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
