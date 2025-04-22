# Introduction
This document supports enhanced analytics on some of the world’s highest mountains with a particular focus on the Andes range in South America. It provides detailed transformation steps and target table specifications to extract mountain details, filtered and sorted by various criteria, to fully inform exploration and understanding of the lay of the land.

## Data Sources

### 1. Mountains Table
- **Description:** Contains mountain peak data from Open Peaks (geojson format).
- **Fields:**  
  - mountain
  - country
  - meters
  - feet
  - latitude
  - longitude

### 2. Countries tables
- **Description:** Contains country details including continent mapping, population, and GDP per capita data from World Bank (2023).
- **Fields:**  
  - Country_Name
  - Continent_Name
  - Population
  - GDP Per_Capita

## Data Targets

### 1. Transformation 1 Target
- **Description:** Details for the ten highest peaks in South America sorted by highest peak.
- **Depends On:**  
  - Mountains Table
  - Countries tables

- **Columns:**

| # | Name      | Data Type | Transformation |
|---|-----------|-----------|----------------|
| 1 | mountain  | VARCHAR   | Retained directly from Mountains Table. |
| 2 | country   | VARCHAR   | Retained directly from Mountains Table; used for joining with Countries tables. |
| 3 | meters    | FLOAT     | Rounded off to two places (from Mountains Table). |
| 4 | feet      | FLOAT     | Rounded off to two places (from Mountains Table). |
| 5 | latitude  | FLOAT     | Rounded off to two places (from Mountains Table). |
| 6 | longitude | FLOAT     | Rounded off to two places (from Mountains Table). |

- **Transformation Steps:**
  - **Step 1: Round float values**
    - Round off all floating point columns (meters, feet, latitude, longitude) to two decimal places.
  - **Step 2: Filter South America peaks**
    - Join Mountains Table with Countries tables on the matching country names. Filter records where Continent_Name equals "South America".
  - **Step 3: Sort and limit**
    - Sort the filtered records by "meters" in descending order and select the top ten highest peaks.

### 2. Transformation 2 Target
- **Description:** Mountain details for the three highest mountains in the Andean countries sorted by highest peak.
- **Depends On:**  
  - Mountains Table
  - Countries tables

- **Columns:**

| # | Name      | Data Type | Transformation |
|---|-----------|-----------|----------------|
| 1 | mountain  | VARCHAR   | Retained directly from Mountains Table. |
| 2 | country   | VARCHAR   | Retained directly from Mountains Table; used for joining with Countries tables. |
| 3 | meters    | FLOAT     | Rounded off to two places (from Mountains Table). |
| 4 | feet      | FLOAT     | Rounded off to two places (from Mountains Table). |
| 5 | latitude  | FLOAT     | Rounded off to two places (from Mountains Table). |
| 6 | longitude | FLOAT     | Rounded off to two places (from Mountains Table). |

- **Transformation Steps:**
  - **Step 1: Round float values**
    - Round off all floating point columns (meters, feet, latitude, longitude) to two decimal places.
  - **Step 2: Filter Andean countries**
    - Join Mountains Table with Countries tables on matching country names and filter records corresponding to Andean countries.
  - **Step 3: Sort and limit**
    - Sort the filtered records by "meters" in descending order and select the top three highest peaks.

### 3. Transformation 3 Target
- **Description:** For each country starting from Ecuador and moving southward, show the three highest peaks.
- **Depends On:**  
  - Mountains Table
  - Countries tables

- **Columns:**

| # | Name      | Data Type | Transformation |
|---|-----------|-----------|----------------|
| 1 | mountain  | VARCHAR   | Retained directly from Mountains Table. |
| 2 | country   | VARCHAR   | Retained directly from Mountains Table; used for matching with Countries tables. |
| 3 | meters    | FLOAT     | Rounded off to two places (from Mountains Table). |
| 4 | feet      | FLOAT     | Rounded off to two places (from Mountains Table). |
| 5 | latitude  | FLOAT     | Rounded off to two places (from Mountains Table). |
| 6 | longitude | FLOAT     | Rounded off to two places (from Mountains Table). |

- **Transformation Steps:**
  - **Step 1: Round float values**
    - Round off all floating point columns (meters, feet, latitude, longitude) to two decimal places.
  - **Step 2: Filter by direction**
    - Identify records from the Mountains Table for countries starting from Ecuador and extending southward.
  - **Step 3: Partition and select**
    - Partition the data by country and select the top three highest peaks for each country based on "meters" in descending order.

### 4. Transformation 4 Target
- **Description:** Details for the ten highest peaks in non-Andean countries in South America sorted by highest peak.
- **Depends On:**  
  - Mountains Table
  - Countries tables

- **Columns:**

| # | Name      | Data Type | Transformation |
|---|-----------|-----------|----------------|
| 1 | mountain  | VARCHAR   | Retained directly from Mountains Table. |
| 2 | country   | VARCHAR   | Retained directly from Mountains Table; used for joining with Countries tables. |
| 3 | meters    | FLOAT     | Rounded off to two places (from Mountains Table). |
| 4 | feet      | FLOAT     | Rounded off to two places (from Mountains Table). |
| 5 | latitude  | FLOAT     | Rounded off to two places (from Mountains Table). |
| 6 | longitude | FLOAT     | Rounded off to two places (from Mountains Table). |

- **Transformation Steps:**
  - **Step 1: Round float values**
    - Round off all floating point columns (meters, feet, latitude, longitude) to two decimal places.
  - **Step 2: Filter non-Andean in South America**
    - Join Mountains Table with Countries tables on country names and filter records where Continent_Name equals "South America" while excluding Andean countries.
  - **Step 3: Sort and limit**
    - Sort the resulting records by "meters" in descending order and select the top ten records.

### 5. Transformation 5 Target
- **Description:** Mountains higher than 6000 meters in the Andes with country information for nations with a GDP per capita over ten thousand dollars a year.
- **Depends On:**  
  - Mountains Table
  - Countries tables

- **Columns:**

| # | Name            | Data Type | Transformation |
|---|-----------------|-----------|----------------|
| 1 | Country_Name    | VARCHAR   | Added from Countries tables to provide the country standard name. |
| 2 | Continent_Name  | VARCHAR   | Added from Countries tables for continental mapping. |
| 3 | Population      | INT       | Added from Countries tables representing country population. |
| 4 | GDP Per_Capita  | FLOAT     | Added from Countries tables; values are rounded off to two decimal places and filtered for being over 10000. |
| 5 | mountain        | VARCHAR   | Retained directly from Mountains Table. |
| 6 | country         | VARCHAR   | Retained directly from Mountains Table; join key with Countries tables. |
| 7 | meters          | FLOAT     | Rounded off to two places (from Mountains Table); must be greater than 6000. |
| 8 | feet            | FLOAT     | Rounded off to two places (from Mountains Table). |
| 9 | latitude        | FLOAT     | Rounded off to two places (from Mountains Table). |
| 10 | longitude       | FLOAT     | Rounded off to two places (from Mountains Table). |

- **Transformation Steps:**
  - **Step 1: Round float values**
    - Round off all floating point columns (meters, feet, latitude, longitude, and GDP Per_Capita if applicable) to two decimal places.
  - **Step 2: Filter mountain height**
    - From the joined data, filter records where "meters" is greater than 6000.
  - **Step 3: Filter Andean countries**
    - Further filter the dataset to include only records corresponding to Andean countries.
  - **Step 4: Filter by GDP**
    - Filter to include only those countries with GDP Per_Capita greater than 10000.
  - **Step 5: Select required fields**
    - Return both mountain details and country information as specified.

### 6. Transformation 6 Target
- **Description:** For each country south of Ecuador, show the top five mountains that are higher than 6000 meters.
- **Depends On:**  
  - Mountains Table
  - Countries tables

- **Columns:**

| # | Name      | Data Type | Transformation |
|---|-----------|-----------|----------------|
| 1 | mountain  | VARCHAR   | Retained directly from Mountains Table. |
| 2 | country   | VARCHAR   | Retained directly from Mountains Table; used for joining with Countries tables. |
| 3 | meters    | FLOAT     | Rounded off to two places (from Mountains Table); must be greater than 6000. |
| 4 | feet      | FLOAT     | Rounded off to two places (from Mountains Table). |
| 5 | latitude  | FLOAT     | Rounded off to two places (from Mountains Table). |
| 6 | longitude | FLOAT     | Rounded off to two places (from Mountains Table). |

- **Transformation Steps:**
  - **Step 1: Round float values**
    - Round off all floating point columns (meters, feet, latitude, longitude) to two decimal places.
  - **Step 2: Filter mountain height**
    - Filter records where "meters" is greater than 6000.
  - **Step 3: Filter by geographic direction**
    - Join Mountains Table with Countries tables on country names and filter for countries located south of Ecuador.
  - **Step 4: Partition and select**
    - For each country, partition the data and select the top five mountains based on "meters" in descending order.