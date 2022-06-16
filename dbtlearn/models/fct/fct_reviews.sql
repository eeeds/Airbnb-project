{{
 config(
 materialized = 'incremental',
 on_schema_change='fail'
 )
}}
WITH src_reviews AS (
 SELECT * FROM {{ ref('src_reviews') }}
)
SELECT * FROM src_reviews
WHERE review_text is not null
{% if is_incremental() %}
 AND review_date > (select max(review_date) from {{ this }})
{% endif %}