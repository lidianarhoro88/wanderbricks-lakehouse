-- Validated change events. Broken events are dropped and counted in the pipeline's
-- data quality metrics; suspicious ones are kept and flagged.
CREATE OR REFRESH STREAMING TABLE silver_booking_updates (
  CONSTRAINT booking_id_present   EXPECT (booking_id IS NOT NULL)            ON VIOLATION DROP ROW,
  CONSTRAINT sequence_present     EXPECT (updated_at IS NOT NULL)            ON VIOLATION DROP ROW,
  CONSTRAINT stay_after_check_in  EXPECT (check_out > check_in)              ON VIOLATION DROP ROW,
  CONSTRAINT amount_not_negative  EXPECT (total_amount >= 0)                 ON VIOLATION DROP ROW,
  CONSTRAINT guests_positive      EXPECT (guests_count > 0),
  CONSTRAINT updated_after_create EXPECT (updated_at >= created_at)
)
COMMENT 'Booking change events that passed validation'
AS SELECT
  booking_update_id,
  booking_id,
  user_id,
  property_id,
  check_in,
  check_out,
  datediff(check_out, check_in) AS nights,
  guests_count,
  CAST(total_amount AS DECIMAL(12, 2)) AS total_amount,
  lower(trim(status)) AS status,
  created_at,
  updated_at
FROM STREAM(bronze_booking_updates);
