{{
  config({    
    "database": "andre_dev",
    "schema": "andre_mt_01_out"
  })
}}

WITH countries_cte_1 AS (

  SELECT * 
  
  FROM {{ source('product_dev.mountains', 'countries') }}

),

countries_cte AS (

  SELECT 
    Country_Name AS country_name,
    Three_Letter_Country_Code AS three_letter_country_code,
    Continent_Code AS continent_code
  
  FROM countries_cte_1

)

SELECT *

FROM countries_cte
