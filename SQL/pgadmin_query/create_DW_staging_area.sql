-- Create raw staging table: weather
CREATE TABLE climeweather.staging_weather_raw (
    id SERIAL PRIMARY KEY,
    source VARCHAR(50) NOT NULL,
    raw_data JSONB NOT NULL,
    received_at TIMESTAMP DEFAULT NOW(),
    processed BOOLEAN DEFAULT FALSE
);

-- Create raw staging table: salinity
CREATE TABLE climeweather.staging_salinity_raw (
    id SERIAL PRIMARY KEY,
    source VARCHAR(50) NOT NULL,
    raw_data JSONB NOT NULL,
    received_at TIMESTAMP DEFAULT NOW(),
    processed BOOLEAN DEFAULT FALSE
);

-- Create cleaned staging table: weather
CREATE TABLE climeweather.staging_weather_cleaned (
    id SERIAL PRIMARY KEY,
    time DATE,
    location VARCHAR(50),
    weather_type VARCHAR(50),
    temp_max NUMERIC(5,2),
    temp_min NUMERIC(5,2),
    precipitation NUMERIC(5,2),
    cloud NUMERIC(5,2),
    processed_at TIMESTAMP DEFAULT NOW()
);

-- Create cleaned staging table: salinity
CREATE TABLE climeweather.staging_salinity_cleaned (
    id SERIAL PRIMARY KEY,
    week_number INT,
    year INT,
    location VARCHAR(50),
    avg_salinity NUMERIC(5,2),
    processed_at TIMESTAMP DEFAULT NOW()
);
