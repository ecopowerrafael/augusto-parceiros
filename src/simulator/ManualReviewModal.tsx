import { useEffect, useRef } from 'react'

type Props = { open: boolean; title: string; reasons: string[]; message: string; whatsapp?: string; onClose: () => void; onWhatsApp: () => void }

export function ManualReviewModal({ open, title, reasons, message, whatsapp, onClose, onWhatsApp }: Props) {
  const closeRef = useRef<HTMLButtonElement>(null)
  useEffect(() => {
    if (!open) return
    closeRef.current?.focus()
    const onKeyDown = (event: KeyboardEvent) => { if (event.key === 'Escape') onClose() }
    document.addEventListener('keydown', onKeyDown)
    return () => document.removeEventListener('keydown', onKeyDown)
  }, [open, onClose])
  if (!open) return null
  return <div className="manual-modal-backdrop" role="presentation" onMouseDown={(event) => { if (event.target === event.currentTarget) onClose() }}><section className="manual-modal" role="dialog" aria-modal="true" aria-labelledby="manual-review-title"><button ref={closeRef} className="manual-modal-close" type="button" onClick={onClose} aria-label="Fechar análise manual">×</button><div className="manual-modal-icon" aria-hidden="true">!</div><h2 id="manual-review-title">{title}</h2><p className="manual-modal-message">{message}</p>{reasons.length > 0 && <div className="manual-modal-reasons"><strong>Motivo identificado</strong><ul>{reasons.map((reason, index) => <li key={`${reason}-${index}`}>{reason}</li>)}</ul></div>}<p className="manual-modal-help">Nossa equipe poderá verificar alternativas de regularização para o seu veículo.</p>{whatsapp ? <button className="manual-modal-whatsapp" type="button" onClick={onWhatsApp}>Solicitar análise manual pelo WhatsApp</button> : <p className="auth-muted">O WhatsApp de análise manual ainda não foi configurado.</p>}<button className="manual-modal-return" type="button" onClick={onClose}>Voltar à consulta</button></section></div>
}
