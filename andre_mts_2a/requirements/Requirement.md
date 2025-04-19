# Introduction
This document outlines the business objectives to extract and transform mountain and country data. The goal is to produce various reports that detail the highest peaks under specific geographic and economic filters. The transformations apply consistent rounding of all floating point values to two decimal places while filtering and sorting mountain details according to the specified business questions.

## Data Sources

### 1. product_dev.mountains.mountains
- **Description:** Contains detailed information about mountains including attributes such as names, heights, and other related details. This table is used as the primary source for mountain information.
- **Fields:**
  - (fields not specified in the document)

### 2. product_dev.mountains.countries
- **Description:** Contains country-level information including regional affiliation, GDP per capita, and other economic indicators. This table is used to filter and join with mountain data based on geographic and economic criteria.
- **Fields:**
  - (fields not specified in the document)

## Data Targets

### 1. Transformation 1 - Ten Highest Peaks in South America
- **Description:** Returns details for the ten highest peaks in South America, sorted by the highest peak.
- **Depends On:**
  - product_dev.mountains.mountains
  - product_dev.mountains.countries

- **Columns:**

| # | Name | Data Type | Transformation |
|---|------|-----------|----------------|
| 1 | height | FLOAT | Floating point values rounded to two decimals; used to sort peaks (modified from product_dev.mountains.mountains). |
| 2 | mountain_name | VARCHAR | Directly taken from product_dev.mountains.mountains. |
| 3 | country | VARCHAR | Joined from product_dev.mountains.countries to filter for South America. |
| 4 | mountain_id | INT | Directly carried from product_dev.mountains.mountains. |

- **Transformation Steps:**
  - **Step 1: Round floating values**
    - Round off all floating point values to two places.
  - **Step 2: Filter by continent**
    - Filter records to include only mountains located in South America using product_dev.mountains.countries.
  - **Step 3: Sort descending**
    - Sort the filtered mountains by the height column in descending order.
  - **Step 4: Limit results**
    - Select the top ten records.

### 2. Transformation 2 - Three Highest Mountains in Andean Countries
- **Description:** Returns mountain details for the three highest mountains in the Andean countries, sorted by the highest peak.
- **Depends On:**
  - product_dev.mountains.mountains
  - product_dev.mountains.countries

- **Columns:**

| # | Name | Data Type | Transformation |
|---|------|-----------|----------------|
| 1 | height | FLOAT | Floating point values rounded to two decimals; used to sort peaks (modified from product_dev.mountains.mountains). |
| 2 | mountain_name | VARCHAR | Directly taken from product_dev.mountains.mountains. |
| 3 | country | VARCHAR | Joined from product_dev.mountains.countries filtering for Andean countries. |
| 4 | mountain_id | INT | Directly carried from product_dev.mountains.mountains. |

- **Transformation Steps:**
  - **Step 1: Round floating values**
    - Round off all floating point values to two places.
  - **Step 2: Filter Andean countries**
    - Filter records to include only mountains located in Andean countries using product_dev.mountains.countries.
  - **Step 3: Sort descending**
    - Sort the filtered mountains by height in descending order.
  - **Step 4: Limit results**
    - Select the top three records.

### 3. Transformation 3 - Three Highest Peaks for Each Country (Southward from Ecuador)
- **Description:** For each country, returns its three highest peaks to support a travel plan beginning in Ecuador and moving southward.
- **Depends On:**
  - product_dev.mountains.mountains
  - product_dev.mountains.countries

- **Columns:**

| # | Name | Data Type | Transformation |
|---|------|-----------|----------------|
| 1 | height | FLOAT | Floating point values rounded to two decimals; used to determine ranking (modified from product_dev.mountains.mountains). |
| 2 | mountain_name | VARCHAR | Directly taken from product_dev.mountains.mountains. |
| 3 | country | VARCHAR | Joined from product_dev.mountains.countries to group peaks by country. |
| 4 | mountain_id | INT | Directly carried from product_dev.mountains.mountains. |

- **Transformation Steps:**
  - **Step 1: Round floating values**
    - Round off all floating point values to two places.
  - **Step 2: Define country grouping**
    - Group mountains by country using product_dev.mountains.countries.
  - **Step 3: Sort within groups**
    - Within each country group, sort mountains by height in descending order.
  - **Step 4: Limit results per group**
    - For each country, select the top three records.

### 4. Transformation 4 - Ten Highest Peaks in Non-Andean South American Countries
- **Description:** Returns details for the ten highest peaks in South America from non-Andean countries, sorted by the highest peak.
- **Depends On:**
  - product_dev.mountains.mountains
  - product_dev.mountains.countries

- **Columns:**

| # | Name | Data Type | Transformation |
|---|------|-----------|----------------|
| 1 | height | FLOAT | Floating point values rounded to two decimals; used to sort peaks (modified from product_dev.mountains.mountains). |
| 2 | mountain_name | VARCHAR | Directly taken from product_dev.mountains.mountains. |
| 3 | country | VARCHAR | Joined from product_dev.mountains.countries filtering for non-Andean South American countries. |
| 4 | mountain_id | INT | Directly carried from product_dev.mountains.mountains. |

- **Transformation Steps:**
  - **Step 1: Round floating values**
    - Round off all floating point values to two places.
  - **Step 2: Filter South America**
    - Filter records to include only mountains in South America using product_dev.mountains.countries.
  - **Step 3: Exclude Andean countries**
    - Exclude mountains located in Andean countries.
  - **Step 4: Sort descending and limit**
    - Sort the remaining records by height in descending order and select the top ten.

### 5. Transformation 5 - Mountains over 6000m in Andes with High GDP Countries
- **Description:** Returns details for mountains higher than 6000 meters in the Andes that are located in countries with a GDP per capita of more than ten thousand dollars a year, including corresponding country information.
- **Depends On:**
  - product_dev.mountains.mountains
  - product_dev.mountains.countries

- **Columns:**

| # | Name | Data Type | Transformation |
|---|------|-----------|----------------|
| 1 | GDP_per_capita | FLOAT | Floating point value rounded to two decimals; directly taken from product_dev.mountains.countries and filtered for values greater than 10000 (new column). |
| 2 | height | FLOAT | Floating point values rounded to two decimals and filtered for values > 6000 (modified from product_dev.mountains.mountains). |
| 3 | mountain_name | VARCHAR | Directly taken from product_dev.mountains.mountains. |
| 4 | country | VARCHAR | Joined from product_dev.mountains.countries filtering for Andean region and GDP criteria. |
| 5 | mountain_id | INT | Directly carried from product_dev.mountains.mountains. |

- **Transformation Steps:**
  - **Step 1: Round floating values**
    - Round off all floating point values to two places.
  - **Step 2: Filter by height**
    - Filter mountains from product_dev.mountains.mountains with height greater than 6000 meters.
  - **Step 3: Filter Andean countries**
    - Join with product_dev.mountains.countries and filter for mountains in the Andes.
  - **Step 4: Filter by GDP**
    - Further filter countries with a GDP per capita greater than $10,000.
  - **Step 5: Select details**
    - Retrieve the mountain and corresponding country information.

### 6. Transformation 6 - Top Five Mountains South of Ecuador over 6000m
- **Description:** For each country south of Ecuador, returns the top five mountains that are higher than 6000 meters.
- **Depends On:**
  - product_dev.mountains.mountains
  - product_dev.mountains.countries

- **Columns:**

| # | Name | Data Type | Transformation |
|---|------|-----------|----------------|
| 1 | height | FLOAT | Floating point values rounded to two decimals and filtered for values > 6000 (modified from product_dev.mountains.mountains). |
| 2 | mountain_name | VARCHAR | Directly taken from product_dev.mountains.mountains. |
| 3 | country | VARCHAR | Joined from product_dev.mountains.countries filtering for countries south of Ecuador. |
| 4 | mountain_id | INT | Directly carried from product_dev.mountains.mountains. |

- **Transformation Steps:**
  - **Step 1: Round floating values**
    - Round off all floating point values to two places.
  - **Step 2: Filter by height**
    - Filter mountains with height greater than 6000 meters.
  - **Step 3: Filter by geography**
    - Join with product_dev.mountains.countries and filter for countries located south of Ecuador.
  - **Step 4: Sort within groups**
    - For each country, sort the mountains by height in descending order.
  - **Step 5: Limit results per group**
    - For each country, select the top five records.