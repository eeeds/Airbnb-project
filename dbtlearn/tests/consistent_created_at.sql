SELECT
 *
FROM
 {{ ref('dim_listings_cleansed') }} l
INNER JOIN {{ref('fct_reviews')}} h ON l.listing_id = h.listing_id
WHERE l.created_at>=h.review_date 
--LIMIT 10