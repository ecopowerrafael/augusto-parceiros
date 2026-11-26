import { PDFDocument, StandardFonts, rgb } from 'pdf-lib'

type DocumentItem = { code?: unknown; name?: unknown; total_cents?: unknown }
export type SimulationDocument = { serviceName: string; viability: string; values: Record<string, unknown>; fields: Array<Record<string, unknown>>; items: DocumentItem[]; documents?: Array<Record<string, unknown>>; missing_amount_items?: unknown[]; total_cents?: unknown; simulated?: boolean; budgetId?: string; responsibleUserCode?: string; partnerPhone?: string; platformPhone?: string; issuedAt?: string }
const money = (value: unknown) => `R$ ${(Number(value || 0) / 100).toFixed(2).replace('.', ',')}`
const label = (value: unknown) => String(value || '').replaceAll('.', ' · ').replaceAll('_', ' ')
const viabilityLabel: Record<string, string> = { VIABLE: 'Viável', VIABLE_WITH_REQUIREMENTS: 'Viável com exigências', MANUAL_REVIEW: 'Análise manual necessária', OUT_OF_CRITERIA: 'Fora dos critérios', UNCLASSIFIED: 'Resultado não classificado' }

export async function generateSimulationPdf(document: SimulationDocument) {
  const pdf = await PDFDocument.create(); const font = await pdf.embedFont(StandardFonts.Helvetica); const bold = await pdf.embedFont(StandardFonts.HelveticaBold); const red = rgb(0.78, 0.04, 0.08); const dark = rgb(0.08, 0.09, 0.11); const muted = rgb(0.35, 0.37, 0.4)
  let page = pdf.addPage([595.28, 841.89]); let y = 785; const margin = 42; const width = 511
  const nextPage = () => { page = pdf.addPage([595.28, 841.89]); y = 785 }
  const text = (value: string, size = 9, isBold = false, color = dark) => { if (y < 70) nextPage(); page.drawText(value.slice(0, 110), { x: margin, y, size, font: isBold ? bold : font, color }); y -= size + 6 }
  const section = (title: string) => { if (y < 105) nextPage(); page.drawRectangle({ x: margin, y: y - 5, width, height: 20, color: dark }); page.drawText(title, { x: margin + 8, y, size: 10, font: bold, color: rgb(1, 1, 1) }); y -= 31 }
  try { const response = await fetch('/assets/brand/doc-motor-logo-retangular.png'); if (response.ok) { const image = await pdf.embedPng(await response.arrayBuffer()); const scale = Math.min(145 / image.width, 42 / image.height); page.drawImage(image, { x: margin, y: y - image.height * scale + 10, width: image.width * scale, height: image.height * scale }) } } catch { /* offline preview can omit the logo */ }
  page.drawText('DOCUMENTAÇÃO VEICULAR', { x: 398, y: y + 17, size: 8, font: bold, color: muted }); y -= 52; page.drawLine({ start: { x: margin, y }, end: { x: margin + width, y }, thickness: 2, color: red }); y -= 24
  text(document.simulated ? 'SIMULAÇÃO — SEM VALIDADE COMERCIAL' : 'ORÇAMENTO COMERCIAL', 10, true, red); text(document.serviceName, 17, true); text(`Resultado: ${viabilityLabel[document.viability] || document.viability}`, 10, true)
  text(`Identificação: ${document.budgetId || 'SIMULAÇÃO'} · Responsável: ${document.responsibleUserCode || 'ADMIN'}` , 8, false, muted); text(`Emissão: ${document.issuedAt || new Date().toLocaleString('pt-BR')}`, 8, false, muted); y -= 6
  section('DADOS DO VEÍCULO E DO MOTOR'); for (const field of document.fields) { const key = String(field.field_key || ''); const value = document.values[key]; if (value !== undefined && value !== null && value !== '') text(`${String(field.label || label(key))}: ${String(value)}`) }
  y -= 5; section('SERVIÇOS E VALORES'); if (document.items.length === 0) text('Nenhum serviço com valor configurado.', 9, false, muted)
  for (const item of document.items) { page.drawText(String(item.name || item.code || 'Item').slice(0, 78), { x: margin, y, size: 9, font }); page.drawText(Number(item.total_cents) >= 0 ? money(item.total_cents) : 'Valor a confirmar', { x: margin + width - 110, y, size: 9, font: bold }); y -= 17 }
  page.drawLine({ start: { x: margin, y: y + 5 }, end: { x: margin + width, y: y + 5 }, thickness: 0.7, color: muted }); text(`TOTAL CONHECIDO: ${money(document.total_cents)}`, 12, true, red); if (document.missing_amount_items?.length) text('Há custos adicionais ainda não definidos. Eles não foram considerados gratuitos.', 8, false, muted)
  if (document.documents?.length) { y -= 5; section('DOCUMENTOS NECESSÁRIOS'); for (const item of document.documents) text(`• ${String(item.name || item.document_code || 'Documento')}`) }
  y -= 8; text('Observação: esta análise é orientativa e não representa garantia de aprovação pelo Detran.', 8, false, muted); text(document.partnerPhone ? `Contato do parceiro: ${document.partnerPhone}` : `Contato Doc Motor: ${document.platformPhone || 'configurar no painel administrativo'}`, 8, false, muted)
  page.drawLine({ start: { x: margin, y: 48 }, end: { x: margin + width, y: 48 }, thickness: 0.7, color: red }); page.drawText('Doc Motor — Documentação Veicular', { x: margin, y: 34, size: 8, font: bold, color: dark })
  const bytes = await pdf.save(); const buffer = new ArrayBuffer(bytes.byteLength); new Uint8Array(buffer).set(bytes); return new Blob([buffer], { type: 'application/pdf' })
}
