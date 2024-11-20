;; contracts/event-betting.clar

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-market-closed (err u104))
(define-constant err-insufficient-balance (err u105))

;; Define data variables
(define-data-var next-market-id uint u1)

;; Define maps
(define-map markets uint {
  description: (string-ascii 256),
  options: (list 5 (string-ascii 64)),
  creator: principal,
  end-block: uint,
  resolved: bool,
  winning-option: (optional uint)
})

(define-map bets {market-id: uint, better: principal} (list 5 uint))

;; Private functions
(define-private (is-owner)
  (is-eq tx-sender contract-owner))

;; Public functions

;; Create a new prediction market
(define-public (create-market (description (string-ascii 256)) (options (list 5 (string-ascii 64))) (duration uint))
  (let
    (
      (market-id (var-get next-market-id))
    )
    (asserts! (> (len options) u0) err-unauthorized)
    (map-set markets market-id {
      description: description,
      options: options,
      creator: tx-sender,
      end-block: (+ block-height duration),
      resolved: false,
      winning-option: none
    })
    (var-set next-market-id (+ market-id u1))
    (ok market-id)
  )
)

;; Place a bet on a market
(define-public (place-bet (market-id uint) (option-index uint) (amount uint))
  (let
    (
      (market (unwrap! (map-get? markets market-id) err-not-found))
      (current-bets (default-to (list u0 u0 u0 u0 u0) (map-get? bets {market-id: market-id, better: tx-sender})))
    )
    (asserts! (< block-height (get end-block market)) err-market-closed)
    (asserts! (< option-index (len (get options market))) err-unauthorized)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (ok (map-set bets {market-id: market-id, better: tx-sender}
      (unwrap-panic (element-at (map + current-bets
        (map u0 current-bets)) option-index amount))))
  )
)

;; Read-only functions

(define-read-only (get-market (market-id uint))
  (map-get? markets market-id))

(define-read-only (get-bets (market-id uint) (better principal))
  (map-get? bets {market-id: market-id, better: better}))
