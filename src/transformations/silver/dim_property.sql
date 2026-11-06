CREATE OR REFRESH MATERIALIZED VIEW dim_property (
  CONSTRAINT property_has_destination EXPECT (destination IS NOT NULL),
  CONSTRAINT price_positive           EXPECT (base_price > 0)
)
COMMENT 'Properties with their destination, country and continent'
AS SELECT
  p.property_id,
  p.host_id,
  p.title,
  p.property_type,
  CAST(p.base_price AS DECIMAL(10, 2)) AS base_price,
  d.destination,
  d.country,
  c.continent
FROM samples.wanderbricks.properties p
LEFT JOIN samples.wanderbricks.destinations d ON p.destination_id = d.destination_id
LEFT JOIN samples.wanderbricks.countries c ON d.country = c.country;
