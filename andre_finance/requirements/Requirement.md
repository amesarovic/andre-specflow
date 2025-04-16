# Introduction
This document outlines a stock market risk and profitability analysis system designed to analyze stock trades, client portfolios, and market trends. The system is built to assess risk exposure, calculate trade profitability, evaluate client and broker performance, and ultimately provide insights that assist investment banks in optimizing trading strategies, managing client risks, and ensuring regulatory compliance.

## Data Sources
### 1. trade_transactions
- **Description:** Records of stock trades executed by brokers and clients.
- **Fields:**
  - transaction_id
  - trade_date
  - security_ticker
  - quantity
  - price
  - total_value
  - broker_id
  - client_id
  - trade_status

### 2. clients
- **Description:** Details of investment clients.
- **Fields:**
  - client_id
  - full_name
  - email
  - phone_number
  - address
  - client_type

### 3. brokers
- **Description:** Information about stock brokers executing trades.
- **Fields:**
  - broker_id
  - broker_name
  - firm_name
  - email
  - phone_number

### 4. assets
- **Description:** Market details of financial assets.
- **Fields:**
  - asset_id
  - name
  - asset_type
  - current_value
  - currency
  - owner_id

### 5. portfolio
- **Description:** Client investment portfolios with valuations.
- **Fields:**
  - portfolio_id
  - client_id
  - portfolio_value
  - creation_date
  - last_update

### 6. big_trade_analysis
- **Description:** Trade analysis focusing on large transactions.
- **Fields:**
  - record_id
  - transaction_id
  - trade_date
  - security_ticker
  - quantity
  - price
  - total_value
  - broker_id
  - client_id
  - profit_loss
  - risk_assessment
  - trading_strategy
  - market_conditions

### 7. compliance_records
- **Description:** Records regulatory compliance data for market trades.
- **Fields:**
  - Not Specified

## Data Targets
### 1. Trade Profitability Summary
- **Description:** Provides a summary analysis of trade profitability while aggregating broker and client performance based on individual trade details.
- **Depends On:**  
  - trade_transactions
  - brokers
  - clients

- **Columns:**

| # | Name                     | Data Type | Transformation |
|---|--------------------------|-----------|----------------|
| 1 | broker_performance       | DECIMAL   | Evaluates broker effectiveness by aggregating profit/loss over multiple trades. Derived by aggregating profit/loss values from trade_transactions. |
| 2 | client_profitability     | DECIMAL   | Measures overall client profitability by summing all trade profits and losses for a given client. |
| 3 | trade_price              | DECIMAL   | Price at which the security was executed. Derived from trade execution details comparing execution price to market price. |
| 4 | market_price             | DECIMAL   | The current market price of the security as used for calculating profit/loss. |
| 5 | total_trade_value        | DECIMAL   | Calculated as trade_price multiplied by quantity, representing the total value of the trade. |
| 6 | profit_loss              | DECIMAL   | Calculated as (market_price - trade_price) * quantity, representing profit or loss per trade. |
| 7 | derived_logic_summary    | VARCHAR   | Summarizes how the calculations were performed for profit/loss, liquidity impact, and risk classification. |
| 8 | transaction_id           | VARCHAR   | Unique trade identifier carried directly from trade_transactions. |
| 9 | trade_date               | DATE      | Date when the trade was executed, carried directly from trade_transactions. |
| 10 | security_ticker         | VARCHAR   | Stock ticker symbol for the traded security, carried directly from trade_transactions. |
| 11 | quantity                | INT       | Number of shares traded, carried directly from trade_transactions. |
| 12 | broker_id               | VARCHAR   | Identifier for the broker executing the trade, carried directly from trade_transactions. |
| 13 | client_id               | VARCHAR   | Identifier for the client associated with the trade, carried directly from trade_transactions. |
| 14 | trade_status            | VARCHAR   | Indicates whether the trade was completed successfully or failed, carried directly from trade_transactions. |
| 15 | market_conditions       | VARCHAR   | Summary of the stock market’s behavior at the time of trade, carried directly from big_trade_analysis. |
| 16 | historical_performance  | OBJECT    | Details of past returns and stock performance trends, carried directly from big_trade_analysis. |
| 17 | liquidity_impact        | DECIMAL   | Evaluates the effect of the trade on the stock’s liquidity by comparing trade volume to average daily trading volume. |
| 18 | sector                  | VARCHAR   | The industry sector of the traded security. Derived from asset information or deduced from security_ticker. |
| 19 | expected_return         | DECIMAL   | Uses historical stock performance and market indicators to estimate future return. |
| 20 | risk_assessment         | VARCHAR   | Classifies the trade as “High Risk,” “Moderate Risk,” or “Low Risk” based on profitability trends, volatility, and Sharpe Ratio. |

- **Transformation Steps:**
  - **Step 1: Compute Profit/Loss**
    - Calculate profit/loss per trade by comparing the trade execution price (trade_price) to the current market price (market_price) and multiplying the difference by the quantity traded.
  - **Step 2: Aggregate Broker Performance**
    - Aggregate total profit/loss for each broker from individual trades to derive the broker_performance metric.
  - **Step 3: Compute Client Profitability**
    - Sum all individual trade profit/loss values per client to derive the client_profitability metric.
  - **Step 4: Summarize Derived Logic**
    - Generate a derived_logic_summary that captures the calculation methodology for profit/loss, liquidity impact, and risk classification.

### 2. Portfolio Risk Analysis
- **Description:** Evaluates client portfolio risk based on historical trade data and market volatility, providing risk measures and performance predictions.
- **Depends On:**  
  - portfolio
  - big_trade_analysis
  - trade_transactions

- **Columns:**

| # | Name                     | Data Type | Transformation |
|---|--------------------------|-----------|----------------|
| 1 | trade_count              | INT       | Total number of trades executed in the portfolio. Derived by counting relevant trade_transactions. |
| 2 | portfolio_volatility     | DECIMAL   | Measures the fluctuation in portfolio value over time. Calculated from portfolio trade history and market data. |
| 3 | drawdown_percentage      | DECIMAL   | Evaluates the largest decline from the peak portfolio value to the lowest recorded value, indicating potential loss risk. |
| 4 | sharpe_ratio             | DECIMAL   | Measures risk-adjusted return by using past portfolio returns and the risk-free rate. |
| 5 | value_at_risk (VaR)      | DECIMAL   | Estimates the worst expected portfolio loss in a given time frame under normal market conditions. |
| 6 | expected_return          | DECIMAL   | Predicted future gains calculated based on historical performance and current market conditions. |
| 7 | sector_exposure          | VARCHAR   | Breaks down the portfolio investments by industry sector. |
| 8 | risk_category            | VARCHAR   | Classifies the portfolio as “High Risk,” “Medium Risk,” or “Low Risk” based on Sharpe Ratio and market fluctuations. |
| 9 | portfolio_id             | VARCHAR   | Unique identifier for the client’s portfolio carried directly from the portfolio table. |
| 10 | client_id               | VARCHAR   | Identifier for the client owning the portfolio, carried directly from the portfolio table. |
| 11 | portfolio_value         | DECIMAL   | Total market value of the portfolio, carried directly from the portfolio table. |
| 12 | last_update             | TIMESTAMP | Timestamp of the last portfolio update, carried directly from the portfolio table. |

- **Transformation Steps:**
  - **Step 1: Analyze Portfolio Metrics**
    - Evaluate high-risk portfolios by analyzing historical trade data, focusing on volatility, liquidity, and drawdowns.
  - **Step 2: Assign Risk Categories**
    - Based on calculated metrics and market fluctuations, assign a risk_category to the portfolio.
  - **Step 3: Compute Risk-Adjusted Returns**
    - Derive the sharpe_ratio and value_at_risk (VaR) to assess risk-adjusted returns.
  - **Step 4: Compile Additional Metrics**
    - Calculate trade_count from trade_transactions, determine expected_return using historical data and market indicators, and assess sector_exposure from portfolio composition.