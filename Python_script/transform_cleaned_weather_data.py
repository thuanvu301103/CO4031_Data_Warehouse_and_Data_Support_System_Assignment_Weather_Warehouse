import psycopg2
import sys
import json
import os
from datetime import datetime
import pandas as pd

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
location_file_path = os.path.join(BASE_DIR, "config", "location.json")
weather_type_file_path = os.path.join(BASE_DIR, "config", "weather_type.json")

def handle_missing_data(data):
    with open(location_file_path, "r", encoding="utf-8") as file:
        location_data = json.load(file)
    locations = [loc["name"] for loc in location_data]
    #print(locations)

    # Insert news row for missing dates and locations
    start_date = data['time'].min() - pd.to_timedelta(data['time'].min().weekday(), unit='D')  # Monday
    end_date = start_date + pd.Timedelta(days=6)  # Sunday
    all_dates = pd.date_range(start=start_date, end=end_date)
    full_grid = pd.MultiIndex.from_product([all_dates, locations], names=['time', 'location']).to_frame(index=False)
    full_grid['time'] = pd.to_datetime(full_grid['time'])
    data['time'] = pd.to_datetime(data['time'])
    df_full = pd.merge(full_grid, data, on=['time', 'location'], how='left')

    # Fill mising values using moving average
    columns_to_fill = ['temp_max', 'temp_min', 'precipitation', 'cloud']

    for col in columns_to_fill:
        df_full[col] = df_full.groupby('location')[col].transform(lambda x: x.fillna(x.rolling(window=3, min_periods=1).mean()).ffill().bfill())
    df_full['weather_type'] = df_full['weather_type'].fillna('Unknow')

    #print(df_full)
    return df_full

def transform_data(cursor):
    
    # Execute SQL query to fect data from staging_weather_cleaned table
    fetch_query = """SELECT * FROM climeweather.staging_weather_cleaned;"""
    cursor.execute(fetch_query)
    rows = cursor.fetchall()

    columns = ['id', 'time', 'location', 'weather_type', 'temp_max', 'temp_min', 'precipitation', 'cloud', 'processed_at']
    df = pd.DataFrame(rows, columns=columns)
    #print(df)

    # Handle mising data
    transformed_data = handle_missing_data(df)
    return transformed_data

def insert_cleaned_data(conn, cursor, data):
    cleaned_data = [
        (row['time'], row['location'], row['weather_type'], row['temp_max'], row['temp_min'], row['precipitation'], row['cloud']) 
        for _, row in data.iterrows()
    ]
    # Create temporary table
    cursor.execute("""
    CREATE TEMP TABLE temp_weather (
        time DATE,
        location TEXT,
        weather_type TEXT,
        temp_max FLOAT,
        temp_min FLOAT,
        precipitation FLOAT,
        cloud FLOAT
    );""")
    conn.commit()
    # Insert cleaned data into temp table
    cursor.executemany("""
    INSERT INTO temp_weather (time, location, weather_type, temp_max, temp_min, precipitation, cloud)
    VALUES (%s, %s, %s, %s, %s, %s, %s)""", cleaned_data)
    conn.commit()

    # Insert data from temp table into fact table
    insert_weather_fact_query = """
        INSERT INTO climeweather.fact_weather 
        (time_id, location_id, weather_type_id, temp_max, temp_min, precipitation, cloud)
        SELECT 
            t.time_id, 
            l.location_id, 
            w.weather_id, 
            s.temp_max,
            s.temp_min,
            s.precipitation,
            s.cloud
        FROM temp_weather s
        LEFT JOIN climeweather.dim_time t ON s.time = t.date
        LEFT JOIN climeweather.dim_location l ON s.location = l.province
        LEFT JOIN climeweather.dim_weather_type w ON s.weather_type = w.weather_type
    """
    cursor.execute(insert_weather_fact_query)
    conn.commit()

def update_cleaned_table(conn, cursor):
    update_query = """
        DELETE FROM climeweather.staging_weather_cleaned;
    """
    cursor.execute(update_query)
    conn.commit()

if __name__ == "__main__":
    # Connect PostgreSQL
    conn = psycopg2.connect(
        dbname="climeweather_dw",
        user="postgres",
        password="admin",
       	host="localhost",
	port="5432"
    )
    cursor = conn.cursor()

    # ETL
    transformed_data = transform_data(cursor)
    #print(transformed_data)
    insert_fact_data(conn, cursor, transformed_data)
    update_cleaned_table(conn, cursor)
    
    # Close connection
    cursor.close()
    conn.close()
