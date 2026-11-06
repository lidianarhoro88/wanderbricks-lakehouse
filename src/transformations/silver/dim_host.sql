CREATE OR REFRESH MATERIALIZED VIEW dim_host
COMMENT 'Hosts without personal contact details'
AS SELECT host_id, country, is_verified, is_active, rating, joined_at
FROM samples.wanderbricks.hosts;
