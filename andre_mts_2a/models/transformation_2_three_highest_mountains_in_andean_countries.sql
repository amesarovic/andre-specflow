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
    CAST(meters AS FLOAT) AS height,
    CAST(feet AS FLOAT) AS feet,
    ROUND(latitude, 2) AS latitude,
    ROUND(longitude, 2) AS longitude,
    region
  
  FROM mountains_cte_1

),

countries_cte AS (

  SELECT 
    Country_Name,
    Country_Code,
    Continent_Name,
    Continent_Code,
    Population,
    ROUND(GDP_Per_Capita, 2) AS GDP_Per_Capita
  
  FROM countries_cte_1

),

south_american_countries AS (

  SELECT *
  
  FROM countries_cte
  
  WHERE Continent_Name = 'South America'
        AND Country_Name IN ('Argentina', 'Bolivia', 'Chile', 'Colombia', 'Ecuador', 'Peru', 'Venezuela')

),

filtered_mountains AS (

  SELECT 
    m.mountain,
    m.country,
    m.height,
    m.feet,
    m.latitude,
    m.longitude,
    m.region
  
  FROM mountains_cte AS m
  JOIN south_american_countries AS ac
     ON m.country = ac.Country_Name

),

sorted_mountains_by_height AS (

  SELECT *
  
  FROM filtered_mountains
  
  ORDER BY height DESC

),

top_3_mountains AS (

  SELECT *
  
  FROM sorted_mountains_by_height
  
  LIMIT 3

)

SELECT *

FROM top_3_mountains
