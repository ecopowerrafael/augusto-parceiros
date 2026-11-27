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

function sqlStringLiterals(source) {
  const literals = []; let index = 0
  while (index < source.length) {
    if (source[index] !== "'") { index += 1; continue }
    index += 1; let value = ''
    while (index < source.length) {
      const char = source[index]
      if (char === '\\' && index + 1 < source.length) { value += source[index + 1]; index += 2; continue }
      if (char === "'") {
        if (source[index + 1] === "'") { value += "'"; index += 2; continue }
        index += 1; break
      }
      value += char; index += 1
    }
    literals.push(value)
  }
  return literals
}

function validateJsonLiterals(source) {
  const errors = []
  for (const literal of sqlStringLiterals(source)) {
    const trimmed = literal.trim()
    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) continue
    try { JSON.parse(trimmed) } catch (error) { errors.push(`literal JSON inválido (${error.message}): ${trimmed.slice(0, 180)}`) }
  }
  return errors
}

function maskSqlStringsAndComments(source) {
  let result = ''; let index = 0; let quote = null
  while (index < source.length) {
    const current = source[index]; const next = source[index + 1]
    if (!quote && current === '-' && next === '-') {
      while (index < source.length && source[index] !== '\n') { result += ' '; index += 1 }
      continue
    }
    if (!quote && current === '/' && next === '*') {
      result += '  '; index += 2
      while (index < source.length && !(source[index] === '*' && source[index + 1] === '/')) { result += source[index] === '\n' ? '\n' : ' '; index += 1 }
      if (index < source.length) { result += '  '; index += 2 }
      continue
    }
    if (quote) {
      result += current === '\n' ? '\n' : ' '
      if (current === '\\') { result += ' '; index += 2; continue }
      if (current === quote) {
        if (source[index + 1] === quote) { result += ' '; index += 2; continue }
        quote = null
      }
      index += 1; continue
    }
    if (current === "'" || current === '"') { quote = current; result += ' '; index += 1; continue }
    result += current; index += 1
  }
  return result
}

function validateCreationOrder(source) {
  const masked = maskSqlStringsAndComments(source)
  const statements = masked.split(';').map((statement) => statement.trim()).filter(Boolean)
  const createdTables = []
  for (const [statementIndex, statement] of statements.entries()) {
    const createMatch = statement.match(/\bCREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?`?([A-Za-z0-9_]+)`?/i)
    if (createMatch) createdTables.push({ name: createMatch[1], statementIndex })
  }
  const errors = []
  for (const { name, statementIndex } of createdTables) {
    const referencePattern = new RegExp(`\\b(?:FROM|JOIN|UPDATE|INTO|ALTER\\s+TABLE)\\s+\`?${name}\`?(?:\\s|$|[.(])`, 'i')
    for (let index = 0; index < statementIndex; index += 1) {
      if (referencePattern.test(statements[index])) errors.push(`referência a ${name} antes de CREATE TABLE no comando ${index + 1}`)
    }
  }
  return errors
}

function validateAmbiguousSelectColumns(source) {
  const masked = maskSqlStringsAndComments(source)
  const errors = []
  if (/\bSELECT\s+id\s+FROM[\s\S]*?\bJOIN\b/i.test(masked)) errors.push('SELECT id não qualificado em consulta com JOIN; use alias explícito, como alias.id')
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
const jsonLiteralErrors = validateJsonLiterals(sql)
if (jsonLiteralErrors.length) throw new Error(`${file}: ${jsonLiteralErrors.join('; ')}`)
console.log(`${file}: literais JSON SQL verificados; sintaxe JSON aprovada.`)
const orderErrors = validateCreationOrder(sql)
if (orderErrors.length) throw new Error(`${file}: ${orderErrors.join('; ')}`)
console.log(`${file}: ordem de criação e uso das tabelas aprovada.`)
const ambiguousColumnErrors = validateAmbiguousSelectColumns(sql)
if (ambiguousColumnErrors.length) throw new Error(`${file}: ${ambiguousColumnErrors.join('; ')}`)
console.log(`${file}: colunas potencialmente ambíguas em SELECT/JOIN não encontradas.`)

if (/INSERT\s+INTO\s+schema_migrations/i.test(sql)) {
  const executableStatements = sql.split(';').map((statement) => statement.replace(/--[^\r\n]*/g, '').trim()).filter(Boolean)
  const lastStatement = executableStatements.at(-1) || ''
  if (!/INSERT\s+INTO\s+schema_migrations/i.test(lastStatement)) {
    throw new Error(`${file}: schema_migrations deve ser registrado somente no último comando executável da migration.`)
  }
  console.log(`${file}: registro de schema_migrations ocorre após os demais comandos.`)
}
