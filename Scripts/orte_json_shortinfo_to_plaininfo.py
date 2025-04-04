import json
import re
import markdown
from bs4 import BeautifulSoup

def remove_mediawiki_formatting(text):
    """Convert MediaWiki markdown to clean plain text."""
    if not text:
        return ""

    # Convert MediaWiki bold: '''text''' -> text (removing bold)
    text = re.sub(r"'''(.*?)'''", r"\1", text)

    # Convert MediaWiki italics: ''text'' -> "text"
    text = re.sub(r"''(.*?)''", r'"\1"', text)

    # Convert MediaWiki links: [[Link|Text]] -> Text, [[Link]] -> Link
    text = re.sub(r"\[\[([^|\]]+)\|?([^\]]*)\]\]", lambda m: m.group(2) if m.group(2) else m.group(1), text)

    # Convert Markdown to HTML (in case there's other markdown)
    html = markdown.markdown(text)

    # Remove any HTML tags (like <br />)
    text = BeautifulSoup(html, "html.parser").get_text()

    return text.strip()

def process_orte_json(input_file, output_file):
    """Read Orte.json, process shortinfo, and save as plaininfo."""
    with open(input_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    for entry in data:
        if "shortinfo" in entry:
            entry["plaininfo"] = remove_mediawiki_formatting(entry["shortinfo"])

    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

# Usage example
process_orte_json("Orte.json", "Orte_plain.json")
