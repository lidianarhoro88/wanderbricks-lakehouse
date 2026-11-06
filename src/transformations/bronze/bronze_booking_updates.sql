-- Raw booking change events, loaded incrementally. Each run picks up only new rows.
CREATE OR REFRESH STREAMING TABLE bronze_booking_updates
COMMENT 'Booking change events from samples.wanderbricks.booking_updates, as received'
AS SELECT
  *,
  current_timestamp() AS _ingested_at
FROM STREAM(samples.wanderbricks.booking_updates);
