-- Summary table: weather by month
CREATE TABLE climeweather.summary_weather_monthly (
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    avg_temp_max NUMERIC(5,2),
    avg_temp_min NUMERIC(5,2),
    max_temp NUMERIC(5,2),
    min_temp NUMERIC(5,2),
    total_precipitation NUMERIC(5,2),
    count INTEGER NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (year, month, location_id),
    FOREIGN KEY (location_id) REFERENCES climeweather.dim_location(location_id)
);

-- Summary table: weather by week
CREATE TABLE climeweather.summary_weather_weekly (
    year INTEGER NOT NULL,
    week_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    avg_temp_max NUMERIC(5,2),
    avg_temp_min NUMERIC(5,2),
    max_temp NUMERIC(5,2),
    min_temp NUMERIC(5,2),
    total_precipitation NUMERIC(5,2),
    count INTEGER NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (year, week_id, location_id),
    FOREIGN KEY (week_id) REFERENCES climeweather.dim_time_week(week_id),
    FOREIGN KEY (location_id) REFERENCES climeweather.dim_location(location_id)
);
