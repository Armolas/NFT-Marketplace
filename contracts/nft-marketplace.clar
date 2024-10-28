;; title: NFT-Marketplace
;; desc: This is an advanced NFT smart contract featuring whitelisting and a Non-custodial marketplace
;; author: Muritadhor Arowolo


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Constants, Variables and Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-non-fungible-token advance-nft uint)

(define-constant nft-creator tx-sender)

(define-constant advance-nft-price u10000000)

(define-constant collection-limit u10)

(define-constant collection-root-url "ipfs://simple/nft/collection/")

(define-data-var admins (list 5 principal) (list nft-creator))

(define-data-var collection-index uint u0)

(define-map whitelist principal uint)

(define-map marketplace uint {price: uint, owner: principal})

(define-map user-tokens principal (list 10 uint))


;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SIP-009 TRAITS ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; GET LAST TOKEN ID
(define-public (get-last-token-id)
    (ok (var-get collection-index))
)

;; GET TOKEN URI
(define-public (get-token-uri (id uint))
    (ok (some (concat
        collection-root-url
        (concat (int-to-ascii id) ".json")
        ))
    )
)

;; GET TOKEN OWNER
(define-public (get-owner (id uint))
    (ok (nft-get-owner? advance-nft id))
)

;; TRANSFER TOKEN
(define-public (transfer (id uint) (sender principal) (recipient principal))
    (let
        (
            (nft-market (map-get? marketplace id))
        )
        (asserts! (is-eq tx-sender sender) (err "err-not-token-owner"))
        (if (is-some nft-market)
            (map-delete marketplace id)
            false
        )
        (ok (nft-transfer? advance-nft id sender recipient))
    )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; MARKETPLACE FUNCS ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; LIST TOKEN
(define-public (list-in-ustx (id uint) (price uint))
    (let
        (
            (nft-owner (unwrap! (get-owner id) (err "err-token-does-not-exist")))
        )
        (asserts! (is-eq (some tx-sender) nft-owner) (err "err-not-token-owner"))
        (ok (map-set marketplace id {price: price, owner: tx-sender}))
    )
)

;; UNLIST TOKEN
(define-public (unlist-in-ustx (id uint))
    (let
        (
            (nft-owner (unwrap! (get-owner id) (err "err-token-does-not-exist")))
            (nft-market (map-get? marketplace id))
        )
        (asserts! (is-eq (some tx-sender) nft-owner) (err "err-not-token-owner"))
        (asserts! (is-some nft-market) (err "err-token-not-listed"))
        (ok (map-delete marketplace id))
    )
)

;; BUY TOKEN
(define-public (buy-in-ustx (id uint))
    (let
        (
            (nft-market (unwrap! (map-get? marketplace id) (err "err-token-not-listed")))
            (price (get price nft-market))
            (owner (get owner nft-market))
        )
        (unwrap! (stx-transfer? price tx-sender owner) (err "err-transferring-stx"))
        (unwrap! (nft-transfer? advance-nft id owner tx-sender) (err "err-token-transfer"))
        (ok (map-delete marketplace id))
    )
)

;; GET TOKEN LISTING
(define-public (get-listing-in-ustx (id uint))
    (ok (map-get? marketplace id))
)


;;;;;;;;;;;;;;;;;;;;
;;;; MINT FUNCS ;;;;
;;;;;;;;;;;;;;;;;;;;

;; MINT ONE TOKEN
(define-public (mint-one)
    (let
        (
            (current-index (var-get collection-index))
            (next-index (+ current-index u1))
            (whitelist-count (unwrap! (map-get? whitelist tx-sender) (err "err-not-whitelisted")))
        )
        (asserts! (< current-index collection-limit) (err "err-token-minted-out"))
        (asserts! (> whitelist-count u0) (err "err-whitelist-minting-spot-exhausted"))
        (unwrap! (stx-transfer? advance-nft-price tx-sender nft-creator) (err "err-transferring-stx"))
        (unwrap! (nft-mint? advance-nft next-index tx-sender) (err "err-minting-token"))
        (unwrap! (track-token next-index) (err "err-tracking-mint"))
        (var-set collection-index next-index)
        (ok (map-set whitelist tx-sender (- whitelist-count u1)))
    )
)

;; MINT TWO TOKENS
(define-public (mint-two)
    (begin
        (unwrap! (mint-one) (err "err-mint-1"))
        (ok (mint-one))
    )
)

;; MINT FIVE TOKENS
(define-public (mint-five)
    (begin
        (unwrap! (mint-one) (err "err-mint-1"))
        (unwrap! (mint-one) (err "err-mint-2"))
        (unwrap! (mint-one) (err "err-mint-3"))
        (unwrap! (mint-one) (err "err-mint-4"))
        (ok (mint-one))
    )
)

;; GET USER MINTS
(define-read-only (get-mints)
    (map-get? user-tokens tx-sender)
)

;; USER TOKEN TRACKER FUNCTION
(define-private (track-token (id uint))
    (let
        (
            (user-mints (map-get? user-tokens tx-sender))
        )
        (if (is-some user-mints)
            (ok (map-set user-tokens tx-sender (unwrap! (as-max-len? (append (unwrap! user-mints (err "err-unwrapping-mints")) id) u10) (err "err-tracking-mint"))))
            (ok (map-set user-tokens tx-sender (list id)))
        )
    )
)