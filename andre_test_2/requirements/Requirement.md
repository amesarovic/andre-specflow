# Introduction
This document outlines the transformation logic to provide analysis on the world’s highest mountains. It defines the data sources and describes step-by-step transformations to generate various views including the five highest mountains per country, the ten highest per continent, northernmost mountains, selected country codes, and mountains higher than 6000 meters within a defined distance of Ojos del Salado.

## Data Sources

### 1. Mountains Table
- **Description:** Contains mountain details including name, associated country, height in meters and feet, latitude, and longitude.
- **Fields:**  
  - mountain  
  - country  
  - meters  
  - feet  
  - latitude  
  - longitude  

### 2. Countries Table
- **Description:** Contains country and continent information including standard country names, continent names, and several country code formats.
- **Fields:**  
  - Continent_Name  
  - Continent_Code  
  - Country_Name  
  - Two_Letter_Country_Code  
  - Three_Letter_Country_Code  
  - Country_Number  

## Data Targets

### 1. Five Highest Mountains per Country
- **Description:** Shows all mountain details for the five highest mountains in each country.
- **Depends On:**  
  - Mountains Table

- **Columns:**

| # | Name     | Data Type | Transformation |
|---|----------|-----------|----------------|
| 1 | mountain | VARCHAR   | Directly carried from Mountains Table. |
| 2 | country  | VARCHAR   | Directly carried from Mountains Table. |
| 3 | meters   | INT       | Directly carried from Mountains Table. |
| 4 | feet     | INT       | Directly carried from Mountains Table. |
| 5 | latitude | DECIMAL   | Directly carried from Mountains Table. |
| 6 | longitude| DECIMAL   | Directly carried from Mountains Table. |

- **Transformation Steps:**
  - **Step 1: Partition by country**  
    - Partition the data from the Mountains Table by the "country" column and order the rows by the "meters" column in descending order.
  - **Step 2: Select top five**  
    - For each country partition, select the top five rows to return all mountain details for the five highest mountains.

### 2. Ten Highest Mountains per Continent
- **Description:** Shows all mountain details for the ten highest mountains in each continent.
- **Depends On:**  
  - Mountains Table  
  - Countries Table

- **Columns:**

| # | Name     | Data Type | Transformation |
|---|----------|-----------|----------------|
| 1 | mountain | VARCHAR   | Directly carried from Mountains Table. |
| 2 | country  | VARCHAR   | Directly carried from Mountains Table. |
| 3 | meters   | INT       | Directly carried from Mountains Table. |
| 4 | feet     | INT       | Directly carried from Mountains Table. |
| 5 | latitude | DECIMAL   | Directly carried from Mountains Table. |
| 6 | longitude| DECIMAL   | Directly carried from Mountains Table. |

- **Transformation Steps:**
  - **Step 1: Join tables**  
    - Join the Mountains Table with the Countries Table on the "country" field from Mountains Table and "Country_Name" from Countries Table.
  - **Step 2: Partition by continent**  
    - Partition the joined data by the "Continent_Name" column from the Countries Table and order by "meters" in descending order.
  - **Step 3: Select top ten**  
    - For each continent partition, select the top ten rows to return the mountain details.

### 3. Most Northern Five Mountains per Country
- **Description:** Shows details for the five most northern mountains for each country.
- **Depends On:**  
  - Mountains Table

- **Columns:**

| # | Name     | Data Type | Transformation |
|---|----------|-----------|----------------|
| 1 | mountain | VARCHAR   | Directly carried from Mountains Table. |
| 2 | country  | VARCHAR   | Directly carried from Mountains Table. |
| 3 | meters   | INT       | Directly carried from Mountains Table. |
| 4 | feet     | INT       | Directly carried from Mountains Table. |
| 5 | latitude | DECIMAL   | Directly carried from Mountains Table. |
| 6 | longitude| DECIMAL   | Directly carried from Mountains Table. |

- **Transformation Steps:**
  - **Step 1: Partition by country**  
    - Partition the Mountains Table data by the "country" column and order by "latitude" in descending order (to capture the most northern locations).
  - **Step 2: Select top five**  
    - For each country partition, retrieve the top five rows based on the highest latitude values.

### 4. Most Northern Five Mountains per Continent
- **Description:** Shows details for the five most northern mountains for each continent.
- **Depends On:**  
  - Mountains Table  
  - Countries Table

- **Columns:**

| # | Name     | Data Type | Transformation |
|---|----------|-----------|----------------|
| 1 | mountain | VARCHAR   | Directly carried from Mountains Table. |
| 2 | country  | VARCHAR   | Directly carried from Mountains Table. |
| 3 | meters   | INT       | Directly carried from Mountains Table. |
| 4 | feet     | INT       | Directly carried from Mountains Table. |
| 5 | latitude | DECIMAL   | Directly carried from Mountains Table. |
| 6 | longitude| DECIMAL   | Directly carried from Mountains Table. |

- **Transformation Steps:**
  - **Step 1: Join tables**  
    - Join the Mountains Table with the Countries Table using the "country" field from Mountains Table and "Country_Name" from Countries Table.
  - **Step 2: Partition by continent**  
    - Partition the resulting data by the "Continent_Name" column and order by "latitude" in descending order.
  - **Step 3: Select top five**  
    - For each continent partition, select the top five rows based on the northernmost (highest latitude) values.

### 5. Country Codes and Continent Code
- **Description:** Shows all country names along with their three-letter country codes and the corresponding continent code.
- **Depends On:**  
  - Countries Table

- **Columns:**

| # | Name                        | Data Type | Transformation |
|---|-----------------------------|-----------|----------------|
| 1 | Country_Name                | VARCHAR   | Directly carried from Countries Table. |
| 2 | Three_Letter_Country_Code   | VARCHAR   | Directly carried from Countries Table. |
| 3 | Continent_Code              | VARCHAR   | Directly carried from Countries Table. |

- **Transformation Steps:**
  - **Step 1: Select country details**  
    - From the Countries Table, select and carry forward the "Country_Name", "Three_Letter_Country_Code", and "Continent_Code" fields.

### 6. Mountains >6000m near Ojos del Salado
- **Description:** Shows all mountain details for mountains higher than 6000 meters that are within 200 kilometers of Ojos del Salado mountain.
- **Depends On:**  
  - Mountains Table

- **Columns:**

| # | Name     | Data Type | Transformation |
|---|----------|-----------|----------------|
| 1 | mountain | VARCHAR   | Directly carried from Mountains Table. |
| 2 | country  | VARCHAR   | Directly carried from Mountains Table. |
| 3 | meters   | INT       | Directly carried from Mountains Table. |
| 4 | feet     | INT       | Directly carried from Mountains Table. |
| 5 | latitude | DECIMAL   | Directly carried from Mountains Table. |
| 6 | longitude| DECIMAL   | Directly carried from Mountains Table. |

- **Transformation Steps:**
  - **Step 1: Filter by height**  
    - Filter the Mountains Table to include only mountain records where the "meters" value is greater than 6000.
  - **Step 2: Calculate distance**  
    - For each remaining mountain record, calculate the distance from the mountain to Ojos del Salado using the latitude and longitude coordinates.
  - **Step 3: Filter by distance**  
    - Retain only those records where the calculated distance is within 200 kilometers of Ojos del Salado.
  - **Step 4: Retrieve mountain details**  
    - Return the full mountain details from those filtered records.