import { describe, expect, it } from 'vitest'
import { evaluateCommission, resolveCommissionConfig } from './commissions.js'

const charges = [{ amountCents: 29580, isPublicFee: true, chargeNature: 'THIRD_PARTY' }, { amountCents: 16000, chargeNature: 'HONORARY' }, { amountCents: 30000, chargeNature: 'HONORARY' }]

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
  it('uses the global configuration when no partner override exists', () => expect(resolveCommissionConfig({ model: 'SERVICE_PERCENTAGE', percentage: 10 }, null)).toEqual({ model: 'SERVICE_PERCENTAGE', percentage: 10 }))
  it('uses a customized partner rule when an override exists', () => expect(resolveCommissionConfig({ model: 'SERVICE_PERCENTAGE', percentage: 10 }, { model: 'FIXED_AMOUNT', fixedAmountCents: 5000 })).toEqual({ model: 'FIXED_AMOUNT', fixedAmountCents: 5000 }))
  it('preserves an explicit partner disable override', () => expect(evaluateCommission(resolveCommissionConfig({ model: 'SERVICE_PERCENTAGE', percentage: 10 }, { model: 'NONE' }), charges).commissionCents).toBe(0))
  it('returns all simulator totals in integer cents', () => expect(evaluateCommission({ model: 'SERVICE_PERCENTAGE', percentage: 12.5 }, [{ amountCents: 10000, chargeNature: 'OWN_SERVICE' }])).toMatchObject({ totalCents: 10000, eligibleServiceCents: 10000, commissionCents: 1250 }))
})
