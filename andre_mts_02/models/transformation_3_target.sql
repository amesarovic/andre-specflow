WITH mountains_cte_1 AS (

  SELECT * 
  
  FROM {{ source('product_dev.mountains', 'mountains') }}

),

mountains_cte AS (

  SELECT 
    mountain,
    country,
    ROUND(meters, 2) AS meters,
    ROUND(feet, 2) AS feet,
    ROUND(latitude, 2) AS latitude,
    ROUND(longitude, 2) AS longitude
  
  FROM mountains_cte_1

),

mountains_in_south_america AS (

  SELECT * 
  
  FROM mountains_cte
  
  WHERE country IN ('Ecuador', 'Peru', 'Bolivia', 'Chile', 'Argentina')

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
  
  FROM mountains_in_south_america

),

top_ranked_mountains AS (

  SELECT * 
  
  FROM ranked_mountains
  
  WHERE rank <= 3

)

SELECT *

FROM top_ranked_mountains
