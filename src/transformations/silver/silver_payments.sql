CREATE OR REFRESH MATERIALIZED VIEW silver_payments (
  CONSTRAINT payment_has_booking EXPECT (booking_id IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT amount_positive     EXPECT (amount > 0)            ON VIOLATION DROP ROW
)
COMMENT 'Valid payments'
AS SELECT
  payment_id,
  booking_id,
  CAST(amount AS DECIMAL(12, 2)) AS amount,
  lower(payment_method) AS payment_method,
  lower(status) AS status,
  payment_date
FROM bronze_payments;
