;; Define constants
(define-constant err-unauthorized (err u101))
(define-constant err-already-reported (err u102))

;; Define maps
(define-map oracles principal bool)
(define-map oracle-reports {market-id: uint, oracle: principal} uint)

;; Public functions

;; Report outcome for a market
(define-public (report-outcome (market-id uint) (outcome uint))
  (let
    (
      (oracle tx-sender)
    )
    (asserts! (default-to false (map-get? oracles oracle)) err-unauthorized)
    (asserts! (is-none (map-get? oracle-reports {market-id: market-id, oracle: oracle})) err-already-reported)
    (ok (map-set oracle-reports {market-id: market-id, oracle: oracle} outcome))
  )
)

;; Read-only functions

(define-read-only (is-oracle (oracle principal))
  (default-to false (map-get? oracles oracle)))

(define-read-only (get-oracle-report (market-id uint) (oracle principal))
  (map-get? oracle-reports {market-id: market-id, oracle: oracle}))

