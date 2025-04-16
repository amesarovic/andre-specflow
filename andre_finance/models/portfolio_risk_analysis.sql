WITH trade_data AS (

  SELECT 
    portfolio_id,
    COUNT(*) AS trade_count,
    MAX(portfolio_value) - MIN(portfolio_value) AS drawdown_percentage,
    STDDEV(portfolio_value) AS portfolio_volatility
  
  FROM trade_transactions
  
  GROUP BY portfolio_id

),

risk_metrics AS (

  SELECT 
    portfolio_id,
    (AVG(portfolio_value) - risk_free_rate) / STDDEV(portfolio_value) AS sharpe_ratio,
    VARIANCE(portfolio_value) AS value_at_risk_var_
  
  FROM trade_transactions
  
  GROUP BY portfolio_id

),

expected_return_cte AS (

  SELECT 
    portfolio_id,
    AVG(portfolio_value) * 0.05 AS expected_return
  
  FROM trade_transactions
  
  GROUP BY portfolio_id

),

sector_exposure_cte AS (

  SELECT 
    portfolio_id,
    GROUP_CONCAT(sector, ', ') AS sector_exposure
  
  FROM (
    SELECT 
      portfolio_id,
      sector
    
    FROM portfolio_composition
    
    GROUP BY 
      portfolio_id, sector
  ) AS subquery
  
  GROUP BY portfolio_id

),

final_cte AS (

  SELECT 
    pd.portfolio_id,
    pd.client_id,
    pd.portfolio_value,
    pd.last_update,
    td.trade_count,
    td.drawdown_percentage,
    td.portfolio_volatility,
    rm.sharpe_ratio,
    rm.value_at_risk_var_,
    er.expected_return,
    se.sector_exposure,
    CASE
      WHEN rm.sharpe_ratio < 1
        THEN 'High Risk'
      WHEN rm.sharpe_ratio BETWEEN 1 AND 2
        THEN 'Medium Risk'
      ELSE 'Low Risk'
    END AS risk_category
  
  FROM portfolio_table AS pd
  JOIN trade_data AS td
     ON pd.portfolio_id = td.portfolio_id
  JOIN risk_metrics AS rm
     ON pd.portfolio_id = rm.portfolio_id
  JOIN expected_return_cte AS er
     ON pd.portfolio_id = er.portfolio_id
  JOIN sector_exposure_cte AS se
     ON pd.portfolio_id = se.portfolio_id

)

SELECT *

FROM final_cte
