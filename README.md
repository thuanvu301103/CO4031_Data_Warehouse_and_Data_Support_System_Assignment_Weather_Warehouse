# Data Warehouse Design and Implementation

## Requirement

## General Structure
```css
[Data Sources] → [ETL (Apache NiFi)] → [Staging Area] → [Data Warehouse] → [BI Tools]
```

## Data Source
The data used in this project comes from 2 source:
- Weather data: collected daily through [MeteoSource API](https://www.meteosource.com/) and is provided in JSON format. It typically includes parameters such as temperature, humidity, precipitation, and other atmospheric conditions.
- Soil salinity data: obtained from a flat file in [CSV format](asset/dump_data/weekly_salinity_report.csv). This file serves as a weekly aggregation of soil salinity levels. This dataset is collected weekly from reports issued by the Southern Regional Hydrometeorological Center of Vietnam's [website](https://www.kttv-nb.org.vn/).

## Create Data houseware Schema on PostgreSQL

### Create new Database using pgADMIN
1. Open `pgAdmin`.
2. Go to `Object` => `Create` => `Database`.
3. Enter the database name (for example: `Climeweather_dw`).
4. Select encoding: `UTF8`.
5. Click `Save`.

### Write SQL to create schema and tables
Run [SQL queries](SQL/pgadmin_query/create_DW_schema.sql) in `pgAdmin`'s `Query Tool` to create Schema tables

### Insert sample data 
- Run [SQL queries](SQL/pgadmin_query/insert_DW_schema_sample_data.sql) to insert sample data into dimension tables
- Run [Python scripts](asset/dump_python_script) to insert sample data into cleaned staging area tables

### Visualize ERD
1. Choose a table in `Object Explorer`
2. Click right-mouse button then choose `ERD for table`

The Schema for Data Warehouse is the same as this: ![ERD](asset/image/ERD.png)

## Design Staging Area
- Staging Area will store raw data from many different sources (weather API, IoT, satellite sensor) and cleaned data before entering Data Warehouse.
- Type of Tables in Staging Area:
	- Raw data table: store un-processed data from Data Source
		- The data will be saved in the form of `JSONB` for flexibility.
		- There is an additional `Processed` column to mark the processed data or not.
	- Cleaned data table: store processed data, the data is ready to be imported into Data Warehouse 

### Create tables in Staging area
Run [SQL queries](SQL/pgadmin_query/create_DW_staging_area.sql) in `pgAdmin`'s `Query Tool` to create Raw data Staging Tables and Cleaned data Staging Tables

## Summary Data
Summary Data refers to aggregated or pre-computed data in a Data Warehouse, designed to improve query performance and facilitate rapid analysis. Instead of repeatedly querying large, detailed datasets, users can work with condensed, pre-summarized information

### Create Summary Data tables
- Run [SQL queries](SQL/pgadmin_query/create_DW_summary_table.sql) to create summary data tables
- The tables contain summarized weather data by week and by month

### Insert sample Summary Data
Run [SQL queries](SQL/pgadmin_query/insert_DW_summary_table_dâ.sql) to insert summary data from fact tables

## ETL (Extract-Transform-Load) Technology
`Apache Nifi` (Compatible with real-time data, provide visual interface) for ETL from Data Source to Staging Area

### Install and Start Apache Nifi (version 2.2.0)
1. Download Nifi: Visit the Apache NiFi Downloads page and choose the version suitable for your operating system (Windows, macOS, or Linux).
2. Extract the Files: Extract the `.zip` file.
3. Set up Java: Ensure you have Java 8 or Java 11 installed. Running `java -version` in terminal to check.
4. Configure NiFi: Navigate to the `conf` folder in the extracted NiFi directory. Edit the `nifi.properties` file to set up configurations like ports, repositories, and sensitive properties.
5. Start NiFi: Open Terminal then navigate to `bin` folder. Run `.\nifi.cmd start`.
6. Access the NiFi UI: Open a web browser and go to `https://localhost:8443/nifi` (default port).
7. Log in: username and password are automatically created by Nifi and stored in `logs/nifi-app.log`

### ETL Pipeline

#### ETL from Data Source to Staging Area 
- ETL weather data (import [processor](ApacheNifi_processor/1_Source_to_Staging/ETL_Weather_Data.json) into Nifi): execute every day
	- Extract: fetch weather data from API
	- Transform: replace missing values
	- Load: load transformed weather data into `staging_weather_raw` table
- ETL soil salinity data (import [processor](ApacheNifi_processor/1_Source_to_Staging/ETL_Salinity_Data.json) into Nifi): execute every week
	- Extract: fetch salinity data from CSV file ([weekly salinity report](asset/dump_data/weekly_salinity_report.csv))
	- Transform: replace missing values
	- Load: load transformed salinity data into `staging_salinity_raw` table

#### Process raw data in Staging Area
Process raw data in raw data tables. Tranform `JSONB` data into cleaned data then insert them into cleaned data tables. Execute every week (import [processor](ApacheNifi_processor/2_Process_in_Staging/Process_Data_in_Staging_Area.json)).
- Tranform raw weather data from `staging_weather_raw` table into cleaned weather data then insert into `staging_weather_cleaned` table using [Python script](Python_script/transform_raw_weather_data.py)
- Tranform raw salinity data from `staging_salinity_raw` table into cleaned salinity data then insert into `staging_salinity_cleaned` table using [Python script](Python_script/transform_raw_salinity_data.py)

#### ETL from Staging Area to DWH
- Insert data from `staging_weather_cleaned` into `fact_weather`
- Delete data in `staging_weather_cleaned` table

## DWH and OLAP Server

### Data

#### Detailed, granular data
Stored in `fact _weather` and dimetional tables

#### Aggregated or summarized data
Run [SQL queries](SQL/nifi_flow_query/update_summarized_data.sql) to summarize data in Nifi

## BI Tool

### Power BI
Power BI is a strong BI (Business Intelligence) tool, which helps you analyze and visualize data from Data Warehouse easily.

### Connect Power BI to PostgreSQL
1. Open `Power BI` → `Home` → `Get Data` → `More...`
2. Choose `Database` → `PostgreSQL database` → `Connect` 
3. Input connection information:
	- Server: `localhost:5432`
	- Database: `climeweather_dw`
4. Choose `DirectQuery`
5. Input username and password

### Query data from Data Warehouse
1. In `Home` → `Recent sources`
2. Choose PostgreSQL server that has been connected
3. Choose the data table that need to be used (the data can be Transformed before Loaded)

### Generate Report 