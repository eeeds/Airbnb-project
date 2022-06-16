{{
 config(
 materialized = 'view'
 )
}}
WITH src_hosts AS (
    SELECT * FROM {{ref('src_hosts')}}
)
SELECT 
    HOST_ID,
    CASE 
        WHEN HOST_NAME IS NOT NULL THEN HOST_NAME
        ELSE NVL(HOST_NAME,'Anonymous')
    END AS HOST_NAME,
    IS_SUPERHOST,
    CREATED_AT,
    UPDATED_AT
FROM src_hosts