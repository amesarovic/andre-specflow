{{
  config({    
    "database": "andre_dev",
    "schema": "andre_mt_01_out"
  })
}}

WITH mountains_cte_1 AS (

  SELECT * 
  
  FROM {{ source('product_dev.mountains', 'mountains') }}

),

mountains_above_6000 AS (

  SELECT * 
  
  FROM mountains_cte_1
  
  WHERE meters > 6000

),

distance_calculation AS (

  SELECT 
    mountain,
    country,
    meters,
    feet,
    latitude,
    longitude,
    6371
    * ACOS(
        COS(RADIANS(-27.1092))
        * COS(RADIANS(latitude))
        * COS(RADIANS(longitude) - RADIANS(-68.5414))
        + SIN(RADIANS(-27.1092)) * SIN(RADIANS(latitude))) AS distance_from_ojos
  
  FROM mountains_above_6000

),

nearby_locations AS (

  SELECT * 
  
  FROM distance_calculation
  
  WHERE distance_from_ojos <= 200

)

SELECT *

FROM nearby_locations
