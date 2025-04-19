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
    Country_Name AS country,
    Country_Code,
    Continent_Name,
    Continent_Code,
    Population,
    ROUND(GDP_Per_Capita, 2) AS gdp_per_capita
  
  FROM countries_cte_1

),

grouped_mountains AS (

  SELECT 
    m.mountain,
    m.country,
    m.height,
    m.feet,
    m.latitude,
    m.longitude,
    m.region,
    c.gdp_per_capita
  
  FROM mountains_cte AS m
  JOIN countries_cte AS c
     ON m.country = c.country

),

sorted_mountains AS (

  SELECT 
    mountain,
    country,
    height,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY height DESC) AS rank
  
  FROM grouped_mountains

),

top_ranked_mountains AS (

  SELECT *
  
  FROM sorted_mountains
  
  WHERE rank <= 3

),

final_cte AS (

  SELECT 
    country,
    GROUP_CONCAT(mountain || ' (' || height || 'm)', ', ') AS top_mountains
  
  FROM top_ranked_mountains
  
  GROUP BY country

)

SELECT *

FROM final_cte
