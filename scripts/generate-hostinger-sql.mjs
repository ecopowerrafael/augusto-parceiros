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
  'brazilian_states', 'vehicle_categories', 'services', 'service_vehicle_categories', 'service_ufs', 'service_relations', 'service_versions', 'service_form_sections', 'service_form_fields', 'service_field_options', 'service_data_sources', 'service_external_queries', 'service_query_mappings', 'price_tables', 'billing_items', 'service_prices', 'service_price_components', 'service_billing_items', 'technical_rules', 'technical_rule_actions', 'technical_rule_services', 'service_documents', 'service_messages', 'commission_settings', 'partner_commission_overrides',
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
function stripManualEnvelope(sql) {
  const envelope = /-- (?:Instalação completa da estrutura Doc Motor|Pré-verificação da Migration \d+|Atualização da Migration \d+|Verificação da Migration \d+)[^\r\n]*\r?\n-- Gerado por scripts\/generate-hostinger-sql\.mjs\.[^\r\n]*\r?\n-- Banco alvo: [^\r\n]*\r?\n-- Importação manual pelo phpMyAdmin; não executar migrations antigas novamente\.\r?\n\r?\nUSE `[^`]+`;\r?\n(?:SELECT DATABASE\(\) AS selected_database;\r?\n)?\r?\n/g
  return sql.replace(envelope, '')
}
async function read(relativePath) { return fs.readFile(path.join(root, relativePath), 'utf8') }
async function write(relativePath, content) { const target = path.isAbsolute(relativePath) ? relativePath : path.join(root, relativePath); await fs.mkdir(path.dirname(target), { recursive: true }); await fs.writeFile(target, content.trimEnd() + '\n', 'utf8') }

const migration002 = await read('migrations/002_services_pricing_rules.sql')
const migration003 = await read('migrations/003_complete_engine_service_seed.sql')
const migration004 = await read('migrations/004_partner_commissions.sql')
const migration001 = await read('migrations/001_initial.sql')
const precheck002 = stripManualEnvelope(await read('database/updates/002_services_pricing_rules_precheck.sql'))
const verify002 = stripManualEnvelope(await read('database/updates/002_services_pricing_rules_verify.sql'))
const precheck003 = `-- Pré-verificação somente leitura da Migration 003.\n\nSELECT DATABASE() AS selected_database;\nSELECT VERSION() AS mysql_version;\nSELECT COUNT(*) AS migration_003_already_registered FROM schema_migrations WHERE name = '003_complete_engine_service_seed.sql';\nSELECT COUNT(*) AS required_tables_present FROM information_schema.tables WHERE table_schema = '${databaseName}' AND table_name IN ('services', 'service_versions', 'service_form_fields', 'service_field_options', 'service_data_sources', 'service_external_queries', 'service_query_mappings', 'billing_items', 'service_billing_items', 'technical_rules', 'technical_rule_actions', 'schema_migrations');\nSELECT COUNT(*) AS compatible_columns_present FROM information_schema.columns WHERE table_schema = '${databaseName}' AND ((table_name = 'service_form_fields' AND column_name IN ('calculation', 'visibility_condition', 'data_origin')) OR (table_name = 'service_external_queries' AND column_name IN ('source_id', 'plate_field_key')) OR (table_name = 'service_query_mappings' AND column_name IN ('target_field_key', 'normalized_path')));\nSELECT COUNT(*) AS motor_version_present FROM service_versions WHERE id = '33000000-0000-4000-8000-000000000001';\nSELECT COUNT(*) AS existing_uf_options FROM service_field_options WHERE field_id = '36000000-0000-4000-8000-000000000003';\nSELECT COUNT(*) AS existing_external_queries FROM service_external_queries WHERE service_version_id = '33000000-0000-4000-8000-000000000001';`
const verify003 = `-- Verificação posterior somente leitura da Migration 003.\n\nSELECT DATABASE() AS selected_database;\nSELECT VERSION() AS mysql_version;\nSELECT COUNT(*) AS migration_003_count FROM schema_migrations WHERE name = '003_complete_engine_service_seed.sql';\nSELECT table_name AS expected_table FROM information_schema.tables WHERE table_schema = '${databaseName}' AND table_name IN ('services', 'service_versions', 'service_form_fields', 'service_field_options', 'service_data_sources', 'service_external_queries', 'service_query_mappings', 'billing_items', 'service_billing_items', 'technical_rules', 'technical_rule_actions', 'schema_migrations') ORDER BY table_name;\nSELECT COUNT(*) AS expected_table_count FROM information_schema.tables WHERE table_schema = '${databaseName}' AND table_name IN ('services', 'service_versions', 'service_form_fields', 'service_field_options', 'service_data_sources', 'service_external_queries', 'service_query_mappings', 'billing_items', 'service_billing_items', 'technical_rules', 'technical_rule_actions', 'schema_migrations');\nSELECT COUNT(*) AS uf_option_count FROM service_field_options WHERE field_id = '36000000-0000-4000-8000-000000000003';\nSELECT COUNT(*) AS external_query_count FROM service_external_queries WHERE service_version_id = '33000000-0000-4000-8000-000000000001';\nSELECT COUNT(*) AS query_mapping_count FROM service_query_mappings WHERE query_id IN (SELECT id FROM service_external_queries WHERE service_version_id = '33000000-0000-4000-8000-000000000001');\nSELECT COUNT(*) AS engine_calculation_count FROM service_form_fields WHERE id = '36000000-0000-4000-8000-000000000013' AND calculation IS NOT NULL;\nSELECT COUNT(*) AS csv_catalog_count FROM billing_items WHERE code = 'ITL_CSV_INSPECTION';\nSELECT COUNT(*) AS technical_rule_count FROM technical_rules WHERE service_version_id = '33000000-0000-4000-8000-000000000001';\nSELECT COUNT(*) AS invalid_query_sources FROM service_external_queries q LEFT JOIN service_data_sources s ON s.id = q.source_id WHERE q.service_version_id = '33000000-0000-4000-8000-000000000001' AND s.id IS NULL;\nSELECT COUNT(*) AS invalid_query_mappings FROM service_query_mappings m LEFT JOIN service_external_queries q ON q.id = m.query_id WHERE q.id IS NULL;\nSELECT COUNT(*) AS invalid_rule_versions FROM technical_rules r LEFT JOIN service_versions v ON v.id = r.service_version_id WHERE r.service_version_id IS NOT NULL AND v.id IS NULL;`
const precheck004 = `-- Pré-verificação somente leitura da Migration 004.\n\nSELECT VERSION() AS mysql_version;\nSELECT COUNT(*) AS migration_004_already_registered FROM schema_migrations WHERE name = '004_partner_commissions.sql';\nSELECT COUNT(*) AS required_tables_present FROM information_schema.tables WHERE table_schema = '${databaseName}' AND table_name IN ('users', 'partner_companies', 'schema_migrations');\nSELECT COUNT(*) AS administrator_count FROM users WHERE role = 'ADMINISTRATOR';`
const verify004 = `-- Verificação posterior somente leitura da Migration 004.\n\nSELECT VERSION() AS mysql_version;\nSELECT COUNT(*) AS migration_004_count FROM schema_migrations WHERE name = '004_partner_commissions.sql';\nSELECT table_name FROM information_schema.tables WHERE table_schema = '${databaseName}' AND table_name IN ('commission_settings', 'partner_commission_overrides') ORDER BY table_name;\nSELECT default_model, default_percentage, default_fixed_amount_cents, honorarium_only FROM commission_settings WHERE id = '45000000-0000-4000-8000-000000000001';\nSELECT COUNT(*) AS invalid_partner_overrides FROM partner_commission_overrides o LEFT JOIN partner_companies p ON p.id = o.partner_company_id WHERE p.id IS NULL;`

const schemaMigrations = `CREATE TABLE IF NOT EXISTS schema_migrations (name VARCHAR(255) NOT NULL PRIMARY KEY, applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;`
const migration001Registration = `INSERT INTO schema_migrations (name)\nSELECT '001_initial.sql'\nFROM information_schema.tables\nWHERE table_schema = '${databaseName}'\n  AND table_name IN ('users', 'partner_companies', 'company_members', 'client_profiles', 'sessions', 'password_reset_tokens', 'rate_limit_events', 'audit_logs')\nGROUP BY table_schema\nHAVING COUNT(*) = 8\n   AND NOT EXISTS (SELECT 1 FROM schema_migrations WHERE name = '001_initial.sql');`
const installSource = `${schemaMigrations}\n\n${migration001}\n\n-- Registra a migration somente se as oito tabelas da Fase 2 existirem.\n${migration001Registration}\n\n${migration002}\n\n${migration003}\n\n${migration004}`
await write(path.join(outputDirectory, '002_services_pricing_rules_precheck.sql'), header('Pré-verificação da Migration 002') + qualifySql(precheck002))
await write(path.join(outputDirectory, '002_services_pricing_rules.sql'), header('Atualização da Migration 002') + qualifySql(migration002))
await write(path.join(outputDirectory, '002_services_pricing_rules_verify.sql'), header('Verificação da Migration 002') + qualifySql(verify002))
await write(path.join(outputDirectory, '003_complete_engine_service_seed_precheck.sql'), header('Pré-verificação da Migration 003') + qualifySql(precheck003))
await write(path.join(outputDirectory, '003_complete_engine_service_seed.sql'), header('Atualização da Migration 003') + qualifySql(migration003))
await write(path.join(outputDirectory, '003_complete_engine_service_seed_verify.sql'), header('Verificação da Migration 003') + qualifySql(verify003))
await write(path.join(outputDirectory, '004_partner_commissions_precheck.sql'), header('Pré-verificação da Migration 004') + qualifySql(precheck004))
await write(path.join(outputDirectory, '004_partner_commissions.sql'), header('Atualização da Migration 004') + qualifySql(migration004))
await write(path.join(outputDirectory, '004_partner_commissions_verify.sql'), header('Verificação da Migration 004') + qualifySql(verify004))
await write('database/install.sql', header('Instalação completa da estrutura Doc Motor') + qualifySql(installSource))
process.stdout.write(`SQLs Hostinger gerados para ${databaseName} em ${outputDirectory}\n`)
