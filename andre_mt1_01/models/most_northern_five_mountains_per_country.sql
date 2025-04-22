{{
  config({    
    "database": "andre_dev",
    "schema": "andre_mt_01_out"
  })
}}

WITH mountains_cte_1 AS (

  SELECT * 
  
  FROM {{ source('product_dev.mountains', 'mountains') }}

),

ranked_mountains AS (

  SELECT 
    mountain,
    country,
    meters,
    feet,
    latitude,
    longitude,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY latitude DESC) AS rn
  
  FROM mountains_cte_1

),

top_ranked_mountains AS (

  SELECT * 
  
  FROM ranked_mountains
  
  WHERE rn <= 5

)

SELECT *

FROM top_ranked_mountains
