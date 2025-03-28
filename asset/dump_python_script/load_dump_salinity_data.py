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

folder_path = "../dump_data/salinity_data"

# Insert data
for filename in os.listdir(folder_path):
    file_name_without_ext, ext = os.path.splitext(filename)  # exclude file extension

    if file_name_without_ext in locations and ext == ".csv":
        file_path = os.path.join(folder_path, filename)
    else:
        continue
    df = pd.read_csv(file_path)

    # format data
    df["date_start"] = pd.to_datetime(df["date_start"])
    df["week_number"] = df["date_start"].dt.isocalendar().week  # Get ISO week 
    df["year"] = df["date_start"].dt.isocalendar().year # Get ISO year
    df = df[["province", "avg_salinity", "week_number", "year"]]
    df.rename(columns={
            "province": "location"
        }, inplace=True)

    df.to_sql("staging_salinity_cleaned", engine, schema="climeweather", if_exists="append", index=False)
