import os
import json
from shapely.geometry import LineString, Point, MultiPoint

# Load the .json and .geojson files
def load_files():
    print("Loading Orte.json and streets.geojson files...")
    # Load Orte.json (locations)
    with open('../Resources/Orte.json', 'r') as f:
        locations = json.load(f)
    
    # Load streets.geojson (streets)
    with open('streets.geojson', 'r') as f:
        streets = json.load(f)

    print("Files loaded successfully.")
    return locations, streets

# Transform geo-coordinates to pixel coordinates
def geo_to_pixel(lon, lat, lon_min, lat_min, lon_max, lat_max, width, height):
    pixel_x = (lon - lon_min) / (lon_max - lon_min) * width
    pixel_y = (lat - lat_min) / (lat_max - lat_min) * height
    pixel_y = height - (11000 - abs(pixel_y))  # Flip Y-axis and adjust for positive range
    return pixel_x, pixel_y

# Transform streets to pixel coordinates
def transform_streets(geojson_file, lon_min, lat_min, lon_max, lat_max, width, height):
    print("Transforming streets to pixel coordinates...")
    with open(geojson_file, 'r') as f:
        data = json.load(f)

    transformed_features = []
    line_strings = []

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
                line_strings.append(LineString(new_line))

        feature['geometry']['coordinates'] = transformed_coords
        transformed_features.append(feature)

    print("Streets transformed successfully.")
    return {"type": "FeatureCollection", "features": transformed_features}, line_strings

# Find intersections between streets and inject intersection points into the respective streets
def find_intersections_and_inject(line_strings):
    print("Finding intersections between streets...")
    all_intersections = []
    
    for i, line1 in enumerate(line_strings):
        for j, line2 in enumerate(line_strings):
            if i >= j:
                continue
            if line1.intersects(line2):
                intersection_points = line1.intersection(line2)
                if isinstance(intersection_points, Point):
                    all_intersections.append([intersection_points.x, intersection_points.y])
                elif intersection_points.geom_type == "MultiPoint":
                    for point in intersection_points.geoms:
                        all_intersections.append([point.x, point.y])
    
    print(f"Found {len(all_intersections)} intersection(s).")
    return all_intersections

# Inject locations into streets
def inject_locations_into_streets(locations, line_strings):
    print("Injecting locations into streets...")
    updated_streets = []
    new_streets = []
    for location in locations:
        location_name = location['name']
        x, y = float(location['x']), float(location['y'])
        location_point = Point(x, y)

        found_intersection = False
        for line in line_strings:
            if line.intersects(location_point.buffer(5)):  # Check if location is within 5px radius
                new_coords = list(line.coords)
                new_coords.insert(0, (x, y))  # Insert location into the street at the correct spot
                updated_streets.append(LineString(new_coords))
                found_intersection = True
        
        if not found_intersection:
            # Find nearest street and create a new street
            nearest_distance = float("inf")
            nearest_line = None
            for line in line_strings:
                nearest_point = line.interpolate(line.project(location_point))
                distance = location_point.distance(nearest_point)
                if distance < nearest_distance:
                    nearest_distance = distance
                    nearest_line = line

            new_street_coords = list(nearest_line.coords) + [(x, y)]
            updated_streets.append(LineString(new_street_coords))
    
    print(f"Injected {len(locations)} location(s) into streets.")
    return updated_streets

# Generate final output geojson with everything injected
def generate_final_output(streets, intersections, updated_streets):
    print("Generating final output with all updates...")
    # Inject intersections
    for intersection in intersections:
        streets['features'].append({
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": intersection
            },
            "properties": {"type": "intersection"}
        })

    # Inject updated streets
    for line in updated_streets:
        streets['features'].append({
            "type": "Feature",
            "geometry": {
                "type": "LineString",
                "coordinates": list(line.coords)
            },
            "properties": {"type": "updated_street"}
        })

    # Save the final output file
    with open('final_output.geojson', 'w') as f:
        json.dump(streets, f)

    print("✅ Final output generated as 'final_output.geojson'")

# Main execution flow
def main():
    print("Starting script execution...")
    locations, streets = load_files()

    # Get bounding box of the map
    lon_min, lat_min = -6000, -6200
    lon_max, lat_max = 6000, 7000
    width, height = 7150, 11000

    # Transform street coordinates to pixels
    streets_transformed, line_strings = transform_streets('streets.geojson', lon_min, lat_min, lon_max, lat_max, width, height)

    # Find intersections between streets
    intersections = find_intersections_and_inject(line_strings)

    # Inject locations into the streets
    updated_streets = inject_locations_into_streets(locations, line_strings)

    # Generate the final geojson output
    generate_final_output(streets_transformed, intersections, updated_streets)

    print("Script execution complete.")

# Run the main function
if __name__ == '__main__':
    main()
