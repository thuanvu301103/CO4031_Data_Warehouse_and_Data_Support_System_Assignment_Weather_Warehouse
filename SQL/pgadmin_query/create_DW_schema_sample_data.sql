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
INSERT INTO climeweather.dim_location (region, province, station_id)
VALUES 
	('SE', 'Binh Duong', 'SE001'),
	('SE', 'Binh Phuoc', 'SE002'),
	('SE', 'Ho Chi Minh City', 'SE003'),
	('SE', 'Dong Nai', 'SE004'),
	('SE', 'Tay Ninh', 'SE005'),
	('SE', 'Ba Ria - Vung Tau', 'SE006'),
	('MD', 'Long An', 'MD001'),
	('MD', 'Dong Thap', 'MD002'),
	('MD', 'Tien Giang', 'MD003'),
	('MD', 'An Giang', 'MD004'),
	('MD', 'Ben Tre', 'MD005'),
	('MD', 'Vinh Long', 'MD006'),
	('MD', 'Tra Vinh', 'MD007'),
	('MD', 'Hau Giang', 'MD008'),
	('MD', 'Kien Giang', 'MD009'),
	('MD', 'Soc Trang', 'MD010'),
	('MD', 'Bac Lieu', 'MD011'),
	('MD', 'Ca Mau', 'MD012'),
	('MD', 'Can Tho City', 'MD013')
;

-- Insert data into dim_weather
INSERT INTO climeweather.dim_weather (weather_type, ndvi)
VALUES ('Light rain', 0.45);

-- Insert data into fact_weather
INSERT INTO climeweather.fact_weather (time_id, location_id, weather_id, temperature, precipitation, humidity, wind_speed)
VALUES (20250311, 1, 1, 30.5, 12, 80, 5);