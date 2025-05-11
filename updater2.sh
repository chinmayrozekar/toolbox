#!/bin/bash

BASE_DIR="/wv/chiroz51/JIRA/2025.3/PERC-16440/chinmay_testcases/mtflex/masa/PERC-16440_mtflex_load_group"

# Process dofile in all subdirectories
find "$BASE_DIR" -name "dofile" | while read -r dofile; do
    echo "Processing dofile: $dofile"
    # Delete the two lines from dofile
    sed -i \
        -e '/# extract mtflex related lines from qaout.log/d' \
        -e '/\.\/mtflex_extract\.pl/d' \
        "$dofile"
done

# Process compare in all subdirectories
find "$BASE_DIR" -name "compare" | while read -r compare; do
    echo "Processing compare: $compare"
    # Delete the line from compare
    sed -i '/perc_calqadiff qaout.mtflex.log baseline\/qaout.mtflex.log/d' "$compare"
done

echo "All files have been processed."
