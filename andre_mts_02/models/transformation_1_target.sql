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

south_america_continent AS (

  SELECT *
  
  FROM transformation_5_target_cte
  
  WHERE LOWER(continent_name) = 'south america'

),

joined_data AS (

  SELECT 
    m.mountain,
    m.country,
    m.meters,
    m.feet,
    m.latitude,
    m.longitude
  
  FROM mountains_cte AS m
  JOIN south_america_continent AS c
     ON LOWER(m.country) = LOWER(c.country_name)

),

sorted_joined_data AS (

  SELECT *
  
  FROM joined_data
  
  ORDER BY meters DESC

),

top_10_sorted_data AS (

  SELECT *
  
  FROM sorted_joined_data
  
  LIMIT 10

)

SELECT *

FROM top_10_sorted_data
