# Introduction
This document outlines the process of selecting mountain and country data to plan a hiking trip abroad. The overall purpose is to filter and join mountain records with country statistics based on specific criteria, including altitude, regional location, corruption, equality, and standard of living. All floating point values are rounded off to two decimal places.

## Data Sources

### 1. andre_dev.data.mountains
- **Description:** This table contains mountain details including altitude and related geographic information used to identify mountains over 5000 meters located in South America.
- **Fields:**
  - All fields available in the source table as defined in the Unity Catalog schema.

### 2. andre_dev.data.countries
- **Description:** This table contains country information, including GINI scores (for equality) and standard of living measured by GDP per capita.
- **Fields:**
  - All fields available in the source table as defined in the Unity Catalog schema.

### 3. andre_dev.data.countries_corruptio
- **Description:** This table contains country corruption data. The corruption score is defined such that a higher value indicates a less corrupt (better) country.
- **Fields:**
  - All fields available in the source table as defined in the Unity Catalog schema.

## Data Targets

### 1. Transformation 1: Least Corrupt Countries Mountain Selection
- **Description:** This target produces a selection of mountain details from andre_dev.data.mountains for mountains over 5000 meters located in South America. It joins these records with country corruption scores from andre_dev.data.countries_corruptio, limited to the three highest mountains in the three least corrupt countries.
- **Depends On:**
  - andre_dev.data.mountains
  - andre_dev.data.countries_corruptio

- **Columns:**

| # | Name                         | Data Type | Transformation |
|---|------------------------------|-----------|----------------|
| 1 | mountain_details             | VARCHAR   | Derived from andre_dev.data.mountains; selects mountain details for records where altitude > 5000 meters and located in South America. Floating point values are rounded to two decimal places. |
| 2 | country_corruption_score     | FLOAT     | Extracted from andre_dev.data.countries_corruptio; the corruption score is used to identify the least corrupt countries (i.e., those with the highest corruption score). Rounded to two decimal places. |

- **Transformation Steps:**
  - **Step 1: Filter Mountains**
    - Filter records in andre_dev.data.mountains where altitude is greater than 5000 meters and the location is in South America. Round all floating point values to two decimal places.
  - **Step 2: Select Least Corrupt Countries**
    - From andre_dev.data.countries_corruptio, filter countries located in South America and order them by corruption score in descending order (since a higher score means less corrupt). Select the top three countries.
  - **Step 3: Join and Select Top Mountains**
    - Join the filtered mountains with the selected country records using the appropriate country identifier. From the joined set, order the mountains by altitude in descending order and select the three highest mountains. 

### 2. Transformation 2: Most Equal Countries Mountain Selection
- **Description:** This target produces a selection of mountain details from andre_dev.data.mountains for mountains over 5000 meters located in South America. It joins these records with country equality scores from andre_dev.data.countries, where equality is measured by the GINI score (lower values indicate more equality), limited to the three highest mountains in the three most equal countries.
- **Depends On:**
  - andre_dev.data.mountains
  - andre_dev.data.countries

- **Columns:**

| # | Name                     | Data Type | Transformation |
|---|--------------------------|-----------|----------------|
| 1 | mountain_details         | VARCHAR   | Derived from andre_dev.data.mountains; selects mountain details for records where altitude > 5000 meters and located in South America. Floating point values are rounded to two decimal places. |
| 2 | country_equality_score   | FLOAT     | Extracted from andre_dev.data.countries; using the GINI score (with lower values indicating more equality) to identify the most equal countries. Rounded to two decimal places. |

- **Transformation Steps:**
  - **Step 1: Filter Mountains**
    - Filter records in andre_dev.data.mountains where altitude is above 5000 meters and the mountain is located in South America. Apply rounding on floating point numbers to two decimal places.
  - **Step 2: Select Most Equal Countries**
    - From andre_dev.data.countries, filter for South American countries and order them by the GINI score in ascending order (since lower values denote higher equality). Select the top three countries.
  - **Step 3: Join and Select Top Mountains**
    - Join the filtered mountain data with the selected countries using the country identifier. Order the resulting records by mountain altitude in descending order and pick the three highest mountains.

### 3. Transformation 3: Highest Standard of Living Countries Mountain Selection
- **Description:** This target produces a selection of mountain details from andre_dev.data.mountains for mountains over 5000 meters located in South America. It joins these records with the country standard of living data (GDP per capita) from andre_dev.data.countries, limited to the three highest mountains in the three countries with the highest standard of living.
- **Depends On:**
  - andre_dev.data.mountains
  - andre_dev.data.countries

- **Columns:**

| # | Name                           | Data Type | Transformation |
|---|--------------------------------|-----------|----------------|
| 1 | mountain_details               | VARCHAR   | Derived from andre_dev.data.mountains; selects mountain details for entries where altitude exceeds 5000 meters in South America. Floating point values are rounded to two decimal places. |
| 2 | country_standard_of_living     | FLOAT     | Extracted from andre_dev.data.countries; represents GDP per capita as the standard of living. Rounded to two decimal places. |

- **Transformation Steps:**
  - **Step 1: Filter Mountains**
    - From andre_dev.data.mountains, filter for records with altitude greater than 5000 meters and located in South America, rounding floating point numbers to two decimal places.
  - **Step 2: Select Countries by Standard of Living**
    - From andre_dev.data.countries, filter for South American countries and order them by the standard of living (GDP per capita) in descending order. Select the top three countries with the highest GDP per capita.
  - **Step 3: Join and Select Top Mountains**
    - Join the filtered mountains with the selected country records using the relevant country key. Order the joined results by mountain altitude in descending order and select the three highest mountains.