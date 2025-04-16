{{
  config({    
    "materialized": "table",
    "database": "trading",
    "schema": "andre_out"
  })
}}

WITH enriched_trade_file_1_cte AS (

  SELECT * 
  
  FROM {{ source('trading.default', 'enriched_trade_file_1') }}

),

enriched_trade_records AS (

  SELECT * 
  
  FROM enriched_trade_file_1_cte
  
  WHERE exclude_flag = 'N'

),

trade_transactions AS (

  SELECT 
    deal_id AS transaction_id,
    trade_date,
    security_name AS security_ticker,
    face_value AS quantity,
    aud_revalue AS trade_price,
    aud_revalue * 1.05 AS market_price,
    trader_name AS broker_id,
    counterparty_name AS client_id,
    'Completed' AS trade_status
  
  FROM enriched_trade_records

),

profit_loss_calculation AS (

  SELECT 
    transaction_id,
    trade_date,
    security_ticker,
    quantity,
    trade_price,
    market_price,
    broker_id,
    client_id,
    trade_status,
    (market_price - trade_price) * quantity AS profit_loss
  
  FROM trade_transactions

),

broker_performance_aggregation AS (

  SELECT 
    broker_id,
    SUM(profit_loss) AS broker_performance
  
  FROM profit_loss_calculation
  
  GROUP BY broker_id

),

client_profitability_aggregation AS (

  SELECT 
    client_id,
    SUM(profit_loss) AS client_profitability
  
  FROM profit_loss_calculation
  
  GROUP BY client_id

),

derived_logic_summary_cte AS (

  SELECT 
    transaction_id,
    'Profit/Loss calculated as (market_price - trade_price) * quantity. Liquidity impact and risk classification to be added.' AS derived_logic_summary
  
  FROM profit_loss_calculation

),

final_cte AS (

  SELECT 
    pt.transaction_id,
    pt.trade_date,
    pt.security_ticker,
    pt.quantity,
    pt.trade_price,
    pt.market_price,
    pt.broker_id,
    pt.client_id,
    pt.trade_status,
    pt.profit_loss,
    bp.broker_performance,
    cp.client_profitability,
    dls.derived_logic_summary
  
  FROM profit_loss_calculation AS pt
  JOIN broker_performance_aggregation AS bp
     ON pt.broker_id = bp.broker_id
  JOIN client_profitability_aggregation AS cp
     ON pt.client_id = cp.client_id
  JOIN derived_logic_summary_cte AS dls
     ON pt.transaction_id = dls.transaction_id

)

SELECT *

FROM final_cte
