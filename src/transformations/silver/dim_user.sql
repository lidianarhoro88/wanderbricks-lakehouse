-- Names and e-mail addresses are left out on purpose: analysis does not need them.
CREATE OR REFRESH MATERIALIZED VIEW dim_user
COMMENT 'Guests without personal contact details'
AS SELECT user_id, country, user_type, is_business, created_at
FROM samples.wanderbricks.users;
