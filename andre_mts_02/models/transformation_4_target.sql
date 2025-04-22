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
    ROUND(CAST(meters AS FLOAT), 2) AS meters,
    ROUND(CAST(feet AS FLOAT), 2) AS feet,
    ROUND(CAST(latitude AS FLOAT), 2) AS latitude,
    ROUND(CAST(longitude AS FLOAT), 2) AS longitude
  
  FROM mountains_cte_1

),

south_america_excluding_selected AS (

  SELECT *
  
  FROM transformation_5_target_cte
  
  WHERE continent_name = 'South America'
        AND NOT country_name IN ('Argentina', 'Bolivia', 'Chile', 'Colombia', 'Ecuador', 'Peru', 'Venezuela')

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
  JOIN south_america_excluding_selected AS c
     ON m.country = c.country

),

sorted_data AS (

  SELECT *
  
  FROM joined_data
  
  ORDER BY meters DESC

),

final_cte AS (

  SELECT *
  
  FROM sorted_data
  
  LIMIT 10

)

SELECT *

FROM final_cte
