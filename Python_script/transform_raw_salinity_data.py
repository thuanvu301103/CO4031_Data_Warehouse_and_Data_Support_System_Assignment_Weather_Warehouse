import psycopg2
import sys
import json
import os
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
location_file_path = os.path.join(BASE_DIR, "config", "location.json")
weather_type_file_path = os.path.join(BASE_DIR, "config", "weather_type.json")

def identify_iso_time(rows):
    transformed_data = []
    for row in rows:
        id, start_date, end_date, location, salinity = row
        if start_date:
            iso_year, iso_week, _ = start_date.isocalendar()
        else:
            iso_year, iso_week = None, None 
        transformed_data.append((id, iso_year, iso_week, location, salinity))
    return transformed_data

def transform_data(cursor):
    
    # Execute SQL query to fect data from raw_salinity_data table
    fetch_query = """SELECT 
    	ssr.id, 
    	TO_DATE(ssr.raw_data::jsonb->>'start_date', 'MM-DD-YYYY') AS start_date,
    	TO_DATE(ssr.raw_data::jsonb->>'end_date', 'MM-DD-YYYY') AS end_date,
    	ssr.raw_data::jsonb->>'location' AS location,
    	ssr.raw_data::jsonb->>'avg_salinity' AS salinity
    FROM 
        climeweather.staging_salinity_raw ssr
    WHERE 
        ssr.processed = FALSE;
    """
    cursor.execute(fetch_query)
    rows = cursor.fetchall()

    # Trainforming data
    transformed_data = identify_iso_time(rows)
    
    return transformed_data

def insert_cleaned_data(conn, cursor, data):
    cleaned_data = [
        (week_number, year, location, salinity) 
        for _, year, week_number, location, salinity in data
    ]

    insert_query = """
        INSERT INTO climeweather.staging_salinity_cleaned 
        (week_number, year, location, avg_salinity)
        VALUES (%s, %s, %s, %s)
    """
    
    cursor.executemany(insert_query, cleaned_data)
    conn.commit()

def update_raw_table(conn, cursor):
    update_query = """
        UPDATE climeweather.staging_salinity_raw 
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
    #print(transformed_data)
    insert_cleaned_data(conn, cursor, transformed_data)
    update_raw_table(conn, cursor)
    
    # Close connection
    cursor.close()
    conn.close()
