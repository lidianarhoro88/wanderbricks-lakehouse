-- Does every booking have the money it should? Compares the latest booking state
-- with completed payments and labels each booking with what needs attention.
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
    WHEN b.status = 'confirmed' AND coalesce(p.amount_paid, 0) = 0             THEN 'confirmed_not_paid'
    WHEN b.status LIKE 'cancel%' AND coalesce(p.amount_paid, 0) > 0            THEN 'cancelled_but_paid'
    WHEN b.status = 'confirmed' AND abs(p.amount_paid - b.total_amount) > 0.01 THEN 'amount_mismatch'
    WHEN b.status = 'confirmed'                                                 THEN 'ok'
    ELSE 'not_due'
  END                                    AS reconciliation
FROM bookings_current b
LEFT JOIN paid p ON b.booking_id = p.booking_id;
