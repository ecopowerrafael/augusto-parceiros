import { describe, expect, it } from 'vitest'
import { documentTypeFor, formatCep, formatCpfCnpj, formatPhone, normalizeDocument } from './formats'

describe('máscaras e normalização de formulários', () => {
  it('formata CPF durante a digitação e preserva zeros à esquerda', () => {
    expect(formatCpfCnpj('00100200304')).toBe('001.002.003-04')
    expect(normalizeDocument('001.002.003-04')).toBe('00100200304')
    expect(documentTypeFor('001.002.003-04')).toBe('PF')
  })

  it('troca para CNPJ ao ultrapassar onze dígitos e retorna para CPF ao apagar', () => {
    expect(formatCpfCnpj('04252011000110')).toBe('04.252.011/0001-10')
    expect(documentTypeFor('04252011000110')).toBe('PJ')
    expect(formatCpfCnpj('00100200304')).toBe('001.002.003-04')
    expect(documentTypeFor('00100200304')).toBe('PF')
  })

  it('aceita colagem formatada e sem formatação', () => {
    expect(formatCpfCnpj('04.252.011/0001-10')).toBe('04.252.011/0001-10')
    expect(formatCpfCnpj('00100200304')).toBe('001.002.003-04')
  })

  it('aplica máscaras reutilizáveis de telefone e CEP', () => {
    expect(formatPhone('15997118125')).toBe('(15) 99711-8125')
    expect(formatPhone('')).toBe('')
    expect(formatCep('18123456')).toBe('18123-456')
  })
})
