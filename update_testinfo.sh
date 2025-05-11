#!/bin/bash

# Base directory
BASE_DIR="/wv/chiroz51/JIRA/2025.3/PERC-16440/chinmay_testcases/mtflex/masa/PERC-15104_mtflex_load_group"

# Find all TESTINFO.json files and process them
find "$BASE_DIR" -name "TESTINFO.json" | while read -r file; do
    echo "Processing: $file"
    
    # Create a backup of the original file
    cp "$file" "${file}.bak"
    
    # Use sed to make all the required changes
    # Note: We're using different delimiters (|) because the paths contain forward slashes
    sed -i \
        -e 's|"owner": *"[^"]*"|"owner": "chiroz51"|' \
        -e 's|"created": *"[^"]*"|"created": "2025-05-02"|' \
        -e 's|"description": *"[^"]*"|"description": "topo test case for PERC-16440"|' \
        -e 's|"first_release": *"[^"]*"|"first_release": "2025.3"|' \
        "$file"
    
    echo "Updated: $file"
done

echo "All TESTINFO.json files have been updated."
