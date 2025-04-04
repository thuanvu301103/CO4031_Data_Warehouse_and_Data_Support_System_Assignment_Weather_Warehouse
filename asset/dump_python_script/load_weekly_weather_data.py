import psycopg2
import csv
import json
import os
import pandas as pd
from sqlalchemy import create_engine

# Read location name from json config
with open("../config/location.json", "r", encoding="utf-8") as file:
    data = json.load(file)
locations = [item["name"] for item in data]

# PostgreSQL connection Info
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "climeweather_dw"
DB_USER = "postgres"
DB_PASS = "admin"
engine = create_engine(f'postgresql+psycopg2://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}')

file_path = "../dump_data/weekly_report/weekly_weather_report.csv"

# Insert data
df = pd.read_csv(file_path)

# format data
df["time"] = pd.to_datetime(df["time"], format="%m/%d/%Y").dt.date
df.to_sql("staging_weather_cleaned", engine, schema="climeweather", if_exists="append", index=False)
