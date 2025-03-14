CREATE TABLE climeweather.staging_weather_raw (
    id SERIAL PRIMARY KEY,
    source VARCHAR(50) NOT NULL,  -- Data source (API, IoT, Satellite, ...)
    raw_data JSONB NOT NULL,       -- Store JSON raw data
    received_at TIMESTAMP DEFAULT NOW(),  -- Insert data time
    processed BOOLEAN DEFAULT FALSE -- Check if data is processed or not
);

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