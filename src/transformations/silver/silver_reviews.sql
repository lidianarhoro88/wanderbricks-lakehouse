CREATE OR REFRESH MATERIALIZED VIEW silver_reviews (
  CONSTRAINT rating_in_range EXPECT (rating BETWEEN 0 AND 5) ON VIOLATION DROP ROW
)
COMMENT 'Reviews that were not deleted'
AS SELECT review_id, booking_id, property_id, user_id, rating, created_at
FROM samples.wanderbricks.reviews
WHERE NOT is_deleted;
