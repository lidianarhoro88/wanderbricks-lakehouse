-- SCD Type 2: one row per version of each booking, with __START_AT / __END_AT.
-- Events can arrive out of order; SEQUENCE BY puts them back in order, and the
-- update id breaks ties when two changes share a timestamp.
CREATE OR REFRESH STREAMING TABLE bookings_history
COMMENT 'Full change history of every booking (SCD Type 2)';

CREATE FLOW bookings_history_cdc AS AUTO CDC INTO bookings_history
FROM STREAM(silver_booking_updates)
KEYS (booking_id)
SEQUENCE BY STRUCT(updated_at, booking_update_id)
STORED AS SCD TYPE 2
TRACK HISTORY ON status, check_in, check_out, guests_count, total_amount;
