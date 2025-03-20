import os
import json

# Load the corners.geojson file
with open('corners.geojson', 'r') as f:
    corners = json.load(f)

# Extract corner coordinates (longitude, latitude) from the corners file
corners_dict = {}
for feature in corners['features']:
    corner_name = feature['properties']['corner']
    lon, lat = feature['geometry']['coordinates']
    corners_dict[corner_name] = (lon, lat)

# Get coordinates of the corners
top_left = corners_dict['TopLeft']
lower_left = corners_dict['LowerLeft']
top_right = corners_dict['TopRight']
lower_right = corners_dict['LowerRight']

# Define the image size (in pixels)
image_width = 7150
image_height = 11000

# Extract the bounding box of the map
lon_min = lower_left[0]
lat_min = lower_left[1]
lon_max = top_right[0]
lat_max = top_left[1]

# Helper function to convert geographic coordinates to pixel coordinates
def geo_to_pixel(lon, lat, lon_min, lat_min, lon_max, lat_max, width, height):
    # Calculate pixel coordinates (without scaling)
    pixel_x = (lon - lon_min) / (lon_max - lon_min) * width
    
    # Flip Y-axis and make it positive using 11000 - abs(Y)
    pixel_y = (lat - lat_min) / (lat_max - lat_min) * height
    pixel_y = height - (11000 - abs(pixel_y))  # Flip Y-axis and adjust for positive range
    
    return pixel_x, pixel_y

# Load the regions.geojson files and transform their coordinates
def transform_geojson(geojson_file, lon_min, lat_min, lon_max, lat_max, width, height):
    if not os.path.exists(geojson_file):
        print("file not found")
        return

    with open(geojson_file, 'r') as f:
        data = json.load(f)
    
    # Iterate through each feature and flip the Y coordinates
    for feature in data['features']:
        geometry = feature['geometry']
        coordinates = geometry['coordinates']
        
        if geometry['type'] == 'Point':
            # For points, just transform the coordinates
            lon, lat = coordinates
            pixel_x, pixel_y = geo_to_pixel(lon, lat, lon_min, lat_min, lon_max, lat_max, width, height)
            feature['geometry']['coordinates'] = [pixel_x, pixel_y]
        
        elif geometry['type'] == 'LineString' or geometry['type'] == 'Polygon':
            # For lines and polygons, transform each coordinate pair
            new_coordinates = []
            for coord in coordinates:
                lon, lat = coord
                pixel_x, pixel_y = geo_to_pixel(lon, lat, lon_min, lat_min, lon_max, lat_max, width, height)
                new_coordinates.append([pixel_x, pixel_y])
            feature['geometry']['coordinates'] = new_coordinates
        
        elif geometry['type'] == 'MultiLineString':
            # For MultiLineString, iterate over each line and transform each coordinate
            new_coordinates = []
            for line in coordinates:
                new_line = []
                for coord in line:
                    lon, lat = coord
                    pixel_x, pixel_y = geo_to_pixel(lon, lat, lon_min, lat_min, lon_max, lat_max, width, height)
                    new_line.append([pixel_x, pixel_y])
                new_coordinates.append(new_line)
            feature['geometry']['coordinates'] = new_coordinates
        
        elif geometry['type'] == 'MultiPolygon':
            # For MultiPolygon, iterate over each polygon and transform each coordinate
            new_coordinates = []
            for polygon in coordinates:
                new_polygon = []
                for ring in polygon:
                    new_ring = []
                    for coord in ring:
                        lon, lat = coord
                        pixel_x, pixel_y = geo_to_pixel(lon, lat, lon_min, lat_min, lon_max, lat_max, width, height)
                        new_ring.append([pixel_x, pixel_y])
                    new_polygon.append(new_ring)
                new_coordinates.append(new_polygon)
            feature['geometry']['coordinates'] = new_coordinates
    
    return data

regions_transformed = transform_geojson('regions.geojson', lon_min, lat_min, lon_max, lat_max, image_width, image_height)

with open('regions_transformed.geojson', 'w') as f:
    json.dump(regions_transformed, f)

print("Transformation complete. Transformed GeoJSON files saved.")
