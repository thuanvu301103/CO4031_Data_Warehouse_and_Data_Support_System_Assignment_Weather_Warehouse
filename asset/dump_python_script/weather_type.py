import json
import os
import pandas as pd

# Identify weather type Function
def weather_type(temp_max, precipitation, humidity, cloud):
    # rain (mm)
    if rain > 100:
        return "Thunderstorm"
    elif rain > 5 and rain <= 50:
        return "Drizzle"
    elif rain > 0:
        return "Rain"
    # cloud (%)
    elif cloud > 80:
        return "Cloudy"
    # temp_max (Celcius) - humidity (%)
    elif humidity > 90 and cloud > 70:
        return "Foggy"
    else:
        return "Sunny"

# Read location name from json config
with open("../config/location.json", "r", encoding="utf-8") as file:
    data = json.load(file)
locations = [item["name"] for item in data]

print("Locations: ", locations)

# Dump_weather_data folder
folder_path = "../dump_data/weather_data"

# Identify weather type
for filename in os.listdir(folder_path):
    file_name_without_ext, ext = os.path.splitext(filename)  # exclude file extension

    if file_name_without_ext in locations and ext == ".csv":
        file_path = os.path.join(folder_path, filename)

        df = pd.read_csv(file_path)

        required_columns = {"temp_max", "precipitation", "humidity", "cloud"}
        if not required_columns.issubset(df.columns):
            print(f"⚠️ {filename} There are not enough necessary columns, ignoring.")
            continue

        df["weather_type"] = df.apply(lambda row: weather_type(
            row["temp_max"], row["precipitation"], row["humidity"], row["cloud"]
        ), axis=1)

        df.to_csv(file_path, index=False)

        print(f"✅ {filename} Updated")
