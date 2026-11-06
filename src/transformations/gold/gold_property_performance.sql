CREATE OR REFRESH MATERIALIZED VIEW gold_property_performance
COMMENT 'Per property: bookings, confirmed revenue, cancellation rate and guest rating'
AS WITH bk AS (
  SELECT
    property_id,
    count(*)                                                             AS bookings,
    count_if(status LIKE 'cancel%')                                      AS cancelled,
    sum(CASE WHEN status = 'confirmed' THEN total_amount ELSE 0 END)     AS confirmed_revenue,
    sum(CASE WHEN status = 'confirmed' THEN nights ELSE 0 END)           AS nights_sold
  FROM bookings_current
  GROUP BY property_id
),
rv AS (
  SELECT property_id, round(avg(rating), 2) AS avg_rating, count(*) AS reviews
  FROM silver_reviews
  GROUP BY property_id
)
SELECT
  p.property_id,
  p.title,
  p.property_type,
  p.destination,
  p.country,
  p.base_price,
  h.is_verified                                   AS host_verified,
  coalesce(bk.bookings, 0)                        AS bookings,
  coalesce(bk.confirmed_revenue, 0)               AS confirmed_revenue,
  coalesce(bk.nights_sold, 0)                     AS nights_sold,
  round(bk.cancelled / bk.bookings, 4)            AS cancellation_rate,
  rv.avg_rating,
  coalesce(rv.reviews, 0)                         AS reviews
FROM dim_property p
LEFT JOIN dim_host h ON p.host_id = h.host_id
LEFT JOIN bk ON p.property_id = bk.property_id
LEFT JOIN rv ON p.property_id = rv.property_id;
