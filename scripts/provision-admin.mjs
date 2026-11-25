/* global process, console */
import bcrypt from 'bcryptjs'
import { randomUUID } from 'node:crypto'
import mysql from 'mysql2/promise'

const databaseUrl = process.env.DATABASE_URL
const email = process.env.ADMIN_EMAIL?.trim().toLowerCase()
const password = process.env.ADMIN_PASSWORD
const name = process.env.ADMIN_NAME?.trim()

if (!databaseUrl || !email || !password || !name) {
  console.error('DATABASE_URL, ADMIN_EMAIL, ADMIN_PASSWORD and ADMIN_NAME are required.')
  process.exit(1)
}
if (password.length < 12) {
  console.error('ADMIN_PASSWORD must have at least 12 characters.')
  process.exit(1)
}

const connection = await mysql.createConnection(databaseUrl)
try {
  const [admins] = await connection.query('SELECT id FROM users WHERE role = ? LIMIT 1', ['ADMINISTRATOR'])
  if (admins.length > 0) {
    console.error('An administrator already exists. Provisioning stopped.')
    process.exitCode = 1
  } else {
    const passwordHash = await bcrypt.hash(password, 12)
    await connection.execute(
      `INSERT INTO users (id, role, status, name, email, password_hash, terms_accepted_at, privacy_acknowledged_at, approved_at)
       VALUES (?, 'ADMINISTRATOR', 'ACTIVE', ?, ?, ?, UTC_TIMESTAMP(), UTC_TIMESTAMP(), UTC_TIMESTAMP())`,
      [randomUUID(), name, email, passwordHash],
    )
    console.log('Administrator provisioned successfully. Do not reuse the provisioning secret.')
  }
} finally {
  await connection.end()
}
