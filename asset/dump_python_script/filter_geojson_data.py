import json

# Read GeoJSON file
with open("../dump_data/geo_data/vietnam_province.geojson", "r", encoding="utf-8") as f:
    geojson_data = json.load(f)

# Read location name from json config
with open("../config/location.json", "r", encoding="utf-8") as file:
    data = json.load(file)
province_list = [item["name"] for item in data]

# Filter provinces
filtered_features = [
    feature for feature in geojson_data["features"]
    if feature["properties"].get("Name") in province_list
]

# Create new GeoJSON file
filtered_geojson = {
    "type": "FeatureCollection",
    "features": filtered_features
}

# Export
with open("../dump_data/geo_data/vietnam_southern_province.geojson", "w", encoding="utf-8") as f:
    json.dump(filtered_geojson, f, ensure_ascii=False, indent=4)

print("Complete Filter!")
