export const COMMISSION_MODELS = ['NONE', 'SERVICE_PERCENTAGE', 'HONORARIUM_PERCENTAGE', 'FULL_HONORARIUM', 'FIXED_AMOUNT']

export function validateCommissionConfig(config) {
  if (!COMMISSION_MODELS.includes(config.model)) throw new Error('INVALID_COMMISSION_MODEL')
  if (config.model.includes('PERCENTAGE') && (!Number.isFinite(Number(config.percentage)) || Number(config.percentage) < 0 || Number(config.percentage) > 100)) throw new Error('INVALID_COMMISSION_PERCENTAGE')
  if (config.model === 'FIXED_AMOUNT' && (!Number.isInteger(config.fixedAmountCents) || config.fixedAmountCents < 0)) throw new Error('INVALID_COMMISSION_AMOUNT')
  return config
}

export function evaluateCommission(config, charges) {
  validateCommissionConfig(config)
  const normalized = charges.map((charge) => ({ ...charge, amountCents: charge.amountCents === null || charge.amountCents === undefined ? NaN : Number(charge.amountCents), isHonorarium: Boolean(charge.isHonorarium), isPublicFee: Boolean(charge.isPublicFee) }))
  if (normalized.some((charge) => !Number.isSafeInteger(charge.amountCents) || charge.amountCents < 0)) throw new Error('UNDEFINED_CHARGE_AMOUNT')
  const total = normalized.reduce((sum, charge) => sum + charge.amountCents, 0)
  const honorarium = normalized.filter((charge) => charge.isHonorarium && !charge.isPublicFee).reduce((sum, charge) => sum + charge.amountCents, 0)
  const serviceTotal = normalized.filter((charge) => !charge.isPublicFee).reduce((sum, charge) => sum + charge.amountCents, 0)
  let commissionCents = 0
  if (config.model === 'SERVICE_PERCENTAGE') commissionCents = Math.round(serviceTotal * Number(config.percentage) / 100)
  if (config.model === 'HONORARIUM_PERCENTAGE') commissionCents = Math.round(honorarium * Number(config.percentage) / 100)
  if (config.model === 'FULL_HONORARIUM') commissionCents = honorarium
  if (config.model === 'FIXED_AMOUNT') commissionCents = config.fixedAmountCents
  if (commissionCents > serviceTotal) throw new Error('COMMISSION_EXCEEDS_BALANCE')
  return { totalCents: total, eligibleServiceCents: serviceTotal, eligibleHonorariumCents: honorarium, commissionCents }
}
