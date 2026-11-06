-- Does every booking have the money it should? Confirmed and completed bookings should be
-- paid in full; cancelled ones should not hold money. Pending bookings are not due yet.
CREATE OR REFRESH MATERIALIZED VIEW gold_payment_reconciliation
COMMENT 'One row per booking: amount due, amount paid and the reconciliation result'
AS WITH paid AS (
  SELECT
    booking_id,
    sum(CASE WHEN status = 'completed' THEN amount ELSE 0 END) AS amount_paid,
    count(*)                                                   AS payment_rows
  FROM silver_payments
  GROUP BY booking_id
)
SELECT
  b.booking_id,
  b.status,
  b.check_in,
  b.total_amount                         AS amount_due,
  coalesce(p.amount_paid, 0)             AS amount_paid,
  coalesce(p.payment_rows, 0)            AS payment_rows,
  CASE
    WHEN b.status IN ('confirmed', 'completed') AND coalesce(p.amount_paid, 0) = 0             THEN 'due_not_paid'
    WHEN b.status LIKE 'cancel%' AND coalesce(p.amount_paid, 0) > 0                            THEN 'cancelled_but_paid'
    WHEN b.status IN ('confirmed', 'completed') AND abs(p.amount_paid - b.total_amount) > 0.01 THEN 'amount_mismatch'
    WHEN b.status IN ('confirmed', 'completed')                                                 THEN 'ok'
    ELSE 'not_due'
  END                                    AS reconciliation
FROM bookings_current b
LEFT JOIN paid p ON b.booking_id = p.booking_id;
