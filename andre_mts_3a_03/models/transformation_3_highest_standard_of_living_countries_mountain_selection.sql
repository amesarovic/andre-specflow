WITH countries_cte AS (

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
  
  WHERE meters > 5000 AND LOWER(region) = 'south america'

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
  
  FROM countries_cte
  
  WHERE LOWER(Continent_Name) = 'south america'

),

gdp_per_capita_desc AS (

  SELECT * 
  
  FROM south_america_countries
  
  ORDER BY GDP_Per_Capita DESC

),

limit_3_results AS (

  SELECT * 
  
  FROM gdp_per_capita_desc
  
  LIMIT 3

),

joined_mountains AS (

  SELECT 
    fm.mountain,
    fm.country,
    fm.meters,
    fm.latitude,
    fm.longitude,
    fm.region,
    ROUND(c.GDP_Per_Capita, 2) AS country_standard_of_living
  
  FROM filtered_mountains AS fm
  JOIN limit_3_results AS c
     ON fm.country = c.Country_Name

),

mountains_ordered_by_height AS (

  SELECT * 
  
  FROM joined_mountains
  
  ORDER BY meters DESC

),

limited_results AS (

  SELECT * 
  
  FROM mountains_ordered_by_height
  
  LIMIT 3

)

SELECT *

FROM limited_results
