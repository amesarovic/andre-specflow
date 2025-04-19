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

tall_mountains AS (

  SELECT *
  
  FROM mountains_cte
  
  WHERE height > 6000

),

countries_southern_hemisphere AS (

  SELECT *
  
  FROM countries_cte
  
  WHERE Country_Name IN (
          SELECT country
          
          FROM mountains_cte
          
          WHERE latitude < 0
         )

),

ranked_mountains AS (

  SELECT 
    fm.mountain,
    fm.country,
    fm.height,
    fm.feet,
    fm.latitude,
    fm.longitude,
    fm.region,
    ROW_NUMBER() OVER (PARTITION BY fm.country ORDER BY fm.height DESC) AS rank
  
  FROM tall_mountains AS fm
  JOIN countries_southern_hemisphere AS se
     ON fm.country = se.Country_Name

),

top_ranked_mountains AS (

  SELECT *
  
  FROM ranked_mountains
  
  WHERE rank <= 5

)

SELECT *

FROM top_ranked_mountains
