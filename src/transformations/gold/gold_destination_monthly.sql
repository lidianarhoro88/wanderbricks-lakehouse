-- Demand and revenue by destination and month of stay. Revenue counts bookings that
-- are confirmed or already completed (the guest stayed); cancelled and pending are excluded.
CREATE OR REFRESH MATERIALIZED VIEW gold_destination_monthly
COMMENT 'Bookings, revenue and cancellations by destination and month of check-in'
AS SELECT
  date_trunc('MONTH', b.check_in)                                        AS stay_month,
  p.continent,
  p.country,
  p.destination,
  p.property_type,
  count(*)                                                               AS bookings,
  count_if(b.status IN ('confirmed', 'completed'))                       AS booked,
  count_if(b.status LIKE 'cancel%')                                      AS cancelled,
  round(count_if(b.status LIKE 'cancel%') / count(*), 4)                 AS cancellation_rate,
  sum(CASE WHEN b.status IN ('confirmed', 'completed') THEN b.total_amount ELSE 0 END) AS booked_revenue,
  round(avg(b.nights), 2)                                                AS avg_nights,
  round(avg(b.guests_count), 2)                                          AS avg_guests
FROM bookings_current b
JOIN dim_property p ON b.property_id = p.property_id
GROUP BY ALL;
