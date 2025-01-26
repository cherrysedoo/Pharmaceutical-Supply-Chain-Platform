;; Transport Conditions Contract

(define-map transport-logs
  { batch-id: (string-ascii 20), timestamp: uint }
  {
    temperature: int,
    humidity: uint,
    location: (string-ascii 50)
  }
)

(define-public (log-transport-conditions
  (batch-id (string-ascii 20))
  (temperature int)
  (humidity uint)
  (location (string-ascii 50)))
  (let
    ((timestamp block-height))
    (map-set transport-logs
      { batch-id: batch-id, timestamp: timestamp }
      {
        temperature: temperature,
        humidity: humidity,
        location: location
      }
    )
    (ok true)
  )
)

(define-read-only (get-transport-log (batch-id (string-ascii 20)) (timestamp uint))
  (map-get? transport-logs { batch-id: batch-id, timestamp: timestamp })
)

(define-read-only (check-conditions (batch-id (string-ascii 20)) (min-temp int) (max-temp int) (max-humidity uint))
  (let
    ((latest-log (unwrap! (map-get? transport-logs { batch-id: batch-id, timestamp: block-height }) (err false))))
    (ok (and
      (>= (get temperature latest-log) min-temp)
      (<= (get temperature latest-log) max-temp)
      (<= (get humidity latest-log) max-humidity)
    ))
  )
)

