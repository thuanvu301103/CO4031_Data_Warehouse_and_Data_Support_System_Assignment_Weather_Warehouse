INSERT INTO climeweather.fact_weather (time_id, location_id, weather_type_id, temp_max, temp_min, precipitation, humidity, cloud)
SELECT 
    t.time_id, 
    l.location_id, 
    w.weather_id, 
    s.temp_max,
    s.temp_min,
    s.precipitation,
    s.humidity,
    s.cloud
FROM climeweather.staging_weather_cleaned s
JOIN climeweather.dim_time t ON s.time = t.date
JOIN climeweather.dim_location l ON s.location = l.province
JOIN climeweather.dim_weather_type w ON s.weather_type = w.weather_type
;