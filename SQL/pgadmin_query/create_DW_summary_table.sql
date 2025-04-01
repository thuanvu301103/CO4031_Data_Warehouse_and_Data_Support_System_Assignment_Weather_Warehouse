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
INSERT INTO climeweather.summary_weather_weekly (
    year, week_id, location_id, avg_temp_max, avg_temp_min, max_temp, min_temp,
    total_precipitation, count, last_updated
)
SELECT 
    EXTRACT(ISOYEAR FROM dt.date) AS year,
    EXTRACT(WEEK FROM dt.date) AS week_id,
    dl.location_id,
    AVG(fw.temp_max) AS avg_temp_max,
    AVG(fw.temp_min) AS avg_temp_min,
    MAX(fw.temp_max) AS max_temp,
    MIN(fw.temp_min) AS min_temp,
    SUM(fw.precipitation) AS total_precipitation,
    COUNT(fw.id) AS count,
    CURRENT_TIMESTAMP AS last_updated
FROM climeweather.fact_weather fw
JOIN climeweather.dim_time dt ON fw.time_id = dt.time_id
JOIN climeweather.dim_time_week dtw ON EXTRACT(WEEK FROM dt.date) = dtw.week_number 
    AND EXTRACT(ISOYEAR FROM dt.date) = dtw.year
JOIN climeweather.dim_location dl ON fw.location_id = dl.location_id
GROUP BY EXTRACT(ISOYEAR FROM dt.date), EXTRACT(WEEK FROM dt.date), dl.location_id
ON CONFLICT (year, week_id, location_id)
DO UPDATE SET
    avg_temp_max = EXCLUDED.avg_temp_max,
    avg_temp_min = EXCLUDED.avg_temp_min,
    max_temp = EXCLUDED.max_temp,
    min_temp = EXCLUDED.min_temp,
    total_precipitation = EXCLUDED.total_precipitation,
    count = EXCLUDED.count,
    last_updated = CURRENT_TIMESTAMP;