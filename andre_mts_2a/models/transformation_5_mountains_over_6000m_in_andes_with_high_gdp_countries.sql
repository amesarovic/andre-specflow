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
    CAST(latitude AS FLOAT) AS latitude,
    CAST(longitude AS FLOAT) AS longitude,
    region
  
  FROM mountains_cte_1

),

countries_cte AS (

  SELECT 
    Country_Name AS country,
    Country_Code,
    Continent_Name,
    Continent_Code,
    CAST(Population AS FLOAT) AS population,
    CAST(GDP_Per_Capita AS FLOAT) AS gdp_per_capita
  
  FROM countries_cte_1

),

mountain_country_info AS (

  SELECT 
    m.mountain AS m_mountain,
    m.height AS m_height,
    m.latitude AS m_latitude,
    m.region AS m_region,
    m.country AS m_country,
    m.feet AS m_feet,
    m.longitude AS m_longitude,
    c.country AS c_country,
    c.gdp_per_capita AS c_gdp_per_capita
  
  FROM mountains_cte AS m
  JOIN countries_cte AS c
     ON m.country = c.country

),

high_gdp_and_height_andes AS (

  SELECT *
  
  FROM mountain_country_info
  
  WHERE c_gdp_per_capita > 10000 AND m_height > 6000 AND m_region = 'Andes'

),

filtered_mountains AS (

  SELECT 
    m_mountain AS mountain,
    m_country AS country,
    ROUND(m_height, 2) AS height,
    ROUND(m_feet, 2) AS feet,
    ROUND(m_latitude, 2) AS latitude,
    ROUND(m_longitude, 2) AS longitude,
    c_gdp_per_capita AS gdp_per_capita
  
  FROM high_gdp_and_height_andes

),

mountain_details AS (

  SELECT 
    mountain AS mountain_name,
    country,
    height,
    gdp_per_capita
  
  FROM filtered_mountains

)

SELECT *

FROM mountain_details
