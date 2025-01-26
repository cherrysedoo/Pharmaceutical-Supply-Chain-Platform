;; Drug Batch Contract

(define-map drug-batches
  { batch-id: (string-ascii 20) }
  {
    manufacturer: principal,
    drug-name: (string-ascii 50),
    quantity: uint,
    manufacture-date: uint,
    expiry-date: uint,
    current-owner: principal,
    status: (string-ascii 20)
  }
)

(define-public (register-batch
  (batch-id (string-ascii 20))
  (drug-name (string-ascii 50))
  (quantity uint)
  (manufacture-date uint)
  (expiry-date uint))
  (let
    ((manufacturer tx-sender))
    (map-set drug-batches
      { batch-id: batch-id }
      {
        manufacturer: manufacturer,
        drug-name: drug-name,
        quantity: quantity,
        manufacture-date: manufacture-date,
        expiry-date: expiry-date,
        current-owner: manufacturer,
        status: "manufactured"
      }
    )
    (ok true)
  )
)

(define-public (transfer-batch (batch-id (string-ascii 20)) (new-owner principal))
  (let
    ((batch (unwrap! (map-get? drug-batches { batch-id: batch-id }) (err u404))))
    (asserts! (is-eq tx-sender (get current-owner batch)) (err u403))
    (map-set drug-batches
      { batch-id: batch-id }
      (merge batch {
        current-owner: new-owner,
        status: "in-transit"
      })
    )
    (ok true)
  )
)

(define-public (update-batch-status (batch-id (string-ascii 20)) (new-status (string-ascii 20)))
  (let
    ((batch (unwrap! (map-get? drug-batches { batch-id: batch-id }) (err u404))))
    (asserts! (is-eq tx-sender (get current-owner batch)) (err u403))
    (map-set drug-batches
      { batch-id: batch-id }
      (merge batch { status: new-status })
    )
    (ok true)
  )
)

(define-read-only (get-batch-info (batch-id (string-ascii 20)))
  (map-get? drug-batches { batch-id: batch-id })
)

