CREATE OR REFRESH STREAMING TABLE bronze_payments
COMMENT 'Payments from samples.wanderbricks.payments, as received'
AS SELECT
  *,
  current_timestamp() AS _ingested_at
FROM STREAM(samples.wanderbricks.payments);
