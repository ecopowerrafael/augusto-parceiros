import { describe, expect, it } from 'vitest'
import { whatsappLink } from './whatsapp'

describe('whatsappLink', () => {
  it('uses the commercial number and encodes the message', () => {
    const link = whatsappLink('Olá, Doc Motor! Quero uma análise.')
    expect(link).toMatch(/^https:\/\/wa\.me\/5515997118125\?text=/)
    expect(link).toContain(encodeURIComponent('Olá, Doc Motor! Quero uma análise.'))
  })
})
