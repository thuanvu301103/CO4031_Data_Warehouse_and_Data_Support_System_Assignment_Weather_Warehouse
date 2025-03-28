INSERT INTO climeweather.fact_salinity (week_id, location_id, salinity)
SELECT 
    t.week_id, 
    l.location_id, 
    s.avg_salinity
FROM climeweather.staging_salinity_cleaned s
JOIN climeweather.dim_time_week t ON (s.week_number = t.week_number AND s.year = t.year)
JOIN climeweather.dim_location l ON s.location = l.province
;