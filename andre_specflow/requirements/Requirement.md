# Introduction
This document outlines the treasury stock availability business use case. The process begins with extracting data from multiple input sources including trade files and security lists, followed by several enrichment and transformation steps. The transformed data is used to calculate key metrics such as the summary long position available for future collateral or repo use. The process includes data extraction and enrichment, applying exclusions and corrections, data tagging, and currency conversion via FX rate lookup, culminating in a final output file – Stock Availability – which is used for financial analysis and decision making.

## Data Sources

### 1. Trade File 1
- **Description:** Base trade data file containing 100,000 rows with transaction details. It provides the primary trade records that are initially enriched and transformed.
- **Fields:**
  - Deal id
  - Security id
  - Currency
  - Portfolio name
  - Location
  - Counterparty name
  - Face value
  - Trader Name
  - Trade Date
  - Settlement Date
  - Maturity date
  - Buy/Sell
  - Trade type

### 2. Trade File 2
- **Description:** Supplementary trade file with 300,000 rows, based on 100,000 deals and 3 different revaluation dates. Contains additional revaluation fields matching the first four columns of Trade File 1.
- **Fields:**
  - Deal ID
  - Security id
  - Currency
  - Portfolio Name
  - Reval Date
  - Reval value

### 3. Security List
- **Description:** Contains a generated list of 100 securities with details including security name, unique security id, ISO currency code, start date (derived from maturity date minus a defined number of years), maturity date, and issuer type. Security names follow specific naming conventions for GOV, Semi Gov, and Corporate bonds.
- **Fields:**
  - Security Name
  - Security id
  - Currency
  - Start Date
  - Maturity Date
  - Issuer Type

### 4. Portfolio to GL
- **Description:** A lookup table with 40 rows (10 per location) that maps portfolio names from Trade File 1 to specific GL (General Ledger) details.
- **Fields:**
  - Portfolio Name
  - Country
  - GL level 1
  - GL level 2
  - GL level 3

### 5. Exchange rate table
- **Description:** Lookup table used for converting non-AUD values to AUD. Contains FX conversion rates and rules to determine whether to divide or multiply based on currency pair order.
- **Fields:**
  - Currency 1
  - Currency 2
  - Conversion rate
  - Conversion rule

## Data Targets

### 1. Enriched Trade File 1 (Intermediate Target)
- **Description:** Intermediate enriched trade file created by combining data from Trade File 1 and Trade File 2, and then performing multiple enrichments including security detail joining, maturity date derivation, GL data enrichment, addition of a coupon rate, applying exclusion flags, and currency conversion to produce an AUD revalue column.
- **Depends On:**
  - Trade File 1
  - Trade File 2
  - Security List
  - Portfolio to GL
  - Exchange rate table

- **Columns:**

| # | Name | Data Type | Transformation |
|---|------|-----------|----------------|
| 1 | AUD revalue | NUMERIC | Derived by converting non-AUD revaluation values using the FX rate lookup table for trades of type BOND (buy/sell='b') and REPO (buy/sell='s'). |
| 2 | Exclude flag | VARCHAR | New column created to tag deals; set to 'Y' for LOANS deals. |
| 3 | Coupon rate | DECIMAL | Derived by parsing the security name from the Security List when TRADETYPE is BOND or REPO. |
| 4 | GL level 1 | VARCHAR | Enriched from the Portfolio to GL lookup table; if lookup fails, default value is set to 'Bank001'. |
| 5 | GL level 2 | VARCHAR | Enriched from the Portfolio to GL lookup table; if lookup fails, default value is set to 'Branch001'. |
| 6 | GL level 3 | VARCHAR | Enriched from the Portfolio to GL lookup table; if lookup fails, default value is set to 'Desk001'. |
| 7 | Maturity Date | DATE | If the Trade File 1 maturity date is NULL, it is derived from the corresponding security's maturity date in the Security List. |
| 8 | Deal id | INT | Taken directly from Trade File 1. |
| 9 | Security id | VARCHAR | Taken directly from Trade File 1. |
| 10 | Currency | VARCHAR | Taken directly from Trade File 1. |
| 11 | Portfolio name | VARCHAR | Taken directly from Trade File 1. |
| 12 | Location | VARCHAR | Taken directly from Trade File 1 (using ISO 3 letter country codes). |
| 13 | Counterparty name | VARCHAR | Taken directly from Trade File 1. |
| 14 | Face value | NUMERIC | Taken directly from Trade File 1. |
| 15 | Trader Name | VARCHAR | Taken directly from Trade File 1. |
| 16 | Trade Date | DATE | Taken directly from Trade File 1. |
| 17 | Settlement Date | DATE | Taken directly from Trade File 1. |
| 18 | Buy/Sell | CHAR | Taken directly from Trade File 1. |
| 19 | Trade type | VARCHAR | Taken directly from Trade File 1. |

- **Transformation Steps:**
  - **Step 1: Extract and Join**
    - Extract data from Trade File 1 and Trade File 2. Join these using the most recent revaluation date from Trade File 2.
  - **Step 2: Enrich Security Details**
    - For trades with TRADETYPE of BOND or REPO, join with the Security List to add security detail columns, derive the coupon rate by parsing the security name, and populate a missing maturity date using the security's maturity date.
  - **Step 3: Enrich with GL Data**
    - Join Trade File 1 with the Portfolio to GL lookup table to add GL level 1, GL level 2, and GL level 3. Default values (e.g., Bank001, Branch001, Desk001) are applied if the lookup fails.
  - **Step 4: Tag Data for Exclusions**
    - Create a new column, Exclude flag, in which each deal is tagged as 'Y' for LOANS.
  - **Step 5: Currency Conversion**
    - For trades in non-AUD currency, use the Exchange rate table to convert values to AUD and add the AUD revalue column.

### 2. Stock Availability (Final Data Target)
- **Description:** Final output file displaying a summary view of the treasury stock availability. It aggregates the enriched trade data to calculate the total AUD long position available for future collateral or repo use, categorizing assets as either 'Long Stock' or 'Reverse Repo'.
- **Depends On:**
  - Enriched Trade File 1
  - Portfolio to GL

- **Columns:**

| # | Name | Data Type | Transformation |
|---|------|-----------|----------------|
| 1 | Total AUD long position available | NUMERIC | Derived by summing the AUD revalue for trades: sum the AUD revalue for BOND trades with buy/sell = 'b' (designated as 'Long Stock') and for REPO trades with buy/sell = 's' (designated as 'Reverse Repo'), after filtering trades with issuer type Gov or Semi Gov, maturity date greater than or equal to today's date, and CounterpartyName containing 'Ext'. |
| 2 | Asset | VARCHAR | Derived from trade type and buy/sell indicator: if trade type is 'BOND' and buy/sell = 'b', then label as 'Long Stock'; if trade type is 'REPO' and buy/sell = 's', then label as 'Reverse Repo'. |
| 3 | Security name | VARCHAR | Taken from the enriched security details in the Security List (as incorporated into Enriched Trade File 1 through coupon rate derivation). |
| 4 | Maturity Date | DATE | Derived from the trade record or, if missing, from the Security List; ensured to be greater than or equal to today's date. |
| 5 | GL level 1 | VARCHAR | Derived from the Portfolio to GL lookup table via a join on Portfolio name. |
| 6 | Location | VARCHAR | Taken directly from Trade File data using ISO 3 letter country codes. |
| 7 | Issuer Type | VARCHAR | Derived from the Security List information; only valid values are 'Gov' or 'Semi Gov'. |

- **Transformation Steps:**
  - **Step 1: Trade Selection**
    - Select trades from Enriched Trade File 1 where the issuer type is Gov or Semi Gov, the maturity date is greater than or equal to today's date, and the CounterpartyName contains 'Ext'.
  - **Step 2: Aggregation by Group**
    - Group the selected trades by Location, GL level 1, Security name, and Maturity Date. Sum the AUD revalue for trades with trade type 'BOND' (buy/sell = 'b') as 'Long Stock' and for trades with trade type 'REPO' (buy/sell = 's') as 'Reverse Repo'.
  - **Step 3: Asset Labeling**
    - Assign asset labels based on trade grouping: 'Long Stock' for aggregated BOND deals and 'Reverse Repo' for aggregated REPO deals.
  - **Step 4: Final Mapping**
    - Incorporate the GL level 1 from the Portfolio to GL lookup and include the issuer type from the Security List to complete the final Stock Availability output.