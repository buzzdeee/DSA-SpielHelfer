import json
from shapely.geometry import Point, shape

# Load Orte.json
with open("DSA-SpielHelfer/Resources/Orte.json", "r", encoding="utf-8") as file:
    locations = json.load(file)

# Load regions.geojson
with open("regions_transformed.geojson", "r", encoding="utf-8") as file:
    regions = json.load(file)

# Convert region features into Shapely polygons
region_polygons = []
for feature in regions["features"]:
    polygon = shape(feature["geometry"])  # Convert to Shapely polygon
    region_name = feature["properties"]["region"]  # Get the region name
    region_polygons.append((polygon, region_name))

# Assign each location to a region
for location in locations:
    x, y = float(location["x"]), float(location["y"])  # Convert x/y to float
    point = Point(x, y)  # Create a Shapely point
    found_region = None

    # Find which region the point belongs to
    for polygon, region_name in region_polygons:
        if polygon.contains(point):
            found_region = region_name
            location["region"] = region_name  # Assign the region
            print(f"Located {location['name']} in region {region_name}")
            break  # Stop checking once we find the region

    if not found_region:
        print(f"Unable to locate {location['name']} in any region!")

# Save updated Orte.json with region assignments
output_file = "DSA-SpielHelfer/Resources/Orte_with_regions.json"
with open(output_file, "w", encoding="utf-8") as file:
    json.dump(locations, file, indent=2, ensure_ascii=False)

print(f"Updated file saved as {output_file}")
