;; Define constants
(define-constant err-not-found (err u102))
(define-constant err-already-resolved (err u103))

;; Define data variables
(define-data-var last-market-id uint u0)

;; Define maps
(define-map markets uint { resolved: bool, winning-option: (optional uint) })

;; Public functions

;; Create a new market
(define-public (create-market)
  (let
    (
      (new-market-id (+ (var-get last-market-id) u1))
    )
    (map-set markets new-market-id { resolved: false, winning-option: none })
    (var-set last-market-id new-market-id)
    (ok new-market-id)
  )
)

;; Resolve a market
(define-public (resolve-market (market-id uint) (winning-option uint))
  (let
    (
      (market (unwrap! (map-get? markets market-id) err-not-found))
    )
    (asserts! (not (get resolved market)) err-already-resolved)
    (map-set markets market-id (merge market { resolved: true, winning-option: (some winning-option) }))
    (ok true)
  )
)

;; Read-only functions

(define-read-only (get-market (market-id uint))
  (map-get? markets market-id))

(define-read-only (get-last-market-id)
  (var-get last-market-id))

