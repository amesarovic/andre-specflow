WITH exchange_rate_table_cte AS (

  SELECT *
  
  FROM {{ source('trading.raw', 'exchange_rate_table') }}

),

trade_file_1_cte_1 AS (

  SELECT *
  
  FROM {{ source('trading.raw', 'trade_file_1') }}

),

trade_file_2_cte_1 AS (

  SELECT *
  
  FROM {{ source('trading.raw', 'trade_file_2') }}

),

securities_list_cte AS (

  SELECT *
  
  FROM {{ source('trading.raw', 'securities_list') }}

),

portfolio_to_gl_cte AS (

  SELECT *
  
  FROM {{ source('trading.raw', 'portfolio_to_gl') }}

),

ranked_revals AS (

  SELECT 
    deal_id,
    security_id,
    currency,
    portfolio_name,
    reval_date,
    reval_value,
    ROW_NUMBER() OVER (PARTITION BY deal_id ORDER BY reval_date DESC) AS rn
  
  FROM trade_file_2_cte_1

),

top_ranked_revals AS (

  SELECT *
  
  FROM ranked_revals
  
  WHERE rn = 1

),

enriched_trades AS (

  SELECT 
    tf1.deal_id,
    tf1.security_id,
    tf1.currency,
    tf1.portfolio_name,
    tf1.location,
    tf1.counterparty_name,
    tf1.face_value,
    tf1.trader_name,
    tf1.trade_date,
    tf1.settlement_date,
    COALESCE(tf1.maturity_date, sl.maturity_date) AS maturity_date,
    tf1.buy_sell,
    tf1.trade_type,
    lr.reval_date,
    lr.reval_value,
    sl.security_name,
    sl.issuer_type,
    CASE
      WHEN tf1.trade_type IN ('BOND', 'REPO')
        THEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(sl.security_name, ' ', -1), '%', 1) AS DECIMAL (5, 2))
      ELSE NULL
    END AS coupon_rate
  
  FROM trade_file_1_cte_1 AS tf1
  JOIN top_ranked_revals AS lr
     ON tf1.deal_id = lr.deal_id
    AND tf1.security_id = lr.security_id
    AND tf1.currency = lr.currency
    AND tf1.portfolio_name = lr.portfolio_name
  LEFT JOIN securities_list_cte AS sl
     ON tf1.security_id = sl.security_id

),

gl_enriched_trades AS (

  SELECT 
    et.deal_id,
    et.security_id,
    et.currency,
    et.portfolio_name,
    et.location,
    et.counterparty_name,
    et.face_value,
    et.trader_name,
    et.trade_date,
    et.settlement_date,
    et.maturity_date,
    et.buy_sell,
    et.trade_type,
    et.reval_date,
    et.reval_value,
    et.security_name,
    et.issuer_type,
    et.coupon_rate,
    COALESCE(pg.GL_Level_1, 'Bank001') AS gl_level_1,
    COALESCE(pg.GL_Level_2, 'Branch001') AS gl_level_2,
    COALESCE(pg.GL_Level_3, 'Desk001') AS gl_level_3
  
  FROM enriched_trades AS et
  LEFT JOIN portfolio_to_gl_cte AS pg
     ON et.portfolio_name = pg.portfolio_name

),

exclude_flagged_trades AS (

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
    reval_date,
    reval_value,
    security_name,
    issuer_type,
    coupon_rate,
    gl_level_1,
    gl_level_2,
    gl_level_3,
    CASE
      WHEN trade_type = 'LOAN'
        THEN 'Y'
      ELSE 'N'
    END AS exclude_flag
  
  FROM gl_enriched_trades

),

aud_converted_trades AS (

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
    reval_date,
    reval_value,
    security_name,
    issuer_type,
    coupon_rate,
    gl_level_1,
    gl_level_2,
    gl_level_3,
    exclude_flag,
    CASE
      WHEN currency <> 'AUD'
        THEN reval_value
        * (
            SELECT Conversion_Rate
            
            FROM exchange_rate_table_cte
            
            WHERE Currency_1 = currency AND Currency_2 = 'AUD'
           )
      ELSE reval_value
    END AS aud_revalue
  
  FROM exclude_flagged_trades

)

SELECT *

FROM aud_converted_trades
