/* global console */
import fs from 'node:fs'
import process from 'node:process'

const file = process.argv[2]
if (!file) throw new Error('Uso: node scripts/validate-migration-inserts.mjs <migration.sql>')
const sql = fs.readFileSync(file, 'utf8')

function splitTopLevel(value) {
  const parts = []; let start = 0; let depth = 0; let quote = null
  for (let index = 0; index < value.length; index += 1) {
    const char = value[index]
    if (quote) { if (char === '\\') index += 1; else if (char === quote) quote = null; continue }
    if (char === "'" || char === '"') { quote = char; continue }
    if (char === '(') depth += 1
    else if (char === ')') depth -= 1
    else if (char === ',' && depth === 0) { parts.push(value.slice(start, index).trim()); start = index + 1 }
  }
  parts.push(value.slice(start).trim())
  return parts.filter(Boolean)
}

function rowsAfterValues(value) {
  const rows = []; let index = 0
  while (index < value.length) {
    while (index < value.length && /\s|,/.test(value[index])) index += 1
    if (value.slice(index).match(/^ON\s+DUPLICATE\s+KEY/i) || value[index] !== '(') break
    const start = ++index; let depth = 1; let quote = null
    for (; index < value.length; index += 1) {
      const char = value[index]
      if (quote) { if (char === '\\') index += 1; else if (char === quote) quote = null; continue }
      if (char === "'" || char === '"') { quote = char; continue }
      if (char === '(') depth += 1
      else if (char === ')' && --depth === 0) break
    }
    if (depth !== 0) throw new Error('Linha VALUES com parênteses desbalanceados.')
    rows.push(value.slice(start, index)); index += 1
  }
  return rows
}

function validateJsonObjectArguments(source) {
  const errors = []; let index = 0
  while ((index = source.indexOf('JSON_OBJECT(', index)) !== -1) {
    let cursor = index + 'JSON_OBJECT('.length; const start = cursor; let depth = 1; let quote = null
    for (; cursor < source.length; cursor += 1) {
      const char = source[cursor]
      if (quote) { if (char === '\\') cursor += 1; else if (char === quote) quote = null; continue }
      if (char === "'") { quote = char; continue }
      if (char === '(') depth += 1
      else if (char === ')' && --depth === 0) break
    }
    if (depth !== 0) errors.push(`JSON_OBJECT sem fechamento próximo ao offset ${index}`)
    else { const argumentsList = splitTopLevel(source.slice(start, cursor)); if (argumentsList.length % 2 !== 0) errors.push(`JSON_OBJECT com argumentos ímpares próximo ao offset ${index}`) }
    index = cursor + 1
  }
  return errors
}

const insertPattern = /INSERT\s+INTO\s+[^;]+?\(([^()]+)\)\s*VALUES\s*/gis
let checked = 0; let match
while ((match = insertPattern.exec(sql))) {
  const columns = splitTopLevel(match[1])
  const tail = sql.slice(insertPattern.lastIndex)
  let rows
  try { rows = rowsAfterValues(tail) } catch (error) { throw new Error(`${file}: falha ao analisar INSERT no offset ${match.index}: ${error.message}`) }
  for (const [rowIndex, row] of rows.entries()) {
    const values = splitTopLevel(row)
    checked += 1
    if (columns.length !== values.length) throw new Error(`${file}: INSERT próximo ao offset ${match.index}, linha ${rowIndex + 1}: ${columns.length} colunas, ${values.length} valores.\n${row}`)
  }
}
console.log(`${file}: ${checked} linhas INSERT verificadas; correspondência de colunas/valores aprovada.`)
const jsonErrors = validateJsonObjectArguments(sql)
if (jsonErrors.length) throw new Error(`${file}: ${jsonErrors.join('; ')}`)
console.log(`${file}: JSON_OBJECT verificados; quantidade de argumentos aprovada.`)

if (/INSERT\s+INTO\s+schema_migrations/i.test(sql)) {
  const executableStatements = sql.split(';').map((statement) => statement.replace(/--[^\r\n]*/g, '').trim()).filter(Boolean)
  const lastStatement = executableStatements.at(-1) || ''
  if (!/INSERT\s+INTO\s+schema_migrations/i.test(lastStatement)) {
    throw new Error(`${file}: schema_migrations deve ser registrado somente no último comando executável da migration.`)
  }
  console.log(`${file}: registro de schema_migrations ocorre após os demais comandos.`)
}
