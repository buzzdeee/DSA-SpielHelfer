import os
import json
from shapely.geometry import LineString, Point

# Load the corners.geojson file
with open('corners.geojson', 'r') as f:
    corners = json.load(f)

# Extract corner coordinates (longitude, latitude)
corners_dict = {feature['properties']['corner']: tuple(feature['geometry']['coordinates']) for feature in corners['features']}

# Get coordinates of the corners
top_left = corners_dict['TopLeft']
lower_left = corners_dict['LowerLeft']
top_right = corners_dict['TopRight']
lower_right = corners_dict['LowerRight']

# Define the image size (in pixels)
image_width = 7150
image_height = 11000

# Extract the bounding box of the map
lon_min, lat_min = lower_left
lon_max, lat_max = top_right

# Convert geographic coordinates to pixel coordinates
def geo_to_pixel(lon, lat, lon_min, lat_min, lon_max, lat_max, width, height):
    pixel_x = (lon - lon_min) / (lon_max - lon_min) * width
    pixel_y = (lat - lat_min) / (lat_max - lat_min) * height
    pixel_y = height - (11000 - abs(pixel_y))  # Flip Y-axis and adjust for positive range
    return pixel_x, pixel_y

# Load and transform streets.geojson
def transform_geojson(geojson_file, lon_min, lat_min, lon_max, lat_max, width, height):
    if not os.path.exists(geojson_file):
        print("File not found:", geojson_file)
        return None

    with open(geojson_file, 'r') as f:
        data = json.load(f)

    transformed_features = []
    line_strings = []  # Store LineString objects for intersection detection

    for feature in data['features']:
        geometry = feature['geometry']
        coordinates = geometry['coordinates']
        transformed_coords = []

        if geometry['type'] == 'MultiLineString':
            for line in coordinates:
                new_line = []
                for coord in line:
                    lon, lat = coord
                    pixel_x, pixel_y = geo_to_pixel(lon, lat, lon_min, lat_min, lon_max, lat_max, width, height)
                    new_line.append([pixel_x, pixel_y])
                transformed_coords.append(new_line)
                line_strings.append(LineString(new_line))  # Convert to shapely LineString

        feature['geometry']['coordinates'] = transformed_coords
        transformed_features.append(feature)

    return {"type": "FeatureCollection", "features": transformed_features}, line_strings

# Detect intersections between roads
def find_intersections(line_strings):
    intersections = []
    for i, line1 in enumerate(line_strings):
        for j, line2 in enumerate(line_strings):
            if i >= j:
                continue  # Avoid duplicate checks
            if line1.intersects(line2):
                intersection_points = line1.intersection(line2)
                if isinstance(intersection_points, Point):
                    intersections.append([intersection_points.x, intersection_points.y])
                elif intersection_points.geom_type == "MultiPoint":
                    for point in intersection_points.geoms:
                        intersections.append([point.x, point.y])

    return intersections

# Find nearest road for each location
def find_nearest_road(locations, line_strings):
    location_road_mapping = {}

    for location in locations:
        location_name = location["name"]
        x, y = float(location["x"]), float(location["y"])
        location_point = Point(x, y)

        nearest_distance = float("inf")
        nearest_point = None

        for line in line_strings:
            nearest = line.interpolate(line.project(location_point))  # Find closest point on line
            distance = location_point.distance(nearest)

            if distance < nearest_distance:
                nearest_distance = distance
                nearest_point = [nearest.x, nearest.y]

        location_road_mapping[location_name] = nearest_point

    return location_road_mapping

# Load Orte.json and find nearest roads
def process_locations(orte_file, line_strings):
    if not os.path.exists(orte_file):
        print("File not found:", orte_file)
        return None

    with open(orte_file, 'r') as f:
        locations = json.load(f)

    return find_nearest_road(locations, line_strings)

# Process streets, intersections, and locations
print("transforming coordinates")
streets_transformed, line_strings = transform_geojson('streets.geojson', lon_min, lat_min, lon_max, lat_max, image_width, image_height)

if streets_transformed:
    print("looking for intersections")
    intersections = find_intersections(line_strings)
    print("looking for closest roads to locations")
    location_to_road = process_locations('../Resources/Orte.json', line_strings)

    # Save transformed streets.geojson
    with open('streets_transformed.geojson', 'w') as f:
        json.dump(streets_transformed, f)

    # Save intersections as geojson
    intersections_geojson = {
        "type": "FeatureCollection",
        "features": [{"type": "Feature", "geometry": {"type": "Point", "coordinates": point}} for point in intersections]
    }
    with open('road_intersections.geojson', 'w') as f:
        json.dump(intersections_geojson, f)

    # Save location to nearest road mapping
    with open('location_to_road.json', 'w') as f:
        json.dump(location_to_road, f)

    print("✅ Transformation complete. Files saved:")
    print("   - streets_transformed.geojson")
    print("   - road_intersections.geojson")
    print("   - location_to_road.json")
else:
    print("❌ Transformation failed.")
