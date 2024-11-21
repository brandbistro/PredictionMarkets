import { describe, it, expect } from 'vitest'
import { readFileSync } from 'fs'

const contractSource = readFileSync('./contracts/oracle-integration.clar', 'utf8')

describe('Oracle Integration Contract', () => {
  it('should define error constants', () => {
    expect(contractSource).toContain('(define-constant err-unauthorized (err u101))')
    expect(contractSource).toContain('(define-constant err-already-reported (err u102))')
  })
  
  it('should define oracles map', () => {
    expect(contractSource).toContain('(define-map oracles principal bool)')
  })
  
  it('should define oracle-reports map', () => {
    expect(contractSource).toContain('(define-map oracle-reports {market-id: uint, oracle: principal} uint)')
  })
  
  it('should have a report-outcome function', () => {
    expect(contractSource).toContain('(define-public (report-outcome (market-id uint) (outcome uint))')
  })
  
  it('should check oracle authorization in report-outcome function', () => {
    expect(contractSource).toContain('(asserts! (default-to false (map-get? oracles oracle)) err-unauthorized)')
  })
  
  it('should check for existing reports in report-outcome function', () => {
    expect(contractSource).toContain('(asserts! (is-none (map-get? oracle-reports {market-id: market-id, oracle: oracle})) err-already-reported)')
  })
  
  it('should set oracle report in report-outcome function', () => {
    expect(contractSource).toContain('(ok (map-set oracle-reports {market-id: market-id, oracle: oracle} outcome))')
  })
  
  it('should have an is-oracle read-only function', () => {
    expect(contractSource).toContain('(define-read-only (is-oracle (oracle principal))')
  })
  
  it('should have a get-oracle-report read-only function', () => {
    expect(contractSource).toContain('(define-read-only (get-oracle-report (market-id uint) (oracle principal))')
  })
})

