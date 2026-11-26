import fs from 'node:fs'
import { evaluateCondition } from '../server/service-config.js'

const file = process.argv[2] || 'migrations/007_engine_rules_and_documents.sql'
const source = fs.readFileSync(file, 'utf8')
const match = source.match(/condition_expression = '([^']+)'/)
if (!match) throw new Error('Condição MODIFICATION_REQUEST não encontrada.')
const condition = JSON.parse(match[1].replaceAll('\\"', '"'))
const values = (category, power, cylinder, targetFuel = 'FLEX', donorFuel = 'FLEX') => ({ 'vehicle_target.category': category, 'engine.power_variation_percent': power, 'engine.cylinder_variation_percent': cylinder, 'vehicle_target.fuel': targetFuel, 'vehicle_donor.fuel': donorFuel })
const cases = [
  ['automóvel sem alteração', values('AUTOMOBILE', 0, 0), false],
  ['automóvel potência até 10%', values('AUTOMOBILE', 10, 0), true],
  ['automóvel cilindrada reduzida', values('AUTOMOBILE', 0, -5), true],
  ['motocicleta combustível alterado', values('MOTORCYCLE', undefined, undefined, 'DIESEL', 'FLEX'), true],
  ['motocicleta sem alteração', values('MOTORCYCLE', undefined, undefined), false],
  ['caminhão alteração acima de 10%', values('TRUCK', 50, 20), true],
  ['ônibus combustível alterado', values('BUS', 0, 0, 'DIESEL', 'FLEX'), true],
]
for (const [name, input, expected] of cases) { const actual = evaluateCondition(condition, input); if (actual !== expected) throw new Error(`${name}: esperado ${expected}, recebido ${actual}`) }
console.log(`${file}: JSON da cobrança MODIFICATION_REQUEST parseado e ${cases.length} cenários semânticos aprovados.`)
