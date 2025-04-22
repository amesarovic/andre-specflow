WITH mountains_cte_1 AS (

  SELECT * 
  
  FROM {{ source('product_dev.mountains', 'mountains') }}

),

countries_cte_1 AS (

  SELECT * 
  
  FROM {{ source('product_dev.mountains', 'countries') }}

),

mountains_cte AS (

  SELECT 
    mountain,
    country,
    ROUND(meters, 2) AS height,
    ROUND(feet, 2) AS feet,
    ROUND(latitude, 2) AS latitude,
    ROUND(longitude, 2) AS longitude,
    region
  
  FROM mountains_cte_1

),

south_america_countries AS (

  SELECT * 
  
  FROM countries_cte_1
  
  WHERE Continent_Name = 'South America'

),

countries_cte AS (

  SELECT 
    Country_Name,
    Country_Code,
    Continent_Name,
    Continent_Code,
    Population,
    ROUND(GDP_Per_Capita, 2) AS GDP_Per_Capita
  
  FROM south_america_countries

),

joined_data AS (

  SELECT 
    mountains_cte.mountain AS mountain_name,
    mountains_cte.country,
    mountains_cte.height,
    mountains_cte.feet,
    mountains_cte.latitude,
    mountains_cte.longitude,
    countries_cte.GDP_Per_Capita
  
  FROM mountains_cte
  JOIN countries_cte
     ON mountains_cte.country = countries_cte.Country_Name

),

sorted_by_height_desc AS (

  SELECT * 
  
  FROM joined_data
  
  ORDER BY height DESC

),

top_10_ordered_data AS (

  SELECT * 
  
  FROM sorted_by_height_desc
  
  LIMIT 10

)

SELECT *

FROM top_10_ordered_data
