import { describe, expect, it } from 'vitest'
import { evaluateCommission } from './commissions.js'

const charges = [{ amountCents: 29580, isPublicFee: true }, { amountCents: 16000, isHonorarium: true }, { amountCents: 30000, isHonorarium: true }]

describe('commission evaluator', () => {
  it('does not commission by default', () => expect(evaluateCommission({ model: 'NONE' }, charges).commissionCents).toBe(0))
  it('calculates service percentage excluding public fee', () => expect(evaluateCommission({ model: 'SERVICE_PERCENTAGE', percentage: 10 }, charges).commissionCents).toBe(4600))
  it('calculates honorarium percentage and full honorarium', () => {
    expect(evaluateCommission({ model: 'HONORARIUM_PERCENTAGE', percentage: 50 }, charges).commissionCents).toBe(23000)
    expect(evaluateCommission({ model: 'FULL_HONORARIUM' }, charges).commissionCents).toBe(46000)
  })
  it('supports fixed amount and rejects undefined values', () => {
    expect(evaluateCommission({ model: 'FIXED_AMOUNT', fixedAmountCents: 10000 }, charges).commissionCents).toBe(10000)
    expect(() => evaluateCommission({ model: 'SERVICE_PERCENTAGE', percentage: 10 }, [{ amountCents: null }])).toThrow('UNDEFINED_CHARGE_AMOUNT')
  })
  it('rejects commission above eligible balance', () => expect(() => evaluateCommission({ model: 'FIXED_AMOUNT', fixedAmountCents: 50000 }, charges)).toThrow('COMMISSION_EXCEEDS_BALANCE'))
})
