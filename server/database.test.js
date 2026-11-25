import { describe, expect, it } from 'vitest'
import { classifyDatabaseError } from './database.js'

describe('database diagnostics', () => {
  it.each(['ECONNREFUSED', 'ETIMEDOUT', 'ENOTFOUND', 'ER_ACCESS_DENIED_ERROR', 'ER_BAD_DB_ERROR'])('preserves the MySQL/network code %s', (code) => {
    expect(classifyDatabaseError({ code })).toBe(code)
  })

  it('classifies malformed driver configuration', () => {
    expect(classifyDatabaseError({ code: 'ERR_INVALID_URL' })).toBe('DATABASE_CONFIG_INVALID')
  })

  it('does not expose unknown driver errors as credentials', () => {
    expect(classifyDatabaseError({ code: 'SOME_DRIVER_ERROR', message: 'password=secret' })).toBe('DATABASE_CONNECTION_ERROR')
  })
})
