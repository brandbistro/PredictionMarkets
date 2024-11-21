;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-market-closed (err u104))

;; Define data variables
(define-data-var next-market-id uint u1)

;; Define maps
(define-map markets uint {
  description: (string-ascii 256),
  options: (list 5 (string-ascii 64)),
  creator: principal,
  end-block: uint,
  resolved: bool
})

(define-map bets {market-id: uint, better: principal, option-index: uint} uint)

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
      resolved: false
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
      (current-bet (default-to u0 (map-get? bets {market-id: market-id, better: tx-sender, option-index: option-index})))
    )
    (asserts! (< block-height (get end-block market)) err-market-closed)
    (asserts! (< option-index (len (get options market))) err-unauthorized)
    (ok (map-set bets {market-id: market-id, better: tx-sender, option-index: option-index}
                 (+ current-bet amount)))
  )
)

;; Read-only functions

(define-read-only (get-market (market-id uint))
  (map-get? markets market-id))

(define-read-only (get-bet (market-id uint) (better principal) (option-index uint))
  (map-get? bets {market-id: market-id, better: better, option-index: option-index}))

