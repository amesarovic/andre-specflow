WITH transformation_5_target_cte_1 AS (

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

tall_mountains AS (

  SELECT *
  
  FROM mountains_cte
  
  WHERE meters > 6000

),

countries_southern_hemisphere AS (

  SELECT *
  
  FROM transformation_5_target_cte_1
  
  WHERE latitude < 0

),

joined_data AS (

  SELECT 
    fm.mountain,
    fm.country,
    fm.meters,
    fm.feet,
    fm.latitude,
    fm.longitude
  
  FROM tall_mountains AS fm
  JOIN countries_southern_hemisphere AS c
     ON fm.country = c.country

),

ranked_mountains AS (

  SELECT 
    mountain,
    country,
    meters,
    feet,
    latitude,
    longitude,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY meters DESC) AS rn
  
  FROM joined_data

),

top_ranked_mountains AS (

  SELECT *
  
  FROM ranked_mountains
  
  WHERE rn <= 5

)

SELECT *

FROM top_ranked_mountains
