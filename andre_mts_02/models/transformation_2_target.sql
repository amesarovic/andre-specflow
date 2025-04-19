WITH transformation_5_target_cte AS (

  SELECT *
  
  FROM {{ ref('transformation_5_target') }}

),

mountains_cte_1 AS (

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

andean_countries_1 AS (

  SELECT *
  
  FROM transformation_5_target_cte
  
  WHERE region = 'Andean'

),

filtered_mountains AS (

  SELECT 
    m.mountain,
    m.country,
    m.meters,
    m.feet,
    m.latitude,
    m.longitude
  
  FROM mountains_cte AS m
  JOIN andean_countries_1 AS ac
     ON LOWER(m.country) = LOWER(ac.country_name)

),

sorted_mountains_1 AS (

  SELECT *
  
  FROM filtered_mountains
  
  ORDER BY meters DESC

),

top_3_mountains AS (

  SELECT *
  
  FROM sorted_mountains_1
  
  LIMIT 3

)

SELECT *

FROM top_3_mountains
