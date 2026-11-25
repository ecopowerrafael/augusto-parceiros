import fs from 'node:fs'
import path from 'node:path'
import process from 'node:process'
import { describe, expect, it } from 'vitest'

const root = process.cwd()
const databaseName = 'u891593158_doc'
const manualFiles = [
  'database/updates/002_services_pricing_rules_precheck.sql',
  'database/updates/002_services_pricing_rules.sql',
  'database/updates/002_services_pricing_rules_verify.sql',
  'database/updates/003_complete_engine_service_seed_precheck.sql',
  'database/updates/003_complete_engine_service_seed.sql',
  'database/updates/003_complete_engine_service_seed_verify.sql',
  'database/updates/004_partner_commissions_precheck.sql',
  'database/updates/004_partner_commissions.sql',
  'database/updates/004_partner_commissions_verify.sql',
  'database/updates/005_application_settings_precheck.sql',
  'database/updates/005_application_settings.sql',
  'database/updates/005_application_settings_verify.sql',
  'database/install.sql',
  'database/verify.sql',
  'database/create-admin.sql',
  'database/verify-admin-approval.sql',
]

describe('SQL manual da Hostinger', () => {
  it('seleciona explicitamente o banco e não contém comandos destrutivos ou credenciais', () => {
    for (const relativePath of manualFiles) {
      const sql = fs.readFileSync(path.join(root, relativePath), 'utf8')
      const useStatement = 'USE `' + databaseName + '`;'
      expect(sql.startsWith(`--`)).toBe(true)
      expect(sql).toContain(useStatement)
      expect(sql.split(useStatement).length - 1).toBe(1)
      expect(sql).toContain('SELECT DATABASE() AS selected_database;')
      expect(sql).not.toMatch(/^\s*(DROP|TRUNCATE)\b/im)
      expect(sql).not.toMatch(/(?:password|secret|token|api[_-]?key)\s*[:=]\s*['"][^'"]+/i)
      expect(sql).not.toMatch(/\b(?:FROM|JOIN|INTO|UPDATE|REFERENCES)\s+`?(?:schema_migrations|users|services|billing_items|technical_rules)`?(?!\s*\.)/i)
      if (relativePath.includes('precheck') || relativePath.includes('verify')) expect(sql).toMatch(new RegExp(`table_schema\\s*=\\s*'${databaseName}'`, 'i'))
    }
  })

  it('qualifica referências das tabelas da aplicação nos SQLs manuais', () => {
    const sql = fs.readFileSync(path.join(root, 'database/updates/003_complete_engine_service_seed.sql'), 'utf8')
    expect(sql).toContain(`UPDATE \`${databaseName}\`.\`service_form_fields\``)
    expect(sql).toContain(`INSERT INTO \`${databaseName}\`.\`service_query_mappings\``)
    expect(sql).toContain(`INSERT INTO \`${databaseName}\`.\`schema_migrations\``)
    expect(sql).not.toMatch(/\b(?:FROM|JOIN|INTO|UPDATE|REFERENCES)\s+`?schema_migrations`?(?!\s*\.)/i)
    expect(sql).not.toMatch(/\b(?:FROM|JOIN|INTO|UPDATE|REFERENCES)\s+`?(?:services|users|billing_items|technical_rules)`?(?!\s*\.)/i)
  })

  it('mantém a migration canônica portável e o instalador completo atualizado', () => {
    const canonical = fs.readFileSync(path.join(root, 'migrations/003_complete_engine_service_seed.sql'), 'utf8')
    const canonical002 = fs.readFileSync(path.join(root, 'migrations/002_services_pricing_rules.sql'), 'utf8')
    const install = fs.readFileSync(path.join(root, 'database/install.sql'), 'utf8')
    expect(canonical).not.toContain(databaseName)
    expect(canonical002).not.toContain(databaseName)
    expect(install).toContain('003_complete_engine_service_seed.sql')
    expect(install).toContain("'PERCENT_VARIATION'")
    expect(install).toContain("'ITL_CSV_INSPECTION'")
  })
})
