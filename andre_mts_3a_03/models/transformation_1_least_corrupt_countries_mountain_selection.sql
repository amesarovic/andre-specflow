WITH countries_corruption_cte AS (

  SELECT * 
  
  FROM {{ source('andre_dev.data', 'countries_corruption') }}

),

countries_cte AS (

  SELECT * 
  
  FROM {{ source('andre_dev.data', 'countries') }}

),

mountains_cte AS (

  SELECT * 
  
  FROM {{ source('andre_dev.data', 'mountains') }}

),

tall_mountains_south_america AS (

  SELECT * 
  
  FROM mountains_cte
  
  WHERE meters > 5000 AND region = 'South America'

),

filtered_mountains AS (

  SELECT 
    mountain,
    country,
    meters,
    ROUND(latitude, 2) AS latitude,
    ROUND(longitude, 2) AS longitude,
    region
  
  FROM tall_mountains_south_america

),

south_america_countries AS (

  SELECT *
  
  FROM countries_corruption_cte
  
  WHERE country IN (
          SELECT Country_Name
          
          FROM countries_cte
          
          WHERE Continent_Name = 'South America'
         )

),

ordered_by_score AS (

  SELECT * 
  
  FROM south_america_countries
  
  ORDER BY score DESC

),

limited_results AS (

  SELECT * 
  
  FROM ordered_by_score
  
  LIMIT 3

),

least_corrupt_countries AS (

  SELECT 
    country,
    ROUND(score, 2) AS country_corruption_score
  
  FROM limited_results

),

joined_mountains AS (

  SELECT 
    fm.mountain,
    fm.country,
    fm.meters,
    fm.latitude,
    fm.longitude,
    fm.region,
    lcc.country_corruption_score
  
  FROM filtered_mountains AS fm
  JOIN least_corrupt_countries AS lcc
     ON fm.country = lcc.country

),

sorted_mountains AS (

  SELECT * 
  
  FROM joined_mountains
  
  ORDER BY meters DESC

),

limit_3_from_cte_5 AS (

  SELECT * 
  
  FROM sorted_mountains
  
  LIMIT 3

)

SELECT *

FROM limit_3_from_cte_5
