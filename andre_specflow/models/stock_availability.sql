WITH enriched_trade_file_1_cte_1 AS (

  SELECT *
  
  FROM {{ ref('enriched_trade_file_1') }}

),

portfolio_to_gl_cte AS (

  SELECT *
  
  FROM {{ source('trading.raw', 'portfolio_to_gl') }}

),

active_government_bonds AS (

  SELECT *
  
  FROM enriched_trade_file_1_cte_1
  
  WHERE LOWER(issuer_type) IN ('gov', 'semi gov')
        AND maturity_date >= CURRENT_DATE
        AND LOWER(counterparty_name) LIKE '%ext%'

),

filtered_trades AS (

  SELECT 
    deal_id,
    security_id,
    currency,
    portfolio_name,
    location,
    counterparty_name,
    face_value,
    trader_name,
    trade_date,
    settlement_date,
    maturity_date,
    buy_sell,
    trade_type,
    aud_revalue,
    gl_level_1,
    CASE
      WHEN trade_type = 'BOND' AND buy_sell = 'b'
        THEN 'Long Stock'
      WHEN trade_type = 'REPO' AND buy_sell = 's'
        THEN 'Reverse Repo'
    END AS asset
  
  FROM active_government_bonds

),

valid_trades AS (

  SELECT *
  
  FROM filtered_trades
  
  WHERE NOT asset IS NULL

),

grouped_trades AS (

  SELECT 
    location,
    gl_level_1,
    security_id AS security_name,
    maturity_date,
    asset,
    SUM(aud_revalue) AS total_aud_long_position_available
  
  FROM valid_trades
  
  GROUP BY 
    location, gl_level_1, security_id, maturity_date, asset

),

gl_enriched_trades AS (

  SELECT 
    gt.*,
    COALESCE(ptg.GL_Level_1, 'Bank001') AS gl_level_1_coalesced
  
  FROM grouped_trades AS gt
  LEFT JOIN portfolio_to_gl_cte AS ptg
     ON gt.gl_level_1 = ptg.GL_Level_1 AND gt.location = ptg.location

),

final_cte AS (

  SELECT 
    total_aud_long_position_available,
    asset,
    security_name,
    maturity_date,
    gl_level_1_coalesced AS gl_level_1,
    location,
    'Gov' AS issuer_type
  
  FROM gl_enriched_trades

)

SELECT *

FROM final_cte
