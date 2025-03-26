-- Create raw staging table: weather
CREATE TABLE climeweather.staging_weather_raw (
    id SERIAL PRIMARY KEY,
    source VARCHAR(50) NOT NULL,  -- Data source (API, IoT, Satellite, ...)
    raw_data JSONB NOT NULL,       -- Store JSON raw data
    received_at TIMESTAMP DEFAULT NOW(),  -- Insert data time
    processed BOOLEAN DEFAULT FALSE -- Check if data is processed or not
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