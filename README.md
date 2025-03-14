# Data houseware 

## Requirement

## General Structure
```css
[Data Sources] → [ETL (Apache NiFi)] → [Staging Area] → [Data Warehouse] → [BI Tools]
```

## Data Source

## Create Data houseware Schema on PostgreSQL

### Create new Database on PGADMIN
1. Open `pgAdmin`.
2. Go to `Object` => `Create` => `Database`.
3. Enter the database name (for example: `Climeweather_dw`).
4. Select encoding: `UTF8`.
5. Click `Save`.

### Write SQL to create schema and tables
Run this SQL in `Query Tool`:
```sql
-- Create Schema ClimeWeather
CREATE SCHEMA climeweather;

-- Create Dimension table: dim_time
CREATE TABLE climeweather.dim_time (
    time_id INT PRIMARY KEY,
    date DATE NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    season VARCHAR(20) NOT NULL
);

-- Create Dimension table: dim_location
CREATE TABLE climeweather.dim_location (
    location_id SERIAL PRIMARY KEY,
    region VARCHAR(50) NOT NULL,
    province VARCHAR(50) NOT NULL,
    station_id VARCHAR(20) UNIQUE NOT NULL
);

-- Create Dimension table: dim_weather
CREATE TABLE climeweather.dim_weather (
    weather_id SERIAL PRIMARY KEY,
    weather_type VARCHAR(50) NOT NULL,
    ndvi NUMERIC(5, 2) NOT NULL
);

-- Create Fact table: fact_weather
CREATE TABLE climeweather.fact_weather (
    id SERIAL PRIMARY KEY,
    time_id INT NOT NULL,
    location_id INT NOT NULL,
    weather_id INT NOT NULL,
    temperature NUMERIC(5,2) NOT NULL,
    precipitation NUMERIC(5,2) NOT NULL,
    humidity NUMERIC(5,2) NOT NULL,
    wind_speed NUMERIC(5,2) NOT NULL,
    FOREIGN KEY (time_id) REFERENCES climeweather.dim_time(time_id),
    FOREIGN KEY (location_id) REFERENCES climeweather.dim_location(location_id),
    FOREIGN KEY (weather_id) REFERENCES climeweather.dim_weather(weather_id)
);
``` 

### Input sample data: Using [these queries](SQL/query/create_DW_schema_sample_data.sql)

### Check the data
```sql
SELECT * FROM climeweather.fact_weather;
```

### Visualize ERD
1. Choose a table in `Object Explorer`
2. Click right-mouse button then choose `ERD for table`

## Design Staging Area
- Staging Area will store raw data from many different sources (weather API, IoT, satellite sensor) before entering Data Warehouse.
- Select Database for Staging Area
	- Use `PostgreSQL`
	- The data will be saved in the form of `JSONB` for flexibility.
	- There is an additional `Processed` column to mark the processed data or not.

### Create tables in Staging area

#### Create main table to store raw data (`staging_weather_raw`)
```sql
CREATE TABLE climeweather.staging_weather_raw (
    id SERIAL PRIMARY KEY,
    source VARCHAR(50) NOT NULL,  -- Data source (API, IoT, Satellite, ...)
    raw_data JSONB NOT NULL,       -- Store JSON raw data
    received_at TIMESTAMP DEFAULT NOW(),  -- Insert data time
    processed BOOLEAN DEFAULT FALSE -- Check if data is processed or not
);
```
- Save all JSON data for flexibility when processing later.
- `Processed` column is used to determine whether the data has been loaded into Data Warehouse or not.

#### Create cleaned intermidate table (`staging_weather_cleaned`)
```sql
CREATE TABLE climeweather.staging_weather_cleaned (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL,
    location_id INT NOT NULL,
    temperature NUMERIC(5,2),
    precipitation NUMERIC(5,2),
    humidity NUMERIC(5,2),
    wind_speed NUMERIC(5,2),
    weather_type VARCHAR(50),
    ndvi NUMERIC(5,2),
    processed_at TIMESTAMP DEFAULT NOW()
);
```

## ETL (Extract-Transform-Load) Technology
- `Apache Nifi` (Compatible with real-time data, provide visual interface) for ETL from Data Source to Staging Area
- `Apache Airflow` from ETL from Staging Area to Data Warehouse

### Install and Start Apache Nifi (for version 2.2.0)
1. Download Nifi: Visit the Apache NiFi Downloads page and choose the version suitable for your operating system (Windows, macOS, or Linux).
2. Extract the Files: Extract the `.zip` file.
3. Set up Java: Ensure you have Java 8 or Java 11 installed. Running `java -version` in terminal to check.
4. Configure NiFi: Navigate to the `conf` folder in the extracted NiFi directory. Edit the `nifi.properties` file to set up configurations like ports, repositories, and sensitive properties.
5. Start NiFi: Open Terminal then navigate to `bin` folder. Run `.\nifi.cmd start`.
6. Access the NiFi UI: Open a web browser and go to `https://localhost:8443/nifi` (default port).

### ETL Pipeline

#### ETL from Data Source to Staging Area 
- ETL from API to Staging Area
	- Extract data from API to `staging_weather_raw` table
	- Process data from `staging_weather_raw` to `staging_weather_cleaned`
	- Update `processed` column in `staging_weather_raw` table
	
	
 