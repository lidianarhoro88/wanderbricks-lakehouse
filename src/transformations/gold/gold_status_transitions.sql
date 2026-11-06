-- How bookings move between states, from the SCD Type 2 history:
-- e.g. how many pending bookings were confirmed, and how long it took.
CREATE OR REFRESH MATERIALIZED VIEW gold_status_transitions
COMMENT 'Status changes between consecutive booking versions, with time between them'
AS WITH versions AS (
  SELECT
    booking_id,
    status,
    __START_AT.updated_at AS valid_from,
    lag(status) OVER (PARTITION BY booking_id ORDER BY __START_AT) AS previous_status,
    lag(__START_AT.updated_at) OVER (PARTITION BY booking_id ORDER BY __START_AT) AS previous_from
  FROM bookings_history
)
SELECT
  coalesce(previous_status, '(created)')                                     AS from_status,
  status                                                                     AS to_status,
  count(*)                                                                   AS transitions,
  round(avg((unix_timestamp(valid_from) - unix_timestamp(previous_from)) / 3600), 1) AS avg_hours_between
FROM versions
WHERE previous_status IS NULL OR previous_status <> status
GROUP BY ALL;
