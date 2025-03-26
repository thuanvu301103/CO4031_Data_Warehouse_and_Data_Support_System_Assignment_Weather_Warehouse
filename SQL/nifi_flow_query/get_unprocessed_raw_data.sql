-- Get unprocessed weather data
SELECT 
    	swr.id, 
    	TO_DATE(swr.raw_data::jsonb->>'time', 'YYYY-MM-DD') AS time,
    	swr.raw_data::jsonb->>'location' AS location,
    	swr.raw_data::jsonb->>'temp_max' AS temp_max,
	swr.raw_data::jsonb->>'temp_min' AS temp_min,
    	swr.raw_data::jsonb->>'precipitation' AS precipitation,
	swr.raw_data::jsonb->>'cloud' AS cloud,
    	swr.raw_data::jsonb->>'weather_type' AS weather_type
FROM 
    climeweather.staging_weather_raw swr
WHERE 
    swr.processed = FALSE;