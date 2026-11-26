import { describe, expect, it } from 'vitest'
import { loadEditor } from './services.js'

function createEditorPool() {
  const calls = []
  return {
    calls,
    async query(sql) {
      calls.push(sql)
      if (sql.includes('FROM service_versions v')) return [[{ id: 'version-1', service_id: 'service-1', service_name: 'Cadastro de motor' }], []]
      if (sql.includes('FROM service_form_sections')) return [[{ id: 'section-1', service_version_id: 'version-1', label: 'Veículo' }], []]
      if (sql.includes('FROM service_form_fields')) return [[{ id: 'field-1', service_version_id: 'version-1', field_key: 'vehicle_target.category', field_type: 'SINGLE_SELECT', is_required: 0 }], []]
      if (sql.includes('FROM service_field_options')) return [[{ id: 'option-1', field_id: 'field-1', option_value: 'AUTOMOBILE', option_label: 'Automóvel' }], []]
      if (sql.includes('FROM service_billing_items')) return [[{ id: 'billing-1', service_version_id: 'version-1', code: 'ENGINE_REGISTRATION', billing_mode: 'REQUIRED', default_amount_cents: 1000 }], []]
      if (sql.includes('FROM technical_rules r')) return [[{ id: 'rule-1', service_version_id: 'version-1', name: 'Regra equivalente', conditions: '{"field":"vehicle_target.category","operator":"EQUALS","value":"AUTOMOBILE"}', expected_result: 'VIABLE', priority: 10, vehicle_category_code: 'AUTOMOBILE' }], []]
      if (sql.includes('FROM service_documents')) return [[{ id: 'document-1', service_version_id: 'version-1', document_code: 'VEHICLE_REGISTRATION', requirement_type: 'REQUIRED' }], []]
      if (sql.includes('FROM service_messages')) return [[{ id: 'message-1', service_version_id: 'version-1', message_key: 'NOTE', content: 'Mensagem' }], []]
      if (sql.includes('FROM service_external_queries')) return [[], []]
      if (sql.includes('FROM technical_rule_actions')) return [[{ id: 'action-1', technical_rule_id: 'rule-1', action_type: 'SHOW_GUIDANCE', target_key: null, payload: '{}' }], []]
      throw new Error(`Consulta não prevista no teste: ${sql}`)
    },
  }
}

describe('carregamento do editor de serviços', () => {
  it('carrega versão, campos, cobranças, regras, ações, documentos e mensagens em um contrato completo', async () => {
    const pool = createEditorPool()
    const editor = await loadEditor('version-1', 'test-request', pool)
    expect(editor.version.service_id).toBe('service-1')
    expect(editor.fields).toHaveLength(1)
    expect(editor.options).toHaveLength(1)
    expect(editor.billingItems[0].code).toBe('ENGINE_REGISTRATION')
    expect(editor.rules[0].actions[0].action_type).toBe('SHOW_GUIDANCE')
    expect(editor.documents).toHaveLength(1)
    expect(editor.messages).toHaveLength(1)
    expect(pool.calls.some((sql) => sql.includes('JSON_ARRAYAGG'))).toBe(false)
  })

  it('propaga a falha SQL para o wrapper da rota registrar como erro controlado', async () => {
    const pool = { query: async () => { const error = new Error('database unavailable'); error.code = 'ER_CON_COUNT_ERROR'; throw error } }
    await expect(loadEditor('version-1', 'test-request', pool)).rejects.toMatchObject({ code: 'ER_CON_COUNT_ERROR' })
  })
})
