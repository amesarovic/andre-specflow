WITH mountains_cte_1 AS (

  SELECT * 
  
  FROM {{ source('product_dev.mountains', 'mountains') }}

),

countries_cte_1 AS (

  SELECT * 
  
  FROM {{ source('product_dev.mountains', 'countries') }}

),

joined_data AS (

  SELECT 
    m.mountain,
    m.country,
    m.meters,
    m.feet,
    m.latitude,
    m.longitude,
    c.Continent_Name
  
  FROM mountains_cte_1 AS m
  JOIN countries_cte_1 AS c
     ON m.country = c.Country_Name

),

ranked_mountains AS (

  SELECT 
    mountain,
    country,
    meters,
    feet,
    latitude,
    longitude,
    Continent_Name,
    ROW_NUMBER() OVER (PARTITION BY Continent_Name ORDER BY latitude DESC) AS rn
  
  FROM joined_data

),

top_ranked_mountains AS (

  SELECT * 
  
  FROM ranked_mountains
  
  WHERE rn <= 5

)

SELECT *

FROM top_ranked_mountains
