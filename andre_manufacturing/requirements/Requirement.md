# Introduction
This document outlines the data sources, transformation steps, and target schemas for a predictive maintenance and anomaly detection solution in industrial manufacturing. The solution leverages IoT sensor data to compute machine health scores, detect anomalies, and schedule maintenance, thereby reducing unplanned downtime and optimizing machine performance.

## Data Sources

### 1. machines
- **Description:** Details of machines deployed in the manufacturing plant.
- **Fields:**  
  - machine_id  
  - machine_name  
  - model_number  
  - manufacturer  
  - installation_date  
  - warranty_expiration  

### 2. sensors
- **Description:** IoT sensor data capturing machine conditions.
- **Fields:**  
  - sensor_id  
  - sensor_type  
  - measurement_unit  
  - machine_id  
  - installation_date  

### 3. sensor_readings
- **Description:** Real-time readings from IoT sensors.
- **Fields:**  
  - reading_id  
  - sensor_id  
  - reading_value  
  - timestamp  

### 4. events
- **Description:** Records of anomalies and incidents occurring in machines.
- **Fields:**  
  - event_id  
  - event_timestamp  
  - machine_id  
  - event_type  
  - severity  
  - description  

### 5. iot_data_wide
- **Description:** Comprehensive IoT data, including sensor metrics and machine status.
- **Fields:**  
  - machine_id  
  - sensor_id  
  - timestamp  
  - temperature  
  - vibration  
  - pressure  
  - uptime  
  - downtime  
  - error_code  
  - maintenance_required  
  - operational_status  

### 6. maintenance_schedule
- **Description:** Details of scheduled machine maintenance tasks.
- **Fields:**  
  - (No fields provided)

## Data Targets

### 1. Machine Health Summary
- **Description:** Contains aggregated machine performance metrics, computed health scores, and maintenance scheduling details for each machine.
- **Depends On:**  
  - machines  
  - iot_data_wide  
  - sensors  
  - sensor_readings  
  - events  
  - maintenance_schedule  
  - Intermediate Target: Machine Performance Scoring (from Transformation 1)  
  - Intermediate Target: Predictive Maintenance Scheduling (from Transformation 3)

- **Columns:**

| # | Name | Data Type | Transformation |
|---|------|-----------|----------------|
| 1 | machine_health_score | FLOAT | Computed in Transformation 1 by aggregating sensor readings (temperature, vibration, pressure), normalizing the values, and assigning weightage based on machine type to yield a score on a 0-100 scale. |
| 2 | maintenance_required | BOOLEAN | Derived in Transformation 3 by comparing the machine health score and historical maintenance patterns to determine if maintenance is needed. |
| 3 | next_maintenance_date | DATE | Predicted in Transformation 3 based on historical maintenance patterns and estimated time-to-failure. |
| 4 | last_maintenance_date | DATE | Evaluated in Transformation 3 by identifying the most recent maintenance date for the machine. |
| 5 | avg_temperature | DOUBLE | Calculated in Transformation 1 by aggregating temperature sensor readings over time. |
| 6 | avg_vibration | DOUBLE | Calculated in Transformation 1 by aggregating vibration sensor readings over time. |
| 7 | avg_pressure | DOUBLE | Calculated in Transformation 1 by aggregating pressure sensor readings over time. |
| 8 | uptime_hours | DOUBLE | Sourced from iot_data_wide, representing total operational hours of the machine. |
| 9 | downtime_hours | DOUBLE | Sourced from iot_data_wide, representing total non-operational hours of the machine. |
| 10 | operational_status | VARCHAR | Sourced from iot_data_wide, indicating the current machine status (Active, Idle, Under Maintenance). |
| 11 | machine_id | INT | Carried over directly from the machines table to uniquely identify each machine. |
| 12 | machine_name | VARCHAR | Carried over directly from the machines table for identification. |
| 13 | model_number | VARCHAR | Carried over directly from the machines table representing machine model identification. |
| 14 | manufacturer | VARCHAR | Carried over directly from the machines table to indicate the machine manufacturer. |

- **Transformation Steps:**
  - **Step 1: Compute performance score**  
    - Aggregate sensor readings (temperature, vibration, pressure) from iot_data_wide, sensors, and sensor_readings. Normalize these values, assign weightage based on machine type, and compute an overall machine health score (0-100 scale) as defined in Transformation 1.
  - **Step 2: Schedule maintenance**  
    - Identify machines with recurring anomalies or declining health scores using insights from Transformation 2. Estimate time to failure using historical patterns from maintenance_schedule and events, and determine maintenance_required, last_maintenance_date, and next_maintenance_date as defined in Transformation 3.
  - **Step 3: Join machine static info**  
    - Merge the results from the sensor aggregation and maintenance scheduling with static machine information from the machines table to build the final Machine Health Summary target.

### 2. Predictive Maintenance Alerts
- **Description:** Captures alerts generated from detected anomalies with severity levels, sensor details, and recommended operator actions.
- **Depends On:**  
  - iot_data_wide  
  - sensor_readings  
  - events  
  - Intermediate Target: Machine Performance Scoring (from Transformation 1)  
  - Intermediate Target: Anomaly Detection Result (from Transformation 2)

- **Columns:**

| # | Name | Data Type | Transformation |
|---|------|-----------|----------------|
| 1 | maintenance_scheduled | BOOLEAN | Set in Transformation 2 by auto-scheduling maintenance tasks when anomalies are detected and conditions are met. |
| 2 | resolution_status | VARCHAR | Assigned in Transformation 2 to indicate the current status of the alert (Open, Investigating, Resolved). |
| 3 | recommended_action | VARCHAR | Derived in Transformation 2 by generating suggested operator actions based on detected anomalies and risk thresholds. |
| 4 | threshold_exceeded | BOOLEAN | Flagged in Transformation 2 to indicate whether a sensor reading (temperature, vibration, pressure) exceeded a critical threshold. |
| 5 | error_code | VARCHAR | Carried from iot_data_wide when an anomaly is detected or generated during the transformation process in Transformation 2. |
| 6 | alert_level | INT | Computed in Transformation 2 where severity is assigned (1=Low, 2=Moderate, 3=High) based on the extent of deviation in sensor values. |
| 7 | alert_type | VARCHAR | Categorized in Transformation 2 (e.g., Temperature Spike, High Vibration) based on the type of sensor anomaly detected. |
| 8 | sensor_reading | FLOAT | Sourced from sensor_readings reflecting the specific value recorded at the time of the alert, used in Transformation 2. |
| 9 | sensor_id | INT | Sourced from sensor_readings to identify which sensor triggered the alert in Transformation 2. |
| 10 | machine_id | INT | Carried over from events and iot_data_wide to link the alert to the corresponding machine in Transformation 2. |
| 11 | timestamp | TIMESTAMP | Represents the time when the alert was generated, sourced from events in Transformation 2. |
| 12 | alert_id | INT | A unique identifier for the alert, generated as part of the alerting process in Transformation 2. |

- **Transformation Steps:**
  - **Step 1: Detect outliers**  
    - Identify outliers in temperature, vibration, and pressure using sensor readings from sensor_readings and corresponding data from iot_data_wide, as described in Transformation 2.
  - **Step 2: Flag risk conditions**  
    - Check sensor values against predefined risk thresholds and flag cases where the values exceed these limits.
  - **Step 3: Generate alerts**  
    - Based on the flagged conditions and with input from the machine performance scoring (Transformation 1), generate alerts. Assign severity levels (alert_level), determine alert_type, and set sensor details (sensor_id, sensor_reading). Include error_code if an anomaly is detected.
  - **Step 4: Recommend actions and schedule maintenance**  
    - Generate recommended actions for operators, set the maintenance_scheduled flag, and record resolution_status. This completes the alerting process as defined in Transformation 2.