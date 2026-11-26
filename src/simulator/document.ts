import { PDFDocument, StandardFonts, rgb } from 'pdf-lib'

type DocumentItem = { code?: unknown; name?: unknown; quantity?: unknown; total_cents?: unknown; amount_status?: unknown; amountStatus?: unknown }
type SimulationDocument = { serviceName: string; viability: string; values: Record<string, unknown>; fields: Array<Record<string, unknown>>; items: DocumentItem[]; documents?: Array<Record<string, unknown>>; missing_amount_items?: unknown[]; total_cents?: unknown; simulated?: boolean }

const money = (value: unknown) => `R$ ${(Number(value || 0) / 100).toFixed(2).replace('.', ',')}`
const label = (value: unknown) => String(value || '').replaceAll('.', ' ').replaceAll('_', ' ')
const viabilityLabel: Record<string, string> = { VIABLE: 'Viável', VIABLE_WITH_REQUIREMENTS: 'Viável com exigências', MANUAL_REVIEW: 'Análise manual necessária', OUT_OF_CRITERIA: 'Fora dos critérios', UNCLASSIFIED: 'Resultado não classificado' }

export async function generateSimulationPdf(document: SimulationDocument) {
  const pdf = await PDFDocument.create()
  const font = await pdf.embedFont(StandardFonts.Helvetica)
  const bold = await pdf.embedFont(StandardFonts.HelveticaBold)
  let page = pdf.addPage([595.28, 841.89])
  let y = 790
  const margin = 48
  const nextPage = () => { page = pdf.addPage([595.28, 841.89]); y = 790 }
  const line = (text: string, isBold = false, size = 10) => { if (y < 58) nextPage(); page.drawText(text.slice(0, 105), { x: margin, y, size, font: isBold ? bold : font, color: rgb(0.09, 0.12, 0.18) }); y -= size + 7 }
  line('DOC MOTOR', true, 20)
  line('SIMULAÇÃO - SEM VALIDADE COMERCIAL', true, 11)
  line(document.serviceName, true, 15)
  line(`Resultado: ${viabilityLabel[document.viability] || document.viability}`, true, 11)
  y -= 8
  line('Dados informados e calculados', true, 12)
  for (const field of document.fields) { const key = String(field.field_key || ''); const value = document.values[key]; if (value !== undefined && value !== null && value !== '') line(`${String(field.label || label(key))}: ${String(value)}`) }
  y -= 8
  line('Cobranças', true, 12)
  for (const item of document.items) line(`${String(item.name || item.code || 'Item')} — ${Number(item.total_cents) >= 0 ? money(item.total_cents) : 'Valor a confirmar'}`)
  line(`Subtotal conhecido: ${money(document.total_cents)}`, true, 11)
  if (document.missing_amount_items?.length) line('Existem custos adicionais ainda não definidos; eles não foram considerados gratuitos.')
  if (document.documents?.length) { y -= 8; line('Documentos necessários', true, 12); for (const item of document.documents) line(`• ${String(item.name || item.document_code || 'Documento')}`) }
  y -= 12
  line('A análise é orientativa e não representa garantia de aprovação pelo Detran.', false, 9)
  line(`Emitido em ${new Date().toLocaleString('pt-BR')}`, false, 9)
  const bytes = await pdf.save()
  const buffer = new ArrayBuffer(bytes.byteLength)
  new Uint8Array(buffer).set(bytes)
  return new Blob([buffer], { type: 'application/pdf' })
}
