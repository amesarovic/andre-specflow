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
    ROUND(meters, 2) AS meters,
    ROUND(feet, 2) AS feet,
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
    ROUND(Population, 2) AS Population,
    ROUND(GDP_Per_Capita, 2) AS GDP_Per_Capita
  
  FROM countries_cte_1

),

mountain_country_info AS (

  SELECT 
    m.mountain AS m_mountain,
    m.meters AS m_meters,
    m.region AS m_region,
    m.country AS m_country,
    c.Country_Name AS c_Country_Name,
    c.Continent_Name AS c_Continent_Name
  
  FROM mountains_cte AS m
  JOIN countries_cte AS c
     ON m.country = c.Country_Name

),

south_america_excluding_countries AS (

  SELECT * 
  
  FROM mountain_country_info
  
  WHERE c_Continent_Name = 'South America'
        AND NOT c_Country_Name IN ('Argentina', 'Bolivia', 'Chile', 'Colombia', 'Ecuador', 'Peru', 'Venezuela')

),

south_american_mountains AS (

  SELECT 
    m_mountain AS mountain_name,
    m_country AS country,
    m_meters AS height,
    m_region AS region
  
  FROM south_america_excluding_countries

),

tallest_south_american_mountains AS (

  SELECT * 
  
  FROM south_american_mountains
  
  ORDER BY height DESC

),

top_10_mountains AS (

  SELECT * 
  
  FROM tallest_south_american_mountains
  
  LIMIT 10

)

SELECT *

FROM top_10_mountains
