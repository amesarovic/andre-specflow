WITH mountains_cte AS (

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
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY meters DESC) AS rank
  
  FROM mountains_cte

),

top_ranked_mountains AS (

  SELECT * 
  
  FROM ranked_mountains
  
  WHERE rank <= 5

)

SELECT *

FROM top_ranked_mountains
