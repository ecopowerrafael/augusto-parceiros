/* global process */
import packageJson from '../package.json' with { type: 'json' }

const booleanFromEnv = (value, fallback) => {
  if (value === undefined) return fallback
  return value.toLowerCase() === 'true'
}

const allowedEnvironments = new Set(['development', 'staging', 'production'])
const requestedEnvironment = process.env.APP_ENV || 'development'

export const config = Object.freeze({
  nodeEnv: process.env.NODE_ENV || 'development',
  appEnv: allowedEnvironments.has(requestedEnvironment) ? requestedEnvironment : 'development',
  allowIndexing: booleanFromEnv(process.env.ALLOW_INDEXING, false),
  debug: booleanFromEnv(process.env.APP_DEBUG, false),
  port: Number(process.env.PORT || 3000),
  version: packageJson.version,
  databaseConfigured: Boolean(process.env.DATABASE_URL),
})

export const databaseDiagnostics = Object.freeze({
  configured: config.databaseConfigured,
  check: 'reserved-for-phase-2',
})
