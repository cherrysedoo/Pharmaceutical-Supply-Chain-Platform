;; Quality Control NFT Contract

(define-non-fungible-token quality-control-nft (string-ascii 20))

(define-map quality-control-data
  { batch-id: (string-ascii 20) }
  {
    certifier: principal,
    certification-date: uint,
    expiration-date: uint
  }
)

(define-public (mint-quality-control-nft (batch-id (string-ascii 20)) (expiration-date uint))
  (let
    ((certifier tx-sender))
    (try! (nft-mint? quality-control-nft batch-id certifier))
    (map-set quality-control-data
      { batch-id: batch-id }
      {
        certifier: certifier,
        certification-date: block-height,
        expiration-date: expiration-date
      }
    )
    (ok true)
  )
)

(define-read-only (get-quality-control-data (batch-id (string-ascii 20)))
  (map-get? quality-control-data { batch-id: batch-id })
)

(define-read-only (is-certification-valid (batch-id (string-ascii 20)))
  (match (map-get? quality-control-data { batch-id: batch-id })
    certification-data (ok (<= block-height (get expiration-date certification-data)))
    (err u404)
  )
)
