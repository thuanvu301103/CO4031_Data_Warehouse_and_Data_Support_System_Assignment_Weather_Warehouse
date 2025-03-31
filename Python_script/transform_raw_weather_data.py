import psycopg2
import sys
import json
import os
import json

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
location_file_path = os.path.join(BASE_DIR, "config", "location.json")
weather_type_file_path = os.path.join(BASE_DIR, "config", "weather_type.json")

def transform_location(rows):
    with open(location_file_path, "r", encoding="utf-8") as file:
        location_data = json.load(file)
    location_map = {loc["place_id"]: loc["name"] for loc in location_data}
    
    # Replace location by name
    transformed_data = []
    for row in rows:
        id, time, location, temp_max, temp_min, precipitation, cloud, weather_type = row
        location_name = location_map.get(location, location)
        transformed_data.append((id, time, location_name, float(temp_max), float(temp_min), float(precipitation), float(cloud), weather_type))
    return transformed_data

def transform_weather_type(rows):
    with open(weather_type_file_path, "r", encoding="utf-8") as file:
        weather_type_data = json.load(file)
    
    # Standarlize weather_type
    transformed_data = []
    for row in rows:
        id, time, location, temp_max, temp_min, precipitation, cloud, weather_type = row
        for key, values in weather_type_data.items():
            found = False
            for value in values:
                if weather_type == value:
                    weather_type = key
                    found = True
                    break
            if found:
                break
        transformed_data.append((id, time, location, temp_max, temp_min, precipitation, cloud, weather_type))
    #print (transformed_data)
    return transformed_data

def transform_data(cursor):
    
    # Execute SQL query to fect data from raw_weather_data table
    fetch_query = """SELECT 
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
    """
    cursor.execute(fetch_query)
    rows = cursor.fetchall()

    # Trainforming data
    #print (rows)
    transformed_data = transform_location(rows)
    transformed_data = transform_weather_type(transformed_data)

    return transformed_data
    """
    # Print data into stdout so that NiFi can process
    for record in transformed_data:
        print(record)
    """

def insert_cleaned_data(conn, cursor, data):
    cleaned_data = [
        (time, location, weather_type, temp_max, temp_min, precipitation, cloud) 
        for _, time, location, temp_max, temp_min, precipitation, cloud, weather_type in transformed_data
    ]

    insert_query = """
        INSERT INTO climeweather.staging_weather_cleaned 
        (time, location, weather_type, temp_max, temp_min, precipitation, cloud)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """
    
    cursor.executemany(insert_query, cleaned_data)
    conn.commit()

def update_raw_table(conn, cursor):
    update_query = """
        UPDATE climeweather.staging_weather_raw 
        SET processed = TRUE;
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
    print(transformed_data)
    insert_cleaned_data(conn, cursor, transformed_data)
    update_raw_table(conn, cursor)
    
    # Close connection
    cursor.close()
    conn.close()
