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
