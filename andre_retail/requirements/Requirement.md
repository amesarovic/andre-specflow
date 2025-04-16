# Introduction
The Retail Multi-Dimensional Performance for Convenience & Specialty Stores use case transforms raw transactional, product, and store data into actionable insights for retail decision-makers. The objective is to empower business users and analysts with detailed performance metrics covering sales, product performance, customer behavior, inventory management, and promotion effectiveness to drive decisions on inventory replenishment, promotions, and operational efficiencies.

## Data Sources

### 1. stores
- **Description:** Information about different retail store locations used to join with transaction records and derive store-level performance metrics.
- **Fields:**  
  - store_id  
  - store_name  
  - store_type  
  - phone_number  
  - email  
  - opening_date  

### 2. products
- **Description:** Details of products available in stores used in performance analysis and inventory evaluations.
- **Fields:**  
  - product_id  
  - product_name  
  - category  
  - price  
  - stock_quantity  
  - supplier_id  

### 3. customers
- **Description:** Records of customers registered in the system used to analyze purchasing patterns and segment customers.
- **Fields:**  
  - customer_id  
  - first_name  
  - last_name  
  - email  
  - phone  
  - birth_date  
  - registration_date  

### 4. transactions
- **Description:** Transaction records capturing purchases made by customers used for sales aggregation, customer segmentation, and promotion analyses.
- **Fields:**  
  - transaction_id  
  - transaction_date  
  - store_id  
  - customer_id  
  - total_amount  
  - payment_method  

### 5. transaction_items
- **Description:** Details of each item in a transaction used to compute product-level metrics such as units sold and revenue.
- **Fields:**  
  - transaction_item_id  
  - transaction_id  
  - product_id  
  - quantity  
  - price  

### 6. inventory
- **Description:** Tracks available stock at each store used for inventory and reorder analysis.
- **Fields:**  
  - inventory_id  
  - product_id  
  - store_id  
  - available_stock  
  - reorder_level  

### 7. store_special_offers
- **Description:** Special discounts and promotional offers available at stores used to assess promotion effectiveness on sales uplift.
- **Fields:**  
  - offer_id  
  - store_id  
  - description  
  - start_date  
  - end_date  
  - discount_percentage  

### 8. customer_feedback
- **Description:** Customer submitted feedback used to derive customer satisfaction scores and product review metrics.
- **Fields:**  
  - feedback_id  
  - customer_id  
  - feedback  
  - date_submitted  

## Data Targets

### 1. Product_Sales_Details
- **Description:** Aggregated product-level sales and performance details including revenue, units sold, pricing metrics, promotion effects, and additional performance indicators.
- **Depends On:**  
  - transaction_items  
  - products  
  - inventory  
  - aggregated_store_sales (output from Transformation 1 – Store Sales Aggregation)  
  - store_special_offers  
  - transactions  

- **Columns:**

| # | Name                        | Data Type       | Transformation |
|---|-----------------------------|-----------------|----------------|
| 1 | price_adjustment_factor     | decimal(10,2)   | Derived via complex expression comparing current product price with historical trends; factors in past price changes to compute an average trend. |
| 2 | custom_index                | decimal(10,2)   | Calculated by blending discount amount, customer reviews, and sales growth into one overall index reflecting the product’s market impact. |
| 3 | complex_expression_metric   | decimal(10,2)   | Composite metric combining effective price and average daily sales with multiple layers of calculations to indicate overall performance. |
| 4 | derived_flag                | boolean         | Flag set if complex conditions such as low stock combined with high demand are met. |
| 5 | promo_uplift_effect         | decimal(10,2)   | Computed from store special offers and transactions; measures sales increase during promotion periods versus non-promotion periods as a percentage uplift. |
| 6 | online_order_count          | int             | Count of online orders for the product; derived from transactional data during promotion analysis. |
| 7 | total_transactions          | int             | Total number of transactions that included the product computed from aggregated transaction details. |
| 8 | price_variance              | decimal(10,2)   | Measures variability in sale prices over time, indicating pricing stability and market behavior. |
| 9 | sales_growth_rate           | decimal(10,2)   | Computed by comparing current to previous period sales, expressed as a percentage change, with error handling for zero previous sales. |
| 10 | review_count              | int             | Total number of product reviews aggregated from customer feedback data. |
| 11 | avg_product_review         | decimal(3,2)    | Average review rating for the product based on customer feedback. |
| 12 | supplier_name              | string          | Derived by joining supplier information from products; represents the product’s supplier name. |
| 13 | stock_depletion_estimate   | int             | Estimated days until stock depletion calculated by dividing available_stock by average daily sales, with safe defaults for zero sales. |
| 14 | available_stock            | int             | Carried from the inventory table representing the current number of items in stock. |
| 15 | reorder_level              | int             | Carried from the inventory table; threshold triggering a reorder. |
| 16 | effective_price            | decimal(10,2)   | Calculated by subtracting discount_applied from the original price to show the final customer price. |
| 17 | discount_applied           | decimal(10,2)   | Determined by checking if a discount during special offers is available; if not, defaults to zero. |
| 18 | max_sale_price           | decimal(10,2)   | Derived from aggregated store sales data as the highest sale price achieved for the product. |
| 19 | min_sale_price           | decimal(10,2)   | Derived from aggregated store sales data as the lowest sale price achieved for the product. |
| 20 | avg_daily_sales           | decimal(10,2)   | Calculated from aggregated store sales data representing average units sold per day. |
| 21 | total_product_revenue      | decimal(10,2)   | Summation of revenue per product computed by joining transaction_items with products and inventory data. |
| 22 | total_units_sold           | int             | Count of units sold per product aggregated from transaction_items. |
| 23 | stock_quantity             | int             | Carried from the products table representing the total stock quantity available for sale. |
| 24 | price                      | decimal(10,2)   | Original listed product price as provided in the products source table. |
| 25 | category                   | string          | Carried directly from the products table; indicates the product category. |
| 26 | product_name               | string          | Directly carried from the products table representing the name of the product. |
| 27 | product_id                 | int             | Unique identifier for the product; carried directly from the products table. |

- **Transformation Steps:**
  - **Step 1: Join and Aggregate Data**
    - Join transaction_items with products and inventory on product_id to compute total_units_sold and total_product_revenue.
  - **Step 2: Integrate Aggregated Sales**
    - Use aggregated_store_sales (from Transformation 1) to derive daily sales metrics such as avg_daily_sales, min_sale_price, and max_sale_price.
  - **Step 3: Determine Pricing Adjustments**
    - Calculate discount_applied based on special offers from store_special_offers, and derive effective_price by subtracting the discount from the original price.
  - **Step 4: Merge Promotion Analysis**
    - Integrate promotion data from store_special_offers and transactions to compute promo_uplift_effect and online_order_count.
  - **Step 5: Compute Advanced Metrics**
    - Derive metrics such as derived_flag, complex_expression_metric, custom_index, and price_adjustment_factor using layered calculations that include comparisons with historical trends and performance indicators.
  - **Step 6: Final Field Carriage**
    - Carry over remaining fields directly from their respective sources ensuring consistency in product identifiers and descriptive details.

### 2. Customer_Purchase_Insights
- **Description:** Provides insights on customer purchasing behavior, capturing spending totals, frequency, favorite product categories, loyalty, and feedback scores for tailored marketing and loyalty programs.
- **Depends On:**  
  - transactions  
  - customers  
  - transaction_items  
  - customer_feedback  

- **Columns:**

| # | Name                 | Data Type       | Transformation |
|---|----------------------|-----------------|----------------|
| 1 | feedback_score       | decimal(3,2)    | Calculated as the average score from customer_feedback records reflecting overall customer satisfaction. |
| 2 | online_purchase_ratio| decimal(10,2)   | Derived by calculating the percentage of online orders compared to the total orders from transactions data. |
| 3 | avg_order_value      | decimal(10,2)   | Computed by dividing total_spent by the number of orders, indicating average spending per order. |
| 4 | loyalty_points       | int             | Aggregated from customer activity and loyalty programs, reflecting total loyalty points earned. |
| 5 | favorite_category    | string          | Identified by analyzing transaction_items to extract the most frequently purchased product category by the customer. |
| 6 | purchase_frequency   | int             | Count of transactions per customer indicating how often purchases are made. |
| 7 | total_spent          | decimal(10,2)   | Summation of total_amount from transactions per customer representing overall spending. |
| 8 | full_name            | string          | Created by combining first_name and last_name from the customers table. |
| 9 | customer_id          | int             | Directly carried from customers as the unique identifier for each customer. |

- **Transformation Steps:**
  - **Step 1: Link Customer Transactions**
    - Join transactions with customers to associate purchase records with customer details.
  - **Step 2: Segment and Aggregate Spending**
    - Aggregate total_spent and count transactions per customer to derive purchase_frequency and calculate avg_order_value.
  - **Step 3: Analyze Product Preferences**
    - Use transaction_items to identify favorite_category based on frequency of purchased product categories.
  - **Step 4: Compute Additional Metrics**
    - Derive online_purchase_ratio by comparing online orders against all orders, and compute loyalty_points from customer activity.
  - **Step 5: Merge Feedback Data**
    - Integrate customer_feedback to calculate feedback_score for an overall measure of customer satisfaction.

### 3. Inventory_Reorder_Alerts
- **Description:** Provides alerts and estimates for inventory reordering by identifying products with low available_stock, estimating days until stock depletion, and computing a criticality index for prompt action.
- **Depends On:**  
  - inventory  
  - products  
  - transactions  
  - product_performance (output from Transformation 2 – Product Performance Analysis)  

- **Columns:**

| # | Name                      | Data Type       | Transformation |
|---|---------------------------|-----------------|----------------|
| 1 | criticality_index         | decimal(10,2)   | Computed by combining current stock levels, average daily sales, and supplier reliability to indicate reorder urgency. |
| 2 | last_restock_date         | date            | Derived directly from inventory records indicating the most recent product restock date. |
| 3 | alert_flag                | boolean         | Flag determined as true if available_stock is below the reorder_level threshold. |
| 4 | estimated_depletion_days  | int             | Estimated by dividing available_stock by avg_daily_sales from recent sales data, with defaults for zero sales to avoid errors. |
| 5 | avg_daily_sales           | decimal(10,2)   | Calculated from transactions data to determine the average units sold per day for each product. |
| 6 | reorder_level             | int             | Carried from the inventory table indicating the minimum stock level triggering a reorder. |
| 7 | available_stock           | int             | Current stock level carried from the inventory table. |
| 8 | product_name              | string          | Derived directly from the products table representing the product’s name. |
| 9 | product_id                | int             | Unique identifier for the product carried directly from the products table. |

- **Transformation Steps:**
  - **Step 1: Calculate Sales Velocity**
    - Analyze transactions to compute avg_daily_sales for each product indicating the sales velocity.
  - **Step 2: Estimate Depletion**
    - Estimate estimated_depletion_days by dividing available_stock by avg_daily_sales, with provisions for zero-sale scenarios.
  - **Step 3: Identify Reorder Conditions**
    - Compare available_stock with reorder_level to set alert_flag when stock levels are below the threshold.
  - **Step 4: Compute Criticality**
    - Derive criticality_index using current stock, sales rate, and supplier reliability to assess the urgency for reorder.
  - **Step 5: Capture Restock Data**
    - Directly capture last_restock_date from inventory to reflect the most recent restocking event.