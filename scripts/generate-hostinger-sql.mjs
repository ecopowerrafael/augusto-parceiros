import fs from 'node:fs/promises'
import path from 'node:path'
import process from 'node:process'

const databaseName = process.argv[2] || 'u891593158_doc'
const outputDirectory = path.resolve(process.argv[3] || 'database/updates')
if (!/^[A-Za-z0-9_]+$/.test(databaseName)) throw new Error('Nome de banco inválido: use somente letras, números e underscore.')

const root = process.cwd()
const quoteDatabase = `\`${databaseName}\``
const applicationTables = new Set([
  'schema_migrations', 'users', 'partner_companies', 'company_members', 'client_profiles', 'sessions', 'password_reset_tokens', 'rate_limit_events', 'audit_logs',
  'brazilian_states', 'vehicle_categories', 'services', 'service_vehicle_categories', 'service_ufs', 'service_relations', 'service_versions', 'service_form_sections', 'service_form_fields', 'service_field_options', 'service_data_sources', 'service_external_queries', 'service_query_mappings', 'price_tables', 'billing_items', 'service_prices', 'service_price_components', 'service_billing_items', 'technical_rules', 'technical_rule_actions', 'technical_rule_services', 'service_documents', 'service_messages', 'commission_settings', 'partner_commission_overrides', 'application_settings',
])

function qualifyCode(code) {
  const placeholders = []
  const protectBackticks = (match, offset, source) => {
    const name = match.slice(1, -1)
    if (!applicationTables.has(name)) return match
    if (offset > 0 && source[offset - 1] === '.') return match
    const token = `__IDENTIFIER_${placeholders.length}__`
    placeholders.push(`${quoteDatabase}.\`${name}\``)
    return token
  }
  let transformed = code.replace(/`[^`]*`/g, protectBackticks)
  const names = [...applicationTables].sort((a, b) => b.length - a.length).join('|')
  transformed = transformed.replace(new RegExp(`(?<![.A-Za-z0-9_])(?:${names})(?![A-Za-z0-9_])`, 'g'), (name) => `${quoteDatabase}.\`${name}\``)
  transformed = transformed.replace(/__IDENTIFIER_(\d+)__/g, (_match, index) => placeholders[Number(index)])
  return transformed.replace(/`?table_schema`?\s*=\s*DATABASE\(\)/gi, `table_schema = '${databaseName}'`)
}

function qualifySql(sql) {
  let result = ''
  let chunk = ''
  let index = 0
  const flush = () => { result += qualifyCode(chunk); chunk = '' }
  while (index < sql.length) {
    const current = sql[index]
    const next = sql[index + 1]
    if (current === "'" || current === '"') {
      flush(); const quote = current; let end = index + 1
      while (end < sql.length) { if (sql[end] === '\\') { end += 2; continue } if (sql[end] === quote && sql[end + 1] !== quote) { end += 1; break } end += 1 }
      result += sql.slice(index, end); index = end; continue
    }
    if (current === '-' && next === '-') {
      flush(); const end = sql.indexOf('\n', index); const stop = end === -1 ? sql.length : end
      result += sql.slice(index, stop); index = stop; continue
    }
    if (current === '/' && next === '*') {
      flush(); const end = sql.indexOf('*/', index + 2); const stop = end === -1 ? sql.length : end + 2
      result += sql.slice(index, stop); index = stop; continue
    }
    chunk += current; index += 1
  }
  flush(); return result
}

function header(description) { return `-- ${description}\n-- Gerado por scripts/generate-hostinger-sql.mjs.\n-- Banco alvo: ${databaseName}.\n-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente.\n\nUSE ${quoteDatabase};\nSELECT DATABASE() AS selected_database;\n\n` }
async function read(relativePath) { return fs.readFile(path.join(root, relativePath), 'utf8') }
async function write(relativePath, content) { const target = path.isAbsolute(relativePath) ? relativePath : path.join(root, relativePath); await fs.mkdir(path.dirname(target), { recursive: true }); await fs.writeFile(target, content.trimEnd() + '\n', 'utf8') }

const migration002 = await read('migrations/002_services_pricing_rules.sql')
const migration003 = await read('migrations/003_complete_engine_service_seed.sql')
const migration004 = await read('migrations/004_partner_commissions.sql')
const migration005 = await read('migrations/005_application_settings.sql')
const migration006 = await read('migrations/006_simulator_input_normalization.sql')
const migration007 = await read('migrations/007_engine_rules_and_documents.sql')
const migration008 = await read('migrations/008_motorcycle_visibility_consistency.sql')
const precheck007 = await read('database/hostinger/007_engine_rules_and_documents_precheck.source.sql')
const verify007 = await read('database/hostinger/007_engine_rules_and_documents_verify.source.sql')
const precheck008 = await read('database/hostinger/008_motorcycle_visibility_consistency_precheck.source.sql')
const verify008 = await read('database/hostinger/008_motorcycle_visibility_consistency_verify.source.sql')
const migration001 = await read('migrations/001_initial.sql')
const precheck005 = `-- Pré-verificação somente leitura da Migration 005.\n\nSELECT VERSION() AS mysql_version;\nSELECT COUNT(*) AS migration_005_already_registered FROM schema_migrations WHERE name = '005_application_settings.sql';\nSELECT COUNT(*) AS required_base_tables_present FROM information_schema.tables WHERE table_schema = '${databaseName}' AND table_name IN ('users', 'schema_migrations');\nSELECT COUNT(*) AS application_settings_present FROM information_schema.tables WHERE table_schema = '${databaseName}' AND table_name = 'application_settings';`
const verify005 = `-- Verificação posterior somente leitura da Migration 005.\n\nSELECT VERSION() AS mysql_version;\nSELECT COUNT(*) AS migration_005_count FROM schema_migrations WHERE name = '005_application_settings.sql';\nSELECT COUNT(*) AS application_settings_count FROM information_schema.tables WHERE table_schema = '${databaseName}' AND table_name = 'application_settings';\nSELECT id, company_name, timezone FROM application_settings WHERE id = '55000000-0000-4000-8000-000000000001';`

const schemaMigrations = `CREATE TABLE IF NOT EXISTS schema_migrations (name VARCHAR(255) NOT NULL PRIMARY KEY, applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;`
const migration001Registration = `INSERT INTO schema_migrations (name)\nSELECT '001_initial.sql'\nFROM information_schema.tables\nWHERE table_schema = '${databaseName}'\n  AND table_name IN ('users', 'partner_companies', 'company_members', 'client_profiles', 'sessions', 'password_reset_tokens', 'rate_limit_events', 'audit_logs')\nGROUP BY table_schema\nHAVING COUNT(*) = 8\n   AND NOT EXISTS (SELECT 1 FROM schema_migrations WHERE name = '001_initial.sql');`
const installSource = `${schemaMigrations}\n\n${migration001}\n\n-- Registra a migration somente se as oito tabelas da Fase 2 existirem.\n${migration001Registration}\n\n${migration002}\n\n${migration003}\n\n${migration004}\n\n${migration005}\n\n${migration006}\n\n${migration007}\n\n${migration008}`
// Os artefatos 002–004 já foram validados e publicados; não os reescrevemos para evitar
// qualificação cumulativa quando o gerador é executado novamente.
await write(path.join(outputDirectory, '005_application_settings_precheck.sql'), header('Pré-verificação da Migration 005') + qualifySql(precheck005))
await write(path.join(outputDirectory, '005_application_settings.sql'), header('Atualização da Migration 005') + qualifySql(migration005))
await write(path.join(outputDirectory, '005_application_settings_verify.sql'), header('Verificação da Migration 005') + qualifySql(verify005))
// O pacote 006 já foi gerado e validado; não o reescrevemos, pois seus artefatos
// publicados já possuem referências qualificadas e uma segunda qualificação seria cumulativa.
await write(path.join(outputDirectory, '007_engine_rules_and_documents_precheck.sql'), header('Pré-verificação da Migration 007') + qualifySql(precheck007))
await write(path.join(outputDirectory, '007_engine_rules_and_documents.sql'), header('Atualização da Migration 007') + qualifySql(migration007))
await write(path.join(outputDirectory, '007_engine_rules_and_documents_verify.sql'), header('Verificação da Migration 007') + qualifySql(verify007))
await write(path.join(outputDirectory, '008_motorcycle_visibility_consistency_precheck.sql'), header('Pré-verificação da Migration 008') + qualifySql(precheck008))
await write(path.join(outputDirectory, '008_motorcycle_visibility_consistency.sql'), header('Atualização da Migration 008') + qualifySql(migration008))
await write(path.join(outputDirectory, '008_motorcycle_visibility_consistency_verify.sql'), header('Verificação da Migration 008') + qualifySql(verify008))
await write('database/install.sql', header('Instalação completa da estrutura Doc Motor') + qualifySql(installSource))
process.stdout.write(`SQLs Hostinger gerados para ${databaseName} em ${outputDirectory}\n`)
