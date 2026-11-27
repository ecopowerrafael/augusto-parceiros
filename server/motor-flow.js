import express from 'express'
import { z } from 'zod'
import { getDatabasePool } from './database.js'
import { requireCsrf, requireRole } from './auth.js'
import { evaluateService, normalizePlate } from './service-config.js'

export const MOTOR_IMPLEMENTATION = 'MOTOR_V1'
export const MOTOR_RULES_VERSION = 'motor-v1'

const condition = (field, operator, value, extra = {}) => ({ field, operator, ...(value === undefined ? {} : { value }), ...extra })

export const MOTOR_FIELDS = [
  { field_key: 'vehicle_target.plate', label: 'Placa do veículo', field_type: 'VEHICLE_PLATE', is_required: true, display_order: 10 },
  { field_key: 'vehicle_target.category', label: 'Categoria veicular', field_type: 'SINGLE_SELECT', is_required: true, display_order: 20 },
  { field_key: 'vehicle_target.state', label: 'UF do veículo', field_type: 'SINGLE_SELECT', is_required: true, display_order: 30 },
  { field_key: 'vehicle_target.power_cv', label: 'Potência original (CV)', field_type: 'DECIMAL', is_required: true, display_order: 40, visibility_condition: { field: 'vehicle_target.category', operator: 'NOT_EQUALS', value: 'MOTORCYCLE' } },
  { field_key: 'vehicle_target.engine_cc', label: 'Cilindrada original (cm³)', field_type: 'INTEGER', is_required: true, display_order: 50, visibility_condition: { field: 'vehicle_target.category', operator: 'NOT_EQUALS', value: 'MOTORCYCLE' } },
  { field_key: 'vehicle_target.fuel', label: 'Combustível original', field_type: 'SINGLE_SELECT', is_required: true, display_order: 60, visibility_condition: { field: 'vehicle_target.category', operator: 'NOT_EQUALS', value: 'MOTORCYCLE' } },
  { field_key: 'engine.has_invoice', label: 'O motor possui nota fiscal?', field_type: 'YES_NO', is_required: true, display_order: 70 },
  { field_key: 'engine.identification_mode', label: 'Como identificar o motor de origem?', field_type: 'SINGLE_SELECT', is_required: true, display_order: 80, visibility_condition: { field: 'vehicle_target.category', operator: 'NOT_EQUALS', value: 'MOTORCYCLE' } },
  { field_key: 'vehicle_donor.plate', label: 'Placa do veículo de origem', field_type: 'VEHICLE_PLATE', is_required: true, display_order: 90, visibility_condition: { all: [condition('vehicle_target.category', 'NOT_EQUALS', 'MOTORCYCLE'), condition('engine.identification_mode', 'EQUALS', 'PLATE')] } },
  { field_key: 'vehicle_donor.power_cv', label: 'Potência do motor (CV)', field_type: 'DECIMAL', is_required: true, display_order: 100, visibility_condition: { all: [condition('vehicle_target.category', 'NOT_EQUALS', 'MOTORCYCLE'), condition('engine.identification_mode', 'EQUALS', 'MANUAL')] } },
  { field_key: 'vehicle_donor.engine_cc', label: 'Cilindrada do motor (cm³)', field_type: 'INTEGER', is_required: true, display_order: 110, visibility_condition: { all: [condition('vehicle_target.category', 'NOT_EQUALS', 'MOTORCYCLE'), condition('engine.identification_mode', 'EQUALS', 'MANUAL')] } },
  { field_key: 'vehicle_donor.fuel', label: 'Combustível do motor', field_type: 'SINGLE_SELECT', is_required: true, display_order: 120, visibility_condition: { all: [condition('vehicle_target.category', 'NOT_EQUALS', 'MOTORCYCLE'), condition('engine.identification_mode', 'EQUALS', 'MANUAL')] } },
  { field_key: 'motorcycle.compatibility_declaration', label: 'Declaro que o motor possui a mesma cilindrada da motocicleta original.', description: 'Esta declaração permite uma análise preliminar e não garante aprovação oficial.', field_type: 'CHECKBOX', is_required: true, display_order: 130, visibility_condition: condition('vehicle_target.category', 'EQUALS', 'MOTORCYCLE') },
]

export const MOTOR_OPTIONS = {
  'vehicle_target.category': [{ value: 'MOTORCYCLE', label: 'Motocicleta' }, { value: 'AUTOMOBILE', label: 'Automóvel' }, { value: 'TRUCK', label: 'Caminhão' }, { value: 'BUS', label: 'Ônibus' }, { value: 'OTHER', label: 'Outra categoria' }],
  'vehicle_target.state': [{ value: 'SP', label: 'São Paulo' }, { value: 'OTHER_STATE', label: 'Outros estados' }],
  'engine.identification_mode': [{ value: 'PLATE', label: 'Consultar pela placa' }, { value: 'MANUAL', label: 'Informar dados manualmente' }, { value: 'UNKNOWN', label: 'Não sei informar' }],
  'vehicle_target.fuel': [{ value: 'ALCOHOL', label: 'Álcool' }, { value: 'GASOLINE', label: 'Gasolina' }, { value: 'DIESEL', label: 'Diesel' }, { value: 'FLEX', label: 'Flex' }],
  'vehicle_donor.fuel': [{ value: 'ALCOHOL', label: 'Álcool' }, { value: 'GASOLINE', label: 'Gasolina' }, { value: 'DIESEL', label: 'Diesel' }, { value: 'FLEX', label: 'Flex' }],
}

const MOTOR_RULES = [
  { name: 'Veículo fora de São Paulo', description: 'O veículo está registrado fora de São Paulo e precisa de análise individual.', conditions: condition('vehicle_target.state', 'NOT_EQUALS', 'SP'), expected_result: 'MANUAL_REVIEW', priority: 1 },
  { name: 'Motocicleta sem declaração de compatibilidade', description: 'A compatibilidade da cilindrada da motocicleta não foi confirmada.', vehicle_category_code: 'MOTORCYCLE', conditions: condition('motorcycle.compatibility_declaration', 'FALSE'), expected_result: 'MANUAL_REVIEW', priority: 2 },
  { name: 'Dados técnicos insuficientes', description: 'Os dados técnicos não foram informados em quantidade suficiente para análise automática.', conditions: { all: [condition('vehicle_target.category', 'IN_LIST', undefined, { values: ['AUTOMOBILE', 'TRUCK', 'BUS'] }), { any: [condition('vehicle_target.power_cv', 'EMPTY'), condition('vehicle_target.engine_cc', 'EMPTY'), condition('vehicle_target.fuel', 'EMPTY'), condition('vehicle_donor.power_cv', 'EMPTY'), condition('vehicle_donor.engine_cc', 'EMPTY'), condition('vehicle_donor.fuel', 'EMPTY')] }] }, expected_result: 'MANUAL_REVIEW', priority: 3 },
  { name: 'Motocicleta com compatibilidade declarada', description: 'Compatibilidade declarada para orçamento preliminar, sujeita à conferência documental.', vehicle_category_code: 'MOTORCYCLE', conditions: condition('motorcycle.compatibility_declaration', 'TRUE'), expected_result: 'VIABLE', priority: 10 },
  { name: 'Automóvel sem alteração', description: 'Mesma potência, cilindrada e combustível.', vehicle_category_code: 'AUTOMOBILE', conditions: { all: [condition('engine.power_variation_percent', 'EQUALS', 0), condition('engine.cylinder_variation_percent', 'EQUALS', 0), condition('vehicle_target.fuel', 'EQUALS', undefined, { valueField: 'vehicle_donor.fuel' })] }, expected_result: 'VIABLE', priority: 10 },
  { name: 'Caminhões e ônibus sem alteração', description: 'Mesma potência, cilindrada e combustível.', conditions: { all: [condition('vehicle_target.category', 'IN_LIST', undefined, { values: ['TRUCK', 'BUS'] }), condition('engine.power_variation_percent', 'EQUALS', 0), condition('engine.cylinder_variation_percent', 'EQUALS', 0), condition('vehicle_target.fuel', 'EQUALS', undefined, { valueField: 'vehicle_donor.fuel' })] }, expected_result: 'VIABLE', priority: 10 },
  { name: 'Automóvel com alteração dentro do limite', description: 'A alteração está dentro do limite operacional e exige solicitação de modificação.', vehicle_category_code: 'AUTOMOBILE', conditions: { all: [{ any: [condition('engine.power_variation_percent', 'NOT_EQUALS', 0), condition('engine.cylinder_variation_percent', 'NOT_EQUALS', 0), condition('vehicle_target.fuel', 'NOT_EQUALS', undefined, { valueField: 'vehicle_donor.fuel' })] }, { any: [condition('engine.power_variation_percent', 'EMPTY'), condition('engine.power_variation_percent', 'LESS_OR_EQUAL', 10)] }, { any: [condition('engine.cylinder_variation_percent', 'EMPTY'), condition('engine.cylinder_variation_percent', 'LESS_OR_EQUAL', 10)] }] }, expected_result: 'VIABLE_WITH_REQUIREMENTS', priority: 20 },
  { name: 'Caminhões e ônibus com alteração técnica', description: 'A alteração técnica será encaminhada com exigências para análise administrativa.', conditions: { all: [condition('vehicle_target.category', 'IN_LIST', undefined, { values: ['TRUCK', 'BUS'] }), { any: [condition('engine.power_variation_percent', 'NOT_EQUALS', 0), condition('engine.cylinder_variation_percent', 'NOT_EQUALS', 0), condition('vehicle_target.fuel', 'NOT_EQUALS', undefined, { valueField: 'vehicle_donor.fuel' })] }] }, expected_result: 'VIABLE_WITH_REQUIREMENTS', priority: 20 },
  { name: 'Cilindrada acima de 10%', description: 'Aumento de cilindrada superior a 10% está fora dos critérios automáticos.', vehicle_category_code: 'AUTOMOBILE', conditions: condition('engine.cylinder_variation_percent', 'GREATER_THAN', 10), expected_result: 'OUT_OF_CRITERIA', priority: 25 },
  { name: 'Potência acima de 10%', description: 'Aumento de potência superior a 10% está fora dos critérios automáticos.', vehicle_category_code: 'AUTOMOBILE', conditions: condition('engine.power_variation_percent', 'GREATER_THAN', 10), expected_result: 'OUT_OF_CRITERIA', priority: 25 },
  { name: 'Categoria sem regra específica', description: 'A categoria informada ainda precisa de análise manual.', conditions: condition('vehicle_target.category', 'NOT_IN_LIST', undefined, { values: ['AUTOMOBILE', 'MOTORCYCLE', 'TRUCK', 'BUS'] }), expected_result: 'MANUAL_REVIEW', priority: 90 },
]

const MOTOR_DOCUMENTS = [
  { document_code: 'VEHICLE_REGISTRATION', name: 'CRLV (Documento do veículo)', requirement_type: 'REQUIRED' },
  { document_code: 'OWNER_IDENTIFICATION', name: 'Documento de identificação do proprietário', requirement_type: 'REQUIRED' },
  { document_code: 'INSPECTION_REPORT', name: 'Laudo de vistoria', requirement_type: 'REQUIRED' },
  { document_code: 'ENGINE_INVOICE', name: 'Nota fiscal do motor', requirement_type: 'CONDITIONAL', condition_expression: condition('engine.has_invoice', 'EQUALS', 'YES') },
]
const MOTOR_MESSAGES = [{ message_key: 'DISCLAIMER', severity: 'INFO', content: 'Este resultado é orientativo e não representa garantia de aprovação pelo Detran.' }]

const motorRequestSchema = z.object({ answers: z.record(z.unknown()).default({}), fixtureContext: z.record(z.unknown()).default({}) }).strict()

export function motorFormDefinition() { return { implementation: MOTOR_IMPLEMENTATION, rulesVersion: MOTOR_RULES_VERSION, version: 1, service: { code: 'ENGINE_REGISTRATION', name: 'Cadastro de motor' }, fields: MOTOR_FIELDS, options: MOTOR_OPTIONS, externalCalls: 0 } }

export async function loadMotorCommercialConfig(pool = getDatabasePool()) {
  const [rows] = await pool.execute(`SELECT sbi.*, bi.code, bi.name, bi.description, bi.default_amount_cents, bi.amount_status, bi.charge_nature, bi.payment_mode, bi.status AS item_status FROM service_billing_items sbi JOIN billing_items bi ON bi.id = sbi.billing_item_id JOIN service_versions v ON v.id = sbi.service_version_id JOIN services s ON s.id = v.service_id WHERE s.code = 'ENGINE_REGISTRATION' AND sbi.visible_to_client = 1 AND v.version_number = (SELECT MAX(latest.version_number) FROM service_versions latest WHERE latest.service_id = s.id) ORDER BY sbi.display_order, bi.name`)
  return rows
}

export function evaluateMotor({ answers, billingItems = [], fixtureContext = {} }) {
  const input = { ...fixtureContext, ...answers }
  const category = String(input['vehicle_target.category'] || '').toUpperCase()
  if (category === 'MOTORCYCLE') { input['motorcycle.compatibility_declaration'] = input['motorcycle.compatibility_declaration'] === true; delete input['engine.identification_mode'] } else if (String(input['engine.identification_mode'] || '').toUpperCase() === 'UNKNOWN') { for (const key of Object.keys(input)) if (key.startsWith('vehicle_donor.')) delete input[key] }
  if (String(input['engine.identification_mode'] || '').toUpperCase() === 'MANUAL') delete input['vehicle_donor.plate']
  const normalized = normalizePlate(input['vehicle_target.plate'])
  if (normalized.pattern !== 'UNKNOWN') input['vehicle_target.plate_pattern'] = normalized.pattern
  const targetPower = Number(input['vehicle_target.power_cv']); const donorPower = Number(input['vehicle_donor.power_cv']); const targetCc = Number(input['vehicle_target.engine_cc']); const donorCc = Number(input['vehicle_donor.engine_cc'])
  if (Number.isFinite(targetPower) && Number.isFinite(donorPower) && targetPower !== 0) input['engine.power_variation_percent'] = (donorPower - targetPower) / targetPower * 100
  if (Number.isFinite(targetCc) && Number.isFinite(donorCc) && targetCc !== 0) input['engine.cylinder_variation_percent'] = (donorCc - targetCc) / targetCc * 100
  const fields = MOTOR_FIELDS.map((field) => ({ ...field, id: field.field_key, field_type: field.field_type }))
  const options = Object.entries(MOTOR_OPTIONS).flatMap(([fieldKey, values]) => values.map((option, index) => ({ id: `${fieldKey}-${index}`, field_id: fieldKey, field_key: fieldKey, option_value: option.value, option_label: option.label })))
  const rules = MOTOR_RULES.map((rule) => ({ ...rule, expected_result: rule.expected_result, vehicle_category_code: rule.vehicle_category_code }))
  return evaluateService({ fields, options, billingItems, rules, documents: MOTOR_DOCUMENTS, messages: MOTOR_MESSAGES, answers: input })
}

async function manualContact(pool) { try { const [rows] = await pool.execute('SELECT manual_whatsapp, manual_team_name, manual_message_template FROM application_settings WHERE id = ? LIMIT 1', ['55000000-0000-4000-8000-000000000001']); return rows[0] || null } catch (error) { if (['ER_NO_SUCH_COLUMN', 'ER_NO_SUCH_TABLE'].includes(error.code)) return null; throw error } }

export function createMotorRouter({ databaseRequired, activeAccount, role }) {
  const router = express.Router(); router.use(databaseRequired); router.use(requireRole(role)); if (role === 'PARTNER') router.use(activeAccount)
  const asyncRoute = (handler) => (request, response, next) => Promise.resolve(handler(request, response, next)).catch(next)
  const authorizedService = async () => { const pool = getDatabasePool(); const [rows] = await pool.execute(`SELECT s.id FROM services s WHERE s.code = 'ENGINE_REGISTRATION' AND s.is_active = 1 ${role === 'PARTNER' ? "AND s.available_to_partner = 1 AND EXISTS (SELECT 1 FROM service_versions v WHERE v.service_id = s.id AND v.status = 'PUBLISHED')" : ''} LIMIT 1`); return rows[0] }
  router.get('/definition', asyncRoute(async (_request, response) => { if (!(await authorizedService())) return response.status(404).json({ error: 'SERVICE_NOT_AVAILABLE' }); response.json(motorFormDefinition()) }))
  router.post('/simulate', requireCsrf, asyncRoute(async (request, response) => { const parsed = motorRequestSchema.safeParse(request.body || {}); if (!parsed.success) return response.status(400).json({ error: 'INVALID_SIMULATION_INPUT' }); if (!(await authorizedService())) return response.status(404).json({ error: 'SERVICE_NOT_AVAILABLE' }); try { const pool = getDatabasePool(); const billingItems = await loadMotorCommercialConfig(pool); const result = evaluateMotor({ ...parsed.data, billingItems }); response.json({ result, implementation: MOTOR_IMPLEMENTATION, rulesVersion: MOTOR_RULES_VERSION, externalCalls: 0, manualContact: role === 'ADMINISTRATOR' ? await manualContact(pool) : null }) } catch (error) { if (error.code === 'INVALID_SIMULATION_INPUT') return response.status(422).json({ error: error.code, details: error.details }); throw error } }))
  return router
}
