import os
import numpy as np
import scipy.interpolate
import xml.etree.ElementTree as ET

def load_gcps(gcp_file):
    """Load GCPs from Aventurien.jpg.points"""
    gcps = []
    with open(gcp_file, 'r') as f:
        lines = f.readlines()
    
    # Skip comments and the first valid data line (header)
    lines = [line.strip() for line in lines if not line.startswith('#')]
    lines = lines[1:]  # Skip the header line

    for line in lines:
        parts = line.split(',')
        if len(parts) >= 4:
            try:
                lat, lon, px, py = map(float, parts[:4])
                gcps.append((lon, lat, px, py))
            except ValueError:
                print(f"Skipping invalid line: {line}")
    
    return gcps

def compute_transformation(gcps):
    """Compute Thin Plate Spline (TPS) transformation."""
    lon, lat, px, py = zip(*gcps)
    tps_x = scipy.interpolate.RBFInterpolator(list(zip(lon, lat)), px, kernel='thin_plate_spline')
    tps_y = scipy.interpolate.RBFInterpolator(list(zip(lon, lat)), py, kernel='thin_plate_spline')
    return tps_x, tps_y

def transform_kml(input_kml, output_kml, tps_x, tps_y):
    """Transform coordinates in a KML file and save to output directory."""
    tree = ET.parse(input_kml)
    root = tree.getroot()
    ns = {'kml': 'http://www.opengis.net/kml/2.2'}
    
    # Stack to track parent elements
    parent_stack = []

    for placemark in root.findall('.//kml:Placemark', ns):
        # Process each child of Placemark
        for coord in placemark.findall('.//kml:coordinates', ns):
            if coord.text:
                # Print raw coordinate text for debugging
                raw_text = coord.text.strip()
                hex_representation = ' '.join(f"{ord(c):02x}" for c in raw_text)
                print(f"\nRaw coordinate string: {raw_text}")
                print(f"Hex representation: {hex_representation}")

                # Check the parent tag by looking at the parent element in the stack
                parent_tag = ''
                if parent_stack:
                    parent_tag = parent_stack[-1].tag

                coord_sets = []

                # If it's a Point, process as single coordinate set
                if parent_tag == '{http://www.opengis.net/kml/2.2}Point':  # Single set of coordinates for a Point
                    coord_sets = [raw_text]
                # If it's a LineString, process as multiple coordinate sets
                elif parent_tag == '{http://www.opengis.net/kml/2.2}LineString':  # Multiple sets of coordinates for a LineString
                    coord_sets = raw_text.split(' ')
                else:
                    # If it doesn't fit any known structure, handle as an unknown case
                    print(f"Skipping unsupported structure: {parent_tag}")
                    continue

                parsed_coords = []

                # Process each coordinate set
                for coord_set in coord_sets:
                    print(f"\ncoordinate set: {coord_set}")
                    # Split by commas to separate lon, lat, alt
                    coord_parts = [part.strip() for part in coord_set.split(',')]

                    # Ensure it's a valid triplet (lon, lat, alt)
                    if len(coord_parts) == 3:
                        parsed_coords.append(coord_parts)
                    else:
                        print(f"Skipping malformed coordinate set: {coord_set}")
                        continue  # Skipping malformed set, not exiting

                # Now handle transformation for each valid set of coordinates
                transformed_coords = []
                for lon, lat, alt in parsed_coords:
                    try:
                        lon, lat, alt = map(float, [lon, lat, alt])
                        # Apply transformations
                        x, y = tps_x([[lon, lat]])[0], tps_y([[lon, lat]])[0]
                        transformed_coord = f"{x},{y},{alt}"
                        # Strip any trailing commas (if any)
                        transformed_coords.append(transformed_coord.rstrip(','))
                    except ValueError as e:
                        print(f"Skipping invalid coordinate: {coord_set} (Error: {e})")

                # Update the coordinates with transformed values
                coord.text = ' '.join(transformed_coords)

        # Track parent elements for the next iteration
        parent_stack.append(placemark)

    tree.write(output_kml)

def main():
    gcp_file = 'Aventurien.jpg.points'
    input_dir = 'kml_downloads'
    output_dir = 'output'
    os.makedirs(output_dir, exist_ok=True)

    print("Loading GCPs...")
    gcps = load_gcps(gcp_file)
    print(f"Loaded {len(gcps)} GCPs.")
    
    print("Computing transformation...")
    tps_x, tps_y = compute_transformation(gcps)
    print("Transformation ready.")
    
    for filename in os.listdir(input_dir):
        if filename.endswith('.kml'):
            input_kml = os.path.join(input_dir, filename)
            output_kml = os.path.join(output_dir, filename)
            print(f"Processing {filename}...")
            transform_kml(input_kml, output_kml, tps_x, tps_y)
            print(f"Saved transformed KML to {output_kml}")

if __name__ == "__main__":
    main()
