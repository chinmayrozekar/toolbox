#!/bin/bash

# 1. Modify dofile
if [ -f dofile ]; then
    # First operation: Comment out the existing line and add the new line
    sed -i '/export CALIBRE_PERC_MTFLEX_LOAD_MEMORY_SUGGESTION=10000/c\#export CALIBRE_PERC_MTFLEX_LOAD_MEMORY_SUGGESTION=10000\nexport CALIBRE_PERC_MTFLEX_LOAD_MEMORY_SUGGESTION=0' dofile

    # Second operation: Add the grep command before the mtflex comment line
    sed -i '/# extract mtflex related lines from qaout.log/i\grep Starting qaout.log | grep LOAD | sed '\''s/\\(.*\\)\\(Starting.*\\)/\\2/'\'' > qaout.loadOrder' dofile
else
    echo "Error: dofile not found"
fi

# 2. Modify compare file
if [ -f compare ]; then
    # Add the new line after the specified line
    sed -i '/perc_calqadiff qaout.mtflex.log baseline\/qaout.mtflex.log/a\ perc_calqadiff qaout.loadOrder baseline\/qaout.loadOrder' compare
else
    echo "Error: compare file not found"
fi

#---------Run the testcase-----------------------#

./setup_tst
./dofile

# Do the copying

cp qaout.perc* baseline/;
cp qaout.loadOrder baseline/;
cp qaout.mtflex.log baseline/

# run compare
./compare

# remove yourself after execution
rm -- "$0"





