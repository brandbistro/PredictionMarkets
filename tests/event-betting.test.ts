import { describe, it, expect } from 'vitest'
import { readFileSync } from 'fs'

const contractSource = readFileSync('./contracts/event-betting.clar', 'utf8')

describe('Event Betting Contract', () => {
  it('should define contract-owner constant', () => {
    expect(contractSource).toContain('(define-constant contract-owner tx-sender)')
  })
  
  it('should define error constants', () => {
    expect(contractSource).toContain('(define-constant err-not-found (err u101))')
    expect(contractSource).toContain('(define-constant err-unauthorized (err u102))')
    expect(contractSource).toContain('(define-constant err-market-closed (err u104))')
  })
  
  it('should define next-market-id data variable', () => {
    expect(contractSource).toContain('(define-data-var next-market-id uint u1)')
  })
  
  it('should define markets map', () => {
    expect(contractSource).toContain('(define-map markets uint {')
    expect(contractSource).toContain('description: (string-ascii 256),')
    expect(contractSource).toContain('options: (list 5 (string-ascii 64)),')
    expect(contractSource).toContain('creator: principal,')
    expect(contractSource).toContain('end-block: uint,')
    expect(contractSource).toContain('resolved: bool')
  })
  
  it('should have a create-market function', () => {
    expect(contractSource).toContain('(define-public (create-market (description (string-ascii 256)) (options (list 5 (string-ascii 64))) (duration uint))')
  })
  
  it('should check for non-empty options in create-market function', () => {
    expect(contractSource).toContain('(asserts! (> (len options) u0) err-unauthorized)')
  })
  
  it('should have a place-bet function', () => {
    expect(contractSource).toContain('(define-public (place-bet (market-id uint) (option-index uint) (amount uint))')
  })
  
  it('should check for market closure in place-bet function', () => {
    expect(contractSource).toContain('(asserts! (< block-height (get end-block market)) err-market-closed)')
  })
  
  it('should check for valid option index in place-bet function', () => {
    expect(contractSource).toContain('(asserts! (< option-index (len (get options market))) err-unauthorized)')
  })
  
  it('should have a get-market read-only function', () => {
    expect(contractSource).toContain('(define-read-only (get-market (market-id uint))')
  })
})

