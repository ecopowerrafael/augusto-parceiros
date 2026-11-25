/* global console, process */
import fs from 'node:fs/promises'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import mysql from 'mysql2/promise'

const root = path.dirname(fileURLToPath(import.meta.url))
const migrationsDir = path.resolve(root, '../migrations')
const databaseUrl = process.env.DATABASE_URL

if (!databaseUrl) {
  console.error('DATABASE_URL is required to run migrations.')
  process.exit(1)
}

const connection = await mysql.createConnection(databaseUrl)
try {
  await connection.query(`CREATE TABLE IF NOT EXISTS schema_migrations (name VARCHAR(255) NOT NULL PRIMARY KEY, applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`)
  const [rows] = await connection.query('SELECT name FROM schema_migrations')
  const applied = new Set(rows.map((row) => row.name))
  const files = (await fs.readdir(migrationsDir)).filter((file) => file.endsWith('.sql')).sort()
  for (const file of files) {
    if (applied.has(file)) continue
    const sql = await fs.readFile(path.join(migrationsDir, file), 'utf8')
    await connection.beginTransaction()
    try {
      const statements = sql.split(/;\s*(?=\n|$)/).map((statement) => statement.trim()).filter(Boolean)
      for (const statement of statements) await connection.query(statement)
      await connection.query('INSERT INTO schema_migrations (name) VALUES (?) ON DUPLICATE KEY UPDATE name = VALUES(name)', [file])
      await connection.commit()
      console.log(`Applied migration ${file}`)
    } catch (error) {
      await connection.rollback()
      throw error
    }
  }
  console.log('Migrations complete.')
} finally {
  await connection.end()
}
