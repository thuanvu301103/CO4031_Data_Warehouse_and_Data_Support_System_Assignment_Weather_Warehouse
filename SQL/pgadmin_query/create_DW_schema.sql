-- Create Schema ClimeWeather
CREATE SCHEMA climeweather;

-- Create Dimension table: dim_time
CREATE TABLE climeweather.dim_time (
    time_id SERIAL PRIMARY KEY,
    date DATE NOT NULL UNIQUE,
    day INT NOT NULL,
    month INT NOT NULL,
    quarter INT NOT NULL,
    year INT NOT NULL
);

-- Create Dimension table: dim_location
CREATE TABLE climeweather.dim_location (
    location_id SERIAL PRIMARY KEY,
    region VARCHAR(50) NOT NULL,
    province VARCHAR(50) NOT NULL
);

-- Create Dimension table: dim_weather_type
CREATE TABLE climeweather.dim_weather_type (
    weather_id SERIAL PRIMARY KEY,
    weather_type VARCHAR(50) NOT NULL
);

-- Create Fact table: fact_weather
CREATE TABLE climeweather.fact_weather (
    id SERIAL PRIMARY KEY,
    time_id INT,
    location_id INT,
    weather_type_id INT,
    temp_max NUMERIC(5,2),
    temp_min NUMERIC(5,2),
    precipitation NUMERIC(5,2),
    humidity NUMERIC(5,2),
    cloud NUMERIC(5,2),
    FOREIGN KEY (time_id) REFERENCES climeweather.dim_time(time_id),
    FOREIGN KEY (location_id) REFERENCES climeweather.dim_location(location_id),
    FOREIGN KEY (weather_type_id) REFERENCES climeweather.dim_weather_type(weather_id)
);
