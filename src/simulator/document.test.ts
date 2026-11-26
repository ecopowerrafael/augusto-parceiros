import { describe, expect, it } from 'vitest'
import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import { generateSimulationPdf } from './document'

describe('documento de simulação', () => {
  it('gera um PDF A4 real a partir do resultado do backend', async () => {
    const logoBytes = readFileSync(resolve(process.cwd(), 'public/assets/brand/doc-motor-logo-retangular.png'))
    const blob = await generateSimulationPdf({ serviceName: 'Cadastro de Motor', viability: 'VIABLE', values: { 'vehicle_target.plate': 'AAA1234' }, fields: [{ field_key: 'vehicle_target.plate', label: 'Placa' }], items: [{ name: 'Serviço', total_cents: 97580 }], total_cents: 97580, simulated: true, logoBytes })
    expect(blob.type).toBe('application/pdf')
    expect(blob.size).toBeGreaterThan(500)
    expect(new Uint8Array(await blob.arrayBuffer()).slice(0, 5)).toEqual(new Uint8Array([37, 80, 68, 70, 45]))
    expect(new TextDecoder().decode(await blob.arrayBuffer())).toContain('/Subtype /Image')
  })
})
