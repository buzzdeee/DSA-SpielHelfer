import os
import requests
import xml.etree.ElementTree as ET

# Set a directory to store downloaded KML files
DOWNLOAD_DIR = "kml_downloads"
os.makedirs(DOWNLOAD_DIR, exist_ok=True)

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

def merge_kml_files(output_file):
    """ Merge all downloaded KML files into a single KML file. """
    kml_files = [f for f in os.listdir(DOWNLOAD_DIR) if f.endswith(".kml")]
    
    if not kml_files:
        print("No KML files to merge.")
        return None

    merged_kml = ET.Element("kml", xmlns="http://www.opengis.net/kml/2.2")
    document = ET.SubElement(merged_kml, "Document")

    for kml_file in kml_files:
        try:
            tree = ET.parse(os.path.join(DOWNLOAD_DIR, kml_file))
            root = tree.getroot()
            for placemark in root.findall(".//{http://www.opengis.net/kml/2.2}Placemark"):
                document.append(placemark)
        except ET.ParseError as e:
            print(f"Error parsing {kml_file}: {e}")

    tree = ET.ElementTree(merged_kml)
    tree.write(output_file, encoding="utf-8", xml_declaration=True)
    print(f"Merged KML saved as: {output_file}")
    return output_file

# Start downloading recursively from the main KML
root_kml_url = "http://www.dereglobus.orkenspalter.de/public/DereGlobus/Dere.kml"
download_kml(root_kml_url)

# Merge all downloaded KMLs into a single file
merged_kml = "merged.kml"
if merge_kml_files(merged_kml):
    # Convert to GeoJSON
    os.system(f"ogr2ogr -f GeoJSON merged.json {merged_kml}")
    print("GeoJSON conversion complete: merged.json")
