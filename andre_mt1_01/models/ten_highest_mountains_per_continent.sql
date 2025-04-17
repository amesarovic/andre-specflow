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
    c.Continent_Name,
    c.Continent_Code
  
  FROM mountains_cte_1 AS m
  JOIN countries_cte_1 AS c
     ON m.country = c.Country_Name

),

partitioned_data AS (

  SELECT 
    mountain,
    country,
    meters,
    feet,
    latitude,
    longitude,
    Continent_Name,
    Continent_Code,
    ROW_NUMBER() OVER (PARTITION BY Continent_Name ORDER BY meters DESC) AS rank
  
  FROM joined_data

),

top_ranked_data AS (

  SELECT *
  
  FROM partitioned_data
  
  WHERE rank <= 10

)

SELECT *

FROM top_ranked_data
