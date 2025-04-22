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

tall_mountains AS (

  SELECT *
  
  FROM mountains_cte
  
  WHERE meters > 6000

),

south_american_mountains AS (

  SELECT *
  
  FROM tall_mountains
  
  WHERE country IN ('Argentina', 'Bolivia', 'Chile', 'Colombia', 'Ecuador', 'Peru', 'Venezuela')

),

countries_above_gdp_threshold AS (

  SELECT *
  
  FROM countries
  
  WHERE gdp_per_capita > 10000

),

countries_cte AS (

  SELECT 
    country_name,
    continent_name,
    population,
    ROUND(gdp_per_capita, 2) AS gdp_per_capita,
    country
  
  FROM countries_above_gdp_threshold

),

final_cte AS (

  SELECT 
    c.country_name,
    c.continent_name,
    c.population,
    c.gdp_per_capita,
    m.mountain,
    m.country,
    m.meters,
    m.feet,
    m.latitude,
    m.longitude
  
  FROM south_american_mountains AS m
  JOIN countries_cte AS c
     ON m.country = c.country

)

SELECT *

FROM final_cte
