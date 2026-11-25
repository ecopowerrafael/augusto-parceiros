export const COMMERCIAL_WHATSAPP = '5515997118125'

export function whatsappLink(message: string): string {
  return `https://wa.me/${COMMERCIAL_WHATSAPP}?text=${encodeURIComponent(message)}`
}
