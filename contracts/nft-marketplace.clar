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