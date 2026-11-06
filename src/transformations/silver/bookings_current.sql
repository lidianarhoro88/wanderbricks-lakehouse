CREATE OR REFRESH MATERIALIZED VIEW bookings_current
COMMENT 'Latest version of every booking'
AS SELECT * EXCEPT (__START_AT, __END_AT)
FROM bookings_history
WHERE __END_AT IS NULL;
