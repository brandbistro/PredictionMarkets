;; contracts/market-resolution.clar

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-not-found (err u102))
(define-constant err-already-resolved (err u103))
(define-constant err-insufficient-reports (err u104))

;; Define data variables
(define-data-var required-oracle-reports uint u3)

;; Public functions

;; Resolve a market
(define-public (resolve-market (market-id uint))
  (let
    (
      (market (unwrap! (contract-call? .event-betting get-market market-id) err-not-found))
      (reports (get-oracle-reports market-id))
      (winning-option (get-winning-option reports))
    )
    (asserts! (not (get resolved market)) err-already-resolved)
    (asserts! (>= (len reports) (var-get required-oracle-reports)) err-insufficient-reports)
    (try! (as-contract (contract-call? .event-betting update-market-resolution market-id winning-option)))
    (ok winning-option)
  )
)

;; Claim winnings for a resolved market
(define-public (claim-winnings (market-id uint))
  (let
    (
      (market (unwrap! (contract-call? .event-betting get-market market-id) err-not-found))
      (bets (unwrap! (contract-call? .event-betting get-bets market-id tx-sender) err-not-found))
      (winning-option (unwrap! (get winning-option market) err-not-found))
      (winning-amount (unwrap! (element-at bets winning-option) err-not-found))
      (total-bets (fold + bets u0))
      (payout (/ (* winning-amount total-bets) (unwrap! (element-at bets winning-option) err-not-found)))
    )
    (asserts! (get resolved market) err-unauthorized)
    (as-contract (stx-transfer? payout tx-sender tx-sender))
  )
)

;; Private functions

(define-private (get-oracle-reports (market-id uint))
  (filter is-some
    (map unwrap-panic
      (map (lambda (oracle)
        (contract-call? .oracle-integration get-oracle-report market-id oracle))
      (get-authorized-oracles)))))

(define-private (get-winning-option (reports (list 100 uint)))
  (let
    (
      (option-counts (fold count-votes {u0: u0, u1: u0, u2: u0, u3: u0, u4: u0} reports))
    )
    (get-max-key option-counts)
  )
)

(define-private (count-votes (vote uint) (counts {u0: uint, u1: uint, u2: uint, u3: uint, u4: uint}))
  (match vote
    0 (merge counts {u0: (+ u1 (get u0 counts))})
    1 (merge counts {u1: (+ u1 (get u1 counts))})
    2 (merge counts {u2: (+ u1 (get u2 counts))})
    3 (merge counts {u3: (+ u1 (get u3 counts))})
    4 (merge counts {u4: (+ u1 (get u4 counts))})
    counts
  )
)

(define-private (get-max-key (counts {u0: uint, u1: uint, u2: uint, u3: uint, u4: uint}))
  (let
    (
      (max-count (fold max u0 (list (get u0 counts) (get u1 counts) (get u2 counts) (get u3 counts) (get u4 counts))))
    )
    (unwrap-panic (find-key-with-value counts max-count))
  )
)

(define-private (find-key-with-value (counts {u0: uint, u1: uint, u2: uint, u3: uint, u4: uint}) (value uint))
  (match value
    (get u0 counts) (some u0)
    (get u1 counts) (some u1)
    (get u2 counts) (some u2)
    (get u3 counts) (some u3)
    (get u4 counts) (some u4)
    none
  )
)

(define-private (get-authorized-oracles)
  (filter is-some
    (map to-optional
      (map (lambda (oracle) (if (contract-call? .oracle-integration is-oracle oracle) oracle none))
        (list contract-owner 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)))))

;; Read-only functions

(define-read-only (get-required-oracle-reports)
  (var-get required-oracle-reports))
