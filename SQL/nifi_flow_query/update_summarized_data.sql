CREATE TABLE climeweather.aggregated_weather_province_month AS
SELECT 
    t.year, 
    t.month, 
    l.province, 
    AVG(f.temperature) AS avg_temp, 
    AVG(f.humidity) AS avg_humidity,
    AVG(f.wind_speed) AS avg_wind_speed
FROM climeweather.fact_weather f
JOIN climeweather.dim_time t ON f.time_id = t.time_id
JOIN climeweather.dim_location l ON f.location_id = l.location_id
GROUP BY t.year, t.month, l.province;

-- Add UNIQUE constraint after table creation
ALTER TABLE climeweather.aggregated_weather_province_month
ADD CONSTRAINT unique_year_month_province UNIQUE (year, month, province);