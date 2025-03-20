-- Insert data into dim_time
INSERT INTO climeweather.dim_time (date, day, month, quarter, year)
SELECT 
    d::DATE AS date,
    EXTRACT(DAY FROM d) AS day,
    EXTRACT(MONTH FROM d) AS month,
    EXTRACT(QUARTER FROM d) AS quarter,
    EXTRACT(YEAR FROM d) AS year
FROM generate_series('2015-01-01'::DATE, '2030-12-31'::DATE, '1 day'::INTERVAL) d;

-- Insert data into dim_location
INSERT INTO climeweather.dim_location (region, province)
VALUES 
	('Dong Nam Bo', 'Binh Duong'),
	('Dong Nam Bo', 'Binh Phuoc'),
	('Dong Nam Bo', 'TP. Ho Cho Minh'),
	('Dong Nam Bo', 'Dong Nai'),
	('Dong Nam Bo', 'Tay Ninh'),
	('Dong Nam Bo', 'Ba Ria - Vung Tau'),
	('Dong bang S.Cuu Long', 'Long An'),
	('Dong bang S.Cuu Long', 'Dong Thap'),
	('Dong bang S.Cuu Long', 'Tien Giang'),
	('Dong bang S.Cuu Long', 'An Giang'),
	('Dong bang S.Cuu Long', 'Ben Tre'),
	('Dong bang S.Cuu Long', 'Vinh Long'),
	('Dong bang S.Cuu Long', 'Tra Vinh'),
	('Dong bang S.Cuu Long', 'Hau Giang'),
	('Dong bang S.Cuu Long', 'Kien Giang'),
	('Dong bang S.Cuu Long', 'Soc Trang'),
	('Dong bang S.Cuu Long', 'Bac Lieu'),
	('Dong bang S.Cuu Long', 'Ca Mau'),
	('Dong bang S.Cuu Long', 'TP. Can Tho')
;

-- Insert data into dim_weather
INSERT INTO climeweather.dim_weather (weather_type, ndvi)
VALUES ('Light rain', 0.45);

-- Insert data into fact_weather
INSERT INTO climeweather.fact_weather (time_id, location_id, weather_id, temperature, precipitation, humidity, wind_speed)
VALUES (20250311, 1, 1, 30.5, 12, 80, 5);