import os
import requests
import xml.etree.ElementTree as ET
import subprocess

# Directories
DOWNLOAD_DIR = "kml_downloads"
OUTPUT_DIR = "geojson_output"
os.makedirs(DOWNLOAD_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Set of downloaded URLs to avoid duplicates
downloaded_urls = set()

def download_kml(url, depth=0, max_depth=5):
    """ Recursively download KML files and follow NetworkLinks. """
    if url in downloaded_urls or depth > max_depth:
        return None

    downloaded_urls.add(url)
    print(f"{'  ' * depth}Downloading: {url}")

    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
    except requests.RequestException as e:
        print(f"{'  ' * depth}Failed to download {url}: {e}")
        return None

    filename = os.path.join(DOWNLOAD_DIR, os.path.basename(url))

    with open(filename, "wb") as f:
        f.write(response.content)

    # Parse the downloaded KML for nested NetworkLinks
    try:
        tree = ET.parse(filename)
        root = tree.getroot()
        namespace = {"kml": "http://www.opengis.net/kml/2.2"}

        for link in root.findall(".//kml:NetworkLink/kml:Link/kml:href", namespace):
            child_url = link.text.strip()
            if not child_url.startswith("http"):
                print(f"{'  ' * depth}Skipping non-HTTP link: {child_url}")
                continue
            download_kml(child_url, depth + 1, max_depth)

        return filename
    except ET.ParseError as e:
        print(f"{'  ' * depth}Error parsing {filename}: {e}")
        return None

def convert_kml_to_geojson(kml_file):
    """Convert a single KML file to GeoJSON using ogr2ogr."""
    geojson_file = os.path.join(OUTPUT_DIR, os.path.splitext(os.path.basename(kml_file))[0] + ".geojson")
    
    try:
        subprocess.run([
            "/usr/local/bin/ogr2ogr", "-f", "GeoJSON", "-skipfailures", "-q", geojson_file, kml_file
        ], check=True, env={"CPL_DEBUG": "ON"})
        print(f"Converted {kml_file} to {geojson_file}")
    except subprocess.CalledProcessError as e:
        print(f"Failed to convert {kml_file} to GeoJSON: {e}")

def process_kml_files():
    """Convert all KML files in the download directory to GeoJSON."""
    kml_files = [f for f in os.listdir(DOWNLOAD_DIR) if f.endswith(".kml")]

    if not kml_files:
        print("No KML files found in the download directory.")
        return

    for kml_file in kml_files:
        convert_kml_to_geojson(os.path.join(DOWNLOAD_DIR, kml_file))

# Start downloading recursively from the main KML
root_kml_url = "http://www.dereglobus.orkenspalter.de/public/DereGlobus/Dere.kml"
download_kml(root_kml_url)

# Convert all downloaded KML files to GeoJSON
process_kml_files()
