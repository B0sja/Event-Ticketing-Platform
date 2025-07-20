;; Event Ticketing Platform: Decentralized event management and ticket sales system
;; Enables organizers to create events, attendees to purchase tickets, and validators to verify entries

(define-data-var platform-validator principal tx-sender)

(define-map event-registry
  { event-id: uint }
  {
    organizer: principal,
    ticket-price: uint,
    event-name: (string-ascii 50),
    event-details: (string-ascii 500),
    max-capacity: uint,
    verified: bool
  }
)

(define-map ticket-sales
  { event-id: uint, sale-id: uint }
  {
    attendee: principal,
    purchase-time: uint,
    ticket-status: (string-ascii 20)
  }
)

(define-data-var next-event-id uint u1)

(define-map sales-counter
  { event-id: uint }
  { tickets-sold: uint }
)

;; Create a new event
(define-public (create-event (name-input (string-ascii 50)) (details-input (string-ascii 500)) (capacity-input uint) (price-input uint))
  (let
    (
      (event-id (var-get next-event-id))
      (sale-id u0)
      (name name-input)
      (details details-input)
      (capacity capacity-input)
      (price price-input)
    )
    ;; Input validation
    (asserts! (> price u0) (err u1))
    (asserts! (> (len name) u0) (err u5))
    (asserts! (> (len details) u0) (err u6))
    (asserts! (> capacity u0) (err u7))
    
    (map-set event-registry
      { event-id: event-id }
      {
        organizer: tx-sender,
        ticket-price: price,
        event-name: name,
        event-details: details,
        max-capacity: capacity,
        verified: false
      }
    )
    (map-set ticket-sales
      { event-id: event-id, sale-id: sale-id }
      {
        attendee: tx-sender,
        purchase-time: event-id,
        ticket-status: "created"
      }
    )
    (map-set sales-counter
      { event-id: event-id }
      { tickets-sold: u1 }
    )
    (var-set next-event-id (+ event-id u1))
    (ok event-id)
  )
)

;; Purchase a ticket
(define-public (purchase-ticket (event-id-input uint))
  (let
    (
      (event-id event-id-input)
      (event-info (unwrap! (map-get? event-registry { event-id: event-id }) (err u2)))
      (price (get ticket-price event-info))
      (organizer (get organizer event-info))
      (sales-data (default-to { tickets-sold: u0 } (map-get? sales-counter { event-id: event-id })))
      (sale-id (get tickets-sold sales-data))
      (new-sale-id (+ sale-id u1))
    )
    ;; Input validation
    (asserts! (> event-id u0) (err u8))
    (asserts! (not (is-eq tx-sender organizer)) (err u3))
    
    (try! (stx-transfer? price tx-sender organizer))
    (map-set ticket-sales
      { event-id: event-id, sale-id: sale-id }
      {
        attendee: tx-sender,
        purchase-time: (var-get next-event-id),
        ticket-status: "purchased"
      }
    )
    (map-set sales-counter
      { event-id: event-id }
      { tickets-sold: new-sale-id }
    )
    (ok true)
  )
)

;; Verify event (platform validator only)
(define-public (verify-event (event-id-input uint))
  (let
    (
      (event-id event-id-input)
      (event-info (unwrap! (map-get? event-registry { event-id: event-id }) (err u2)))
      (sales-data (default-to { tickets-sold: u0 } (map-get? sales-counter { event-id: event-id })))
      (sale-id (get tickets-sold sales-data))
      (new-sale-id (+ sale-id u1))
    )
    ;; Input validation
    (asserts! (> event-id u0) (err u8))
    (asserts! (is-eq tx-sender (var-get platform-validator)) (err u4))
    
    (map-set event-registry
      { event-id: event-id }
      (merge event-info { verified: true })
    )
    (map-set ticket-sales
      { event-id: event-id, sale-id: sale-id }
      {
        attendee: (get organizer event-info),
        purchase-time: (var-get next-event-id),
        ticket-status: "verified"
      }
    )
    (map-set sales-counter
      { event-id: event-id }
      { tickets-sold: new-sale-id }
    )
    (ok true)
  )
)

;; Get event details
(define-read-only (get-event (event-id uint))
  (map-get? event-registry { event-id: event-id })
)

;; Get ticket sale entry
(define-read-only (get-ticket-sale (event-id uint) (sale-id uint))
  (map-get? ticket-sales { event-id: event-id, sale-id: sale-id })
)

;; Get total tickets sold for an event
(define-read-only (get-tickets-sold (event-id uint))
  (let
    (
      (sales-data (default-to { tickets-sold: u0 } (map-get? sales-counter { event-id: event-id })))
    )
    (get tickets-sold sales-data)
  )
)
