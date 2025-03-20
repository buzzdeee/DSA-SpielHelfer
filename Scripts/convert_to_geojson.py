import os
from fastkml import kml
import geojson
import re

def remove_invalid_timespan(kml_content):
    """Remove TimeSpan elements with invalid date formats (e.g., -1600)."""
    # Regular expression to match TimeSpan elements with invalid dates
    kml_content = re.sub(r'<TimeSpan[^>]*>.*?</TimeSpan>', '', kml_content, flags=re.DOTALL)
    return kml_content

def convert_kml_to_geojson(kml_file, geojson_file):
    with open(kml_file, 'r', encoding='utf-8') as kml_f:
        kml_content = kml_f.read()

    # Remove XML declaration if it exists
    kml_content = kml_content.replace('<?xml version="1.0" encoding="UTF-8"?>', '')

    # Remove TimeSpan elements with invalid date formats
    kml_content = remove_invalid_timespan(kml_content)

    # Parse KML content
    k = kml.KML()
    k.from_string(kml_content)

    # Access the features directly (not as a method)
    features = []
    for feature in k.features():  # Accessing directly as it is a property, not a method
        if isinstance(feature, kml.KML.Placemark):
            geojson_data = feature.to_geojson()
            features.append(geojson_data)

    # Create GeoJSON structure
    geojson_data = geojson.FeatureCollection(features)

    # Write GeoJSON to file
    with open(geojson_file, 'w', encoding='utf-8') as geojson_f:
        geojson.dump(geojson_data, geojson_f)

    print(f"Converted {kml_file} to {geojson_file}")

def process_kml_files(input_dir, output_dir):
    # Get all KML files from the input directory
    kml_files = [f for f in os.listdir(input_dir) if f.endswith('.kml')]

    # Process each KML file
    for kml_file in kml_files:
        kml_path = os.path.join(input_dir, kml_file)
        geojson_file = os.path.join(output_dir, f"{os.path.splitext(kml_file)[0]}.json")
        print(f"Converting {kml_file} to GeoJSON...")
        convert_kml_to_geojson(kml_path, geojson_file)

if __name__ == "__main__":
    input_dir = 'kml_downloads'  # Folder containing KML files
    output_dir = 'kml_downloads'  # Folder to save converted GeoJSON files

    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Process all KML files in the directory
    process_kml_files(input_dir, output_dir)
