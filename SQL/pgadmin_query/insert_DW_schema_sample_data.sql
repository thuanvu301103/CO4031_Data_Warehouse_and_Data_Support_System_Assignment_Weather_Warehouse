-- Insert data into dim_time_week
INSERT INTO climeweather.dim_time_week (week_number, year)
SELECT 
    DISTINCT EXTRACT(WEEK FROM d) AS week_number,
    EXTRACT(YEAR FROM d) AS year
FROM generate_series('2020-01-01'::DATE, '2030-12-31'::DATE, '1 day'::INTERVAL) d
ORDER BY year, week_number;

-- Insert data into dim_time
INSERT INTO climeweather.dim_time (date, day, month, quarter, year)
SELECT 
    d::DATE AS date,
    EXTRACT(DAY FROM d) AS day,
    EXTRACT(MONTH FROM d) AS month,
    EXTRACT(QUARTER FROM d) AS quarter,
    EXTRACT(YEAR FROM d) AS year
FROM generate_series('2020-01-01'::DATE, '2030-12-31'::DATE, '1 day'::INTERVAL) d;

-- Insert week_id into dim_time
UPDATE climeweather.dim_time AS dt
SET week_id = dtw.week_id
FROM climeweather.dim_time_week AS dtw
WHERE EXTRACT(WEEK FROM dt.date) = dtw.week_number
  AND dt.year = dtw.year;

-- Insert data into dim_location
INSERT INTO climeweather.dim_location (region, province)
VALUES 
	('Dong Nam Bo', 'Binh Duong'),
	('Dong Nam Bo', 'Binh Phuoc'),
	('Dong Nam Bo', 'Ho Cho Minh City'),
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
	('Dong bang S.Cuu Long', 'Can Tho')
;

-- Insert data into dim_weather
INSERT INTO climeweather.dim_weather_type (weather_type)
VALUES 
    ('Sunny'),
    ('Rain'),
    ('Cloudy'),
    ('Snow'),
    ('Stormy'),
    ('Foggy'),
    ('Windy'),
    ('Hail'),
    ('Thunderstorm'),
    ('Drizzle')
;