#!/usr/bin/env python3

import os
import re
import json
from collections import defaultdict

image_dir = "."  # Passe ggf. an
#pattern = re.compile(r"^([A-Za-z]+)_\d+(?:-\d+x\d+)?\.webp$")
pattern = re.compile(r"^([A-Za-z_]+)(?:_\d+)(?:-\d+x\d+)?\.webp$")

index = defaultdict(list)

for filename in os.listdir(image_dir):
    if filename.endswith(".webp"):
        match = pattern.match(filename)
        if match:
            category = match.group(1)
            if "-128x128" not in filename and "-256x256" not in filename:  # Nur "normale"
                index[category].append(filename)

with open(os.path.join(image_dir, "image_index.json"), "w") as f:
    json.dump(index, f, indent=2)
